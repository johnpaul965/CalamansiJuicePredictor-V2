import 'package:flutter/material.dart';
import '../models/prediction_result.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  final ValueChanged<AppUser> onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegister = false;
  bool _showPassword = false;
  String? _error;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _error = null;
    });

    final u = _usernameController.text.trim().toLowerCase();
    final p = _passwordController.text.trim();
    final cp = _confirmPasswordController.text.trim();

    if (u.isEmpty) {
      setState(() => _error = 'Please enter a username.');
      return;
    }
    if (p.isEmpty) {
      setState(() => _error = 'Please enter a password.');
      return;
    }

    final users = await StorageService.getUsers();

    if (_isRegister) {
      if (p.length < 4) {
        setState(() => _error = 'Password must be at least 4 characters long.');
        return;
      }
      if (p != cp) {
        setState(() => _error = 'Passwords do not match. Please verify.');
        return;
      }
      if (users.any((x) => x.username.toLowerCase() == u)) {
        setState(() => _error =
            'Username already registered. Please sign in or pick another.');
        return;
      }

      final now = DateTime.now();
      final joinedStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final newUser = AppUser(
        id: 'user-${now.millisecondsSinceEpoch}',
        username: u,
        password: p,
        role: 'user',
        status: 'Active',
        joined: joinedStr,
      );

      final updated = <AppUser>[...users, newUser];
      await StorageService.saveUsers(updated);
      widget.onLoginSuccess(newUser);
    } else {
      AppUser? existing;
      for (final x in users) {
        if (x.username.toLowerCase() == u && x.password == p) {
          existing = x;
          break;
        }
      }
      if (existing == null) {
        setState(() => _error =
            'Incorrect username or password. Please verify and try again.');
        return;
      }
      if (existing.status == 'Suspended') {
        setState(() =>
            _error = 'This account has been suspended by an Administrator.');
        return;
      }
      widget.onLoginSuccess(existing);
    }
  }

  Future<void> _handleQuickFill(String username, String password) async {
    setState(() {
      _isRegister = false;
      _error = null;
      _usernameController.text = username;
      _passwordController.text = password;
    });
    final users = await StorageService.getUsers();
    for (final x in users) {
      if (x.username.toLowerCase() == username.toLowerCase() &&
          x.password == password) {
        if (x.status == 'Suspended') {
          setState(() =>
              _error = 'This account has been suspended by an Administrator.');
          return;
        }
        widget.onLoginSuccess(x);
        return;
      }
    }
    await _handleSubmit();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 13.5),
      prefixIcon: Icon(prefixIcon, size: 18, color: AppColors.slate400),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.slate300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.emerald600, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 380;
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Container(
                padding: EdgeInsets.all(isCompact ? 20 : 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.slate900.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo Badge
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.emerald100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '🍋',
                          style: TextStyle(fontSize: 28, height: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Headings
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Calamansi Yield Predictor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate900,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Leyte Normal University • Tacloban City Harvest Study',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.emerald800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Predict pure juice extraction yield using trained regression algorithms',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.slate500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Segmented Auth Control
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _isRegister = false;
                                _error = null;
                              }),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: !_isRegister
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                  boxShadow: !_isRegister
                                      ? [
                                          BoxShadow(
                                            color: AppColors.slate900
                                                .withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: !_isRegister
                                        ? AppColors.emerald800
                                        : AppColors.slate600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _isRegister = true;
                                _error = null;
                              }),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: _isRegister
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                  boxShadow: _isRegister
                                      ? [
                                          BoxShadow(
                                            color: AppColors.slate900
                                                .withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _isRegister
                                        ? AppColors.emerald800
                                        : AppColors.slate600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Username
                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.slate900,
                      ),
                      onSubmitted: (_) => _handleSubmit(),
                      decoration: _inputDecoration(
                        hint: 'Enter your username',
                        prefixIcon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Password
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.slate900,
                      ),
                      onSubmitted: (_) => _handleSubmit(),
                      decoration: _inputDecoration(
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.slate400,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                    ),

                    if (_isRegister) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_showPassword,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.slate900,
                        ),
                        onSubmitted: (_) => _handleSubmit(),
                        decoration: _inputDecoration(
                          hint: 'Re-enter password',
                          prefixIcon: Icons.lock_outline,
                        ),
                      ),
                    ],

                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.red50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.red200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 16,
                              color: AppColors.red500,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.red700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald700,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isRegister
                            ? 'Create Account & Sign In'
                            : 'Sign In to Predictor',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // DEMO ACCOUNTS DIVIDER
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppColors.slate200, height: 1),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'DEMO ACCOUNTS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate500,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: AppColors.slate200, height: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // DEMO ACCOUNTS BOX
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.eco_outlined,
                                    size: 15,
                                    color: AppColors.emerald600,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'User:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.slate600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border:
                                        Border.all(color: AppColors.slate200),
                                  ),
                                  child: const Text(
                                    'farmer_juan / user123',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: AppColors.monoFont,
                                      fontSize: 11,
                                      color: AppColors.slate800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_user_outlined,
                                    size: 15,
                                    color: AppColors.amber600,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Admin:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.slate600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border:
                                        Border.all(color: AppColors.slate200),
                                  ),
                                  child: const Text(
                                    'admin / admin123',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: AppColors.monoFont,
                                      fontSize: 11,
                                      color: AppColors.slate800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick Fill Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _handleQuickFill('farmer_juan', 'user123'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.slate700,
                              side: const BorderSide(color: AppColors.slate300),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.eco_outlined,
                              size: 15,
                              color: AppColors.emerald600,
                            ),
                            label: const Text(
                              'Quick User',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _handleQuickFill('admin', 'admin123'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.amber900,
                              side: const BorderSide(color: AppColors.amber300),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.verified_user_outlined,
                              size: 15,
                              color: AppColors.amber600,
                            ),
                            label: const Text(
                              'Quick Admin',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
