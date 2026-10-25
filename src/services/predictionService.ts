import { PredictionResult, ResearchMetadata } from '../types';

export const RESEARCH_METADATA: ResearchMetadata = {
  institution: 'Leyte Normal University',
  study: 'Tacloban City Calamansi Harvest Study',
  total_samples: 1522,
  training_samples: 1217,
  testing_samples: 305,
  best_model: 'Polynomial Regression (d=2)',
  overall_mean_fruit_weight_g: 12.65,
  overall_mean_fruit_juice_ml: 5.22,
};

// Empirical harvest distribution across all valid harvested fruits in Tacloban City
export const HARVEST_BASELINE = {
  representativeWeight: 12.65, // Empirical mean calamansi weight in grams
  sizeIndex: 2.08,             // Weighted empirical size index (Small=1, Medium=2, Large=3)
  label: 'General Harvest Average',
};

// The verified Cross-Validation Benchmark Suite (Cleaned N=1,519, Zero Leakage)
export const DEFENSE_CV_BENCHMARKS = [
  { model: 'SLR', cvR2: 0.7892, role: 'Control Group', desc: 'Linear baseline (Weight only)' },
  { model: 'Polynomial Ridge (d=2)', cvR2: 0.7886, role: 'Polynomial Baseline', desc: 'Quadratic interaction terms' },
  { model: 'Polynomial Ridge + log(w)', cvR2: 0.7888, role: 'Allometric Scaling', desc: 'Log-weight target stabilized' },
  { model: 'Random Forest', cvR2: 0.7877, role: 'Bagging Benchmark', desc: '100 randomized decision trees' },
  { model: 'CatBoost', cvR2: 0.7863, role: 'Boosting Benchmark', desc: 'Gradient boosted decision trees' },
  { model: 'Natural Cubic Spline', cvR2: 0.7881, role: 'Piecewise Cubic', desc: '5 knots with constant extrapolation' },
];
// Summary Finding: Spread: 0.0029 | All gaps < 0.01 | Ceiling reached (~0.79).

export const MODEL_SPECS = {
  simple: {
    name: 'Simple Linear Regression',
    shortName: 'SLR',
    features: ['Weight (g)'],
    formula: 'Juice (ml) = 0.4569 × Weight - 0.6080',
    weightCoef: 0.4569,
    intercept: -0.6080,
    metrics: {
      r2: 0.7099,
      cvR2: 0.7892,
      mae: 0.5294,
      rmse: 0.6635,
      mse: 0.4403,
      mape: 10.42,
    },
    badge: 'Baseline',
    isWinner: false,
  },
  multiple: {
    name: 'Multiple Linear Regression',
    shortName: 'MLR',
    features: ['Weight (g)', 'Size (1–3)'],
    formula: 'Juice (ml) = 0.4580 × Weight - 0.0053 × Size - 0.6108',
    weightCoef: 0.4580,
    sizeCoef: -0.0053,
    intercept: -0.6108,
    metrics: {
      r2: 0.7100,
      cvR2: 0.7886,
      mae: 0.5292,
      rmse: 0.6635,
      mse: 0.4402,
      mape: 10.42,
    },
    badge: 'Comparative',
    isWinner: false,
  },
  poly: {
    name: 'Polynomial Regression (d=2)',
    shortName: 'Poly d=2',
    features: ['Weight', 'Size', 'Weight²', 'Weight·Size', 'Size²'],
    formula: 'Juice = -0.5480 + 0.4357(W) + 0.0865(S) - 0.0031(W²) + 0.0474(W·S) - 0.1641(S²)',
    intercept: -0.5480,
    coefs: [0.43568, 0.086517, -0.003075, 0.047385, -0.164087],
    metrics: {
      r2: 0.7102,
      cvR2: 0.7888,
      mae: 0.5279,
      rmse: 0.6637,
      mse: 0.4405,
      mape: 10.39,
    },
    badge: '★ Best Performing',
    isWinner: true,
  },
};

export function predictSimplePerFruit(w: number): number {
  const val = MODEL_SPECS.simple.weightCoef * w + MODEL_SPECS.simple.intercept;
  return val > 0 ? val : 0;
}

export function predictMultiplePerFruit(w: number, s: number): number {
  const val =
    MODEL_SPECS.multiple.weightCoef * w +
    MODEL_SPECS.multiple.sizeCoef * s +
    MODEL_SPECS.multiple.intercept;
  return val > 0 ? val : 0;
}

export function predictPolyPerFruit(w: number, s: number): number {
  const features = [w, s, w * w, w * s, s * s];
  let val = MODEL_SPECS.poly.intercept;
  for (let i = 0; i < features.length; i++) {
    val += MODEL_SPECS.poly.coefs[i] * features[i];
  }
  return val > 0 ? val : 0;
}

// Streamlined calculation engine: requires ONLY batch weight, no manual small/medium sorting
export function runCalculationEngine(weightG: number): PredictionResult {
  const repWeight = HARVEST_BASELINE.representativeWeight; // 12.65g empirical mean
  const sizeCode = HARVEST_BASELINE.sizeIndex;            // 2.08 empirical harvest index

  const count = Math.max(1, Math.round(weightG / repWeight));
  const countFloat = weightG / repWeight;

  const slrPerFruit = predictSimplePerFruit(repWeight);
  const mlrPerFruit = predictMultiplePerFruit(repWeight, sizeCode);
  const polyPerFruit = predictPolyPerFruit(repWeight, sizeCode);

  const slrTotalMl = countFloat * slrPerFruit;
  const mlrTotalMl = countFloat * mlrPerFruit;
  const polyTotalMl = countFloat * polyPerFruit;

  return {
    count,
    repWeight,
    sizeCode,
    sizeLabel: 'Natural Harvest Average (No Manual Sorting Needed)',
    slrTotalMl,
    mlrTotalMl,
    polyTotalMl,
    bottles330: +(polyTotalMl / 330).toFixed(1),
    bottles500: +(polyTotalMl / 500).toFixed(1),
    bottles1000: +(polyTotalMl / 1000).toFixed(2),
  };
}
