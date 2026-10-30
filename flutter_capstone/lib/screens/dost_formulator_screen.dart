import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class DostFormulatorScreen extends StatefulWidget {
  final double initialJuiceMl;
  final double initialWeightKg;
  final void Function(double weightKg, int bottles)? onNavigateToProfit;

  const DostFormulatorScreen({
    super.key,
    this.initialJuiceMl = 1000.0,
    this.initialWeightKg = 10.0,
    this.onNavigateToProfit,
  });

  @override
  State<DostFormulatorScreen> createState() => _DostFormulatorScreenState();
}

class _DostFormulatorScreenState extends State<DostFormulatorScreen> {
  String _inputMode = 'juice'; // 'juice' | 'calamansi'
  late double _pureJuiceLiters;
  late double _calamansiWeightKg;
  double _sugarRatioKgPerLiter = 1.5;
  int _bottleSizeMl = 350;
  double _sugarPricePerKg = 80.0;

  late final TextEditingController _juiceCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _sugarPriceCtrl;

  @override
  void initState() {
    super.initState();
    _pureJuiceLiters =
        widget.initialJuiceMl > 0 ? widget.initialJuiceMl / 1000.0 : 1.0;
    _calamansiWeightKg =
        widget.initialWeightKg > 0 ? widget.initialWeightKg : 10.0;
    _juiceCtrl =
        TextEditingController(text: _pureJuiceLiters.toStringAsFixed(2));
    _weightCtrl = TextEditingController(text: _fmtNum(_calamansiWeightKg));
    _sugarPriceCtrl = TextEditingController(text: '80');
  }

  @override
  void didUpdateWidget(covariant DostFormulatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialJuiceMl != widget.initialJuiceMl &&
        widget.initialJuiceMl > 0) {
      _pureJuiceLiters = widget.initialJuiceMl / 1000.0;
      _juiceCtrl.text = _pureJuiceLiters.toStringAsFixed(2);
    }
    if (oldWidget.initialWeightKg != widget.initialWeightKg &&
        widget.initialWeightKg > 0) {
      _calamansiWeightKg = widget.initialWeightKg;
      _weightCtrl.text = _fmtNum(_calamansiWeightKg);
    }
  }

  @override
  void dispose() {
    _juiceCtrl.dispose();
    _weightCtrl.dispose();
    _sugarPriceCtrl.dispose();
    super.dispose();
  }

  String _fmtNum(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  double _round2(double v) => double.parse(v.toStringAsFixed(2));
  double _round1(double v) => double.parse(v.toStringAsFixed(1));

  void _handleLoadDostStandard() {
    setState(() {
      _inputMode = 'juice';
      _pureJuiceLiters = 1.0;
      _sugarRatioKgPerLiter = 1.5;
      _bottleSizeMl = 350;
      _juiceCtrl.text = '1.0';
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveJuiceLiters = _inputMode == 'calamansi'
        ? _calamansiWeightKg * 0.412
        : _pureJuiceLiters;

    final concentrateFactor = 1.0 + (_sugarRatioKgPerLiter * 0.70);
    final finishedConcentrateLiters =
        _round2(effectiveJuiceLiters * concentrateFactor);
    final finishedConcentrateMl = (finishedConcentrateLiters * 1000.0).round();

    final totalSugarKg = _round2(effectiveJuiceLiters * _sugarRatioKgPerLiter);
    final bottlesYielded =
        math.max(1, (finishedConcentrateMl / _bottleSizeMl).round());

    final readyToDrinkLiters = _round1(finishedConcentrateLiters * 5.0);
    final totalGlasses200ml = ((readyToDrinkLiters * 1000.0) / 200.0).round();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1024),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. HERO BANNER
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.teal900,
                    AppColors.emerald950,
                    AppColors.slate900,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.teal700.withOpacity(0.5),
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20,
                runSpacing: 16,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.teal500.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.teal300.withOpacity(0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.science_outlined,
                                size: 14,
                                color: AppColors.amber300,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'DOST-ITDI FOOD PROCESSING FORMULATION',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.teal300,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'DOST Sugar Recipe Formulator (Juice Concentrate)',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.teal100,
                              height: 1.45,
                            ),
                            children: [
                              TextSpan(
                                text: "Answers the Panel's Practical Question: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.amber300,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '"What does the farmer actually do with the pure juice after extracting it?"',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Raw calamansi juice is naturally high in citric acid (5%–6%) with an aggressive pH of ~2.2. Drinking it pure is too sour and causes throat irritation. By compounding with DOST's 1:1.5 standard sugar ratio, the juice forms a 50°–55° Brix concentrate that naturally preserves for 6–12 months without chemical preservatives!",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.teal200.withOpacity(0.85),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _handleLoadDostStandard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.amber400,
                          foregroundColor: AppColors.slate950,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '⭐ Load DOST Standard (1 L)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '1 Liter Pure Juice ➔ 1.5 kg Sugar ➔ ~2 Liters',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.teal300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. DOST STANDARD FORMULATION CALLOUT
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.emerald50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.emerald200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.emerald700,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'DOST-ITDI STANDARD FORMULATION:',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.emerald900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 640;
                      final s1 = _dostRefCard(
                        title: '1. Pure Calamansi Juice',
                        big: '1.0 Liter',
                        bigColor: AppColors.slate900,
                        sub: 'Strained, unpasteurized 100% natural pure juice',
                      );
                      final s2 = _dostRefCard(
                        title: '2. Add Refined White Sugar',
                        big: '+1.5 kg Sugar',
                        bigColor: AppColors.amber700,
                        sub: 'DOST 1 : 1.5 food preservation sweetening ratio',
                      );
                      final s3 = Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.emerald900,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.emerald700),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '3. Finished Concentrate Yield',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.emerald200,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '~2.0 Liters',
                              style: TextStyle(
                                fontFamily: AppColors.monoFont,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: AppColors.amber300,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sweet concentrate (50–55° Brix, shelf-stable)',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.emerald200,
                              ),
                            ),
                          ],
                        ),
                      );

                      if (isWide) {
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: s1),
                              const SizedBox(width: 12),
                              Expanded(child: s2),
                              const SizedBox(width: 12),
                              Expanded(child: s3),
                            ],
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          s1,
                          const SizedBox(height: 8),
                          s2,
                          const SizedBox(height: 8),
                          s3,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 3. INTERACTIVE FORMULATION CALCULATOR
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 860;
                final leftInputs = _buildInputsCard();
                final rightOutputs = _buildOutputColumn(
                  effectiveJuiceLiters: effectiveJuiceLiters,
                  finishedConcentrateLiters: finishedConcentrateLiters,
                  totalSugarKg: totalSugarKg,
                  bottlesYielded: bottlesYielded,
                  readyToDrinkLiters: readyToDrinkLiters,
                  totalGlasses200ml: totalGlasses200ml,
                );

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: leftInputs),
                      const SizedBox(width: 22),
                      Expanded(flex: 7, child: rightOutputs),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    leftInputs,
                    const SizedBox(height: 20),
                    rightOutputs,
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _dostRefCard({
    required String title,
    required String big,
    required Color bigColor,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.emerald200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.slate500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            big,
            style: TextStyle(
              fontFamily: AppColors.monoFont,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: bigColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputsCard() {
    const ratioOptions = <Map<String, Object>>[
      {'label': 'Mild (1 : 1.2)', 'ratio': 1.2, 'note': '~45° Brix'},
      {'label': 'DOST (1 : 1.5)', 'ratio': 1.5, 'note': 'Standard ~55° Brix'},
      {'label': 'Rich (1 : 1.8)', 'ratio': 1.8, 'note': 'Cordial ~60° Brix'},
    ];

    const bottleOptions = <Map<String, Object>>[
      {'label': '330 mL', 'ml': 330, 'desc': 'Compact'},
      {'label': '350 mL', 'ml': 350, 'desc': 'Standard PET'},
      {'label': '500 mL', 'ml': 500, 'desc': 'Family Size'},
    ];

    return Container(
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
            spacing: 8,
            runSpacing: 8,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.scale_outlined,
                    size: 18,
                    color: AppColors.teal700,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Batch Formulation Inputs',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _modeBtn('juice', 'By Juice (L)'),
                    _modeBtn('calamansi', 'By Calamansi (kg)'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.slate100, height: 1),
          const SizedBox(height: 16),

          if (_inputMode == 'juice') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'EXTRACTED PURE JUICE VOLUME',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate600,
                  ),
                ),
                Text(
                  '${NumberFormat('#,##0').format(_pureJuiceLiters * 1000)} mL',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.slate400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _tealInput(
              controller: _juiceCtrl,
              suffix: 'Liters',
              onChanged: (v) {
                final parsed = double.tryParse(v);
                setState(() {
                  _pureJuiceLiters = math.max(0.05, parsed ?? 0.05);
                });
              },
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HARVESTED CALAMANSI WEIGHT (KG)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate600,
                  ),
                ),
                Text(
                  '~${(_calamansiWeightKg * 0.412).toStringAsFixed(2)} L juice est.',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _tealInput(
              controller: _weightCtrl,
              suffix: 'kg raw calamansi',
              onChanged: (v) {
                final parsed = double.tryParse(v);
                setState(() {
                  _calamansiWeightKg = math.max(0.1, parsed ?? 0.1);
                });
              },
            ),
            const SizedBox(height: 4),
            const Text(
              'Calculated using calibrated 41.2% juice extraction density.',
              style: TextStyle(fontSize: 11, color: AppColors.slate400),
            ),
          ],
          const SizedBox(height: 18),

          // DOST Recipe Formulation
          const Text(
            'DOST RECIPE FORMULATION:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.slate600,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: ratioOptions.map((r) {
              final label = r['label'] as String;
              final ratio = r['ratio'] as double;
              final note = r['note'] as String;
              final selected = (_sugarRatioKgPerLiter - ratio).abs() < 0.01;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _sugarRatioKgPerLiter = ratio),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.teal50 : AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            selected ? AppColors.teal600 : AppColors.slate200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? AppColors.teal950
                                : AppColors.slate700,
                          ),
                        ),
                        Text(
                          note,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.slate400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Packaging Format (Bottle Size)
          const Text(
            'PACKAGING FORMAT (BOTTLE SIZE):',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.slate600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: bottleOptions.map((b) {
              final label = b['label'] as String;
              final ml = b['ml'] as int;
              final desc = b['desc'] as String;
              final selected = _bottleSizeMl == ml;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: ml == 500 ? 0 : 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _bottleSizeMl = ml),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.teal700 : AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              selected ? AppColors.teal700 : AppColors.slate200,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color:
                                  selected ? Colors.white : AppColors.slate700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            desc,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: selected
                                  ? AppColors.teal200
                                  : AppColors.slate400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Sugar Price
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WHITE REFINED SUGAR PRICE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate600,
                ),
              ),
              Text(
                'Market rate',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.slate400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _tealInput(
            controller: _sugarPriceCtrl,
            prefix: '₱',
            suffix: '/ kg',
            onChanged: (v) {
              final parsed = double.tryParse(v);
              setState(() {
                _sugarPricePerKg = math.max(1.0, parsed ?? 1.0);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _modeBtn(String mode, String label) {
    final active = _inputMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _inputMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.teal700 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.slate600,
          ),
        ),
      ),
    );
  }

  Widget _tealInput({
    required TextEditingController controller,
    String? prefix,
    String? suffix,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: AppColors.monoFont,
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.slate900,
      ),
      decoration: InputDecoration(
        prefixText: prefix != null ? '$prefix ' : null,
        prefixStyle: const TextStyle(
          fontFamily: AppColors.monoFont,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.slate400,
        ),
        suffixText: suffix,
        suffixStyle: const TextStyle(
          fontFamily: AppColors.monoFont,
          fontSize: 12,
          fontWeight: FontWeight.w700,
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
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.teal600, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildOutputColumn({
    required double effectiveJuiceLiters,
    required double finishedConcentrateLiters,
    required double totalSugarKg,
    required int bottlesYielded,
    required double readyToDrinkLiters,
    required int totalGlasses200ml,
  }) {
    final sopSteps = <Map<String, String>>[
      {
        'num': '1',
        'title': 'Careful Extraction & Filtration: ',
        'body':
            'Slice the top third of the calamansi. Squeeze gently by hand or food-grade press without piercing the peel (to prevent bitter essential oil contamination). Strain through fine nylon/stainless mesh.',
      },
      {
        'num': '2',
        'title': 'Sugar Blending: ',
        'body':
            'Stir in $_sugarRatioKgPerLiter kg refined sugar per 1 L pure juice in a stainless steel kettle until completely dissolved.',
      },
      {
        'num': '3',
        'title': 'Low-Heat Pasteurization (65°C - 70°C for 5 mins): ',
        'body':
            'Heat with continuous stirring. Never boil—boiling destroys natural Vitamin C and degrades the fresh citrus aroma.',
      },
      {
        'num': '4',
        'title': 'Hot Filling & Airtight Capping: ',
        'body':
            'Pour concentrate while warm (~65°C) into pre-sterilized bottles leaving 1 cm headspace. Cap tightly with tamper-evident seals.',
      },
      {
        'num': '5',
        'title': 'Water-Bath Cooling & Ambient Storage: ',
        'body':
            'Immediately submerge capped bottles in cold running water to halt residual heating. Shelf-life: 6 months at room temperature, 12 months chilled.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Recipe Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.teal600, width: 2),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.teal100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'BATCH PRODUCTION SHEET',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.teal800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Finished Sweet Concentrate: ~$finishedConcentrateLiters Liters',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.teal800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'YIELD COUNT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.teal200,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '~$bottlesYielded Bottles',
                          style: const TextStyle(
                            fontFamily: AppColors.monoFont,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.slate100, height: 1),
              const SizedBox(height: 16),

              // Recipe Quantities Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final boxJuice = Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.teal50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.teal200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pure Calamansi Juice:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.slate500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${effectiveJuiceLiters.toStringAsFixed(2)} Liters',
                              style: const TextStyle(
                                fontFamily: AppColors.monoFont,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.teal900,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.water_drop_outlined,
                          size: 24,
                          color: AppColors.teal600,
                        ),
                      ],
                    ),
                  );

                  final boxSugar = Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.amber50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.amber200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Refined Sugar Needed:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.slate500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$totalSugarKg kg (@ ₱${_fmtNum(_sugarPricePerKg)}/kg)',
                                style: const TextStyle(
                                  fontFamily: AppColors.monoFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.amber900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.scale_outlined,
                          size: 24,
                          color: AppColors.amber600,
                        ),
                      ],
                    ),
                  );

                  if (constraints.maxWidth >= 500) {
                    return Row(
                      children: [
                        Expanded(child: boxJuice),
                        const SizedBox(width: 12),
                        Expanded(child: boxSugar),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      boxJuice,
                      const SizedBox(height: 10),
                      boxSugar,
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Customer Dilution & Serving Guide
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.local_cafe_outlined,
                          size: 16,
                          color: AppColors.emerald700,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Customer Dilution & Serving Guide:',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slate600,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: 'The concentrate is diluted at '),
                          TextSpan(
                            text: '1 part concentrate to 4 parts chilled water',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.emerald800,
                            ),
                          ),
                          TextSpan(text: ' (or 1:5 for light refreshment).'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.slate200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ready-to-Drink Volume:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.slate500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '~$readyToDrinkLiters Liters',
                                  style: const TextStyle(
                                    fontFamily: AppColors.monoFont,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.slate800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.slate200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Glasses Served (200 mL):',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.slate500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '~$totalGlasses200ml glasses',
                                  style: const TextStyle(
                                    fontFamily: AppColors.monoFont,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.emerald700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (widget.onNavigateToProfit != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final effectiveKg = _inputMode == 'calamansi'
                        ? _calamansiWeightKg
                        : _round2(effectiveJuiceLiters / 0.412);
                    widget.onNavigateToProfit!(effectiveKg, bottlesYielded);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          '💰 Calculate Farmgate vs Bottling Profit for these $bottlesYielded Bottles',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),

        // DOST 5-Step Pasteurization Standard Protocol
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.thermostat_outlined,
                    size: 18,
                    color: AppColors.teal700,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'DOST-ITDI 5-STEP SAFE PROCESSING PROTOCOL (SOP)',
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
              ...sopSteps.map((step) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.slate100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.teal100,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            step['num']!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.teal800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.slate600,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: step['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slate800,
                                  ),
                                ),
                                TextSpan(text: step['body']),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
