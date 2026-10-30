class AppUser {
  final String id;
  final String username;
  final String password;
  final String role; // 'admin' | 'user'
  final String status; // 'Active' | 'Suspended'
  final String joined;

  const AppUser({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.status,
    required this.joined,
  });

  AppUser copyWith({
    String? id,
    String? username,
    String? password,
    String? role,
    String? status,
    String? joined,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      status: status ?? this.status,
      joined: joined ?? this.joined,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'role': role,
        'status': status,
        'joined': joined,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: (json['id'] ?? '').toString(),
        username: (json['username'] ?? '').toString(),
        password: (json['password'] ?? '').toString(),
        role: (json['role'] ?? 'user').toString(),
        status: (json['status'] ?? 'Active').toString(),
        joined: (json['joined'] ?? '2026-09-01').toString(),
      );
}

class PredictionResult {
  final int count;
  final double repWeight;
  final bool isSingleSample;
  final double slrTotalMl;
  final double polyTotalMl;
  final double rbfTotalMl;
  final double primaryTotalMl;
  final double bottles330;
  final double bottles500;
  final double bottles1000;
  final double extractionRatioPercent;

  const PredictionResult({
    required this.count,
    required this.repWeight,
    required this.isSingleSample,
    required this.slrTotalMl,
    required this.polyTotalMl,
    required this.rbfTotalMl,
    required this.primaryTotalMl,
    required this.bottles330,
    required this.bottles500,
    required this.bottles1000,
    required this.extractionRatioPercent,
  });
}

class PredictionLog {
  final String id;
  final String date;
  final String user;
  final double weightG;
  final String weight;
  final int count;
  final String slr;
  final String poly;
  final String rbf;
  final String primary;
  final double slrMl;
  final double polyMl;
  final double rbfMl;
  final double primaryMl;

  const PredictionLog({
    required this.id,
    required this.date,
    required this.user,
    required this.weightG,
    required this.weight,
    required this.count,
    required this.slr,
    required this.poly,
    required this.rbf,
    required this.primary,
    required this.slrMl,
    required this.polyMl,
    required this.rbfMl,
    required this.primaryMl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'user': user,
        'weightG': weightG,
        'weight': weight,
        'count': count,
        'slr': slr,
        'poly': poly,
        'rbf': rbf,
        'primary': primary,
        'slrMl': slrMl,
        'polyMl': polyMl,
        'rbfMl': rbfMl,
        'primaryMl': primaryMl,
      };

  factory PredictionLog.fromJson(Map<String, dynamic> json) {
    final slrVal = (json['slrMl'] as num?)?.toDouble() ?? 0.0;
    final polyVal = (json['polyMl'] as num?)?.toDouble() ?? 0.0;
    final rbfVal = (json['rbfMl'] as num?)?.toDouble() ?? 0.0;
    final primaryVal = (json['primaryMl'] as num?)?.toDouble() ?? 0.0;

    return PredictionLog(
      id: (json['id'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      user: (json['user'] ?? '').toString(),
      weightG: (json['weightG'] as num?)?.toDouble() ?? 0.0,
      weight: (json['weight'] ?? '').toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
      slr: (json['slr'] ?? '${slrVal.toStringAsFixed(2)} ml').toString(),
      poly: (json['poly'] ??
              (polyVal > 0 ? '${polyVal.toStringAsFixed(2)} ml' : '—'))
          .toString(),
      rbf: (json['rbf'] ??
              (rbfVal > 0 ? '${rbfVal.toStringAsFixed(2)} ml' : '—'))
          .toString(),
      primary: (json['primary'] ??
              json['cbPoly'] ??
              (primaryVal > 0 ? '${primaryVal.toStringAsFixed(2)} ml' : '—'))
          .toString(),
      slrMl: slrVal,
      polyMl: polyVal,
      rbfMl: rbfVal,
      primaryMl: primaryVal,
    );
  }
}

class ModelBenchmark {
  final String name;
  final String shortName;
  final double r2Percent;
  final double maeMl;
  final double rmseMl;
  final double mapePercent;
  final String formula;
  final bool isBest;
  final double? alpha;

  const ModelBenchmark({
    required this.name,
    required this.shortName,
    required this.r2Percent,
    required this.maeMl,
    required this.rmseMl,
    required this.mapePercent,
    required this.formula,
    required this.isBest,
    this.alpha,
  });
}
