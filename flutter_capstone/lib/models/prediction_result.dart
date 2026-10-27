class PredictionResult {
  final double weightG;
  final int fruitCount;
  final double representativeFruitWeight;
  final double proposedJuiceMl;
  final double slrJuiceMl;
  final double polyJuiceMl;
  final double mlrJuiceMl;
  final double bottles330;
  final double bottles500;
  final double bottles1000;
  final double extractionRatioPercent;

  PredictionResult({
    required this.weightG,
    required this.fruitCount,
    required this.representativeFruitWeight,
    required this.proposedJuiceMl,
    required this.slrJuiceMl,
    required this.polyJuiceMl,
    required this.mlrJuiceMl,
    required this.bottles330,
    required this.bottles500,
    required this.bottles1000,
    required this.extractionRatioPercent,
  });
}

class HarvestLog {
  final String id;
  final String dateTime;
  final String weightText;
  final double weightG;
  final int fruitCount;
  final double proposedMl;
  final double slrMl;
  final double polyMl;
  final double mlrMl;

  HarvestLog({
    required this.id,
    required this.dateTime,
    required this.weightText,
    required this.weightG,
    required this.fruitCount,
    required this.proposedMl,
    required this.slrMl,
    required this.polyMl,
    required this.mlrMl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime,
    'weightText': weightText,
    'weightG': weightG,
    'fruitCount': fruitCount,
    'proposedMl': proposedMl,
    'slrMl': slrMl,
    'polyMl': polyMl,
    'mlrMl': mlrMl,
  };

  factory HarvestLog.fromJson(Map<String, dynamic> json) => HarvestLog(
    id: json['id'] as String? ?? '',
    dateTime: json['dateTime'] as String? ?? '',
    weightText: json['weightText'] as String? ?? '',
    weightG: (json['weightG'] as num?)?.toDouble() ?? 0.0,
    fruitCount: (json['fruitCount'] as num?)?.toInt() ?? 0,
    proposedMl: (json['proposedMl'] as num?)?.toDouble() ?? 0.0,
    slrMl: (json['slrMl'] as num?)?.toDouble() ?? 0.0,
    polyMl: (json['polyMl'] as num?)?.toDouble() ?? 0.0,
    mlrMl: (json['mlrMl'] as num?)?.toDouble() ?? 0.0,
  );
}
