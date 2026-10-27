import 'dart:math' as math;
import '../models/prediction_result.dart';

class PredictionService {
  // Scientific study constants from Leyte Normal University (Tacloban City Calamansi Harvest Study)
  static const double representativeFruitWeightG = 12.686; // Cleaned mean fruit weight
  static const double meanJuicePerFruitMl = 5.225; // Cleaned mean juice extraction

  /// 1. ★ Proposed Champion Model:
  /// Polynomial (degree 2) + ln(Weight) & L2 Ridge Regularization (alpha = 0.01)
  /// Performance: R² = 82.28%, MAE = 0.4896 mL, RMSE = 0.6160 mL
  static double predictProposedPerFruit(double weightG) {
    if (weightG <= 0) return 0.0;
    final double logW = math.log(math.max(1.0, weightG));
    final double juice = 2.317885 +
        (1.100407 * weightG) -
        (0.014151 * weightG * weightG) -
        (3.445975 * logW);
    return juice > 0 ? juice : 0.0;
  }

  /// 2. Simple Linear Regression (SLR Baseline):
  /// Performance: R² = 80.74%, MAE = 0.5142 mL, RMSE = 0.6423 mL
  static double predictSlrPerFruit(double weightG) {
    if (weightG <= 0) return 0.0;
    final double juice = (0.416169 * weightG) - 0.043154;
    return juice > 0 ? juice : 0.0;
  }

  /// 3. Ordinary Polynomial Regression Degree 2 (V1 Baseline Without Regularization):
  /// Performance: R² = 76.23%, MAE = 0.5690 mL, RMSE = 0.7136 mL
  static double predictPolyPerFruit(double weightG) {
    if (weightG <= 0) return 0.0;
    final double juice = 2.160503 + (0.041943 * weightG) + (0.014995 * weightG * weightG);
    return juice > 0 ? juice : 0.0;
  }

  /// 4. Multiple Linear Regression (MLR Baseline):
  /// Performance: R² = 79.71%, MAE = 0.5288 mL, RMSE = 0.6593 mL
  static double predictMlrPerFruit(double weightG) {
    if (weightG <= 0) return 0.0;
    // Evaluated at average fruit class weight
    final double juice = -0.5423 + (0.4530 * weightG) + (0.0098 * 1.97);
    return juice > 0 ? juice : 0.0;
  }

  /// Run full operational batch estimation without manual size sorting
  static PredictionResult calculateBatch(double totalWeightG) {
    final double repWeight = representativeFruitWeightG;
    final int count = math.max(1, (totalWeightG / repWeight).round());
    final double countFloat = totalWeightG / repWeight;

    final double proposedUnit = predictProposedPerFruit(repWeight);
    final double slrUnit = predictSlrPerFruit(repWeight);
    final double polyUnit = predictPolyPerFruit(repWeight);
    final double mlrUnit = predictMlrPerFruit(repWeight);

    final double proposedTotal = countFloat * proposedUnit;
    final double slrTotal = countFloat * slrUnit;
    final double polyTotal = countFloat * polyUnit;
    final double mlrTotal = countFloat * mlrUnit;

    return PredictionResult(
      weightG: totalWeightG,
      fruitCount: count,
      representativeFruitWeight: repWeight,
      proposedJuiceMl: proposedTotal,
      slrJuiceMl: slrTotal,
      polyJuiceMl: polyTotal,
      mlrJuiceMl: mlrTotal,
      bottles330: proposedTotal / 330.0,
      bottles500: proposedTotal / 500.0,
      bottles1000: proposedTotal / 1000.0,
      extractionRatioPercent: (proposedTotal / totalWeightG) * 100.0,
    );
  }

  /// Central Limit Theorem batch operational accuracy
  static Map<String, dynamic> getBatchAccuracy(double weightG) {
    if (weightG < 50) {
      return {'accuracy': 89.45, 'label': 'Single Fruit Scale', 'tag': 'Single Peel Variance'};
    } else if (weightG < 300) {
      return {'accuracy': 96.92, 'label': 'Retail Bag (~10-25 fruits)', 'tag': 'Damped Variance'};
    } else if (weightG < 1000) {
      return {'accuracy': 98.60, 'label': 'Harvest Basket (~50 fruits)', 'tag': 'High Reliability'};
    } else if (weightG < 3000) {
      return {'accuracy': 98.99, 'label': 'Standard Pack (~100-200 fruits)', 'tag': 'Near-Zero Biological Bias'};
    } else {
      return {'accuracy': 99.45, 'label': 'Commercial Crate (500+ fruits)', 'tag': 'Variance Cancellation (99.45%)'};
    }
  }
}
