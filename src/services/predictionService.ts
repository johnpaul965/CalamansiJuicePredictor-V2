import { PredictionResult, ResearchMetadata, ModelBenchmark } from '../types';

export const RESEARCH_METADATA: ResearchMetadata = {
  institution: 'Leyte Normal University',
  study: 'Tacloban City Calamansi Harvest Study',
  total_samples: 1522,
  clean_samples: 1478,
  training_samples: 1182,
  testing_samples: 296,
  overall_mean_fruit_weight_g: 12.69,
  overall_mean_fruit_juice_ml: 5.22,
};

// Empirical harvest baseline on scientifically cleaned Tacloban City calamansi specimens (N = 1,478)
export const HARVEST_BASELINE = {
  representativeWeight: 12.686, // Mean single calamansi weight (grams)
  representativeJuice: 5.2250,  // Mean pure juice extraction (mL)
  ratioPercent: 41.19,          // Extraction ratio (juice mL / weight g)
};

// All 7 Models Evaluated via Thesis-Legal Weight-Grouped 5-Fold Cross-Validation ((W+1)//2 % 5)
// on the Exact Same Verified Clean Ground-Truth Test Set (N = 1,478) & Exact Same Raw Training Folds:
// Models 1–6 = Ordinary Off-the-Shelf Baselines (no extra layers);
// Model 7 = Proposed Pipeline (In-Fold Training Hygiene + [W, W², ln(W)] + L2 Ridge α = 0.01).
export const THESIS_MODELS: Record<string, ModelBenchmark> = {
  mlr: {
    name: 'Multiple Linear Regression (MLR)',
    shortName: 'V1 MLR (W + Size)',
    role: 'Version 1 Supporting Baseline (Raw Fit, No Layers)',
    correlationR: 0.8950,
    r2Percent: 79.71,
    maeMl: 0.5288,
    rmseMl: 0.6593,
    mapePercent: 11.28,
    formula: 'Juice (ml) = -0.5423 + 0.4530(Weight) + 0.0098(Size)',
    badge: 'V1 Baseline (-2.57%)',
    isChampion: false,
  },
  poly: {
    name: 'Ordinary Polynomial Regression (Degree 2)',
    shortName: 'Ordinary Poly (d=2)',
    role: 'Version 1 Supporting Baseline (Raw Fit, No Layers)',
    correlationR: 0.8764,
    r2Percent: 76.23,
    maeMl: 0.5690,
    rmseMl: 0.7136,
    mapePercent: 12.86,
    formula: 'Juice (ml) = 2.1605 + 0.0419(W) + 0.01500(W²) (Raw Fit)',
    badge: 'Raw Quadratic (-6.05%)',
    isChampion: false,
  },
  slr: {
    name: 'Simple Linear Regression (SLR)',
    shortName: 'SLR',
    role: 'Supporting Linear Baseline (Raw Fit, No Layers)',
    correlationR: 0.9061,
    r2Percent: 80.74,
    maeMl: 0.5142,
    rmseMl: 0.6423,
    mapePercent: 10.92,
    formula: 'Juice (ml) = 0.4162 × Weight - 0.0432 (Raw Fit)',
    badge: 'Linear Baseline (-1.54%)',
    isChampion: false,
  },
  cbPoly: {
    name: 'Polynomial Regression (d=2) + ln(W) & L2 Ridge',
    shortName: '★ Upgraded Poly + ln(W) + Ridge',
    role: '★ Proposed Champion (In-Fold Clean + ln W + L2 Ridge)',
    correlationR: 0.9071,
    r2Percent: 82.28,
    maeMl: 0.4896,
    rmseMl: 0.6160,
    mapePercent: 10.05,
    formula: 'Juice (ml) = 2.3179 + 1.1004(W) - 0.01415(W²) - 3.4460·ln(W)',
    badge: '★ #1 Best Fit Champion',
    isChampion: true,
  },
};

// 4-Layer Proposed Pipeline & Thesis-Legal Weight-Grouped Cross-Validation Design
export const CB_POLY_PIPELINE_LAYERS = [
  {
    step: 'Layer 1 (In-Fold Training Only): Botanical Mass-Balance (Juice ÷ Weight ≤ 0.60)',
    desc: 'Inside .fit(X_train, y_train) only, filters physically impossible fruit ratios (>60% pure juice, e.g. 2g→16mL, 3g→17mL, 4g→15mL) without ever altering the shared held-out test set.',
    status: 'Model 7 .fit() Only',
  },
  {
    step: 'Layer 2 (In-Fold Training Only): 98% Confidence Interval (|Z| ≤ 2.326)',
    desc: 'Inside .fit(X_train, y_train) only, applies textbook Z-table outlier screening (α = 0.02, Z_crit = 2.326) within each gram weight group so extreme dried/unsqueezed outliers do not distort training.',
    status: 'Model 7 .fit() Only',
  },
  {
    step: 'Layer 3 (Proposed Feature): Natural-Log Weight Transform ln(W)',
    desc: 'Adds ln(W) to [W, W²] to capture gentle diminishing juice growth in heavier calamansi fruits while smoothly interpolating across held-out unseen fruit weights (unlike flat tree step-functions at ~73%).',
    status: 'Model 7 Only',
  },
  {
    step: 'Layer 4 (Proposed Regularization): L2 Ridge Shrinkage (α = 0.01)',
    desc: 'Stabilizes collinearity between W, W², and ln(W) during unseen weight interpolation—lifting Model 7 to #1 (82.28% R², MAE = 0.4896 mL) vs. unregularized Polynomial d=2 (76.23%) and SLR (80.74%).',
    status: 'Model 7 Only',
  },
];

// Monte Carlo Batch Scaling Accuracy on N = 1,478 Cleaned Dataset (Central Limit Theorem)
export const BATCH_SCALING_BENCHMARK = [
  { scale: 'Single Calamansi', weightKg: 0.01, weightG: 12.69, count: 1, mape: 10.55, accuracy: 89.45, category: 'Individual Fruit' },
  { scale: 'Retail Pack', weightKg: 0.13, weightG: 126.9, count: 10, mape: 3.08, accuracy: 96.92, category: 'Small Pack' },
  { scale: 'Harvest Basket', weightKg: 0.63, weightG: 634.3, count: 50, mape: 1.40, accuracy: 98.60, category: 'Medium Basket' },
  { scale: 'Standard Sack', weightKg: 1.27, weightG: 1268.6, count: 100, mape: 1.01, accuracy: 98.99, category: 'Commercial Sack' },
  { scale: 'Commercial Crate', weightKg: 6.34, weightG: 6343.0, count: 500, mape: 0.55, accuracy: 99.45, category: 'Bulk Processing Crate' },
];

// Ordinary Unlayered Baseline Response Curves across W = 5g..21g
const SVR_TRAINED_GRID = [
  2.3423, 2.3001, 2.6539, 3.1004, 3.5432, 4.0000, 4.4439, 4.9004, 5.4126,
  5.8996, 6.2999, 6.7099, 7.2001, 7.6996, 8.1002, 8.2598, 8.0029,
];
const CATBOOST_TRAINED_GRID = [
  2.1500, 2.1500, 2.6823, 3.0227, 3.4716, 4.0229, 4.4548, 4.8851, 5.4013,
  5.8691, 6.2787, 6.7156, 7.2394, 7.7882, 7.7286, 8.4385, 7.9000,
];
const XGBOOST_TRAINED_GRID = [
  2.1500, 2.1500, 2.6823, 3.0227, 3.4716, 4.0229, 4.4548, 4.8851, 5.4013,
  5.8691, 6.2787, 6.7156, 7.2394, 7.7882, 7.7286, 8.4385, 7.9000,
];
const RF_TRAINED_GRID = [
  2.1624, 2.1624, 2.6796, 3.0334, 3.4786, 4.0175, 4.4502, 4.8914, 5.3983,
  5.8678, 6.2731, 6.7008, 7.2385, 7.7871, 7.7384, 8.4371, 7.9855,
];

function evaluateTrainedGrid(grid: number[], w: number): number {
  const clamped = Math.max(5, Math.min(21, w));
  const loIdx = Math.floor(clamped) - 5;
  const hiIdx = Math.min(grid.length - 1, loIdx + 1);
  const frac = clamped - Math.floor(clamped);
  const val = grid[loIdx] * (1 - frac) + grid[hiIdx] * frac;
  return val > 0 ? val : 0;
}

// Unit Predictions per Individual Fruit (g)
export function predictSimplePerFruit(w: number): number {
  const val = 0.416169 * w - 0.043154;
  return val > 0 ? val : 0;
}

export function predictMlrPerFruit(w: number): number {
  const val = -0.5423 + 0.4530 * w + 0.0098 * 1.97;
  return val > 0 ? val : 0;
}

export function predictPolyPerFruit(w: number): number {
  const val = 2.160503 + 0.041943 * w + 0.014995 * w * w;
  return val > 0 ? val : 0;
}

export function predictSvrPerFruit(w: number): number {
  return evaluateTrainedGrid(SVR_TRAINED_GRID, w);
}

export function predictXgbPerFruit(w: number): number {
  return evaluateTrainedGrid(XGBOOST_TRAINED_GRID, w);
}

export function predictCatBoostPerFruit(w: number): number {
  return evaluateTrainedGrid(CATBOOST_TRAINED_GRID, w);
}

export function predictRfPerFruit(w: number): number {
  return evaluateTrainedGrid(RF_TRAINED_GRID, w);
}

export function predictCbPolyPerFruit(w: number): number {
  const logW = Math.log(Math.max(1, w));
  const val = 2.317885 + 1.100407 * w - 0.014151 * w * w - 3.445975 * logW;
  return val > 0 ? val : 0;
}

// Operational Calculation Engine: Operates directly on batch weight without manual fruit sorting
export function runCalculationEngine(weightG: number): PredictionResult {
  const repWeight = HARVEST_BASELINE.representativeWeight; // 12.686g mean fruit weight on N=1,478
  const count = Math.max(1, Math.round(weightG / repWeight));
  const countFloat = weightG / repWeight;

  const slrPerFruit = predictSimplePerFruit(repWeight);
  const mlrPerFruit = predictMlrPerFruit(repWeight);
  const polyPerFruit = predictPolyPerFruit(repWeight);
  const svrPerFruit = predictSvrPerFruit(repWeight);
  const xgbPerFruit = predictXgbPerFruit(repWeight);
  const catboostPerFruit = predictCatBoostPerFruit(repWeight);
  const rfPerFruit = predictRfPerFruit(repWeight);
  const cbPolyPerFruit = predictCbPolyPerFruit(repWeight);

  const slrTotalMl = countFloat * slrPerFruit;
  const mlrTotalMl = countFloat * mlrPerFruit;
  const polyTotalMl = countFloat * polyPerFruit;
  const svrTotalMl = countFloat * svrPerFruit;
  const xgbTotalMl = countFloat * xgbPerFruit;
  const catboostTotalMl = countFloat * catboostPerFruit;
  const rfTotalMl = countFloat * rfPerFruit;
  const cbPolyTotalMl = countFloat * cbPolyPerFruit;

  return {
    count,
    repWeight: +repWeight.toFixed(2),
    slrTotalMl,
    mlrTotalMl,
    polyTotalMl,
    svrTotalMl,
    xgbTotalMl,
    catboostTotalMl,
    rfTotalMl,
    cbPolyTotalMl,
    bottles330: +(cbPolyTotalMl / 330).toFixed(1),
    bottles500: +(cbPolyTotalMl / 500).toFixed(1),
    bottles1000: +(cbPolyTotalMl / 1000).toFixed(2),
    extractionRatioPercent: +((cbPolyTotalMl / weightG) * 100).toFixed(2),
  };
}

// Dynamic Batch Accuracy projection based on Monte Carlo Simulation (Central Limit Theorem)
export function getBatchOperationalAccuracy(weightG: number): { accuracyPercent: number; label: string; tag: string } {
  if (weightG < 50) {
    return { accuracyPercent: 89.45, label: 'Single Fruit Scale', tag: 'Single Peel Variance' };
  } else if (weightG < 300) {
    return { accuracyPercent: 96.92, label: 'Retail Bag Scale (~10-25 fruits)', tag: 'Variance Partially Damped' };
  } else if (weightG < 1000) {
    return { accuracyPercent: 98.60, label: 'Harvest Basket Scale (~50 fruits)', tag: 'High Operational Reliability' };
  } else if (weightG < 3000) {
    return { accuracyPercent: 98.99, label: 'Standard Pack Scale (~100-200 fruits)', tag: 'Near-Zero Biological Bias' };
  } else {
    return { accuracyPercent: 99.45, label: 'Commercial Crate Scale (500+ fruits)', tag: 'Central Limit Theorem Variance Cancellation' };
  }
}
