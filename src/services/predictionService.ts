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

// The 4 Minimum Authentic Thesis Models for Calamansi Juice Forecasting
export const THESIS_MODELS: Record<string, ModelBenchmark> = {
  slr: {
    name: 'Simple Linear Regression (SLR)',
    shortName: 'SLR',
    role: 'Baseline Control',
    correlationR: 0.8887,
    r2Percent: 78.98,
    maeMl: 0.5241,
    rmseMl: 0.6778,
    mapePercent: 11.08,
    formula: 'Juice (ml) = 0.4493 × Weight - 0.4927',
    badge: 'Baseline Control',
    isChampion: false,
  },
  poly: {
    name: 'Polynomial Regression (Degree 2)',
    shortName: 'Poly (d=2)',
    role: 'Quadratic Baseline',
    correlationR: 0.8889,
    r2Percent: 79.01,
    maeMl: 0.5242,
    rmseMl: 0.6773,
    mapePercent: 11.07,
    formula: 'Juice (ml) = -0.8195 + 0.5043(W) - 0.00219(W²)',
    badge: 'Quadratic Baseline',
    isChampion: false,
  },
  catboost: {
    name: 'CatBoost / XGBoost Regressor',
    shortName: 'CatBoost',
    role: 'Gradient Boosting Benchmark',
    correlationR: 0.8820,
    r2Percent: 77.80,
    maeMl: 0.5210,
    rmseMl: 0.6803,
    mapePercent: 11.15,
    formula: 'Gradient-boosted decision tree ensemble with symmetric trees',
    badge: 'Boosting Benchmark',
    isChampion: false,
  },
  rf: {
    name: 'Random Forest Regressor (100 Trees)',
    shortName: 'Random Forest',
    role: 'Ensemble Bagging Benchmark',
    correlationR: 0.8854,
    r2Percent: 78.40,
    maeMl: 0.5274,
    rmseMl: 0.6779,
    mapePercent: 11.20,
    formula: 'Ensemble aggregation of 100 bootstrapped decision trees',
    badge: 'Bagging Benchmark',
    isChampion: false,
  },
  cbPoly: {
    name: 'Calamansi Bio-Allometric Polynomial (CB-Poly)',
    shortName: 'CB-Poly',
    role: '★ Proposed Champion Architecture',
    correlationR: 0.9080,
    r2Percent: 82.45,
    maeMl: 0.4812,
    rmseMl: 0.6420,
    mapePercent: 9.85,
    formula: 'Juice (ml) = -0.2805 + 0.6002(W) - 0.00410(W²) - 0.5700·ln(W)',
    badge: '★ Proposed Champion',
    isChampion: true,
  },
};

// 4-Layer Bio-Allometric Architecture Pipeline
export const CB_POLY_PIPELINE_LAYERS = [
  {
    step: 'Layer 0: Data Hygiene Audit',
    desc: 'Audited all 1,522 collected sample records to remove 3 physical recording typos (e.g. 2g fruit with 16mL juice), leaving 1,519 physically verified calamansi samples.',
    status: 'Verified',
  },
  {
    step: 'Layer 1: Linear & Quadratic Mass Dynamics',
    desc: 'Models primary fruit mass transfer (W) and high-mass density compression damping (W²).',
    status: 'Parametric',
  },
  {
    step: 'Layer 2: Allometric Vesicle Growth Layer',
    desc: 'Incorporates biological power-law scaling of citrus endocarp juice sacs via the natural logarithm term ln(W).',
    status: 'Domain Layer',
  },
  {
    step: 'Layer 3: L2 Ridge Regularization Layer',
    desc: 'Applies L2 penalty shrinkage (λ = 0.01) to eliminate feature multicollinearity and constrain generalization error gap to < 0.002.',
    status: 'Regularized',
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

// Unit Predictions per Individual Fruit (g)
export function predictSimplePerFruit(w: number): number {
  const val = 0.4493 * w - 0.4927;
  return val > 0 ? val : 0;
}

export function predictPolyPerFruit(w: number): number {
  const val = -0.8195 + 0.5043 * w - 0.002187 * w * w;
  return val > 0 ? val : 0;
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
  const cbPolyPerFruit = predictCbPolyPerFruit(repWeight);

  const slrTotalMl = countFloat * slrPerFruit;
  const polyTotalMl = countFloat * polyPerFruit;
  const cbPolyTotalMl = countFloat * cbPolyPerFruit;

  return {
    count,
    repWeight,
    slrTotalMl,
    polyTotalMl,
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
