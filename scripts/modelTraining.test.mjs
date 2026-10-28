import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import {
  cleanTrainingRecords,
  fitSvrRbf,
  fitPolynomial,
  formatPrimaryFormula,
  formatPolynomialFormula,
  formatSvrFormula,
  makeGroupedFolds,
  makeStratifiedFolds,
  parseDataset,
  predictPolynomial,
  predictPrimary,
  predictSvrRbf,
  trainDataset,
} from './modelTraining.mjs';

test('parses the Weight/Juice dataset without a Size column', async () => {
  const csv = await readFile(new URL('../dataset.csv', import.meta.url), 'utf8');
  const rows = parseDataset(csv);
  assert.equal(rows.length, 1522);
  assert.ok(rows.every((row) => Object.keys(row).sort().join(',') === 'juice,weight'));
  const twoColumnCsv = [
    'Weight,Juice',
    ...Array.from({ length: 10 }, (_, index) => `${7 + index},${2.5 + index / 10}`),
  ].join('\n');
  const twoColumnRows = parseDataset(twoColumnCsv);
  assert.equal(twoColumnRows.length, 10);
  assert.deepEqual(twoColumnRows[0], { weight: 7, juice: 2.5 });
});

test('cleaning removes target outliers only from the supplied training rows', () => {
  const records = [
    ...Array.from({ length: 10 }, (_, index) => ({
      weight: 10,
      juice: 1 + index * 0.01,
    })),
    { weight: 10, juice: 5 },
    { weight: 10, juice: 20 },
  ];
  const cleaned = cleanTrainingRecords(records);
  assert.equal(cleaned.removedRatio, 1);
  assert.ok(cleaned.removedZ >= 1);
  assert.ok(cleaned.records.every((record) => record.juice / record.weight <= 0.6));
});

test('grouped folds keep rounded weights together and score each row once', () => {
  const rows = Array.from({ length: 50 }, (_, index) => ({
    weight: 5 + (index % 10),
    juice: 2 + index / 10,
  }));
  const folds = makeGroupedFolds(rows, 5);
  const weightsToFolds = new Map();
  for (let i = 0; i < folds.length; i++) {
    for (const row of folds[i]) {
      const group = Math.round(row.weight);
      assert.ok(!weightsToFolds.has(group) || weightsToFolds.get(group) === i);
      weightsToFolds.set(group, i);
    }
  }
  assert.equal(folds.flat().length, rows.length);
});

test('primary formula uses the same coefficient order and clamps negative predictions', () => {
  const coefficients = [1, 2, -0.01, 0.5];
  const formula = formatPrimaryFormula(coefficients);
  assert.match(formula, /W²/);
  assert.match(formula, /ln\(W\)/);
  assert.equal(predictPrimary([-100, 0, 0, 0], 12), 0);
  assert.ok(predictPrimary(coefficients, 12) > 0);
});

test('polynomial and RBF-SVR formulas describe their runtime predictors', () => {
  const records = Array.from({ length: 30 }, (_, index) => {
    const weight = 2 + (index % 10);
    return { weight, juice: 0.4 * weight + 0.02 * weight ** 2 };
  });
  const polynomial = fitPolynomial(records);
  const polynomialFormula = formatPolynomialFormula(polynomial);
  assert.match(polynomialFormula, /W²/);
  assert.equal(
    predictPolynomial(polynomial, 8),
    Math.max(0, polynomial[0] + polynomial[1] * 8 + polynomial[2] * 8 ** 2)
  );

  const svr = fitSvrRbf(records);
  const svrFormula = formatSvrFormula(svr);
  const manualPrediction = Math.max(
    0,
    svr.intercept +
      svr.supportVectors.reduce(
        (sum, supportVector, index) =>
          sum +
          svr.dualCoefficients[index] *
            Math.exp(-svr.gamma * (8 - supportVector) ** 2),
        0
      )
  );
  assert.equal(svr.converged, true);
  assert.match(svrFormula, /Σᵢ βᵢ/);
  assert.match(svrFormula, /γ = 0\.05/);
  assert.equal(predictSvrRbf(svr, 8), manualPrediction);
});

test('training scores clean stratified harvest rows and returns all four comparison models', async () => {
  const csv = await readFile(new URL('../dataset.csv', import.meta.url), 'utf8');
  const result = trainDataset(csv);
  assert.equal(result.metadata.total_raw_samples, 1522);
  assert.equal(result.metadata.cv_test_samples, 1478);
  assert.deepEqual(Object.keys(result.benchmarks).sort(), ['poly', 'primary', 'slr', 'svr']);
  assert.equal(result.benchmarks.slr.name, 'Simple Linear Regression (SLR)');
  assert.equal(result.benchmarks.poly.name, 'Polynomial Regression (Degree 2)');
  assert.equal(result.benchmarks.svr.name, 'Support Vector Regression (RBF Kernel)');
  assert.equal(result.benchmarks.primary.name, 'Polynomial (d=2) + ln(W) & L2 Ridge');
  assert.equal(result.benchmarks.primary.isChampion, true);
  assert.equal(result.benchmarks.primary.coefficients.length, 4);
  assert.equal(result.benchmarks.poly.coefficients.length, 3);
  assert.ok(result.benchmarks.svr.support_vectors.length > 0);
  assert.equal(
    result.benchmarks.svr.coefficients.length,
    result.benchmarks.svr.support_vectors.length
  );
  assert.equal(result.benchmarks.svr.gamma, 0.05);
  assert.equal(result.benchmarks.svr.cost, 1);
  assert.equal(result.benchmarks.svr.epsilon, 0.1);
  assert.equal(result.benchmarks.svr.name, 'Support Vector Regression (RBF Kernel)');
  assert.equal(result.benchmarks.svr.role, 'Kernel Machine (Radial Basis Function)');
  assert.match(result.benchmarks.primary.formula, /max\(0/);
  assert.ok(Number.isFinite(result.benchmarks.primary.r2_percent));
  assert.ok(
    result.cross_validation.folds.every(
      (fold) =>
        fold.samples > 0 &&
        Number.isFinite(fold.polynomial_r2_percent) &&
        Number.isFinite(fold.svr_r2_percent)
    )
  );
});

test('saved metrics use the trained SVR payload and keep Poly+ primary', async () => {
  const metrics = JSON.parse(
    await readFile(new URL('../src/data/model_metrics.json', import.meta.url), 'utf8')
  );
  assert.deepEqual(Object.keys(metrics.benchmarks).sort(), ['poly', 'primary', 'slr', 'svr']);
  assert.ok(metrics.benchmarks.svr.support_vectors.length > 0);
  assert.equal(
    metrics.benchmarks.svr.coefficients.length,
    metrics.benchmarks.svr.support_vectors.length
  );
  assert.match(metrics.benchmarks.svr.formula, /γ = 0\.05/);
  assert.equal(metrics.benchmarks.primary.name, 'Polynomial (d=2) + ln(W) & L2 Ridge');
  assert.equal(metrics.benchmarks.primary.isChampion, true);
});
