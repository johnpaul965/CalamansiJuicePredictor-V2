import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prediction_result.dart';
import 'prediction_service.dart';

class StorageService {
  StorageService._();

  static const String _usersKey = 'calamansi_app_users_v2';
  static const String _logsKey = 'calamansi_prediction_logs_v2';
  static const String _sessionKey = 'calamansi_active_user_v2';

  static const List<AppUser> initialUsers = [
    AppUser(
      id: 'user-1',
      username: 'admin',
      password: 'admin123',
      role: 'admin',
      status: 'Active',
      joined: '2026-09-01',
    ),
    AppUser(
      id: 'user-2',
      username: 'farmer_juan',
      password: 'user123',
      role: 'user',
      status: 'Active',
      joined: '2026-09-02',
    ),
    AppUser(
      id: 'user-3',
      username: 'tacloban_vendor',
      password: 'user123',
      role: 'user',
      status: 'Active',
      joined: '2026-09-03',
    ),
  ];

  static List<PredictionLog> _buildInitialLogs() {
    final c5000 = PredictionService.runCalculationEngine(5000);
    final c10000 = PredictionService.runCalculationEngine(10000);
    final c1000 = PredictionService.runCalculationEngine(1000);

    return [
      PredictionLog(
        id: 'log-101',
        date: '2026-10-24 14:32',
        user: 'farmer_juan',
        weightG: 5000,
        weight: '5.00 kg (5000g)',
        count: c5000.count,
        slr: '${c5000.slrTotalMl.toStringAsFixed(2)} ml',
        poly: '${c5000.polyTotalMl.toStringAsFixed(2)} ml',
        rbf: '${c5000.rbfTotalMl.toStringAsFixed(2)} ml',
        primary: '${c5000.primaryTotalMl.toStringAsFixed(2)} ml',
        slrMl: c5000.slrTotalMl,
        polyMl: c5000.polyTotalMl,
        rbfMl: c5000.rbfTotalMl,
        primaryMl: c5000.primaryTotalMl,
      ),
      PredictionLog(
        id: 'log-102',
        date: '2026-10-23 09:15',
        user: 'tacloban_vendor',
        weightG: 10000,
        weight: '10.00 kg (10000g)',
        count: c10000.count,
        slr: '${c10000.slrTotalMl.toStringAsFixed(2)} ml',
        poly: '${c10000.polyTotalMl.toStringAsFixed(2)} ml',
        rbf: '${c10000.rbfTotalMl.toStringAsFixed(2)} ml',
        primary: '${c10000.primaryTotalMl.toStringAsFixed(2)} ml',
        slrMl: c10000.slrTotalMl,
        polyMl: c10000.polyTotalMl,
        rbfMl: c10000.rbfTotalMl,
        primaryMl: c10000.primaryTotalMl,
      ),
      PredictionLog(
        id: 'log-103',
        date: '2026-10-22 16:40',
        user: 'farmer_juan',
        weightG: 1000,
        weight: '1.00 kg (1000g)',
        count: c1000.count,
        slr: '${c1000.slrTotalMl.toStringAsFixed(2)} ml',
        poly: '${c1000.polyTotalMl.toStringAsFixed(2)} ml',
        rbf: '${c1000.rbfTotalMl.toStringAsFixed(2)} ml',
        primary: '${c1000.primaryTotalMl.toStringAsFixed(2)} ml',
        slrMl: c1000.slrTotalMl,
        polyMl: c1000.polyTotalMl,
        rbfMl: c1000.rbfTotalMl,
        primaryMl: c1000.primaryTotalMl,
      ),
    ];
  }

  static Future<List<AppUser>> getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_usersKey);
      if (raw == null || raw.isEmpty) {
        await saveUsers(initialUsers);
        return List<AppUser>.from(initialUsers);
      }
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return List<AppUser>.from(initialUsers);
    }
  }

  static Future<void> saveUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  static Future<List<PredictionLog>> getLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_logsKey);
      if (raw == null || raw.isEmpty) {
        final seeded = _buildInitialLogs();
        await saveLogs(seeded);
        return seeded;
      }
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => PredictionLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _buildInitialLogs();
    }
  }

  static Future<void> saveLogs(List<PredictionLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _logsKey,
      jsonEncode(logs.map((l) => l.toJson()).toList()),
    );
  }

  static Future<List<PredictionLog>> addLog(PredictionLog log) async {
    final logs = await getLogs();
    logs.insert(0, log);
    if (logs.length > 200) {
      logs.removeRange(200, logs.length);
    }
    await saveLogs(logs);
    return logs;
  }

  static Future<void> clearLogs() async {
    await saveLogs(<PredictionLog>[]);
  }

  static Future<AppUser?> getSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionKey);
      if (raw == null || raw.isEmpty) return null;
      return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setSavedSession(AppUser? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_sessionKey);
    } else {
      await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
    }
  }

  static String buildLogsCsv(List<PredictionLog> logs) {
    const headers = [
      'Log ID',
      'Date & Time',
      'User',
      'Batch Weight',
      'Est. Calamansi Count',
      'Simple Linear (mL)',
      'Polynomial Degree 2 (mL)',
      'RBF SVR (mL)',
      'Poly+ Ridge (mL)',
    ];

    String sanitizeCell(Object? val) {
      String str = (val ?? '').toString();
      if (RegExp(r'^[=+\-@\t\r]').hasMatch(str)) {
        str = "'$str";
      }
      final escaped = str.replaceAll('"', '""');
      return '"$escaped"';
    }

    final lines = <String>[
      headers.map(sanitizeCell).join(','),
      ...logs.map((l) => [
            l.id,
            l.date,
            l.user,
            l.weight,
            l.count,
            l.slr,
            l.poly,
            l.rbf,
            l.primary,
          ].map(sanitizeCell).join(',')),
    ];
    return lines.join('\n');
  }
}
