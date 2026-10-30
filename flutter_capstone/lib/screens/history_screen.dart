import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/prediction_result.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  final AppUser currentUser;
  final List<PredictionLog> logs;
  final VoidCallback onClearLogs;
  final ValueChanged<String>? onShowToast;

  const HistoryScreen({
    super.key,
    required this.currentUser,
    required this.logs,
    required this.onClearLogs,
    this.onShowToast,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleExportCsv(List<PredictionLog> targetLogs) async {
    final csv = StorageService.buildLogsCsv(targetLogs);
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.download_done_rounded, color: AppColors.emerald700),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'CSV Export Ready (Copied)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate900,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'CSV content has been copied to your clipboard and can be pasted directly into Excel or Google Sheets:',
                style: TextStyle(fontSize: 12.5, color: AppColors.slate600),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    csv,
                    style: const TextStyle(
                      fontFamily: AppColors.monoFont,
                      fontSize: 11,
                      color: AppColors.slate800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald700,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.red50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.red600,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Clear Prediction History?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate900,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear your prediction history records? This cannot be undone.',
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
              'Clear All Records',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onClearLogs();
      widget.onShowToast?.call('Prediction history cleared.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLogs = widget.logs
        .where((l) =>
            widget.currentUser.role == 'admin' ||
            l.user == widget.currentUser.username)
        .toList();

    final q = _searchQuery.trim().toLowerCase();
    final filteredLogs = userLogs.where((l) {
      if (q.isEmpty) return true;
      return l.weight.toLowerCase().contains(q) ||
          l.date.toLowerCase().contains(q) ||
          l.primary.toLowerCase().contains(q) ||
          l.count.toString().contains(q) ||
          l.user.toLowerCase().contains(q);
    }).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 896),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Controls
            Container(
              padding: const EdgeInsets.all(22),
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 20,
                                color: AppColors.emerald700,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Harvest Prediction History',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.slate900,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Review and audit logged calamansi batch calculations and juice yield outputs',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                      if (userLogs.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _handleExportCsv(userLogs),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.slate700,
                                side: const BorderSide(
                                  color: AppColors.slate200,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.download_outlined,
                                size: 15,
                                color: AppColors.slate500,
                              ),
                              label: const Text(
                                'Export CSV',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _confirmClearHistory,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.red700,
                                side: const BorderSide(color: AppColors.red200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
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
                                'Clear History',
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
                  if (userLogs.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.slate900,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Search by weight, calamansi count, or date...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColors.slate400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.slate400,
                        ),
                        filled: true,
                        fillColor: AppColors.slate50,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.slate200),
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
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // History Items List
            if (filteredLogs.isEmpty)
              Container(
                padding: const EdgeInsets.all(42),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.schedule,
                        size: 28,
                        color: AppColors.slate400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No matching predictions found'
                          : 'No predictions yet',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Try searching with a different batch weight or date keyword.'
                          : 'Run a calculation from the Yield Estimator tab to see your extraction records logged here.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filteredLogs.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 560;
                        final leftSide = Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.emerald100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '🍋',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        item.weight,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.slate900,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.emerald100,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.workspace_premium,
                                              size: 11,
                                              color: AppColors.emerald800,
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              'Poly+ Ridge',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.emerald800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        '~${item.count} calamansi',
                                        style: const TextStyle(
                                          fontFamily: AppColors.monoFont,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.emerald700,
                                        ),
                                      ),
                                      const Text(
                                        '•',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.slate400,
                                        ),
                                      ),
                                      Text(
                                        item.date,
                                        style: const TextStyle(
                                          fontFamily: AppColors.monoFont,
                                          fontSize: 11,
                                          color: AppColors.slate400,
                                        ),
                                      ),
                                      if (widget.currentUser.role ==
                                          'admin') ...[
                                        const Text(
                                          '•',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.slate400,
                                          ),
                                        ),
                                        Text(
                                          'User: ${item.user}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: AppColors.slate400,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );

                        final rightSide = Column(
                          crossAxisAlignment: isWide
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.primary,
                              style: const TextStyle(
                                fontFamily: AppColors.monoFont,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.emerald700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'SLR: ${item.slr} · Poly (d=2): ${item.poly} · RBF SVR: ${item.rbf}',
                              style: const TextStyle(
                                fontFamily: AppColors.monoFont,
                                fontSize: 11,
                                color: AppColors.slate400,
                              ),
                            ),
                          ],
                        );

                        if (isWide) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: leftSide),
                              const SizedBox(width: 16),
                              rightSide,
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            leftSide,
                            const SizedBox(height: 12),
                            const Divider(
                              color: AppColors.slate100,
                              height: 1,
                            ),
                            const SizedBox(height: 10),
                            rightSide,
                          ],
                        );
                      },
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
