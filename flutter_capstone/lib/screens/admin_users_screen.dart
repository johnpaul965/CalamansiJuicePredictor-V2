import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/prediction_result.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import 'model_comparison_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  final AppUser currentUser;
  final List<AppUser> users;
  final List<PredictionLog> logs;
  final ValueChanged<List<AppUser>> onUpdateUsers;
  final VoidCallback onClearLogs;
  final VoidCallback onRefreshLogs;
  final VoidCallback onSignOut;
  final ValueChanged<String> onShowToast;

  const AdminUsersScreen({
    super.key,
    required this.currentUser,
    required this.users,
    required this.logs,
    required this.onUpdateUsers,
    required this.onClearLogs,
    required this.onRefreshLogs,
    required this.onSignOut,
    required this.onShowToast,
  });

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _activeTab = 'users'; // 'users' | 'audit' | 'research'

  void _handleToggleStatus(String targetUsername) {
    final updated = widget.users.map((u) {
      if (u.username == targetUsername) {
        final nextStatus = u.status == 'Active' ? 'Suspended' : 'Active';
        return u.copyWith(status: nextStatus);
      }
      return u;
    }).toList();
    widget.onUpdateUsers(updated);
    widget.onShowToast('Updated account status for $targetUsername');
  }

  void _handleToggleRole(String targetUsername) {
    final updated = widget.users.map((u) {
      if (u.username == targetUsername) {
        final nextRole = u.role == 'admin' ? 'user' : 'admin';
        return u.copyWith(role: nextRole);
      }
      return u;
    }).toList();
    widget.onUpdateUsers(updated);
    widget.onShowToast('Updated role for $targetUsername');
  }

  Future<void> _openCreateUserModal() async {
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'user';
    String? errorMsg;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            void submit() {
              final trimmed = usernameCtrl.text.trim().toLowerCase();
              final pass = passwordCtrl.text.trim();
              if (trimmed.isEmpty || pass.isEmpty) {
                setModalState(() => errorMsg = 'Please fill in all fields.');
                return;
              }
              if (pass.length < 4) {
                setModalState(() =>
                    errorMsg = 'Password must be at least 4 characters long.');
                return;
              }
              if (widget.users
                  .any((u) => u.username.toLowerCase() == trimmed)) {
                setModalState(() => errorMsg =
                    'That username already exists in the system.');
                return;
              }

              final now = DateTime.now();
              final joined =
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

              final newUser = AppUser(
                id: 'user-${now.millisecondsSinceEpoch}',
                username: trimmed,
                password: pass,
                role: selectedRole,
                status: 'Active',
                joined: joined,
              );

              widget.onUpdateUsers([...widget.users, newUser]);
              widget.onShowToast('Created $selectedRole account: $trimmed');
              Navigator.of(ctx).pop();
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.person_add_alt_1_outlined,
                        color: AppColors.emerald700,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Create New Account',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate900,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      controller: usernameCtrl,
                      onChanged: (_) {
                        if (errorMsg != null) {
                          setModalState(() => errorMsg = null);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'e.g. farmer_elena',
                        hintStyle: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.slate400,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.slate300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.slate300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.emerald600,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
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
                      controller: passwordCtrl,
                      obscureText: true,
                      onChanged: (_) {
                        if (errorMsg != null) {
                          setModalState(() => errorMsg = null);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Minimum 4 characters',
                        hintStyle: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.slate400,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.slate300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.slate300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.emerald600,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Role',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      items: const [
                        DropdownMenuItem(
                          value: 'user',
                          child: Text(
                            'User (Farmer / Researcher)',
                            style: TextStyle(fontSize: 13.5),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text(
                            'Administrator',
                            style: TextStyle(fontSize: 13.5),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedRole = val);
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.slate300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.emerald600,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    if (errorMsg != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.red50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.red100),
                        ),
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.red600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.slate100,
                    foregroundColor: AppColors.slate700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Create User',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openResetPasswordModal(String targetUsername) async {
    final passCtrl = TextEditingController();
    String? errorMsg;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            void submit() {
              final nextPass = passCtrl.text.trim();
              if (nextPass.length < 4) {
                setModalState(() =>
                    errorMsg = 'Password must be at least 4 characters.');
                return;
              }
              final updated = widget.users.map((u) {
                if (u.username == targetUsername) {
                  return u.copyWith(password: nextPass);
                }
                return u;
              }).toList();
              widget.onUpdateUsers(updated);
              widget.onShowToast(
                'Password reset successfully for $targetUsername',
              );
              Navigator.of(ctx).pop();
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.key_outlined,
                    size: 20,
                    color: AppColors.emerald700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reset Password for $targetUsername',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate900,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'New Password',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      onChanged: (_) {
                        if (errorMsg != null) {
                          setModalState(() => errorMsg = null);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Minimum 4 characters',
                        hintStyle: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.slate400,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.slate300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.emerald600,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    if (errorMsg != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.red50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.red100),
                        ),
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.red600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.slate100,
                    foregroundColor: AppColors.slate700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Update Password',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteUser(String targetUsername) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete User Account?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.slate900,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete user "$targetUsername"? This action cannot be reversed.',
          style: const TextStyle(fontSize: 13.5, color: AppColors.slate600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.slate100,
              foregroundColor: AppColors.slate700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete Account',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final updated =
          widget.users.where((u) => u.username != targetUsername).toList();
      widget.onUpdateUsers(updated);
      widget.onShowToast('Deleted account $targetUsername');
    }
  }

  Future<void> _confirmClearAllLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear All System Logs?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.slate900,
          ),
        ),
        content: const Text(
          'Are you sure you want to erase all prediction history audit logs across the entire system?',
          style: TextStyle(fontSize: 13.5, color: AppColors.slate600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.slate100,
              foregroundColor: AppColors.slate700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Erase All Logs',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onClearLogs();
      widget.onShowToast('All audit logs cleared.');
    }
  }

  Future<void> _exportCsv() async {
    final csv = StorageService.buildLogsCsv(widget.logs);
    await Clipboard.setData(ClipboardData(text: csv));
    widget.onShowToast('CSV audit logs copied to clipboard.');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 460;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          children: [
            // Admin AppBar — auto-adjusts height and scales text without clipping
            Container(
              color: AppColors.slate900,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 12 : 16,
                vertical: 10,
              ),
              constraints: const BoxConstraints(minHeight: 60),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1152),
                  child: Row(
                    children: [
                      Container(
                        width: isCompact ? 36 : 40,
                        height: isCompact ? 36 : 40,
                        decoration: BoxDecoration(
                          color: AppColors.emerald600.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: AppColors.emerald500.withOpacity(0.45),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '🛡️',
                          style: TextStyle(fontSize: isCompact ? 17 : 18),
                        ),
                      ),
                      SizedBox(width: isCompact ? 10 : 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isCompact)
                              const FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Calamansi Yield Predictor',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              )
                            else
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Calamansi Yield Predictor',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.emerald500.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AppColors.emerald500
                                            .withOpacity(0.4),
                                      ),
                                    ),
                                    child: const Text(
                                      'ADMIN CONSOLE',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.emerald300,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                isCompact
                                    ? 'Admin Console • Leyte Normal University'
                                    : 'Leyte Normal University • Tacloban City Study',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isCompact
                                      ? AppColors.emerald300
                                      : AppColors.slate300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: isCompact ? 105 : 160,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 10 : 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.slate800,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.slate700),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.emerald400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                widget.currentUser.username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: widget.onSignOut,
                        tooltip: 'Sign Out',
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: const EdgeInsets.all(6),
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 19,
                          color: AppColors.slate300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Admin Navigation Bar
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.slate200),
                ),
              ),
              width: double.infinity,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1152),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 10 : 16,
                    ),
                    child: Row(
                      children: [
                        _adminNavTab(
                          id: 'users',
                          icon: Icons.people_outline,
                          label: 'User Management',
                          countBadge: widget.users.length,
                        ),
                        const SizedBox(width: 6),
                        _adminNavTab(
                          id: 'audit',
                          icon: Icons.table_chart_outlined,
                          label: 'Batch Audit Logs',
                          countBadge: widget.logs.length,
                        ),
                        const SizedBox(width: 6),
                        _adminNavTab(
                          id: 'research',
                          icon: Icons.shield_outlined,
                          label: 'Research Analytics Portal',
                          iconColor: AppColors.emerald600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isCompact ? 12 : 16,
                  16,
                  isCompact ? 12 : 16,
                  32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1024),
                    child: _buildActiveAdminBody(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminNavTab({
    required String id,
    required IconData icon,
    required String label,
    int? countBadge,
    Color? iconColor,
  }) {
    final active = _activeTab == id;
    return InkWell(
      onTap: () => setState(() => _activeTab = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.emerald700 : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: iconColor ??
                  (active ? AppColors.emerald800 : AppColors.slate500),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.emerald800 : AppColors.slate500,
              ),
            ),
            if (countBadge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$countBadge',
                  style: const TextStyle(
                    fontFamily: AppColors.monoFont,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveAdminBody() {
    if (_activeTab == 'users') {
      return _buildUsersTab();
    }
    if (_activeTab == 'audit') {
      return _buildAuditTab();
    }
    return const ModelComparisonScreen();
  }

  Widget _buildUsersTab() {
    final isCompact = MediaQuery.sizeOf(context).width < 460;
    return Container(
      padding: EdgeInsets.all(isCompact ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Accounts & Access Control',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Manage system credentials, activation status, and role permissions',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _openCreateUserModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                label: const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.slate100, height: 1),
          const SizedBox(height: 6),
          ...widget.users.map((u) {
            final isSelf = u.username == widget.currentUser.username;
            final isAdmin = u.role == 'admin';
            final isSuspended = u.status == 'Suspended';
            final isRootAdmin = u.username == 'admin';
            final initials = u.username.length >= 2
                ? u.username.substring(0, 2).toUpperCase()
                : u.username.toUpperCase();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isAdmin
                                  ? AppColors.emerald100
                                  : AppColors.slate100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isAdmin
                                    ? AppColors.emerald800
                                    : AppColors.slate700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        u.username,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.slate900,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isAdmin
                                              ? AppColors.emerald100
                                              : AppColors.slate100,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          u.role.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: isAdmin
                                                ? AppColors.emerald800
                                                : AppColors.slate600,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSuspended
                                              ? AppColors.red100
                                              : AppColors.emerald50,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          u.status,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isSuspended
                                                ? AppColors.red700
                                                : AppColors.emerald700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Member since ${u.joined}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.slate500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (!isSelf) ...[
                            _smallActionBtn(
                              label: isSuspended ? 'Activate' : 'Suspend',
                              bgColor: isSuspended
                                  ? AppColors.emerald50
                                  : Colors.white,
                              borderColor: isSuspended
                                  ? AppColors.emerald300
                                  : AppColors.slate200,
                              textColor: isSuspended
                                  ? AppColors.emerald800
                                  : AppColors.slate700,
                              onTap: () => _handleToggleStatus(u.username),
                            ),
                            _smallActionBtn(
                              label: isAdmin ? 'Make User' : 'Make Admin',
                              onTap: () => _handleToggleRole(u.username),
                            ),
                            _smallActionBtn(
                              label: 'Reset Password',
                              onTap: () => _openResetPasswordModal(u.username),
                            ),
                          ] else
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'Current Session',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.slate400,
                                ),
                              ),
                            ),
                          if (!isRootAdmin && !isSelf)
                            _smallActionBtn(
                              label: 'Delete',
                              borderColor: AppColors.red200,
                              textColor: AppColors.red600,
                              onTap: () => _confirmDeleteUser(u.username),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.slate100, height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _smallActionBtn({
    required String label,
    required VoidCallback onTap,
    Color bgColor = Colors.white,
    Color borderColor = AppColors.slate200,
    Color textColor = AppColors.slate700,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAuditTab() {
    final isCompact = MediaQuery.sizeOf(context).width < 460;
    return Container(
      padding: EdgeInsets.all(isCompact ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Batch Prediction Audit Logs',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Central audit trail of all batch calculations recorded across field user sessions',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _exportCsv,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald700,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.download_outlined, size: 15),
                    label: const Text(
                      'Export CSV',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (widget.logs.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: _confirmClearAllLogs,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.red700,
                        side: const BorderSide(color: AppColors.red200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 15,
                        color: AppColors.red700,
                      ),
                      label: const Text(
                        'Clear Logs',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.slate100, height: 1),
          const SizedBox(height: 12),
          if (widget.logs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  'No prediction logs recorded in system yet.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.slate400),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 860),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: FlexColumnWidth(1.55),
                    1: FlexColumnWidth(1.15),
                    2: FlexColumnWidth(1.10),
                    3: FlexColumnWidth(1.30),
                    4: FlexColumnWidth(1.15),
                    5: FlexColumnWidth(1.25),
                    6: FlexColumnWidth(1.05),
                    7: FlexColumnWidth(1.15),
                  },
                  border: const TableBorder(
                    top: BorderSide(color: AppColors.slate200),
                    bottom: BorderSide(color: AppColors.slate200),
                    horizontalInside: BorderSide(color: AppColors.slate100),
                  ),
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: AppColors.slate50),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          child: Text(
                            'DATE & TIME',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          child: Text(
                            'USER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          child: Text(
                            'BATCH WEIGHT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          child: Text(
                            'EST. CALAMANSI',
                            style: TextStyle(
                              fontFamily: AppColors.monoFont,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          child: Text(
                            'SIMPLE LINEAR',
                            style: TextStyle(
                              fontFamily: AppColors.monoFont,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          child: Text(
                            'POLY (DEGREE 2)',
                            style: TextStyle(
                              fontFamily: AppColors.monoFont,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          child: Text(
                            'RBF SVR',
                            style: TextStyle(
                              fontFamily: AppColors.monoFont,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          child: Text(
                            'POLY+ RIDGE',
                            style: TextStyle(
                              fontFamily: AppColors.monoFont,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.emerald700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...widget.logs.map((log) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Text(
                              log.date,
                              style: const TextStyle(
                                fontFamily: AppColors.monoFont,
                                fontSize: 12,
                                color: AppColors.slate500,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Text(
                              log.user,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate800,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Text(
                              log.weight,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate900,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Text(
                              '~${log.count} calamansi',
                              style: const TextStyle(
                                fontFamily: AppColors.monoFont,
                                fontSize: 12,
                                color: AppColors.slate700,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Text(
                              log.slr,
                              style: const TextStyle(
                                fontFamily: AppColors.monoFont,
                                fontSize: 12,
                                color: AppColors.slate600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Text(
                              log.poly,
                              style: const TextStyle(
                                fontFamily: AppColors.monoFont,
                                fontSize: 12,
                                color: AppColors.slate600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Text(
                              log.rbf,
                              style: const TextStyle(
                                fontFamily: AppColors.monoFont,
                                fontSize: 12,
                                color: AppColors.slate600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Text(
                              log.primary,
                              style: const TextStyle(
                                fontFamily: AppColors.monoFont,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.emerald700,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
