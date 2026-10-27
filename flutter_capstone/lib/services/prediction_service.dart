import 'dart:math';
import '../models/prediction_result.dart';

class PredictionService {
  // Empirical mean single fruit weight from Tacloban City harvest (N = 1,478 clean fruits)
  static const double representativeFruitWeightG = 12.686;

  // ── 1. SIMPLE LINEAR REGRESSION (SLR Baseline) ──
  // Ordinary Linear Baseline: Juice = 0.416169 * W - 0.043154
  static double predictSLR(double w) {
    final val = 0.416169 * w - 0.043154;
    return val > 0 ? val : 0.0;
  }

  // ── 2. POLYNOMIAL REGRESSION d=2 (Quadratic Baseline) ──
  // Ordinary Quadratic Baseline: Juice = 2.160503 + 0.041943 * W + 0.014995 * W²
  static double predictPoly(double w) {
    final val = 2.160503 + 0.041943 * w + 0.014995 * w * w;
    return val > 0 ? val : 0.0;
  }

  // ── 3. SUPPORT VECTOR REGRESSION (SVR - RBF Kernel) ──
  // Evaluated on trained SVR grid (C=1.0, epsilon=0.1, RBF kernel on W)
  static const List<double> _svrGrid = [
    2.3423, 2.3001, 2.6539, 3.1004, 3.5432, 4.0000, 4.4439, 4.9004, 5.4126,
    5.8996, 6.2999, 6.7099, 7.2001, 7.6996, 8.1002, 8.2598, 8.0029
  ];

  static double predictSVR(double w) {
    final clamped = max(5.0, min(21.0, w));
    final lo = (clamped.floor() - 5).clamp(0, _svrGrid.length - 2);
    final hi = min(_svrGrid.length - 1, lo + 1);
    final frac = clamped - clamped.floor();
    final val = _svrGrid[lo] * (1.0 - frac) + _svrGrid[hi] * frac;
    return val > 0 ? val : 0.0;
  }

  // ── 4. ★ PROPOSED CHAMPION MODEL: Poly (d=2) + ln(W) & L2 Ridge (alpha = 0.01) ──
  // Juice = 2.317885 + 1.100407 * W - 0.014151 * W² - 3.445975 * ln(W)
  static double predictProposed(double w) {
    final logW = log(max(1.0, w));
    final val = 2.317885 + 1.100407 * w - 0.014151 * (w * w) - 3.445975 * logW;
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

  // Official 4-Model Comparative Benchmark Suite (Weight-Grouped 5-Fold Cross-Validation, N = 1,478)
  static final List<ModelBenchmarkItem> benchmarks = [
    ModelBenchmarkItem(
      id: 'slr',
      name: 'Simple Linear Regression (SLR)',
      formula: 'Juice = 0.4162(W) - 0.0432',
      configuration: 'Ordinary Linear Baseline (W only, no layers)',
      r2: 80.74,
      mae: 0.5142,
      rmse: 0.6423,
      mape: 10.92,
      status: 'No Layers (-1.54%)',
      isChampion: false,
    ),
    ModelBenchmarkItem(
      id: 'svr',
      name: 'Support Vector Regression (Ordinary RBF)',
      formula: 'RBF Kernel (C=1.0, ε=0.1, γ=scale)',
      configuration: 'Default Off-the-Shelf SVR (W only, no layers)',
      r2: 80.53,
      mae: 0.5128,
      rmse: 0.6458,
      mape: 10.99,
      status: 'No Layers (-1.75%)',
      isChampion: false,
    ),
    ModelBenchmarkItem(
      id: 'poly',
      name: 'Polynomial Regression (Degree 2)',
      formula: 'Juice = 2.1605 + 0.0419(W) + 0.0150(W²)',
      configuration: 'Ordinary Quadratic Baseline (W, W², no layers)',
      r2: 76.23,
      mae: 0.5690,
      rmse: 0.7136,
      mape: 12.86,
      status: 'No Layers (-6.05%)',
      isChampion: false,
    ),
    ModelBenchmarkItem(
      id: 'proposed',
      name: 'Polynomial Regression (d=2) + ln(W) & L2 Ridge',
      formula: 'Juice = 2.3179 + 1.1004(W) - 0.01415(W²) - 3.4460·ln(W)',
      configuration: '★ Proposed Model (In-Fold Clean + ln W + L2 Ridge)',
      r2: 82.28,
      mae: 0.4896,
      rmse: 0.6160,
      mape: 10.05,
      status: '★ BEST FIT',
      isChampion: true,
    ),
  ];

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
