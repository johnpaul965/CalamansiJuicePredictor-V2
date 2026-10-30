import 'package:flutter/material.dart';
import '../models/prediction_result.dart';
import '../theme/app_colors.dart';
import 'dost_formulator_screen.dart';
import 'history_screen.dart';
import 'predict_screen.dart';
import 'profit_calculator_screen.dart';

class UserScaffold extends StatefulWidget {
  final AppUser currentUser;
  final List<PredictionLog> logs;
  final VoidCallback onRefreshLogs;
  final VoidCallback onClearLogs;
  final VoidCallback onSignOut;
  final ValueChanged<String> onShowToast;

  const UserScaffold({
    super.key,
    required this.currentUser,
    required this.logs,
    required this.onRefreshLogs,
    required this.onClearLogs,
    required this.onSignOut,
    required this.onShowToast,
  });

  @override
  State<UserScaffold> createState() => _UserScaffoldState();
}

class _UserScaffoldState extends State<UserScaffold> {
  String _activeTab = 'predict'; // 'predict' | 'profit' | 'dost-recipe' | 'history'
  double _sharedWeightKg = 10.0;
  double _sharedJuiceMl = 4120.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          children: [
            // Top Emerald AppBar (matches UserScaffold.tsx header)
            Container(
              color: AppColors.emerald800,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 64,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1152),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '🍋',
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Calamansi Yield Predictor',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    'Leyte Normal University • Tacloban City Study',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.emerald200,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.emerald900.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.emerald700.withOpacity(0.6),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.emerald500,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    widget.currentUser.role.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.emerald950,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  widget.currentUser.username,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            onPressed: widget.onSignOut,
                            tooltip: 'Sign Out',
                            icon: const Icon(
                              Icons.logout_rounded,
                              size: 19,
                              color: AppColors.emerald200,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation Tabs Bar (matches UserScaffold.tsx nav)
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _navTab(
                          id: 'predict',
                          icon: Icons.bolt,
                          activeIconColor: AppColors.amber500,
                          label: 'Yield Estimator',
                        ),
                        const SizedBox(width: 6),
                        _navTab(
                          id: 'profit',
                          icon: Icons.monetization_on_outlined,
                          activeIconColor: AppColors.emerald600,
                          label: 'Money & Profit Calculator',
                          tagText: 'Farmgate vs Bottled',
                          tagBg: AppColors.emerald100,
                          tagColor: AppColors.emerald800,
                        ),
                        const SizedBox(width: 6),
                        _navTab(
                          id: 'dost-recipe',
                          icon: Icons.science_outlined,
                          activeIconColor: AppColors.teal600,
                          label: 'DOST Sugar Recipe',
                          tagText: 'Juice Concentrate',
                          tagBg: AppColors.teal100,
                          tagColor: AppColors.teal800,
                        ),
                        const SizedBox(width: 6),
                        _navTab(
                          id: 'history',
                          icon: Icons.schedule,
                          activeIconColor: AppColors.emerald800,
                          label: 'Harvest History',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1024),
                    child: _buildActiveUserTab(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navTab({
    required String id,
    required IconData icon,
    required Color activeIconColor,
    required String label,
    String? tagText,
    Color? tagBg,
    Color? tagColor,
  }) {
    final active = _activeTab == id;
    return InkWell(
      onTap: () => setState(() => _activeTab = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
              size: 17,
              color: active ? activeIconColor : AppColors.slate500,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.emerald800 : AppColors.slate500,
              ),
            ),
            if (tagText != null && tagBg != null && tagColor != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  tagText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: tagColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveUserTab() {
    switch (_activeTab) {
      case 'profit':
        return ProfitCalculatorScreen(
          initialWeightKg: _sharedWeightKg,
          initialJuiceMl: _sharedJuiceMl,
          onNavigateToDost: (juiceMl) {
            setState(() {
              _sharedJuiceMl = juiceMl;
              _activeTab = 'dost-recipe';
            });
          },
        );
      case 'dost-recipe':
        return DostFormulatorScreen(
          initialJuiceMl: _sharedJuiceMl,
          initialWeightKg: _sharedWeightKg,
          onNavigateToProfit: (weightKg, _) {
            setState(() {
              _sharedWeightKg = weightKg;
              _activeTab = 'profit';
            });
          },
        );
      case 'history':
        return HistoryScreen(
          currentUser: widget.currentUser,
          logs: widget.logs,
          onClearLogs: widget.onClearLogs,
          onShowToast: widget.onShowToast,
        );
      case 'predict':
      default:
        return PredictScreen(
          currentUser: widget.currentUser,
          logs: widget.logs,
          onRefreshLogs: widget.onRefreshLogs,
          onNavigateToProfit: (weightKg, juiceMl) {
            setState(() {
              _sharedWeightKg = weightKg;
              _sharedJuiceMl = juiceMl;
              _activeTab = 'profit';
            });
          },
          onNavigateToDost: (juiceMl, weightKg) {
            setState(() {
              _sharedJuiceMl = juiceMl;
              _sharedWeightKg = weightKg;
              _activeTab = 'dost-recipe';
            });
          },
        );
    }
  }
}
