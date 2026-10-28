import { ModelBenchmark, PredictionResult, ResearchMetadata } from '../types';
import trainedMetrics from '../data/model_metrics.json';

export const RESEARCH_METADATA: ResearchMetadata = {
  institution: trainedMetrics.metadata.institution,
  study: trainedMetrics.metadata.study,
  total_samples: trainedMetrics.metadata.total_raw_samples,
  clean_samples: trainedMetrics.metadata.clean_samples,
  overall_mean_fruit_weight_g: trainedMetrics.metadata.representative_weight_g,
  overall_mean_fruit_juice_ml: trainedMetrics.metadata.representative_juice_ml,
};

export const HARVEST_BASELINE = {
  representativeWeight: trainedMetrics.metadata.representative_weight_g,
  representativeJuice: trainedMetrics.metadata.representative_juice_ml,
  ratioPercent: trainedMetrics.metadata.extraction_ratio_pct,
};

function toBenchmark(
  model: (typeof trainedMetrics.benchmarks)[keyof typeof trainedMetrics.benchmarks],
  shortName: string,
  badge: string
): ModelBenchmark {
  return {
    name: model.name,
    shortName,
    role: model.role,
    r2Percent: model.r2_percent,
    maeMl: model.mae,
    rmseMl: model.rmse,
    mapePercent: model.mape,
    formula: model.formula,
    badge,
    isChampion: model.isChampion,
    ...('alpha' in model ? { alpha: model.alpha } : {}),
  };
}

export const THESIS_MODELS = {
  slr: toBenchmark(
    trainedMetrics.benchmarks.slr,
    'Simple Linear Regression (SLR)',
    'Linear Baseline'
  ),
  poly: toBenchmark(
    trainedMetrics.benchmarks.poly,
    'Polynomial Regression (Degree 2)',
    'Polynomial (Degree 2) Baseline'
  ),
  rbf: toBenchmark(
    trainedMetrics.benchmarks.svr,
    'Support Vector Regression (RBF Kernel)',
    'RBF Kernel'
  ),
  primary: toBenchmark(
    trainedMetrics.benchmarks.primary,
    'Polynomial (d=2) + ln(W) & L2 Ridge',
    'Selected Final'
  ),
};

const SLR_COEFFICIENTS = trainedMetrics.benchmarks.slr.coefficients;
const POLY_COEFFICIENTS = trainedMetrics.benchmarks.poly.coefficients;
const RBF_MODEL = trainedMetrics.benchmarks.svr;
const PRIMARY_COEFFICIENTS = trainedMetrics.benchmarks.primary.coefficients;

export function predictSimplePerFruit(weightG: number): number {
  return Math.max(0, SLR_COEFFICIENTS[0] + SLR_COEFFICIENTS[1] * weightG);
}

export function predictPolynomialPerFruit(weightG: number): number {
  const value =
    POLY_COEFFICIENTS[0] +
    POLY_COEFFICIENTS[1] * weightG +
    POLY_COEFFICIENTS[2] * weightG ** 2;
  return Math.max(0, value);
}

export function predictRbfPerFruit(weightG: number): number {
  const value =
    RBF_MODEL.intercept +
    RBF_MODEL.support_vectors.reduce(
      (sum, supportVector, index) =>
        sum +
        RBF_MODEL.coefficients[index] *
          Math.exp(-RBF_MODEL.gamma * (weightG - supportVector) ** 2),
      0
    );
  return Math.max(0, value);
}

export function predictPrimaryPerFruit(weightG: number): number {
  const value =
    PRIMARY_COEFFICIENTS[0] +
    PRIMARY_COEFFICIENTS[1] * weightG +
    PRIMARY_COEFFICIENTS[2] * weightG ** 2 +
    PRIMARY_COEFFICIENTS[3] * Math.log(Math.max(1, weightG));
  return Math.max(0, value);
}

// Maximum weight (g) treated directly as a single calamansi fruit (dataset range: 2g–21g)
export const SINGLE_FRUIT_MAX_WEIGHT_G = 25;

export function runCalculationEngine(
  weightG: number,
  mode: 'auto' | 'single' | 'batch' = 'auto'
): PredictionResult {
  if (!Number.isFinite(weightG) || weightG <= 0) {
    throw new Error('Batch weight must be a finite number greater than zero.');
  }

  const isSingleFruit =
    mode === 'single' || (mode === 'auto' && weightG <= SINGLE_FRUIT_MAX_WEIGHT_G);

  const representativeWeight = HARVEST_BASELINE.representativeWeight;
  const evalWeightG = isSingleFruit ? weightG : representativeWeight;
  const exactFruitUnits = isSingleFruit ? 1 : weightG / representativeWeight;
  const count = isSingleFruit ? 1 : Math.max(1, Math.round(exactFruitUnits));

  const slrTotalMl = predictSimplePerFruit(evalWeightG) * exactFruitUnits;
  const polyTotalMl = predictPolynomialPerFruit(evalWeightG) * exactFruitUnits;
  const rbfTotalMl = predictRbfPerFruit(evalWeightG) * exactFruitUnits;
  const primaryTotalMl = predictPrimaryPerFruit(evalWeightG) * exactFruitUnits;

  return {
    count,
    repWeight: evalWeightG,
    isSingleFruit,
    slrTotalMl: Number(slrTotalMl.toFixed(2)),
    polyTotalMl: Number(polyTotalMl.toFixed(2)),
    rbfTotalMl: Number(rbfTotalMl.toFixed(2)),
    primaryTotalMl: Number(primaryTotalMl.toFixed(2)),
    bottles330: Number((primaryTotalMl / 330).toFixed(1)),
    bottles500: Number((primaryTotalMl / 500).toFixed(1)),
    bottles1000: Number((primaryTotalMl / 1000).toFixed(2)),
    extractionRatioPercent: Number(((primaryTotalMl / weightG) * 100).toFixed(2)),
  };
}
