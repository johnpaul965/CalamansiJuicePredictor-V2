import { readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { trainDataset } from './modelTraining.mjs';

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const dataset = await readFile(path.join(projectRoot, 'dataset.csv'), 'utf8');
const result = trainDataset(dataset);
const serialized = `${JSON.stringify(result, null, 2)}\n`;
const baselineMae = result.benchmarks.slr.mae;
const benchmarkSummary = [
  ['Simple Linear Regression (SLR)', result.benchmarks.slr],
  ['Polynomial Regression (Degree 2)', result.benchmarks.poly],
  ['Support Vector Regression (RBF Kernel)', result.benchmarks.svr],
  ['Polynomial (d=2) + ln(W) & L2 Ridge', result.benchmarks.primary],
]
  .map(
    ([name, model], index) => {
      const deltaMae = ((model.mae - baselineMae) / baselineMae) * 100;
      const deltaLabel =
        index === 0 ? 'Baseline' : `${deltaMae > 0 ? '+' : ''}${deltaMae.toFixed(2)}%`;
      return (
        `${name}: R² ${model.r2_percent.toFixed(2)}%, ` +
        `MAE ${model.mae.toFixed(4)} mL, RMSE ${model.rmse.toFixed(4)} mL, ` +
        `MAPE ${model.mape.toFixed(2)}%, Δ MAE ${deltaLabel}`
      );
    }
  )
  .join('\n');

for (const outputPath of [
  'model_metrics.json',
  'src/data/model_metrics.json',
  'public/model_metrics.json',
]) {
  await writeFile(path.join(projectRoot, outputPath), serialized);
}

console.log(
  [
    `Trained four weight-only models from ${result.metadata.total_raw_samples} weight/juice rows.`,
    `Training rows after clean: ${result.metadata.clean_samples}.`,
    'Weight-grouped 5-fold out-of-fold results (Pipeline vs. Baseline):',
    benchmarkSummary,
    `Selected standardized Ridge alpha for Poly+ primary: ${result.benchmarks.primary.alpha}.`,
    `RBF SVR parameters: C = ${result.benchmarks.svr.cost}, ε = ${result.benchmarks.svr.epsilon}, γ = ${result.benchmarks.svr.gamma}; support vectors = ${result.benchmarks.svr.support_vectors.length}.`,
  ].join('\n')
);
