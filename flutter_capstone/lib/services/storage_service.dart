import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prediction_result.dart';

class StorageService {
  static const String _historyKey = 'calamansi_prediction_logs_v2';
  static const String _usersKey = 'calamansi_user_accounts_v2';
  static const String _activeUserKey = 'calamansi_active_user_v2';

  // Initial seed user accounts
  static final List<UserAccount> _defaultUsers = [
    UserAccount(
      id: 'usr_1',
      name: 'Farmer Juan',
      username: 'farmer_juan',
      role: 'user',
      organization: 'Leyte Calamansi Growers Cooperative',
      isActive: true,
      dateCreated: '2026-01-15',
    ),
    UserAccount(
      id: 'usr_2',
      name: 'Dr. Santos',
      username: 'admin_santos',
      role: 'admin',
      organization: 'Leyte Normal University Thesis Panel',
      isActive: true,
      dateCreated: '2026-01-10',
    ),
    UserAccount(
      id: 'usr_3',
      name: 'Maria Elena',
      username: 'maria_grower',
      role: 'user',
      organization: 'Barangay San Jose Farm Cluster',
      isActive: true,
      dateCreated: '2026-02-01',
    ),
  ];

  // Active User State
  static Future<UserAccount> getActiveUser() async {
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getString(_activeUserKey) ?? 'usr_1';
    final users = await getUsers();
    return users.firstWhere(
      (u) => u.id == activeId,
      orElse: () => users.first,
    );
  }

  static Future<void> setActiveUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUserKey, userId);
  }

  // User Accounts Management
  static Future<List<UserAccount>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) {
      // Seed default users
      await saveUsers(_defaultUsers);
      return List.from(_defaultUsers);
    }
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => UserAccount.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return List.from(_defaultUsers);
    }
  }

  static Future<void> saveUsers(List<UserAccount> users) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, raw);
  }

  static Future<void> toggleUserStatus(String userId) async {
    final users = await getUsers();
    final user = users.firstWhere((u) => u.id == userId);
    user.isActive = !user.isActive;
    await saveUsers(users);
  }

  static Future<void> addUser(UserAccount newUser) async {
    final users = await getUsers();
    users.add(newUser);
    await saveUsers(users);
  }

  // History Logs
  static Future<List<PredictionLogItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) {
      // Provide some initial verified thesis sample logs
      return [
        PredictionLogItem(
          id: 'log_thesis_01',
          date: '2026-10-25 14:30',
          user: 'Farmer Juan',
          weightG: 10000.0,
          weightFormatted: '10.00 kg',
          count: 788,
          proposedMl: 3412.5,
          slrMl: 3340.2,
          polyMl: 3180.0,
          svrMl: 3315.4,
          bottles330: 10.34,
          bottles500: 6.82,
          bottles1000: 3.41,
        ),
        PredictionLogItem(
          id: 'log_thesis_02',
          date: '2026-10-26 09:15',
          user: 'Dr. Santos',
          weightG: 5000.0,
          weightFormatted: '5.00 kg',
          count: 394,
          proposedMl: 1706.2,
          slrMl: 1670.1,
          polyMl: 1590.0,
          svrMl: 1657.7,
          bottles330: 5.17,
          bottles500: 3.41,
          bottles1000: 1.71,
        ),
      ];
    }
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => PredictionLogItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addHistoryItem(PredictionLogItem item) async {
    final current = await getHistory();
    current.insert(0, item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(current.map((e) => e.toJson()).toList()));
  }

  static Future<void> deleteHistoryItem(String id) async {
    final current = await getHistory();
    current.removeWhere((e) => e.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(current.map((e) => e.toJson()).toList()));
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // CSV Export Generator
  static Future<String> generateCsvExport() async {
    final logs = await getHistory();
    final buffer = StringBuffer();
    buffer.writeln('ID,Timestamp,User,Total Weight (g),Fruit Count,Proposed Yield (mL),SLR Yield (mL),Poly d=2 Yield (mL),SVR Yield (mL),330mL Bottles,500mL Bottles,1L Bottles');
    for (final l in logs) {
      buffer.writeln('${l.id},"${l.date}","${l.user}",${l.weightG},${l.count},${l.proposedMl.toStringAsFixed(2)},${l.slrMl.toStringAsFixed(2)},${l.polyMl.toStringAsFixed(2)},${l.svrMl.toStringAsFixed(2)},${l.bottles330.toStringAsFixed(2)},${l.bottles500.toStringAsFixed(2)},${l.bottles1000.toStringAsFixed(2)}');
    }
    return buffer.toString();
  }
}
