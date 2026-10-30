import 'dart:math' as math;
import '../models/prediction_result.dart';

class ResearchMetadata {
  static const String institution = 'Leyte Normal University';
  static const String study = 'Tacloban City Calamansi Harvest Study';
  static const int totalSamples = 1522;
  static const int cleanSamples = 1478;
  static const double representativeWeightG = 12.686062;
  static const double representativeJuiceMl = 5.224966;
  static const double extractionRatioPct = 41.1867;
}

class ThesisModels {
  ThesisModels._();

  static const ModelBenchmark slr = ModelBenchmark(
    name: 'Simple Linear Regression (SLR)',
    shortName: 'Simple Linear Regression (SLR)',
    r2Percent: 77.998105,
    maeMl: 0.544144,
    rmseMl: 0.693891,
    mapePercent: 11.928524,
    formula: 'Juice (mL) = max(0, -0.5488877886 + 0.4551336614·W)',
    isBest: false,
  );

  static const ModelBenchmark poly = ModelBenchmark(
    name: 'Polynomial Regression (Degree 2)',
    shortName: 'Polynomial Regression (Degree 2)',
    r2Percent: 76.23046,
    maeMl: 0.569004,
    rmseMl: 0.713551,
    mapePercent: 12.861827,
    formula:
        'Juice (mL) = max(0, -0.8979234205 + 0.5136818207·W - 0.0023233940·W²)',
    isBest: false,
  );

  static const ModelBenchmark rbf = ModelBenchmark(
    name: 'Support Vector Regression (RBF Kernel)',
    shortName: 'Support Vector Regression (RBF Kernel)',
    r2Percent: 78.685467,
    maeMl: 0.531933,
    rmseMl: 0.682967,
    mapePercent: 11.474536,
    formula:
        'Juice (mL) = max(0, 5.1947683581 + Σᵢ βᵢ·exp(-0.050000·(W - SVᵢ)²)); C = 1, ε = 0.1, γ = 0.05, Nsv = 1283',
    isBest: false,
  );

  static const ModelBenchmark primary = ModelBenchmark(
    name: 'Polynomial (d=2) + ln(W) & L2 Ridge',
    shortName: 'Polynomial (d=2) + ln(W) & L2 Ridge',
    r2Percent: 82.277148,
    maeMl: 0.489689,
    rmseMl: 0.616143,
    mapePercent: 10.061399,
    formula:
        'Juice (mL) = max(0, 2.4583277642 + 1.1252024747·W - 0.0146438683·W² - 3.5939118293·ln(W))',
    isBest: true,
    alpha: 0.01,
  );

  static const List<ModelBenchmark> all = [slr, poly, rbf, primary];
}

class PredictionService {
  PredictionService._();

  static const double singleSampleMaxWeightG = 25.0;

  // SLR coefficients
  static const List<double> _slrCoeffs = [-0.5488877886, 0.4551336614];

  // Polynomial Degree 2 coefficients
  static const List<double> _polyCoeffs = [
    -0.8979234205,
    0.5136818207,
    -0.002323394,
  ];

  // Primary (Poly d=2 + ln(W) & L2 Ridge) coefficients
  static const List<double> _primaryCoeffs = [
    2.4583277642,
    1.1252024747,
    -0.0146438683,
    -3.5939118293,
  ];

  // Exact RBF SVR parameters collapsed from all 1,283 support vectors
  static const double _rbfIntercept = 5.1947683581;
  static const double _rbfGamma = 0.05;
  static const List<List<double>> _rbfCollapsedSupportVectors = [
    [6.0, -8.0],
    [7.0, 7.0],
    [8.0, -0.2142060019000005],
    [9.0, -5.0],
    [10.0, 6.0],
    [11.0, 3.769047099399998],
    [12.0, -16.7258283571],
    [13.0, 3.0],
    [14.0, 20.060439674],
    [15.0, -13.0],
    [16.0, -4.0],
    [17.0, 4.0],
    [18.0, 1.1105475856000002],
    [19.0, -2.0],
    [20.0, 5.0],
    [21.0, -1.0],
  ];

  static double predictSimplePerSample(double weightG) {
    final val = _slrCoeffs[0] + _slrCoeffs[1] * weightG;
    return math.max(0.0, val);
  }

  static double predictPolynomialPerSample(double weightG) {
    final val = _polyCoeffs[0] +
        _polyCoeffs[1] * weightG +
        _polyCoeffs[2] * weightG * weightG;
    return math.max(0.0, val);
  }

  static double predictRbfPerSample(double weightG) {
    double kernelSum = 0.0;
    for (final pair in _rbfCollapsedSupportVectors) {
      final diff = weightG - pair[0];
      kernelSum += pair[1] * math.exp(-_rbfGamma * diff * diff);
    }
    return math.max(0.0, _rbfIntercept + kernelSum);
  }

  static double predictPrimaryPerSample(double weightG) {
    final safeW = math.max(1.0, weightG);
    final val = _primaryCoeffs[0] +
        _primaryCoeffs[1] * weightG +
        _primaryCoeffs[2] * weightG * weightG +
        _primaryCoeffs[3] * math.log(safeW);
    return math.max(0.0, val);
  }

  static double _roundTo(double value, int decimals) {
    return double.parse(value.toStringAsFixed(decimals));
  }

  static PredictionResult runCalculationEngine(double weightG) {
    if (!weightG.isFinite || weightG <= 0) {
      throw ArgumentError('Batch weight must be greater than zero.');
    }

    final bool isSingleSample = weightG <= singleSampleMaxWeightG;
    const double representativeWeight = ResearchMetadata.representativeWeightG;
    final double evalWeightG = isSingleSample ? weightG : representativeWeight;
    final double exactUnits =
        isSingleSample ? 1.0 : weightG / representativeWeight;
    final int count =
        isSingleSample ? 1 : math.max(1, exactUnits.round());

    final double slrTotalMl = predictSimplePerSample(evalWeightG) * exactUnits;
    final double polyTotalMl =
        predictPolynomialPerSample(evalWeightG) * exactUnits;
    final double rbfTotalMl = predictRbfPerSample(evalWeightG) * exactUnits;
    final double primaryTotalMl =
        predictPrimaryPerSample(evalWeightG) * exactUnits;

    return PredictionResult(
      count: count,
      repWeight: evalWeightG,
      isSingleSample: isSingleSample,
      slrTotalMl: _roundTo(slrTotalMl, 2),
      polyTotalMl: _roundTo(polyTotalMl, 2),
      rbfTotalMl: _roundTo(rbfTotalMl, 2),
      primaryTotalMl: _roundTo(primaryTotalMl, 2),
      bottles330: _roundTo(primaryTotalMl / 330.0, 1),
      bottles500: _roundTo(primaryTotalMl / 500.0, 1),
      bottles1000: _roundTo(primaryTotalMl / 1000.0, 2),
      extractionRatioPercent: _roundTo((primaryTotalMl / weightG) * 100.0, 2),
    );
  }
}
