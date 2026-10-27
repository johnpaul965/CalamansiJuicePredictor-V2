import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/predict_screen.dart';
import 'screens/model_comparison_screen.dart';
import 'screens/history_screen.dart';
import 'screens/admin_users_screen.dart';
import 'services/storage_service.dart';
import 'models/prediction_result.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CalamansiPredictorApp());
}

class CalamansiPredictorApp extends StatelessWidget {
  const CalamansiPredictorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calamansi Yield Predictor V2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF15803D), // Forest Emerald
          primary: const Color(0xFF15803D),
          secondary: const Color(0xFF047857),
          surface: const Color(0xFFF8FAFC),
        ),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF15803D),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const RootNavigationContainer(),
    );
  }
}

class RootNavigationContainer extends StatefulWidget {
  const RootNavigationContainer({Key? key}) : super(key: key);

  @override
  State<RootNavigationContainer> createState() => _RootNavigationContainerState();
}

class _RootNavigationContainerState extends State<RootNavigationContainer> {
  int _currentIndex = 0;
  UserAccount? _currentUser;
  List<UserAccount> _allUsers = [];

  final List<Widget> _screens = const [
    PredictScreen(),
    ModelComparisonScreen(),
    HistoryScreen(),
    AdminUsersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserContext();
  }

  Future<void> _loadUserContext() async {
    final current = await StorageService.getActiveUser();
    final users = await StorageService.getUsers();
    if (mounted) {
      setState(() {
        _currentUser = current;
        _allUsers = users;
      });
    }
  }

  Future<void> _switchUser(UserAccount target) async {
    await StorageService.setActiveUser(target.id);
    await _loadUserContext();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched role to ${target.name} (${target.role.toUpperCase()})'),
          backgroundColor: const Color(0xFF15803D),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showRoleSwitcherDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Switch User Persona / Role',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Icon(Icons.swap_horiz, color: Color(0xFF15803D)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Toggle between field farmer and academic thesis admin testing:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ..._allUsers.map((user) {
                final isSelected = user.id == _currentUser?.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: user.role == 'admin'
                        ? const Color(0xFF15803D).withOpacity(0.15)
                        : const Color(0xFF0284C7).withOpacity(0.15),
                    child: Icon(
                      user.role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                      color: user.role == 'admin' ? const Color(0xFF15803D) : const Color(0xFF0284C7),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? const Color(0xFF15803D) : const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text('${user.role.toUpperCase()} • ${user.organization}'),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF15803D))
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    _switchUser(user);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF15803D),
          unselectedItemColor: const Color(0xFF64748B),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate),
              label: 'Predictor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: '4 Models',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts_outlined),
              activeIcon: Icon(Icons.manage_accounts),
              label: 'Admin',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: const Color(0xFF15803D),
        foregroundColor: Colors.white,
        tooltip: 'Switch User Persona',
        onPressed: _showRoleSwitcherDialog,
        child: const Icon(Icons.switch_account),
      ),
    );
  }
}
