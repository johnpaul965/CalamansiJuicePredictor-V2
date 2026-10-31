import 'package:flutter/material.dart';
import '../models/prediction_result.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';

class PredictScreen extends StatefulWidget {
  final AppUser currentUser;
  final List<PredictionLog> logs;
  final VoidCallback onRefreshLogs;
  final void Function(double juiceMl, double weightKg)? onNavigateToDost;

  const PredictScreen({
    super.key,
    required this.currentUser,
    required this.logs,
    required this.onRefreshLogs,
    this.onNavigateToDost,
  });

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  String _unit = 'kg'; // 'kg' | 'g'
  final TextEditingController _weightController =
      TextEditingController(text: '5');
  String? _error;
  PredictionResult? _result;
  String _activeModelView = 'primary'; // 'primary' | 'compare'

  @override
  void initState() {
    super.initState();
    _result = PredictionService.runCalculationEngine(5000);
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _handleUnitToggle(String newUnit) {
    if (newUnit == _unit) return;
    final currentVal = double.tryParse(_weightController.text.trim());
    if (currentVal != null && currentVal > 0) {
      if (newUnit == 'g') {
        _weightController.text = (currentVal * 1000).toStringAsFixed(0);
      } else {
        _weightController.text = (currentVal / 1000).toStringAsFixed(2);
      }
    }
    setState(() {
      _unit = newUnit;
      _error = null;
    });
  }

  Future<void> _handleExecute({double? customWeight}) async {
    setState(() {
      _error = null;
    });

    final rawVal = customWeight ??
        double.tryParse(_weightController.text.trim());

    if (rawVal == null || rawVal <= 0 || !rawVal.isFinite) {
      setState(() {
        _error = 'Please enter a valid batch weight greater than zero.';
      });
      return;
    }

    final weightG = _unit == 'kg' ? rawVal * 1000.0 : rawVal;
    final calc = PredictionService.runCalculationEngine(weightG);

    setState(() {
      _result = calc;
    });

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final weightDisplay = weightG >= 1000
        ? '${(weightG / 1000).toStringAsFixed(2)} kg (${weightG.toStringAsFixed(0)}g)'
        : '${weightG.toStringAsFixed(0)} g';

    final newLog = PredictionLog(
      id: 'log-${now.millisecondsSinceEpoch}',
      date: dateStr,
      user: widget.currentUser.username,
      weightG: weightG,
      weight: weightDisplay,
      count: calc.count,
      slr: '${calc.slrTotalMl.toStringAsFixed(2)} ml',
      poly: '${calc.polyTotalMl.toStringAsFixed(2)} ml',
      rbf: '${calc.rbfTotalMl.toStringAsFixed(2)} ml',
      primary: '${calc.primaryTotalMl.toStringAsFixed(2)} ml',
      slrMl: calc.slrTotalMl,
      polyMl: calc.polyTotalMl,
      rbfMl: calc.rbfTotalMl,
      primaryMl: calc.primaryTotalMl,
    );

    await StorageService.addLog(newLog);
    widget.onRefreshLogs();
  }

  double _currentWeightKg() {
    final parsed = double.tryParse(_weightController.text.trim()) ?? 5.0;
    if (parsed <= 0) return 5.0;
    return _unit == 'kg' ? parsed : parsed / 1000.0;
  }

  @override
  Widget build(BuildContext context) {
    final quickPresets = _unit == 'kg'
        ? const <Map<String, Object>>[
            {'label': '1 kg', 'val': 1.0},
            {'label': '5 kg', 'val': 5.0},
            {'label': '10 kg', 'val': 10.0},
            {'label': '25 kg', 'val': 25.0},
            {'label': '50 kg', 'val': 50.0},
          ]
        : const <Map<String, Object>>[
            {'label': '10 g (1 sample)', 'val': 10.0},
            {'label': '15 g (1 sample)', 'val': 15.0},
            {'label': '500 g', 'val': 500.0},
            {'label': '1000 g', 'val': 1000.0},
            {'label': '5000 g', 'val': 5000.0},
          ];

    final userRecentLogs = widget.logs
        .where((l) =>
            widget.currentUser.role == 'admin' ||
            l.user == widget.currentUser.username)
        .take(8)
        .toList();

    final isCompact = MediaQuery.sizeOf(context).width < 480;
    final result = _result;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. INPUT ESTIMATION CARD
        Container(
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
                runSpacing: 12,
                spacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          const Text(
                            'Calamansi Batch Yield Estimator',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slate900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.emerald100,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Direct Weight Input',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.emerald800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enter total harvested batch weight. Pure juice projection is calculated automatically without manual size sorting.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),

                  // Unit Toggle
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Unit:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildUnitButton('kg'),
                            _buildUnitButton('g'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.slate100, height: 1),
              const SizedBox(height: 18),

              const Text(
                'TOTAL CALAMANSI BATCH WEIGHT',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate600,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: TextField(
                  controller: _weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) {
                    if (_error != null) {
                      setState(() => _error = null);
                    } else {
                      setState(() {});
                    }
                  },
                  onSubmitted: (_) => _handleExecute(),
                  style: const TextStyle(
                    fontFamily: AppColors.monoFont,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate900,
                  ),
                  decoration: InputDecoration(
                    hintText: _unit == 'kg' ? 'e.g. 5' : 'e.g. 5000',
                    hintStyle: const TextStyle(
                      fontFamily: AppColors.monoFont,
                      color: AppColors.slate400,
                      fontSize: 22,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _unit,
                            style: const TextStyle(
                              fontFamily: AppColors.monoFont,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.slate50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.slate200,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.emerald600,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Quick Presets
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Text(
                      'Presets:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                  ),
                  ...quickPresets.map((p) {
                    final label = p['label'] as String;
                    final val = p['val'] as double;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final formatted = val == val.roundToDouble()
                            ? val.toInt().toString()
                            : val.toString();
                        _weightController.text = formatted;
                        _handleExecute(customWeight: val);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate700,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),

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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => _handleExecute(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.bolt,
                  color: AppColors.amber300,
                  size: 22,
                ),
                label: const Text(
                  'Calculate Batch Forecast',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. RESULTS & COMMERCIAL FORECAST
        if (result != null) ...[
          const SizedBox(height: 24),
          Container(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            const Text(
                              'Forecast Summary',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.slate900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.emerald50,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.emerald200),
                              ),
                              child: Text(
                                result.isSingleSample
                                    ? 'Single-Sample Formula (W = ${result.repWeight.toStringAsFixed(0)} g)'
                                    : 'Batch Scaling (Mean = ${result.repWeight.toStringAsFixed(2)} g/fruit)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emerald800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.isSingleSample
                              ? 'Direct per-sample regression output evaluated at W = ${result.repWeight.toStringAsFixed(0)} g:'
                              : 'Calibrated extraction metrics based on empirical calamansi density:',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),

                    // View Toggle
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildViewToggle('primary', 'Primary Forecast'),
                          _buildViewToggle('compare', 'Compare All 4 Models'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.slate100, height: 1),
                const SizedBox(height: 20),

                // Primary Highlight OR Compare All 4 Models
                if (_activeModelView == 'primary')
                  _buildPrimaryForecastCard(result)
                else
                  _buildCompareGrid(result),

                const SizedBox(height: 20),

                // Commercial Bottling & Inventory Yields
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: AppColors.emerald700,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'COMMERCIAL BOTTLING & INVENTORY YIELDS',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.slate700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 560;
                          final cards = [
                            _buildBottleCard(
                              '330 mL Bottles',
                              '~${result.bottles330}',
                              'Ready-to-drink size',
                            ),
                            _buildBottleCard(
                              '500 mL Bottles',
                              '~${result.bottles500}',
                              'Retail concentrate format',
                            ),
                            _buildBottleCard(
                              '1.0 Liter Commercial Jugs',
                              '~${result.bottles1000}',
                              'Pure juice catering volume',
                            ),
                          ];
                          if (isWide) {
                            return Row(
                              children: [
                                Expanded(child: cards[0]),
                                const SizedBox(width: 12),
                                Expanded(child: cards[1]),
                                const SizedBox(width: 12),
                                Expanded(child: cards[2]),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              cards[0],
                              const SizedBox(height: 8),
                              cards[1],
                              const SizedBox(height: 8),
                              cards[2],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // DOST Sugar Recipe Formulator Action Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.teal50, AppColors.cyan50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.teal200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.teal100,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'DOST-ITDI CONCENTRATE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.teal800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '1 L : 1.5 kg Sugar',
                            style: TextStyle(
                              fontFamily: AppColors.monoFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.teal700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'DOST Sugar Recipe Formulator (Concentrate)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Calamansi is too sour to drink pure. Formulate the exact sugar ratio to yield sweet concentrate with DOST-standard pasteurization.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slate600,
                          height: 1.4,
                        ),
                      ),
                      if (widget.onNavigateToDost != null) ...[
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () {
                            widget.onNavigateToDost!(
                              result.primaryTotalMl,
                              _currentWeightKg(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal700,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.science_outlined,
                            size: 16,
                            color: AppColors.cyan200,
                          ),
                          label: const Text(
                            'Formulate DOST Sugar Recipe →',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // 3. RECENT BATCH HARVEST RECORDS
        const SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(isCompact ? 18 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Batch Harvest Records',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Recent batch calculations logged in this session',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onRefreshLogs,
                    tooltip: 'Refresh records',
                    icon: const Icon(
                      Icons.refresh,
                      size: 18,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.slate100, height: 1),
              const SizedBox(height: 12),
              if (userRecentLogs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text(
                      'No harvest predictions recorded yet.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.slate400,
                      ),
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 780),
                    child: Table(
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      columnWidths: const {
                        0: FlexColumnWidth(1.55),
                        1: FlexColumnWidth(1.10),
                        2: FlexColumnWidth(1.30),
                        3: FlexColumnWidth(1.15),
                        4: FlexColumnWidth(1.25),
                        5: FlexColumnWidth(1.05),
                        6: FlexColumnWidth(1.15),
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
                        ...userRecentLogs.map((log) {
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
                                  log.weight,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
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
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildUnitButton(String u) {
    final active = _unit == u;
    return GestureDetector(
      onTap: () => _handleUnitToggle(u),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.emerald700 : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          u,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.slate600,
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle(String mode, String label) {
    final active = _activeModelView == mode;
    return GestureDetector(
      onTap: () => setState(() => _activeModelView = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.slate900.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.emerald800 : AppColors.slate600,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryForecastCard(PredictionResult result) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.emerald800,
            AppColors.emerald900,
            AppColors.slate900,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emerald500.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(999),
                    ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            size: 14,
                            color: AppColors.amber300,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              ThesisModels.primary.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.emerald200,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${result.primaryTotalMl.toStringAsFixed(2)} mL',
                        style: const TextStyle(
                          fontFamily: AppColors.monoFont,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '~${(result.primaryTotalMl / 1000.0).toStringAsFixed(3)} Liters Pure Juice',
                      style: const TextStyle(
                        fontFamily: AppColors.monoFont,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.emerald200,
                      ),
                    ),
                  ],
                ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emerald950.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.emerald700.withOpacity(0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Calamansi',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.emerald300,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.isSingleSample
                              ? '1 calamansi'
                              : '~${result.count} calamansi',
                          style: const TextStyle(
                            fontFamily: AppColors.monoFont,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emerald950.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.emerald700.withOpacity(0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Extraction Ratio',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.emerald300,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${result.extractionRatioPercent}%',
                          style: const TextStyle(
                            fontFamily: AppColors.monoFont,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.emerald300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.emerald700.withOpacity(0.6), height: 1),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 6,
            children: [
              Text(
                'Grouped 5-fold CV: R² = ${ThesisModels.primary.r2Percent.toStringAsFixed(2)}% • MAE = ${ThesisModels.primary.maeMl.toStringAsFixed(4)} mL',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.emerald200,
                ),
              ),
              const Text(
                'Weight-only, out-of-fold estimate',
                style: TextStyle(
                  fontFamily: AppColors.monoFont,
                  fontSize: 11,
                  color: AppColors.emerald300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompareGrid(PredictionResult result) {
    final items = <Map<String, Object>>[
      {'meta': ThesisModels.slr, 'totalMl': result.slrTotalMl},
      {'meta': ThesisModels.poly, 'totalMl': result.polyTotalMl},
      {'meta': ThesisModels.rbf, 'totalMl': result.rbfTotalMl},
      {'meta': ThesisModels.primary, 'totalMl': result.primaryTotalMl},
    ];

    Widget buildModelCard(Map<String, Object> item) {
      final meta = item['meta'] as ModelBenchmark;
      final totalMl = item['totalMl'] as double;
      final isBest = meta.isBest;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isBest ? AppColors.emerald50 : AppColors.slate50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isBest ? AppColors.emerald300 : AppColors.slate200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        meta.name,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                    ),
                    if (isBest)
                      const Icon(
                        Icons.workspace_premium,
                        size: 18,
                        color: AppColors.emerald700,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${totalMl.toStringAsFixed(2)} mL',
                  style: const TextStyle(
                    fontFamily: AppColors.monoFont,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '~${(totalMl / 1000.0).toStringAsFixed(3)} L',
                  style: const TextStyle(
                    fontFamily: AppColors.monoFont,
                    fontSize: 12,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(height: 14),
                const Divider(color: AppColors.slate200, height: 1),
                const SizedBox(height: 10),
                _metricRow(
                  'Grouped CV R²:',
                  '${meta.r2Percent.toStringAsFixed(2)}%',
                  bold: true,
                ),
                const SizedBox(height: 4),
                _metricRow(
                  'MAE:',
                  '${meta.maeMl.toStringAsFixed(4)} mL',
                ),
                const SizedBox(height: 4),
                _metricRow(
                  'RMSE:',
                  '${meta.rmseMl.toStringAsFixed(4)} mL',
                ),
              ],
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 660) {
          return Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: buildModelCard(items[0])),
                    const SizedBox(width: 14),
                    Expanded(child: buildModelCard(items[1])),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: buildModelCard(items[2])),
                    const SizedBox(width: 14),
                    Expanded(child: buildModelCard(items[3])),
                  ],
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            buildModelCard(items[0]),
            const SizedBox(height: 12),
            buildModelCard(items[1]),
            const SizedBox(height: 12),
            buildModelCard(items[2]),
            const SizedBox(height: 12),
            buildModelCard(items[3]),
          ],
        );
      },
    );
  }

  Widget _metricRow(String label, String val, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.slate600),
        ),
        Text(
          val,
          style: TextStyle(
            fontFamily: AppColors.monoFont,
            fontSize: 12,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: bold ? AppColors.slate800 : AppColors.slate700,
          ),
        ),
      ],
    );
  }

  Widget _buildBottleCard(String title, String count, String sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.slate500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              fontFamily: AppColors.monoFont,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.emerald700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }
}
