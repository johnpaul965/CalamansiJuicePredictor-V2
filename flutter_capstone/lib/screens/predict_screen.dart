import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prediction_result.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';

class PredictScreen extends StatefulWidget {
  final VoidCallback? onLogAdded;
  const PredictScreen({Key? key, this.onLogAdded}) : super(key: key);

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final TextEditingController _weightController = TextEditingController(text: '5');
  String _selectedUnit = 'kg'; // 'kg' or 'g'
  PredictionResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _calculate(5000); // Default 5 kg calculation
  }

  void _calculate([double? directGrams]) {
    setState(() => _errorMessage = null);
    double grams;

    if (directGrams != null) {
      grams = directGrams;
    } else {
      final double? parsed = double.tryParse(_weightController.text.trim());
      if (parsed == null || parsed <= 0) {
        setState(() => _errorMessage = 'Please enter a valid batch weight > 0');
        return;
      }
      grams = _selectedUnit == 'kg' ? parsed * 1000.0 : parsed;
    }

    final res = PredictionService.calculateBatch(grams);
    setState(() => _result = res);

    // Save to history log
    final nowStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final displayWeight = grams >= 1000
        ? '${(grams / 1000.0).toStringAsFixed(2)} kg (${grams.toStringAsFixed(0)}g)'
        : '${grams.toStringAsFixed(0)} g';

    final log = HarvestLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      dateTime: nowStr,
      weightText: displayWeight,
      weightG: grams,
      fruitCount: res.fruitCount,
      proposedMl: res.proposedJuiceMl,
      slrMl: res.slrJuiceMl,
      polyMl: res.polyJuiceMl,
      mlrMl: res.mlrJuiceMl,
    );
    StorageService.saveLog(log);
    widget.onLogAdded?.call();
  }

  void _setPreset(double val, String unit) {
    setState(() {
      _selectedUnit = unit;
      _weightController.text = val.toString();
    });
    final grams = unit == 'kg' ? val * 1000.0 : val;
    _calculate(grams);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentGrams = _selectedUnit == 'kg'
        ? (double.tryParse(_weightController.text) ?? 5.0) * 1000.0
        : (double.tryParse(_weightController.text) ?? 5000.0);
    final batchAcc = PredictionService.getBatchAccuracy(currentGrams);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Study Info Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  const Text('🍋', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Leyte Normal University • Tacloban City Study',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        Text(
                          'Batch Weight Scale Input (Manual Size Categorization Removed)',
                          style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 1: Batch Weight Input
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Batch Harvest Weight',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              _unitButton('kg'),
                              _unitButton('g'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        suffixText: _selectedUnit,
                        suffixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        prefixIcon: const Icon(Icons.scale, color: Color(0xFF2E7D32)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        errorText: _errorMessage,
                      ),
                      onSubmitted: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Quick Presets:',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        _presetChip(1, 'kg'),
                        _presetChip(5, 'kg'),
                        _presetChip(10, 'kg'),
                        _presetChip(25, 'kg'),
                        _presetChip(50, 'kg'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => _calculate(),
                      icon: const Icon(Icons.bolt, color: Colors.white),
                      label: const Text(
                        'Estimate Juice Yield',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card 2: Champion Result Card
            if (_result != null) ...[
              Card(
                elevation: 2,
                color: const Color(0xFF1B5E20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD54F),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '★ PROPOSED CHAMPION MODEL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'R² = 82.28% • MAE = 0.49 mL',
                              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Polynomial (d=2) + ln(W) & L2 Ridge',
                        style: TextStyle(fontSize: 14, color: Color(0xFFA5D6A7), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_result!.proposedJuiceMl.toStringAsFixed(1)} mL',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '≈ ${(_result!.proposedJuiceMl / 1000.0).toStringAsFixed(2)} Liters of pure juice extracted',
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statTile('Fruit Count', '~${_result!.fruitCount} pcs'),
                          _statTile('Extraction Ratio', '${_result!.extractionRatioPercent.toStringAsFixed(1)}%'),
                          _statTile('Batch Reliability', '${batchAcc['accuracy']}%'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card 3: Commercial Bottling Projections
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Commercial Bottling Projections',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _bottleCard('330 mL Bottle', _result!.bottles330, Icons.local_drink)),
                          const SizedBox(width: 8),
                          Expanded(child: _bottleCard('500 mL Bottle', _result!.bottles500, Icons.water_drop)),
                          const SizedBox(width: 8),
                          Expanded(child: _bottleCard('1.0 L Jug', _result!.bottles1000, Icons.wine_bar)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card 4: Baseline Models Comparison
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Supporting Baseline Models Comparison',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Demonstrates the clear +6.05% performance gap of the Proposed Model',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      _modelRow(
                        name: '★ Proposed Poly + ln(W) & Ridge',
                        juiceMl: _result!.proposedJuiceMl,
                        r2: '82.28%',
                        mae: '0.4896 mL',
                        isChampion: true,
                      ),
                      const Divider(height: 16),
                      _modelRow(
                        name: 'Simple Linear Regression (SLR)',
                        juiceMl: _result!.slrJuiceMl,
                        r2: '80.74%',
                        mae: '0.5142 mL',
                      ),
                      const Divider(height: 16),
                      _modelRow(
                        name: 'Multiple Linear Regression (MLR)',
                        juiceMl: _result!.mlrJuiceMl,
                        r2: '79.71%',
                        mae: '0.5288 mL',
                      ),
                      const Divider(height: 16),
                      _modelRow(
                        name: 'Ordinary Polynomial (degree 2)',
                        juiceMl: _result!.polyJuiceMl,
                        r2: '76.23%',
                        mae: '0.5690 mL',
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _unitButton(String u) {
    final bool active = _selectedUnit == u;
    return GestureDetector(
      onTap: () {
        if (_selectedUnit == u) return;
        final currentVal = double.tryParse(_weightController.text) ?? 5.0;
        setState(() {
          _selectedUnit = u;
          if (u == 'g') {
            _weightController.text = (currentVal * 1000).toStringAsFixed(0);
          } else {
            _weightController.text = (currentVal / 1000).toStringAsFixed(2);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1B5E20) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          u,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _presetChip(double val, String unit) {
    return ActionChip(
      label: Text('$val $unit'),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      backgroundColor: Colors.grey.shade100,
      onPressed: () => _setPreset(val, unit),
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }

  Widget _bottleCard(String label, double count, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCEDC8)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF33691E), size: 24),
          const SizedBox(height: 6),
          Text(
            count.toStringAsFixed(1),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF558B2F))),
        ],
      ),
    );
  }

  Widget _modelRow({
    required String name,
    required double juiceMl,
    required String r2,
    required String mae,
    bool isChampion = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isChampion ? FontWeight.w900 : FontWeight.w600,
                  color: isChampion ? const Color(0xFF1B5E20) : Colors.black87,
                ),
              ),
              Text('R²: $r2 | MAE: $mae', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
        Text(
          '${juiceMl.toStringAsFixed(1)} mL',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isChampion ? const Color(0xFF1B5E20) : Colors.black87,
          ),
        ),
      ],
    );
  }
}
