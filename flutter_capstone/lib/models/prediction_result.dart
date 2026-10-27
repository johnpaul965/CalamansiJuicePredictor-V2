class PredictionResult {
  final int count;
  final double representativeWeight;
  final double slrTotalMl;
  final double polyTotalMl;
  final double svrTotalMl;
  final double proposedTotalMl;
  final double bottles330;
  final double bottles500;
  final double bottles1000;
  final double extractionRatio;

  PredictionResult({
    required this.count,
    required this.representativeWeight,
    required this.slrTotalMl,
    required this.polyTotalMl,
    required this.svrTotalMl,
    required this.proposedTotalMl,
    required this.bottles330,
    required this.bottles500,
    required this.bottles1000,
    required this.extractionRatio,
  });
}

class ModelBenchmarkItem {
  final String id;
  final String name;
  final String formula;
  final String configuration;
  final double r2;
  final double mae;
  final double rmse;
  final double mape;
  final String status;
  final bool isChampion;

  ModelBenchmarkItem({
    required this.id,
    required this.name,
    required this.formula,
    required this.configuration,
    required this.r2,
    required this.mae,
    required this.rmse,
    required this.mape,
    required this.status,
    this.isChampion = false,
  });
}

class DataCleaningStep {
  final int step;
  final String title;
  final String description;
  final int inputCount;
  final int outputCount;
  final int dropCount;
  final double percentageRetained;

  DataCleaningStep({
    required this.step,
    required this.title,
    required this.description,
    required this.inputCount,
    required this.outputCount,
    required this.dropCount,
    required this.percentageRetained,
  });
}

class UserAccount {
  final String id;
  final String name;
  final String username;
  final String role; // 'user' or 'admin'
  final String organization;
  bool isActive;
  final String dateCreated;

  UserAccount({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.organization,
    required this.isActive,
    required this.dateCreated,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'role': role,
    'organization': organization,
    'isActive': isActive,
    'dateCreated': dateCreated,
  };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
    id: json['id'] as String,
    name: json['name'] as String,
    username: json['username'] as String,
    role: json['role'] as String,
    organization: json['organization'] as String,
    isActive: json['isActive'] as bool? ?? true,
    dateCreated: json['dateCreated'] as String,
  );
}

class PredictionLogItem {
  final String id;
  final String date;
  final String user;
  final double weightG;
  final String weightFormatted;
  final int count;
  final double proposedMl;
  final double slrMl;
  final double polyMl;
  final double svrMl;
  final double bottles330;
  final double bottles500;
  final double bottles1000;

  PredictionLogItem({
    required this.id,
    required this.date,
    required this.user,
    required this.weightG,
    required this.weightFormatted,
    required this.count,
    required this.proposedMl,
    required this.slrMl,
    required this.polyMl,
    required this.svrMl,
    required this.bottles330,
    required this.bottles500,
    required this.bottles1000,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'user': user,
    'weightG': weightG,
    'weightFormatted': weightFormatted,
    'count': count,
    'proposedMl': proposedMl,
    'slrMl': slrMl,
    'polyMl': polyMl,
    'svrMl': svrMl,
    'bottles330': bottles330,
    'bottles500': bottles500,
    'bottles1000': bottles1000,
  };

  factory PredictionLogItem.fromJson(Map<String, dynamic> json) => PredictionLogItem(
    id: json['id'] as String,
    date: json['date'] as String,
    user: json['user'] as String,
    weightG: (json['weightG'] as num).toDouble(),
    weightFormatted: json['weightFormatted'] as String,
    count: json['count'] as int,
    proposedMl: (json['proposedMl'] as num).toDouble(),
    slrMl: (json['slrMl'] as num).toDouble(),
    polyMl: (json['polyMl'] as num).toDouble(),
    svrMl: (json['svrMl'] as num).toDouble(),
    bottles330: (json['bottles330'] as num?)?.toDouble() ?? (json['proposedMl'] as num).toDouble() / 330.0,
    bottles500: (json['bottles500'] as num?)?.toDouble() ?? (json['proposedMl'] as num).toDouble() / 500.0,
    bottles1000: (json['bottles1000'] as num?)?.toDouble() ?? (json['proposedMl'] as num).toDouble() / 1000.0,
  );
}
