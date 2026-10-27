import { PredictionResult, ResearchMetadata, ModelBenchmark } from '../types';
import liveMetrics from '../data/model_metrics.json';

// Initialize dynamically from train_model.py output (model_metrics.json)
export const RESEARCH_METADATA: ResearchMetadata = {
  institution: liveMetrics.metadata.institution,
  study: liveMetrics.metadata.study,
  total_samples: liveMetrics.metadata.total_raw_samples,
  clean_samples: liveMetrics.metadata.clean_samples,
  training_samples: Math.round(liveMetrics.metadata.clean_samples * 0.8),
  testing_samples: Math.round(liveMetrics.metadata.clean_samples * 0.2),
  overall_mean_fruit_weight_g: liveMetrics.metadata.representative_weight_g,
  overall_mean_fruit_juice_ml: liveMetrics.metadata.representative_juice_ml,
};

// Empirical harvest baseline computed directly from clean dataset
export const HARVEST_BASELINE = {
  representativeWeight: liveMetrics.metadata.representative_weight_g,
  representativeJuice: liveMetrics.metadata.representative_juice_ml,
  ratioPercent: liveMetrics.metadata.extraction_ratio_pct,
};

// 4 Models Loaded Live from Cross-Validation Training Script Output
export const THESIS_MODELS: Record<string, ModelBenchmark> = {
  slr: {
    name: liveMetrics.cv_benchmarks.slr.name,
    shortName: 'SLR',
    role: 'Ordinary Linear Baseline (W only, no layers)',
    correlationR: liveMetrics.cv_benchmarks.slr.correlation_r,
    r2Percent: liveMetrics.cv_benchmarks.slr.r2_percent,
    maeMl: liveMetrics.cv_benchmarks.slr.mae,
    rmseMl: liveMetrics.cv_benchmarks.slr.rmse,
    mapePercent: liveMetrics.cv_benchmarks.slr.mape,
    formula: liveMetrics.cv_benchmarks.slr.formula,
    badge: 'Ordinary Baseline',
    isChampion: false,
  },
  svr: {
    name: liveMetrics.cv_benchmarks.svr.name,
    shortName: 'SVR (RBF)',
    role: 'Default Off-the-Shelf SVR (W only, no layers)',
    correlationR: liveMetrics.cv_benchmarks.svr.correlation_r,
    r2Percent: liveMetrics.cv_benchmarks.svr.r2_percent,
    maeMl: liveMetrics.cv_benchmarks.svr.mae,
    rmseMl: liveMetrics.cv_benchmarks.svr.rmse,
    mapePercent: liveMetrics.cv_benchmarks.svr.mape,
    formula: liveMetrics.cv_benchmarks.svr.formula,
    badge: 'Ordinary SVR',
    isChampion: false,
  },
  poly: {
    name: liveMetrics.cv_benchmarks.poly.name,
    shortName: 'Poly (d=2)',
    role: 'Ordinary Quadratic Baseline (W, W², no layers)',
    correlationR: liveMetrics.cv_benchmarks.poly.correlation_r,
    r2Percent: liveMetrics.cv_benchmarks.poly.r2_percent,
    maeMl: liveMetrics.cv_benchmarks.poly.mae,
    rmseMl: liveMetrics.cv_benchmarks.poly.rmse,
    mapePercent: liveMetrics.cv_benchmarks.poly.mape,
    formula: liveMetrics.cv_benchmarks.poly.formula,
    badge: 'Ordinary Quadratic',
    isChampion: false,
  },
  cbPoly: {
    name: liveMetrics.cv_benchmarks.proposed.name,
    shortName: 'Poly + ln(W) + Ridge',
    role: '★ Proposed Model (In-Fold Clean + ln W + L2 Ridge)',
    correlationR: liveMetrics.cv_benchmarks.proposed.correlation_r,
    r2Percent: liveMetrics.cv_benchmarks.proposed.r2_percent,
    maeMl: liveMetrics.cv_benchmarks.proposed.mae,
    rmseMl: liveMetrics.cv_benchmarks.proposed.rmse,
    mapePercent: liveMetrics.cv_benchmarks.proposed.mape,
    formula: liveMetrics.cv_benchmarks.proposed.formula,
    badge: '★ Best Fit',
    isChampion: true,
  },
};

// 4-Layer Proposed Pipeline & Thesis-Legal Weight-Grouped Cross-Validation Design
export const CB_POLY_PIPELINE_LAYERS = [
  {
    step: 'Layer 1 (In-Fold Training Only): Botanical Mass-Balance (Juice ÷ Weight ≤ 0.60)',
    desc: `Inside .fit(X_train, y_train) only, filters ${liveMetrics.metadata.removed_ratio} physically impossible fruit ratios (>60% pure juice) without altering the shared held-out test set.`,
    status: 'Model 4 .fit() Only',
  },
  {
    step: 'Layer 2 (In-Fold Training Only): 98% Confidence Interval (|Z| ≤ 2.326)',
    desc: `Inside .fit(X_train, y_train) only, applies textbook Z-table outlier screening (${liveMetrics.metadata.removed_z} rows filtered) so extreme dried or punctured specimens do not distort training weights.`,
    status: 'Model 4 .fit() Only',
  },
  {
    step: 'Layer 3 (Proposed Feature): Natural-Log Weight Transform ln(W)',
    desc: 'Adds ln(W) to [W, W²] to capture gentle diminishing juice growth in heavier calamansi fruits while smoothly interpolating across held-out unseen fruit weights.',
    status: 'Model 4 Only',
  },
  {
    step: 'Layer 4 (Proposed Regularization): L2 Ridge Shrinkage (α = 0.01)',
    desc: `Stabilizes collinearity between W, W², and ln(W) during unseen weight interpolation—achieving #${1} (${liveMetrics.cv_benchmarks.proposed.r2_percent}% R², MAE = ${liveMetrics.cv_benchmarks.proposed.mae} mL) vs. unregularized Polynomial d=2 (${liveMetrics.cv_benchmarks.poly.r2_percent}%) and SLR (${liveMetrics.cv_benchmarks.slr.r2_percent}%).`,
    status: 'Model 4 Only',
  },
];

// Monte Carlo Batch Scaling Accuracy directly from training output (Central Limit Theorem)
export const BATCH_SCALING_BENCHMARK = liveMetrics.batch_scaling_clt;

// Dynamic Trained Coefficients
const SLR_COEFFS = liveMetrics.cv_benchmarks.slr.coefficients; // [b0, b1]
const SVR_COEFFS = liveMetrics.cv_benchmarks.svr.coefficients; // [b0, b1, b2]
const POLY_COEFFS = liveMetrics.cv_benchmarks.poly.coefficients; // [b0, b1, b2]
const PROP_COEFFS = liveMetrics.cv_benchmarks.proposed.coefficients; // [b0, b1, b2, b3]

// Unit Predictions per Individual Fruit (g) - Evaluated Directly from Trained Coefficients
export function predictSimplePerFruit(w: number): number {
  const val = SLR_COEFFS[0] + SLR_COEFFS[1] * w;
  return val > 0 ? val : 0;
}

export function predictSvrPerFruit(w: number): number {
  const val = SVR_COEFFS[0] + SVR_COEFFS[1] * w + SVR_COEFFS[2] * Math.pow(w, 0.3);
  return val > 0 ? val : 0;
}

export function predictPolyPerFruit(w: number): number {
  const val = POLY_COEFFS[0] + POLY_COEFFS[1] * w + POLY_COEFFS[2] * w * w;
  return val > 0 ? val : 0;
}

export function predictCbPolyPerFruit(w: number): number {
  const logW = Math.log(Math.max(1, w));
  const val =
    PROP_COEFFS[0] +
    PROP_COEFFS[1] * w +
    PROP_COEFFS[2] * w * w +
    PROP_COEFFS[3] * logW;
  return val > 0 ? val : 0;
}

// Operational Calculation Engine: Operates directly on batch weight
export function runCalculationEngine(weightG: number): PredictionResult {
  const repWeight = HARVEST_BASELINE.representativeWeight;
  const count = Math.max(1, Math.round(weightG / repWeight));

  const slrTotalMl = predictSimplePerFruit(repWeight) * count;
  const polyTotalMl = predictPolyPerFruit(repWeight) * count;
  const svrTotalMl = predictSvrPerFruit(repWeight) * count;
  const cbPolyTotalMl = predictCbPolyPerFruit(repWeight) * count;

  return {
    count,
    repWeight,
    slrTotalMl: Number(slrTotalMl.toFixed(1)),
    polyTotalMl: Number(polyTotalMl.toFixed(1)),
    svrTotalMl: Number(svrTotalMl.toFixed(1)),
    cbPolyTotalMl: Number(cbPolyTotalMl.toFixed(1)),
    bottles330: Number((cbPolyTotalMl / 330).toFixed(1)),
    bottles500: Number((cbPolyTotalMl / 500).toFixed(1)),
    bottles1000: Number((cbPolyTotalMl / 1000).toFixed(2)),
    extractionRatioPercent: Number(((cbPolyTotalMl / weightG) * 100).toFixed(2)),
  };
}
