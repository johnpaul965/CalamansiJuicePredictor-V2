import 'dart:async';
import 'package:flutter/material.dart';
import 'models/prediction_result.dart';
import 'screens/admin_users_screen.dart';
import 'screens/login_screen.dart';
import 'screens/user_scaffold.dart';
import 'services/storage_service.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalamansiYieldApp());
}

class CalamansiYieldApp extends StatelessWidget {
  const CalamansiYieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calamansi Yield Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.slate50,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emerald700,
          primary: AppColors.emerald700,
          surface: Colors.white,
        ),
      ),
      home: const AppRootController(),
    );
  }
}

class AppRootController extends StatefulWidget {
  const AppRootController({super.key});

  @override
  State<AppRootController> createState() => _AppRootControllerState();
}

class _AppRootControllerState extends State<AppRootController> {
  bool _loading = true;
  AppUser? _currentUser;
  List<AppUser> _users = <AppUser>[];
  List<PredictionLog> _logs = <PredictionLog>[];
  String? _toastMessage;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _initStateFromStorage();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  Future<void> _initStateFromStorage() async {
    final loadedUsers = await StorageService.getUsers();
    final loadedLogs = await StorageService.getLogs();
    final savedSession = await StorageService.getSavedSession();

    AppUser? validSession;
    if (savedSession != null) {
      for (final u in loadedUsers) {
        if (u.username == savedSession.username && u.status == 'Active') {
          validSession = u;
          break;
        }
      }
      if (validSession == null) {
        await StorageService.setSavedSession(null);
      }
    }

    if (!mounted) return;
    setState(() {
      _users = loadedUsers;
      _logs = loadedLogs;
      _currentUser = validSession;
      _loading = false;
    });
  }

  void _showToast(String msg) {
    _toastTimer?.cancel();
    setState(() {
      _toastMessage = msg;
    });
    _toastTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _toastMessage = null;
        });
      }
    });
  }

  Future<void> _handleLoginSuccess(AppUser user) async {
    await StorageService.setSavedSession(user);
    final freshUsers = await StorageService.getUsers();
    final freshLogs = await StorageService.getLogs();
    if (!mounted) return;
    setState(() {
      _users = freshUsers;
      _logs = freshLogs;
      _currentUser = user;
    });
    _showToast('Signed in as ${user.username}');
  }

  Future<void> _handleSignOut() async {
    await StorageService.setSavedSession(null);
    if (!mounted) return;
    setState(() {
      _currentUser = null;
    });
    _showToast('Signed out successfully');
  }

  Future<void> _handleUpdateUsers(List<AppUser> newUsers) async {
    await StorageService.saveUsers(newUsers);
    if (!mounted) return;
    setState(() {
      _users = newUsers;
      if (_currentUser != null) {
        for (final u in newUsers) {
          if (u.username == _currentUser!.username) {
            _currentUser = u;
            StorageService.setSavedSession(u);
            break;
          }
        }
      }
    });
  }

  Future<void> _handleRefreshLogs() async {
    final freshLogs = await StorageService.getLogs();
    if (!mounted) return;
    setState(() {
      _logs = freshLogs;
    });
  }

  Future<void> _handleClearLogs() async {
    await StorageService.clearLogs();
    if (!mounted) return;
    setState(() {
      _logs = <PredictionLog>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.slate50,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.emerald700),
        ),
      );
    }

    final Widget screen;
    if (_currentUser == null) {
      screen = LoginScreen(onLoginSuccess: _handleLoginSuccess);
    } else if (_currentUser!.role == 'admin') {
      screen = AdminUsersScreen(
        currentUser: _currentUser!,
        users: _users,
        logs: _logs,
        onUpdateUsers: _handleUpdateUsers,
        onClearLogs: _handleClearLogs,
        onRefreshLogs: _handleRefreshLogs,
        onSignOut: _handleSignOut,
        onShowToast: _showToast,
      );
    } else {
      screen = UserScaffold(
        currentUser: _currentUser!,
        logs: _logs,
        onRefreshLogs: _handleRefreshLogs,
        onClearLogs: _handleClearLogs,
        onSignOut: _handleSignOut,
        onShowToast: _showToast,
      );
    }

    return Stack(
      children: [
        screen,
        if (_toastMessage != null)
          Positioned(
            right: 20,
            bottom: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.slate900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate700),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.slate950.withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 17,
                      color: AppColors.emerald400,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _toastMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _toastMessage = null),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.slate400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
