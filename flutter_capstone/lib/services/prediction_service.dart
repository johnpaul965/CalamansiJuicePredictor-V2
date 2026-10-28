import 'dart:math';
import '../models/prediction_result.dart';

class PredictionService {
  // Empirical mean single fruit weight from the 1,478 cleaned training rows.
  static const double representativeFruitWeightG = 12.686062;

  // ── 1. SIMPLE LINEAR REGRESSION (SLR Baseline) ──
  // Current trained baseline: Juice = -0.5488877886 + 0.4551336614 * W
  static double predictSLR(double w) {
    final val = -0.5488877886 + 0.4551336614 * w;
    return val > 0 ? val : 0.0;
  }

  // ── 2. POLYNOMIAL REGRESSION d=2 (Quadratic Baseline) ──
  // Current trained baseline: Juice = -0.8979234205 + 0.5136818207 * W - 0.002323394 * W²
  static double predictPoly(double w) {
    final val = -0.8979234205 + 0.5136818207 * w - 0.002323394 * w * w;
    return val > 0 ? val : 0.0;
  }

  // ── 3. SUPPORT VECTOR REGRESSION (SVR - RBF Kernel) ──
  // Current trained RBF model predictions at integer weights from 5 g to 21 g.
  // Intermediate inputs use linear interpolation, as in the existing app.
  static const List<double> _svrGrid = [
    2.2095, 2.3342, 2.6713, 3.1000, 3.5308, 3.9511, 4.4000, 4.9000, 5.4187,
    5.9000, 6.3284, 6.7489, 7.2127, 7.7000, 8.0992, 8.2672, 8.1220
  ];

  static double predictSVR(double w) {
    final clamped = max(5.0, min(21.0, w));
    final lo = (clamped.floor() - 5).clamp(0, _svrGrid.length - 2);
    final hi = min(_svrGrid.length - 1, lo + 1);
    final frac = clamped - (lo + 5.0);
    final val = _svrGrid[lo] * (1.0 - frac) + _svrGrid[hi] * frac;
    return val > 0 ? val : 0.0;
  }

  // ── 4. ★ SELECTED PROPOSED MODEL: Poly (d=2) + ln(W) & L2 Ridge ──
  // Current trained formula; nested grouped CV selected alpha = 0.01.
  static double predictProposed(double w) {
    final logW = log(max(1.0, w));
    final val =
        2.4583277642 +
        1.1252024747 * w -
        0.0146438683 * (w * w) -
        3.5939118293 * logW;
    return val > 0 ? val : 0.0;
  }

  // Batch Calculation Engine for Farmers
  static PredictionResult calculateBatch(double totalWeightG) {
    final countFloat = totalWeightG / representativeFruitWeightG;
    final count = max(1, countFloat.round());

    final slrMl = countFloat * predictSLR(representativeFruitWeightG);
    final polyMl = countFloat * predictPoly(representativeFruitWeightG);
    final svrMl = countFloat * predictSVR(representativeFruitWeightG);
    final proposedMl = countFloat * predictProposed(representativeFruitWeightG);

    return PredictionResult(
      count: count,
      representativeWeight: representativeFruitWeightG,
      slrTotalMl: slrMl,
      polyTotalMl: polyMl,
      svrTotalMl: svrMl,
      proposedTotalMl: proposedMl,
      bottles330: proposedMl / 330.0,
      bottles500: proposedMl / 500.0,
      bottles1000: proposedMl / 1000.0,
      extractionRatio: (proposedMl / totalWeightG) * 100.0,
    );
  }

  // Weight-grouped 5-fold out-of-fold metrics (Proposed Pipeline vs. Baselines).
  static final List<ModelBenchmarkItem> benchmarks = [
    ModelBenchmarkItem(
      id: 'proposed',
      name: 'Polynomial (d=2) + ln(W) & L2 Ridge',
      formula: 'Juice = max(0, 2.4583277642 + 1.1252024747·W - 0.0146438683·W² - 3.5939118293·ln(W))',
      configuration: '★ Proposed Model (in-fold sanitization + L2 Ridge; α = 0.01)',
      r2: 82.277148,
      mae: 0.489689,
      rmse: 0.616053,
      mape: 10.061737,
      status: '★ Champion Model',
      isChampion: true,
    ),
    ModelBenchmarkItem(
      id: 'svr',
      name: 'Support Vector Regression (RBF Kernel)',
      formula: 'RBF Kernel (C=1, ε=0.1, γ=0.05)',
      configuration: 'Standard Kernel Machine (off-the-shelf baseline)',
      r2: 78.685467,
      mae: 0.531933,
      rmse: 0.683020,
      mape: 11.472535,
      status: 'RBF Kernel',
      isChampion: false,
    ),
    ModelBenchmarkItem(
      id: 'slr',
      name: 'Simple Linear Regression (SLR)',
      formula: 'Juice = max(0, -0.5488877886 + 0.4551336614·W)',
      configuration: 'Ordinary Linear Baseline (off-the-shelf baseline)',
      r2: 77.998105,
      mae: 0.544144,
      rmse: 0.693892,
      mape: 11.933256,
      status: 'Linear Baseline',
      isChampion: false,
    ),
    ModelBenchmarkItem(
      id: 'poly',
      name: 'Polynomial Regression (Degree 2)',
      formula: 'Juice = max(0, -0.8979234205 + 0.5136818207·W - 0.002323394·W²)',
      configuration: 'Polynomial Degree 2 Baseline (off-the-shelf)',
      r2: 76.230460,
      mae: 0.569004,
      rmse: 0.713589,
      mape: 12.859663,
      status: 'Polynomial (Degree 2)',
      isChampion: false,
    ),
  ];

  static String r2Label(String modelId) {
    final benchmark = benchmarks.firstWhere((item) => item.id == modelId);
    return '${benchmark.r2.toStringAsFixed(2)}%';
  }

  // Chapter 4 Data Cleaning & Hygiene Audit Pipeline
  static final List<DataCleaningStep> dataHygieneSteps = [
    DataCleaningStep(
      step: 1,
      title: 'Raw Field Harvest Ingestion',
      description: 'Physical harvesting from Leyte calamansi orchards across varying tree maturities and microclimates.',
      inputCount: 1522,
      outputCount: 1522,
      dropCount: 0,
      percentageRetained: 100.0,
    ),
    DataCleaningStep(
      step: 2,
      title: 'Biological Ratio Boundary Filter',
      description: 'Strict rejection of physiologically impossible fruits where Juice/Weight ratio > 0.60 (ruptured or dehydrated peels).',
      inputCount: 1522,
      outputCount: 1514,
      dropCount: 8,
      percentageRetained: 99.47,
    ),
    DataCleaningStep(
      step: 3,
      title: '98% Confidence Interval Outlier Filter',
      description: 'Standardized residual analysis (|Z| ≤ 2.326) removing developmental malformations and scale measurement shock.',
      inputCount: 1514,
      outputCount: 1478,
      dropCount: 36,
      percentageRetained: 97.11,
    ),
  ];
}
