import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class ProfitCalculatorScreen extends StatefulWidget {
  final double initialWeightKg;
  final double? initialJuiceMl;
  final ValueChanged<double>? onNavigateToDost;

  const ProfitCalculatorScreen({
    super.key,
    this.initialWeightKg = 10.0,
    this.initialJuiceMl,
    this.onNavigateToDost,
  });

  @override
  State<ProfitCalculatorScreen> createState() => _ProfitCalculatorScreenState();
}

class _ProfitCalculatorScreenState extends State<ProfitCalculatorScreen> {
  late double _batchWeightKg;
  double _farmgatePricePerKg = 35.0;
  bool _isManualBottleCount = false;
  int _manualBottles = 10;
  double _sellingPricePerBottle = 65.0;
  double _bottleCost = 8.0;
  double _sugarPricePerKg = 80.0;
  bool _useLinkedJuice = true;

  late final TextEditingController _weightCtrl;
  late final TextEditingController _farmgateCtrl;
  late final TextEditingController _manualBottlesCtrl;
  late final TextEditingController _sellingPriceCtrl;
  late final TextEditingController _bottleCostCtrl;
  late final TextEditingController _sugarPriceCtrl;

  @override
  void initState() {
    super.initState();
    _batchWeightKg = widget.initialWeightKg;
    _weightCtrl = TextEditingController(text: _fmtNum(_batchWeightKg));
    _farmgateCtrl = TextEditingController(text: '35');
    _manualBottlesCtrl = TextEditingController(text: '10');
    _sellingPriceCtrl = TextEditingController(text: '65');
    _bottleCostCtrl = TextEditingController(text: '8');
    _sugarPriceCtrl = TextEditingController(text: '80');
  }

  @override
  void didUpdateWidget(covariant ProfitCalculatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialWeightKg != widget.initialWeightKg) {
      _batchWeightKg = widget.initialWeightKg;
      _weightCtrl.text = _fmtNum(_batchWeightKg);
      _useLinkedJuice = true;
    }
    if (oldWidget.initialJuiceMl != widget.initialJuiceMl) {
      _useLinkedJuice = true;
    }
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _farmgateCtrl.dispose();
    _manualBottlesCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _bottleCostCtrl.dispose();
    _sugarPriceCtrl.dispose();
    super.dispose();
  }

  String _fmtNum(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  String _fmtMoney(double v) {
    final fmt = NumberFormat('#,##0.##');
    return fmt.format(v);
  }

  double _round2(double v) => double.parse(v.toStringAsFixed(2));
  double _round1(double v) => double.parse(v.toStringAsFixed(1));

  void _handleLoadPanelExample() {
    setState(() {
      _batchWeightKg = 10.0;
      _useLinkedJuice = false;
      _farmgatePricePerKg = 35.0;
      _isManualBottleCount = true;
      _manualBottles = 10;
      _sellingPricePerBottle = 65.0;
      _bottleCost = 5.0;
      _sugarPricePerKg = 20.0;

      _weightCtrl.text = '10';
      _farmgateCtrl.text = '35';
      _manualBottlesCtrl.text = '10';
      _sellingPriceCtrl.text = '65';
      _bottleCostCtrl.text = '5';
      _sugarPriceCtrl.text = '20';
    });
  }

  @override
  Widget build(BuildContext context) {
    final estimatedJuiceLiters =
        (_useLinkedJuice && widget.initialJuiceMl != null &&
                (_batchWeightKg - widget.initialWeightKg).abs() < 0.001)
            ? widget.initialJuiceMl! / 1000.0
            : _batchWeightKg * 0.412;

    final autoBottlesCount = math.max(1, (_batchWeightKg * 1.0).round());
    final effectiveBottles =
        _isManualBottleCount ? _manualBottles : autoBottlesCount;

    final sugarRequiredKg = _round2(estimatedJuiceLiters * 1.5);
    final totalSugarCost = _round2(sugarRequiredKg * _sugarPricePerKg);
    final totalPackagingCost = _round2(effectiveBottles * _bottleCost);
    final totalProductionCost = _round2(totalPackagingCost + totalSugarCost);

    final rawRevenue = _round2(_batchWeightKg * _farmgatePricePerKg);
    final rawProfit = rawRevenue;

    final bottledGrossRevenue =
        _round2(effectiveBottles * _sellingPricePerBottle);
    final bottledNetProfit = _round2(bottledGrossRevenue - totalProductionCost);

    final netGain = _round2(bottledNetProfit - rawProfit);
    final percentageGain =
        rawProfit > 0 ? _round1((netGain / rawProfit) * 100.0) : 0.0;

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
                    AppColors.emerald900,
                    AppColors.teal900,
                    AppColors.slate900,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.emerald700.withOpacity(0.5),
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
                            color: AppColors.emerald500.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.emerald400.withOpacity(0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: AppColors.amber300,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'THESIS DEFENSE HIGH-IMPACT FEATURE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.emerald300,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Money & Profit Calculator (Farmgate vs. Bottled)',
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
                              color: AppColors.emerald100,
                              height: 1.45,
                            ),
                            children: [
                              TextSpan(
                                text: "Answers the Panel's #1 Question: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.amber300,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '"How does predicting calamansi yield actually help the farmer earn more money?"',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Raw calamansi suffers severe seasonal middleman price slashing (down to ₱30–₱35/kg) and decays in 3–5 days. Processing into sealed bottled concentrate turns fresh harvest into an ambient 6-month shelf-life product with high profit margins.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.emerald200.withOpacity(0.85),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _handleLoadPanelExample,
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
                          '⭐ Load Panel Example (10 kg)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '10 kg raw @ ₱350 vs. 10 bottles @ ₱650',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.emerald300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. PANEL QUICK EXAMPLE BREAKDOWN
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.amber50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.amber200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.amber600,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'PANEL QUICK EXAMPLE BREAKDOWN:',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.amber900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 640;
                      final c1 = _exampleSubCard(
                        title: '1. Sell Raw to Middleman',
                        big: '₱350 Gross',
                        bigColor: AppColors.slate800,
                        sub: '10 kg raw calamansi × ₱35 / kg farmgate price',
                      );
                      final c2 = _exampleSubCard(
                        title: '2. Squeeze & Bottle',
                        big: '₱650 Gross',
                        bigColor: AppColors.emerald700,
                        sub: '10 bottles juice / concentrate × ₱65 / bottle',
                      );
                      final c3 = Container(
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
                              '3. Result: Farmer Advantage',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.emerald200,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '+₱220 More Profit',
                              style: TextStyle(
                                fontFamily: AppColors.monoFont,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: AppColors.amber300,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '+60% Net Profit Increase over raw sale',
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
                              Expanded(child: c1),
                              const SizedBox(width: 12),
                              Expanded(child: c2),
                              const SizedBox(width: 12),
                              Expanded(child: c3),
                            ],
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          c1,
                          const SizedBox(height: 8),
                          c2,
                          const SizedBox(height: 8),
                          c3,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 3. INTERACTIVE CALCULATOR INPUTS + OUTPUT
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 860;
                final leftForm = _buildParametersCard(effectiveBottles);
                final rightOutput = _buildComparativeOutput(
                  estimatedJuiceLiters: estimatedJuiceLiters,
                  effectiveBottles: effectiveBottles,
                  sugarRequiredKg: sugarRequiredKg,
                  totalSugarCost: totalSugarCost,
                  totalPackagingCost: totalPackagingCost,
                  totalProductionCost: totalProductionCost,
                  rawRevenue: rawRevenue,
                  rawProfit: rawProfit,
                  bottledGrossRevenue: bottledGrossRevenue,
                  bottledNetProfit: bottledNetProfit,
                  netGain: netGain,
                  percentageGain: percentageGain,
                );

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: leftForm),
                      const SizedBox(width: 22),
                      Expanded(flex: 7, child: rightOutput),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    leftForm,
                    const SizedBox(height: 20),
                    rightOutput,
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

  Widget _exampleSubCard({
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
        border: Border.all(color: AppColors.amber200),
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
              fontWeight: FontWeight.w800,
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

  Widget _buildParametersCard(int effectiveBottles) {
    const presets = <Map<String, Object>>[
      {'label': '5 kg', 'kg': 5.0, 'b': 5},
      {'label': '10 kg (Thesis)', 'kg': 10.0, 'b': 10},
      {'label': '25 kg (Half-Sack)', 'kg': 25.0, 'b': 25},
      {'label': '50 kg (Full Sack)', 'kg': 50.0, 'b': 50},
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.monetization_on_outlined,
                    size: 18,
                    color: AppColors.emerald700,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Harvest & Market Parameters',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Live Interactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.slate100, height: 1),
          const SizedBox(height: 16),

          // Batch Presets
          const Text(
            'BATCH PRESETS:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.slate500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: presets.map((p) {
              final label = p['label'] as String;
              final kg = p['kg'] as double;
              final b = p['b'] as int;
              final selected = (_batchWeightKg - kg).abs() < 0.01;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _batchWeightKg = kg;
                    _weightCtrl.text = kg.toInt().toString();
                    _useLinkedJuice = false;
                    if (_isManualBottleCount) {
                      _manualBottles = b;
                      _manualBottlesCtrl.text = b.toString();
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.emerald700 : AppColors.slate50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          selected ? AppColors.emerald700 : AppColors.slate200,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.slate700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Calamansi Batch Weight
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CALAMANSI BATCH WEIGHT (KG)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate600,
                ),
              ),
              Text(
                '${NumberFormat('#,##0').format(_batchWeightKg * 1000)} grams',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.slate400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _numInput(
            controller: _weightCtrl,
            suffix: 'kg',
            onChanged: (v) {
              final parsed = double.tryParse(v);
              setState(() {
                _batchWeightKg = math.max(0.1, parsed ?? 0.1);
                _useLinkedJuice = false;
              });
            },
          ),
          const SizedBox(height: 16),

          // Middleman Farmgate Price
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MIDDLEMAN FARMGATE PRICE (₱ / KG)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate600,
                ),
              ),
              Text(
                'Raw calamansi rate',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.slate400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _numInput(
            controller: _farmgateCtrl,
            prefix: '₱',
            suffix: '/ kg',
            onChanged: (v) {
              final parsed = double.tryParse(v);
              setState(() {
                _farmgatePricePerKg = math.max(0.0, parsed ?? 0.0);
              });
            },
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.slate100, height: 1),
          const SizedBox(height: 14),

          // Bottles Produced
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BOTTLES PRODUCED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate600,
                ),
              ),
              GestureDetector(
                onTap: () => setState(
                    () => _isManualBottleCount = !_isManualBottleCount),
                child: Text(
                  _isManualBottleCount ? 'Auto-calculate' : 'Customize count',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isManualBottleCount)
            _numInput(
              controller: _manualBottlesCtrl,
              suffix: 'bottles',
              onChanged: (v) {
                final parsed = int.tryParse(v);
                setState(() {
                  _manualBottles = math.max(1, parsed ?? 1);
                });
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Standard packaging yield:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate600,
                    ),
                  ),
                  Text(
                    '$effectiveBottles bottles',
                    style: const TextStyle(
                      fontFamily: AppColors.monoFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.emerald800,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),

          // Retail Price per Bottle
          const Text(
            'RETAIL PRICE PER BOTTLE (₱)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.slate600,
            ),
          ),
          const SizedBox(height: 6),
          _numInput(
            controller: _sellingPriceCtrl,
            prefix: '₱',
            suffix: '/ bottle',
            onChanged: (v) {
              final parsed = double.tryParse(v);
              setState(() {
                _sellingPricePerBottle = math.max(0.0, parsed ?? 0.0);
              });
            },
          ),
          const SizedBox(height: 14),

          // Packaging & Sugar Cost Breakdown
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bottle + Cap + Label',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _numInput(
                      controller: _bottleCostCtrl,
                      prefix: '₱',
                      compact: true,
                      onChanged: (v) {
                        final parsed = double.tryParse(v);
                        setState(() {
                          _bottleCost = math.max(0.0, parsed ?? 0.0);
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sugar Cost (₱/kg)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _numInput(
                      controller: _sugarPriceCtrl,
                      prefix: '₱',
                      compact: true,
                      onChanged: (v) {
                        final parsed = double.tryParse(v);
                        setState(() {
                          _sugarPricePerKg = math.max(0.0, parsed ?? 0.0);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numInput({
    required TextEditingController controller,
    String? prefix,
    String? suffix,
    bool compact = false,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: TextStyle(
        fontFamily: AppColors.monoFont,
        fontSize: compact ? 13 : 17,
        fontWeight: FontWeight.w800,
        color: AppColors.slate900,
      ),
      decoration: InputDecoration(
        prefixText: prefix != null ? '$prefix ' : null,
        prefixStyle: TextStyle(
          fontFamily: AppColors.monoFont,
          fontSize: compact ? 12 : 15,
          fontWeight: FontWeight.w700,
          color: AppColors.slate400,
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          fontFamily: AppColors.monoFont,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w700,
          color: AppColors.slate400,
        ),
        filled: true,
        fillColor: AppColors.slate50,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 10 : 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compact ? 8 : 12),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compact ? 8 : 12),
          borderSide: const BorderSide(color: AppColors.emerald600, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildComparativeOutput({
    required double estimatedJuiceLiters,
    required int effectiveBottles,
    required double sugarRequiredKg,
    required double totalSugarCost,
    required double totalPackagingCost,
    required double totalProductionCost,
    required double rawRevenue,
    required double rawProfit,
    required double bottledGrossRevenue,
    required double bottledNetProfit,
    required double netGain,
    required double percentageGain,
  }) {
    final gainSign = netGain >= 0 ? '+' : '';
    final pctSign = percentageGain >= 0 ? '+' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Profit Difference Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.emerald600, width: 2),
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
                          color: AppColors.emerald100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'NET COMMERCIAL GAIN',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.emerald800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Farmer Advantage: $gainSign₱${_fmtMoney(netGain)}',
                        style: const TextStyle(
                          fontSize: 20,
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
                      color: AppColors.emerald700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'PROFIT BOOST',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emerald200,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '$pctSign$percentageGain%',
                          style: const TextStyle(
                            fontFamily: AppColors.monoFont,
                            fontSize: 22,
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

              // Side-by-Side Comparison
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 520;
                  final optionA = Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.storefront_outlined,
                                    size: 15,
                                    color: AppColors.slate500,
                                  ),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      'OPTION A: RAW MIDDLEMAN',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.slate700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.amber100,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Status Quo',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.amber700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '₱${_fmtMoney(rawProfit)}',
                          style: const TextStyle(
                            fontFamily: AppColors.monoFont,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.slate800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_fmtNum(_batchWeightKg)} kg × ₱${_fmtNum(_farmgatePricePerKg)}/kg',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.slate500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.slate200, height: 1),
                        const SizedBox(height: 8),
                        _rowLine('Gross Revenue:', '₱${_fmtMoney(rawRevenue)}'),
                        const SizedBox(height: 4),
                        _rowLine('Processing Cost:', '₱0.00'),
                        const SizedBox(height: 4),
                        _rowLine(
                          'Net Farmer Pocket:',
                          '₱${_fmtMoney(rawProfit)}',
                          bold: true,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.amber50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.amber200),
                          ),
                          child: const Text(
                            '⚠️ Price dictated by middleman; calamansi begins degrading in 72 hours.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.amber800,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  final optionB = Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.emerald50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.emerald500, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 15,
                                    color: AppColors.emerald700,
                                  ),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      'OPTION B: SQUEEZE & BOTTLE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.emerald950,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.emerald200,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Recommended',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emerald800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '₱${_fmtMoney(bottledNetProfit)}',
                          style: const TextStyle(
                            fontFamily: AppColors.monoFont,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.emerald800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$effectiveBottles bottles × ₱${_fmtNum(_sellingPricePerBottle)} (less costs)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.emerald700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.emerald200, height: 1),
                        const SizedBox(height: 8),
                        _rowLine(
                          'Gross Sales:',
                          '₱${_fmtMoney(bottledGrossRevenue)}',
                          bold: true,
                          valueColor: AppColors.emerald900,
                        ),
                        const SizedBox(height: 4),
                        _rowLine(
                          'Production Costs:',
                          '-₱${_fmtMoney(totalProductionCost)}',
                        ),
                        const SizedBox(height: 4),
                        _rowLine(
                          'Net Farmer Profit:',
                          '₱${_fmtMoney(bottledNetProfit)}',
                          bold: true,
                          valueColor: AppColors.emerald800,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.emerald100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.emerald300),
                          ),
                          child: const Text(
                            '✅ 6-month shelf-life; farmer controls retail pricing and direct brand revenue.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.emerald900,
                              height: 1.35,
                            ),
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
                          Expanded(child: optionA),
                          const SizedBox(width: 14),
                          Expanded(child: optionB),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      optionA,
                      const SizedBox(height: 12),
                      optionB,
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Production Costs Detailed Breakdown
              Container(
                padding: const EdgeInsets.all(14),
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
                        const Text(
                          'Value-Addition Cost Breakdown:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate800,
                          ),
                        ),
                        Text(
                          'Total: ₱${_fmtMoney(totalProductionCost)}',
                          style: const TextStyle(
                            fontFamily: AppColors.monoFont,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final box1 = Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Bottles ($effectiveBottles @ ₱${_fmtNum(_bottleCost)}):',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.slate600,
                                  ),
                                ),
                              ),
                              Text(
                                '₱${_fmtMoney(totalPackagingCost)}',
                                style: const TextStyle(
                                  fontFamily: AppColors.monoFont,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.slate800,
                                ),
                              ),
                            ],
                          ),
                        );

                        final box2 = Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Sugar ($sugarRequiredKg kg @ ₱${_fmtNum(_sugarPricePerKg)}):',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.slate600,
                                  ),
                                ),
                              ),
                              Text(
                                '₱${_fmtMoney(totalSugarCost)}',
                                style: const TextStyle(
                                  fontFamily: AppColors.monoFont,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.slate800,
                                ),
                              ),
                            ],
                          ),
                        );

                        if (constraints.maxWidth >= 460) {
                          return Row(
                            children: [
                              Expanded(child: box1),
                              const SizedBox(width: 8),
                              Expanded(child: box2),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            box1,
                            const SizedBox(height: 6),
                            box2,
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Connected Action to DOST Formulator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.teal50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.teal200),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.teal600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🧪', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need the exact sugar recipe for these $effectiveBottles bottles?',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.teal950,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'See the DOST-ITDI standard concentrate recipe to formulate sweet juice safely.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.teal800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.onNavigateToDost != null)
                ElevatedButton.icon(
                  onPressed: () =>
                      widget.onNavigateToDost!(estimatedJuiceLiters * 1000.0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal700,
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
                  icon: const Text(
                    'Open DOST Formulator',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  label: const Icon(Icons.arrow_forward, size: 16),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rowLine(
    String label,
    String val, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: bold ? AppColors.slate800 : AppColors.slate600,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontFamily: AppColors.monoFont,
            fontSize: bold ? 13 : 11.5,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.slate700,
          ),
        ),
      ],
    );
  }
}
