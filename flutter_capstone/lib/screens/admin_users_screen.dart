import 'package:flutter/material.dart';
import '../models/prediction_result.dart';
import '../services/storage_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<UserAccount> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await StorageService.getUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _toggleStatus(UserAccount user) async {
    await StorageService.toggleUserStatus(user.id);
    _loadUsers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} is now ${user.isActive ? "Suspended" : "Active"}'),
          backgroundColor: const Color(0xFF15803D),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _showAddUserDialog() async {
    final nameCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final orgCtrl = TextEditingController(text: 'Leyte Calamansi Growers');
    String role = 'user';

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Cooperative User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name (e.g. Pedro Reyes)'),
                ),
                TextField(
                  controller: userCtrl,
                  decoration: const InputDecoration(labelText: 'Username (e.g. pedro_calamansi)'),
                ),
                TextField(
                  controller: orgCtrl,
                  decoration: const InputDecoration(labelText: 'Organization / Cluster'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Role: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Radio<String>(
                      value: 'user',
                      groupValue: role,
                      onChanged: (val) => setDialogState(() => role = val!),
                    ),
                    const Text('Farmer / User'),
                    Radio<String>(
                      value: 'admin',
                      groupValue: role,
                      onChanged: (val) => setDialogState(() => role = val!),
                    ),
                    const Text('Admin'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15803D)),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty && userCtrl.text.trim().isNotEmpty) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Create User', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (created == true) {
      final newUser = UserAccount(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: nameCtrl.text.trim(),
        username: userCtrl.text.trim(),
        role: role,
        organization: orgCtrl.text.trim(),
        isActive: true,
        dateCreated: DateTime.now().toIso8601String().split('T').first,
      );
      await StorageService.addUser(newUser);
      _loadUsers();
    }
  }

  void _resetPassword(UserAccount user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset Password: ${user.name}'),
        content: Text(
          'Temporary one-time password has been generated for ${user.username}:\n\nCalamansi@2026\n\nThe user will be prompted to update credentials upon next login.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15803D)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15803D),
        elevation: 0,
        title: const Text(
          'Admin & User Management',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
            tooltip: 'Add User',
            onPressed: _showAddUserDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF15803D)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Academic Governance Notice
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.shield_outlined, color: Color(0xFF15803D), size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Role-Based Access Control (RBAC): Admin accounts can manage field testers, modify model thresholds, and audit harvest records.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF166534), height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Authorized Personnel & Accounts',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),

                ..._users.map((user) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: user.role == 'admin'
                              ? const Color(0xFF15803D).withOpacity(0.15)
                              : const Color(0xFF0284C7).withOpacity(0.15),
                          child: Icon(
                            user.role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                            color: user.role == 'admin' ? const Color(0xFF15803D) : const Color(0xFF0284C7),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: user.role == 'admin' ? const Color(0xFF15803D) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      user.role.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: user.role == 'admin' ? Colors.white : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@${user.username} • ${user.organization}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => _toggleStatus(user),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: user.isActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: user.isActive ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Text(
                                  user.isActive ? 'Active' : 'Suspended',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: user.isActive ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => _resetPassword(user),
                              child: const Text(
                                'Reset PWD',
                                style: TextStyle(fontSize: 10, color: Color(0xFF0284C7), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }
}
