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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 460;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          children: [
            // Top Emerald AppBar — auto-scales title and adapts height cleanly
            Container(
              color: AppColors.emerald800,
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
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '🍋',
                          style: TextStyle(fontSize: isCompact ? 19 : 22),
                        ),
                      ),
                      SizedBox(width: isCompact ? 10 : 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            ),
                            const SizedBox(height: 1),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                isCompact
                                    ? 'Leyte Normal University'
                                    : 'Leyte Normal University • Tacloban City Study',
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.emerald100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: isCompact ? 118 : 180,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 9 : 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.emerald900.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.emerald700.withOpacity(0.7),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isCompact) ...[
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
                            ] else ...[
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.emerald400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Text(
                                widget.currentUser.username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
                          color: AppColors.emerald100,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation Tabs Bar
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
                        _navTab(
                          id: 'predict',
                          icon: Icons.bolt,
                          activeIconColor: AppColors.amber500,
                          label: 'Yield Estimator',
                        ),
                        const SizedBox(width: 4),
                        _navTab(
                          id: 'profit',
                          icon: Icons.monetization_on_outlined,
                          activeIconColor: AppColors.emerald600,
                          label: 'Profit Calculator',
                          tagText: isCompact ? null : 'Farmgate vs Bottled',
                          tagBg: AppColors.emerald100,
                          tagColor: AppColors.emerald800,
                        ),
                        const SizedBox(width: 4),
                        _navTab(
                          id: 'dost-recipe',
                          icon: Icons.science_outlined,
                          activeIconColor: AppColors.teal600,
                          label: 'DOST Sugar Recipe',
                          tagText: isCompact ? null : 'Juice Concentrate',
                          tagBg: AppColors.teal100,
                          tagColor: AppColors.teal800,
                        ),
                        const SizedBox(width: 4),
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
                padding: EdgeInsets.fromLTRB(
                  isCompact ? 12 : 16,
                  16,
                  isCompact ? 12 : 16,
                  32,
                ),
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
