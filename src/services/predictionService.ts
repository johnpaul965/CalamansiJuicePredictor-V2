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

// 4 Models Loaded Live from Cleaned Benchmark in model_metrics.json
export const THESIS_MODELS: Record<string, ModelBenchmark> = {
  slr: {
    name: liveMetrics.clean_benchmarks.slr.name,
    shortName: 'SLR',
    role: liveMetrics.clean_benchmarks.slr.role,
    correlationR: liveMetrics.clean_benchmarks.slr.correlation_r,
    r2Percent: liveMetrics.clean_benchmarks.slr.r2_percent,
    maeMl: liveMetrics.clean_benchmarks.slr.mae,
    rmseMl: liveMetrics.clean_benchmarks.slr.rmse,
    mapePercent: liveMetrics.clean_benchmarks.slr.mape,
    formula: liveMetrics.clean_benchmarks.slr.formula,
    badge: liveMetrics.clean_benchmarks.slr.isChampion ? '★ Best Fit' : 'Linear Baseline',
    isChampion: liveMetrics.clean_benchmarks.slr.isChampion,
  },
  poly: {
    name: liveMetrics.clean_benchmarks.poly.name,
    shortName: 'Poly (d=2)',
    role: liveMetrics.clean_benchmarks.poly.role,
    correlationR: liveMetrics.clean_benchmarks.poly.correlation_r,
    r2Percent: liveMetrics.clean_benchmarks.poly.r2_percent,
    maeMl: liveMetrics.clean_benchmarks.poly.mae,
    rmseMl: liveMetrics.clean_benchmarks.poly.rmse,
    mapePercent: liveMetrics.clean_benchmarks.poly.mape,
    formula: liveMetrics.clean_benchmarks.poly.formula,
    badge: liveMetrics.clean_benchmarks.poly.isChampion ? '★ Best Fit' : 'Quadratic Baseline',
    isChampion: liveMetrics.clean_benchmarks.poly.isChampion,
  },
  svr: {
    name: liveMetrics.clean_benchmarks.svr.name,
    shortName: 'SVR (RBF)',
    role: liveMetrics.clean_benchmarks.svr.role,
    correlationR: liveMetrics.clean_benchmarks.svr.correlation_r,
    r2Percent: liveMetrics.clean_benchmarks.svr.r2_percent,
    maeMl: liveMetrics.clean_benchmarks.svr.mae,
    rmseMl: liveMetrics.clean_benchmarks.svr.rmse,
    mapePercent: liveMetrics.clean_benchmarks.svr.mape,
    formula: liveMetrics.clean_benchmarks.svr.formula,
    badge: liveMetrics.clean_benchmarks.svr.isChampion ? '★ Best Fit' : 'RBF Kernel',
    isChampion: liveMetrics.clean_benchmarks.svr.isChampion,
  },
  cbPoly: {
    name: liveMetrics.clean_benchmarks.proposed.name,
    shortName: 'Poly + ln(W) + Ridge',
    role: liveMetrics.clean_benchmarks.proposed.role,
    correlationR: liveMetrics.clean_benchmarks.proposed.correlation_r,
    r2Percent: liveMetrics.clean_benchmarks.proposed.r2_percent,
    maeMl: liveMetrics.clean_benchmarks.proposed.mae,
    rmseMl: liveMetrics.clean_benchmarks.proposed.rmse,
    mapePercent: liveMetrics.clean_benchmarks.proposed.mape,
    formula: liveMetrics.clean_benchmarks.proposed.formula,
    badge: liveMetrics.clean_benchmarks.proposed.isChampion ? '★ Best Fit' : 'Proposed Model',
    isChampion: liveMetrics.clean_benchmarks.proposed.isChampion,
  },
};

export const CLEAN_BENCHMARKS = liveMetrics.clean_benchmarks;


// Empirical Monte Carlo Batch Scaling Accuracy (200 Resampling Trials)
export const BATCH_SCALING_BENCHMARK = liveMetrics.batch_scaling_clt;

// Dynamic Trained Coefficients
const SLR_COEFFS = liveMetrics.clean_benchmarks.slr.coefficients;
const SVR_COEFFS = liveMetrics.clean_benchmarks.svr.coefficients;
const POLY_COEFFS = liveMetrics.clean_benchmarks.poly.coefficients;
const PROP_COEFFS = liveMetrics.clean_benchmarks.proposed.coefficients;

// Unit Predictions per Individual Fruit (g)
export function predictSimplePerFruit(w: number): number {
  const val = SLR_COEFFS[0] + SLR_COEFFS[1] * w;
  return val > 0 ? val : 0;
}

export function predictSvrPerFruit(w: number): number {
  const val = SVR_COEFFS[0] + SVR_COEFFS[1] * w;
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

// Operational Calculation Engine
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
