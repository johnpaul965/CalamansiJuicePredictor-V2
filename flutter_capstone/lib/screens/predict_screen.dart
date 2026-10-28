import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prediction_result.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';

class PredictScreen extends StatefulWidget {
  const PredictScreen({Key? key}) : super(key: key);

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final TextEditingController _weightController = TextEditingController(text: '10');
  String _unit = 'kg'; // 'kg' or 'g'
  PredictionResult? _result;
  UserAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _calculate();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.getActiveUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _calculate() {
    final text = _weightController.text.trim();
    final parsed = double.tryParse(text);
    if (parsed == null || parsed <= 0) {
      setState(() {
        _result = null;
      });
      return;
    }

    // Convert to grams
    final weightInGrams = _unit == 'kg' ? parsed * 1000.0 : parsed;
    final res = PredictionService.calculateBatch(weightInGrams);
    setState(() {
      _result = res;
    });
  }

  void _setPreset(double val, String unit) {
    setState(() {
      _unit = unit;
      _weightController.text = val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 2);
    });
    _calculate();
  }

  Future<void> _saveToHistory() async {
    if (_result == null) return;
    final text = _weightController.text.trim();
    final parsed = double.tryParse(text) ?? 0;
    final weightInG = _unit == 'kg' ? parsed * 1000.0 : parsed;
    final formatted = _unit == 'kg'
        ? '${parsed.toStringAsFixed(2)} kg'
        : '${parsed.toStringAsFixed(0)} g';

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(now);
    final user = _currentUser?.name ?? 'Farmer Juan';

    final logItem = PredictionLogItem(
      id: 'log_${now.millisecondsSinceEpoch}',
      date: dateStr,
      user: user,
      weightG: weightInG,
      weightFormatted: formatted,
      count: _result!.count,
      proposedMl: _result!.proposedTotalMl,
      slrMl: _result!.slrTotalMl,
      polyMl: _result!.polyTotalMl,
      svrMl: _result!.svrTotalMl,
      bottles330: _result!.bottles330,
      bottles500: _result!.bottles500,
      bottles1000: _result!.bottles1000,
    );

    await StorageService.addHistoryItem(logItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved $formatted harvest batch prediction to History!'),
          backgroundColor: const Color(0xFF15803D),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Harvest Yield Predictor',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF15803D),
        elevation: 0,
        actions: [
          if (_currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Chip(
                backgroundColor: const Color(0xFF166534),
                label: Text(
                  _currentUser!.name,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                avatar: const Icon(Icons.person, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Batch Weight Input Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Calamansi Batch Weight',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildUnitButton('kg', 'Kilograms (kg)'),
                            _buildUnitButton('g', 'Grams (g)'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _calculate(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF15803D), width: 2),
                      ),
                      suffixText: _unit,
                      suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 16),
                      prefixIcon: const Icon(Icons.scale_outlined, color: Color(0xFF15803D)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildPresetChip(500, 'g', '500 g pack'),
                      _buildPresetChip(1, 'kg', '1 kg basket'),
                      _buildPresetChip(5, 'kg', '5 kg bag'),
                      _buildPresetChip(10, 'kg', '10 kg crate'),
                      _buildPresetChip(25, 'kg', '25 kg sack'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_result != null) ...[
              // Expected Juice Yield Primary Display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF15803D), Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF15803D).withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated Pure Juice Yield',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Proposed Champion Model',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _result!.proposedTotalMl >= 1000
                              ? (_result!.proposedTotalMl / 1000.0).toStringAsFixed(2)
                              : _result!.proposedTotalMl.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _result!.proposedTotalMl >= 1000 ? 'Liters (L)' : 'mL',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Equivalent: ${_result!.proposedTotalMl.toStringAsFixed(1)} mL',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          'Extraction: ${_result!.extractionRatio.toStringAsFixed(1)}% w/w',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Mini Batch Stats
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStat(
                      icon: Icons.grain,
                      label: 'Est. Fruit Count',
                      value: '${_result!.count} fruits',
                      subtext: '~12.69g per fruit',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniStat(
                      icon: Icons.water_drop,
                      label: 'Avg Juice/Fruit',
                      value: '${(_result!.proposedTotalMl / _result!.count).toStringAsFixed(2)} mL',
                      subtext: 'Fit on 1,478 clean rows',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Commercial Bottling Distribution Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Commercial Bottling Capacity',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ready-to-pack bottles calculated from predicted pure juice volume:',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBottleCard(
                            size: '330 mL',
                            type: 'Standard Bottle',
                            count: _result!.bottles330,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildBottleCard(
                            size: '500 mL',
                            type: 'Retail Bottle',
                            count: _result!.bottles500,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildBottleCard(
                            size: '1.0 L',
                            type: 'Bulk Jug',
                            count: _result!.bottles1000,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Live 4-Model Comparative Breakdown Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Live 4-Model Comparison for this Batch',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          '5-Fold CV',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildModelRow(
                      name: 'Proposed Model (ln W + Ridge)',
                      yieldMl: _result!.proposedTotalMl,
                      isProposed: true,
                      r2: PredictionService.r2Label('proposed'),
                      diff: '★ Benchmark Reference',
                    ),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildModelRow(
                      name: 'Simple Linear Regression (SLR)',
                      yieldMl: _result!.slrTotalMl,
                      isProposed: false,
                      r2: PredictionService.r2Label('slr'),
                      diff: '${(_result!.slrTotalMl - _result!.proposedTotalMl).toStringAsFixed(1)} mL',
                    ),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildModelRow(
                      name: 'Support Vector Regression (RBF)',
                      yieldMl: _result!.svrTotalMl,
                      isProposed: false,
                      r2: PredictionService.r2Label('svr'),
                      diff: '${(_result!.svrTotalMl - _result!.proposedTotalMl).toStringAsFixed(1)} mL',
                    ),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildModelRow(
                      name: 'Polynomial Regression (Degree 2)',
                      yieldMl: _result!.polyTotalMl,
                      isProposed: false,
                      r2: PredictionService.r2Label('poly'),
                      diff: '${(_result!.polyTotalMl - _result!.proposedTotalMl).toStringAsFixed(1)} mL',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Save to History Action Button
              ElevatedButton.icon(
                onPressed: _saveToHistory,
                icon: const Icon(Icons.bookmark_added_outlined, color: Colors.white),
                label: const Text(
                  'Save Prediction to Batch History',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUnitButton(String unitKey, String tooltip) {
    final isSelected = _unit == unitKey;
    return GestureDetector(
      onTap: () {
        if (_unit != unitKey) {
          final text = _weightController.text.trim();
          final parsed = double.tryParse(text);
          setState(() {
            _unit = unitKey;
            if (parsed != null) {
              if (unitKey == 'g') {
                _weightController.text = (parsed * 1000).toStringAsFixed(0);
              } else {
                _weightController.text = (parsed / 1000).toStringAsFixed(2);
              }
            }
          });
          _calculate();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF15803D) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          unitKey.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(double val, String unit, String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFFF1F5F9),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
      onPressed: () => _setPreset(val, unit),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF15803D)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(subtext, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildBottleCard({
    required String size,
    required String type,
    required double count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(size, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(type, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          Text(
            count >= 1 ? count.toStringAsFixed(1) : count.toStringAsFixed(2),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
          ),
          const Text('bottles', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildModelRow({
    required String name,
    required double yieldMl,
    required bool isProposed,
    required String r2,
    required String diff,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isProposed ? FontWeight.bold : FontWeight.w500,
                  color: isProposed ? const Color(0xFF15803D) : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text('R²: $r2', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${yieldMl.toStringAsFixed(1)} mL',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: isProposed ? const Color(0xFF15803D) : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                diff,
                style: TextStyle(
                  fontSize: 10,
                  color: isProposed ? const Color(0xFF15803D) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
