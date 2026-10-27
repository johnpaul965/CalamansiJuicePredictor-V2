import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prediction_result.dart';

class StorageService {
  static const String _keyLogs = 'calamansi_harvest_logs_v2';

  static Future<List<HarvestLog>> getLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_keyLogs);
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => HarvestLog.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveLog(HarvestLog log) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<HarvestLog> existing = await getLogs();
      existing.insert(0, log);
      final String encoded = jsonEncode(existing.map((e) => e.toJson()).toList());
      await prefs.setString(_keyLogs, encoded);
    } catch (_) {}
  }

  static Future<void> clearLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLogs);
    } catch (_) {}
  }

  static String exportToCsv(List<HarvestLog> logs) {
    final StringBuffer sb = StringBuffer();
    sb.writeln('ID,Date,BatchWeight,FruitCount,ProposedJuiceMl,SlrJuiceMl,PolyJuiceMl,MlrJuiceMl');
    for (final log in logs) {
      sb.writeln(
        '"${log.id}","${log.dateTime}","${log.weightText}",${log.fruitCount},'
        '${log.proposedMl.toStringAsFixed(2)},${log.slrMl.toStringAsFixed(2)},'
        '${log.polyMl.toStringAsFixed(2)},${log.mlrMl.toStringAsFixed(2)}',
      );
    }
    return sb.toString();
  }
}
