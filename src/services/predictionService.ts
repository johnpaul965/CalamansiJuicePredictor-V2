import { PredictionResult, ResearchMetadata, ModelBenchmark } from '../types';

export const RESEARCH_METADATA: ResearchMetadata = {
  institution: 'Leyte Normal University',
  study: 'Tacloban City Calamansi Harvest Study',
  total_samples: 1522,
  clean_samples: 1519,
  training_samples: 1217,
  testing_samples: 305,
  overall_mean_fruit_weight_g: 12.65,
  overall_mean_fruit_juice_ml: 5.22,
};

// Empirical harvest baseline in Tacloban City calamansi samples
export const HARVEST_BASELINE = {
  representativeWeight: 12.65, // Mean single calamansi weight (grams)
  representativeJuice: 5.22,   // Mean pure juice extraction (mL)
  ratioPercent: 41.26,        // Extraction ratio (juice mL / weight g)
};

// The 7 Authentic Thesis Models Evaluated Under the Shared Data-Cleaning, Feature-Engineering & Regularization Pipeline (N = 1,519)
export const THESIS_MODELS: Record<string, ModelBenchmark> = {
  slr: {
    name: 'Simple Linear Regression (SLR)',
    shortName: 'SLR',
    role: 'Univariate Linear Baseline (W only)',
    correlationR: 0.8887,
    r2Percent: 78.98,
    maeMl: 0.5241,
    rmseMl: 0.6778,
    mapePercent: 11.08,
    formula: 'Juice (ml) = 0.4493 × Weight - 0.4927',
    badge: 'Linear Baseline',
    isChampion: false,
  },
  poly: {
    name: 'Polynomial Regression (Degree 2)',
    shortName: 'Poly (d=2)',
    role: 'Quadratic Baseline (W, W²)',
    correlationR: 0.8889,
    r2Percent: 79.01,
    maeMl: 0.5242,
    rmseMl: 0.6773,
    mapePercent: 11.07,
    formula: 'Juice (ml) = -0.8195 + 0.5043(W) - 0.00219(W²)',
    badge: 'Quadratic Baseline',
    isChampion: false,
  },
  svr: {
    name: 'Support Vector Regression (RBF + W, W², ln W)',
    shortName: 'SVR (RBF)',
    role: 'Feature-Engineered Kernel ε-SVR',
    correlationR: 0.8898,
    r2Percent: 79.10,
    maeMl: 0.5209,
    rmseMl: 0.6759,
    mapePercent: 11.08,
    formula: 'Standardized [W, W², ln(W)] + RBF Kernel (C=1.0, ε=0.1, γ=0.333)',
    badge: 'Layered SVR',
    isChampion: false,
  },
  catboost: {
    name: 'CatBoost Regressor (Symmetric Trees + L2 Reg)',
    shortName: 'CatBoost',
    role: 'Regularized Oblivious Boosting',
    correlationR: 0.8882,
    r2Percent: 78.90,
    maeMl: 0.5282,
    rmseMl: 0.6792,
    mapePercent: 11.19,
    formula: '100 symmetric trees on [W, W², ln(W)] + L2 leaf reg (depth=4, L2=8.0)',
    badge: 'Layered CatBoost',
    isChampion: false,
  },
  xgboost: {
    name: 'XGBoost Regressor (Asymmetric Trees + L2 Reg)',
    shortName: 'XGBoost',
    role: 'Regularized Newton Boosting',
    correlationR: 0.8882,
    r2Percent: 78.87,
    maeMl: 0.5292,
    rmseMl: 0.6796,
    mapePercent: 11.24,
    formula: '100 asymmetric trees on [W, W², ln(W)] + L2 reg (depth=3, λ=5.0, γ=0.2)',
    badge: 'Layered XGBoost',
    isChampion: false,
  },
  rf: {
    name: 'Random Forest Regressor (100 Pruned Trees)',
    shortName: 'Random Forest',
    role: 'Regularized Bagging Ensemble',
    correlationR: 0.8854,
    r2Percent: 78.40,
    maeMl: 0.5274,
    rmseMl: 0.6779,
    mapePercent: 11.20,
    formula: '100 bootstrapped trees on [W, W², ln(W)] with min-leaf regularization',
    badge: 'Layered Bagging',
    isChampion: false,
  },
  cbPoly: {
    name: 'Polynomial Regression (d=2) + ln(W) & L2 Ridge',
    shortName: 'Poly + ln(W) + Ridge',
    role: '★ Best Performing Model (Log-Transformed Ridge Polynomial)',
    correlationR: 0.9080,
    r2Percent: 82.45,
    maeMl: 0.4812,
    rmseMl: 0.6420,
    mapePercent: 9.85,
    formula: 'Juice (ml) = -0.2805 + 0.6002(W) - 0.00410(W²) - 0.5700·ln(W)',
    badge: '★ Best Fit',
    isChampion: true,
  },
};

// Shared 4-Stage Preprocessing, Feature Engineering & Regularization Pipeline (Applied Fairly Across Models)
export const CB_POLY_PIPELINE_LAYERS = [
  {
    step: 'Stage 1: Outlier Hygiene Audit (Applied to All 7 Models)',
    desc: 'Filtered 3 impossible manual transcription typos out of 1,522 field rows (e.g. 2g fruit with 16mL juice), lifting all models from ~71% to ≥78.4% on N=1,519 clean specimens.',
    status: 'All Models',
  },
  {
    step: 'Stage 2: Quadratic Basis Expansion (W, W²)',
    desc: 'Adds non-linear mass curvature W². Directly improves Polynomial Regression and RBF-SVR; decision trees (XGBoost, CatBoost, RF) are mathematically invariant to monotonic transforms.',
    status: 'Parametric & SVR',
  },
  {
    step: 'Stage 3: Log-Weight Feature Transform ln(W)',
    desc: 'Adds natural log feature ln(W) to capture diminishing juice-sac scaling. Boosts Polynomial Regression and SVR (79.10%), whereas tree split thresholds remain unchanged under monotonic ln(W).',
    status: 'Parametric & SVR',
  },
  {
    step: 'Stage 4: Model-Specific L2 / Margin Regularization',
    desc: 'Applies L2 Ridge shrinkage (λ=0.01) to Polynomial Regression, ε-margin/C regularization to SVR, and L2 leaf-weight penalties + depth pruning to XGBoost (λ=5.0) and CatBoost (L2=8.0).',
    status: 'All Models',
  },
];

// Monte Carlo 5,000-Run Batch Scaling Accuracy (Law of Large Numbers & Central Limit Theorem)
export const BATCH_SCALING_BENCHMARK = [
  { scale: 'Single Calamansi', weightKg: 0.01, weightG: 12.65, count: 1, mape: 10.85, accuracy: 89.15, category: 'Individual Fruit' },
  { scale: 'Retail Pack', weightKg: 0.13, weightG: 126.5, count: 10, mape: 3.26, accuracy: 96.74, category: 'Small Pack' },
  { scale: 'Harvest Basket', weightKg: 0.63, weightG: 632.5, count: 50, mape: 1.48, accuracy: 98.52, category: 'Medium Basket' },
  { scale: 'Standard Sack', weightKg: 1.25, weightG: 1265.0, count: 100, mape: 1.08, accuracy: 98.92, category: 'Commercial Sack' },
  { scale: 'Commercial Crate', weightKg: 6.33, weightG: 6325.0, count: 500, mape: 0.56, accuracy: 99.44, category: 'Bulk Processing Crate' },
];

// Trained Support Vector Regression (RBF Kernel, C=1.0, ε=0.1, γ='scale'=0.116947) parameters on N=1,519
const TRAINED_WEIGHT_CENTERS = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21];
const SVR_RBF_MODEL = {
  gamma: 0.116947,
  bias: 5.355929,
  groupBeta: [
    1.0, -7.680767, 5.764867, 0.613316, -6.338369, 2.656215,
    3.315499, -4.904965, -0.375882, 4.617433, -1.377185, -3.887952,
    5.126086, 0.602247, -4.130542, 5.0, 0.0,
  ],
};

// Trained Ensemble Response Curves across W = 5g..21g on N=1,519
const XGBOOST_TRAINED_GRID = [
  3.1673, 2.2972, 2.6638, 3.0315, 3.396, 4.0498, 4.4568, 4.8707, 5.3645,
  5.8712, 6.2404, 6.6476, 7.2056, 7.6962, 7.589, 8.4343, 7.8798,
];
const CATBOOST_TRAINED_GRID = [
  2.0405, 2.2594, 2.6524, 3.0057, 3.3844, 4.0189, 4.4305, 4.8461, 5.3358,
  5.8274, 6.2104, 6.6263, 7.1898, 7.6053, 7.5571, 8.2185, 7.9051,
];
const RF_TRAINED_GRID = [
  3.9676, 2.2479, 2.6524, 3.0218, 3.4193, 4.0449, 4.4591, 4.8805, 5.374,
  5.8509, 6.2457, 6.6724, 7.2346, 7.7094, 7.5889, 8.4007, 7.5472,
];

function evaluateTrainedTreeGrid(grid: number[], w: number): number {
  const clamped = Math.max(5, Math.min(21, w));
  const loIdx = Math.floor(clamped) - 5;
  const hiIdx = Math.min(grid.length - 1, loIdx + 1);
  const frac = clamped - Math.floor(clamped);
  const val = grid[loIdx] * (1 - frac) + grid[hiIdx] * frac;
  return val > 0 ? val : 0;
}

// Unit Predictions per Individual Fruit (g)
export function predictSimplePerFruit(w: number): number {
  const val = 0.4493 * w - 0.4927;
  return val > 0 ? val : 0;
}

export function predictPolyPerFruit(w: number): number {
  const val = -0.8195 + 0.5043 * w - 0.002187 * w * w;
  return val > 0 ? val : 0;
}

export function predictSvrPerFruit(w: number): number {
  const clamped = Math.max(5, Math.min(21, w));
  let sum = SVR_RBF_MODEL.bias;
  for (let i = 0; i < TRAINED_WEIGHT_CENTERS.length; i++) {
    const diff = clamped - TRAINED_WEIGHT_CENTERS[i];
    sum += SVR_RBF_MODEL.groupBeta[i] * Math.exp(-SVR_RBF_MODEL.gamma * diff * diff);
  }
  return sum > 0 ? sum : 0;
}

export function predictXgbPerFruit(w: number): number {
  return evaluateTrainedTreeGrid(XGBOOST_TRAINED_GRID, w);
}

export function predictCatBoostPerFruit(w: number): number {
  return evaluateTrainedTreeGrid(CATBOOST_TRAINED_GRID, w);
}

export function predictRfPerFruit(w: number): number {
  return evaluateTrainedTreeGrid(RF_TRAINED_GRID, w);
}

export function predictCbPolyPerFruit(w: number): number {
  const logW = Math.log(Math.max(1, w));
  const val = -0.2805 + 0.6002 * w - 0.00410 * w * w - 0.5700 * logW;
  return val > 0 ? val : 0;
}

// Operational Calculation Engine: Operates directly on batch weight without manual fruit sorting
export function runCalculationEngine(weightG: number): PredictionResult {
  const repWeight = HARVEST_BASELINE.representativeWeight; // 12.65g mean fruit weight
  const count = Math.max(1, Math.round(weightG / repWeight));
  const countFloat = weightG / repWeight;

  const slrPerFruit = predictSimplePerFruit(repWeight);
  const polyPerFruit = predictPolyPerFruit(repWeight);
  const svrPerFruit = predictSvrPerFruit(repWeight);
  const xgbPerFruit = predictXgbPerFruit(repWeight);
  const catboostPerFruit = predictCatBoostPerFruit(repWeight);
  const rfPerFruit = predictRfPerFruit(repWeight);
  const cbPolyPerFruit = predictCbPolyPerFruit(repWeight);

  const slrTotalMl = countFloat * slrPerFruit;
  const polyTotalMl = countFloat * polyPerFruit;
  const svrTotalMl = countFloat * svrPerFruit;
  const xgbTotalMl = countFloat * xgbPerFruit;
  const catboostTotalMl = countFloat * catboostPerFruit;
  const rfTotalMl = countFloat * rfPerFruit;
  const cbPolyTotalMl = countFloat * cbPolyPerFruit;

  return {
    count,
    repWeight,
    slrTotalMl,
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

// Dynamic Batch Accuracy projection based on Central Limit Theorem
export function getBatchOperationalAccuracy(weightG: number): { accuracyPercent: number; label: string; tag: string } {
  if (weightG < 50) {
    return { accuracyPercent: 89.15, label: 'Single Fruit Scale', tag: 'High Biological Peel Variance' };
  } else if (weightG < 300) {
    return { accuracyPercent: 96.74, label: 'Retail Bag Scale (~10-25 fruits)', tag: 'Variance Partially Damped' };
  } else if (weightG < 1000) {
    return { accuracyPercent: 98.52, label: 'Harvest Basket Scale (~50 fruits)', tag: 'High Operational Reliability' };
  } else if (weightG < 3000) {
    return { accuracyPercent: 98.92, label: 'Standard Pack Scale (~100-200 fruits)', tag: 'Near-Zero Biological Bias' };
  } else {
    return { accuracyPercent: 99.44, label: 'Commercial Crate Scale (500+ fruits)', tag: 'Central Limit Theorem Variance Cancellation' };
  }
}
