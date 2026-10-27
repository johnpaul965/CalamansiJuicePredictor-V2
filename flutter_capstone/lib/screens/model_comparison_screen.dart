import 'package:flutter/material.dart';

class ModelComparisonScreen extends StatelessWidget {
  const ModelComparisonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: const Text(
                'Tacloban City Calamansi Harvest Study (Chapter 4 Model Benchmark)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Performance Benchmark Table Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Model Benchmark Comparison',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '5-Fold Cross-Validation on Cleaned Ground-Truth Harvest Data (N = 1,478)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _modelMetricCard(
                      title: '★ Proposed: Poly (d=2) + ln(W) & L2 Ridge',
                      role: 'Proposed Champion Architecture',
                      r2: '82.28%',
                      mae: '0.4896 mL',
                      rmse: '0.6160 mL',
                      isChampion: true,
                    ),
                    const SizedBox(height: 10),
                    _modelMetricCard(
                      title: 'Simple Linear Regression (SLR)',
                      role: 'Linear Baseline (Raw Fit, No Layers)',
                      r2: '80.74%',
                      mae: '0.5142 mL',
                      rmse: '0.6423 mL',
                    ),
                    const SizedBox(height: 10),
                    _modelMetricCard(
                      title: 'Multiple Linear Regression (MLR)',
                      role: 'Version 1 Supporting Baseline (Weight + Size)',
                      r2: '79.71%',
                      mae: '0.5288 mL',
                      rmse: '0.6593 mL',
                    ),
                    const SizedBox(height: 10),
                    _modelMetricCard(
                      title: 'Ordinary Polynomial Regression (degree 2)',
                      role: 'Raw Quadratic Baseline (Distorted by Outliers)',
                      r2: '76.23%',
                      mae: '0.5690 mL',
                      rmse: '0.7136 mL',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Visual R² Comparison Chart (Bar Chart)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'R² Accuracy Comparison (Higher is Better)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Shows the clear +6.05% performance advantage of the Proposed Model',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _visualBar(label: 'Proposed Poly+ln(W)+Ridge', value: 82.28, max: 100, isChampion: true),
                    _visualBar(label: 'Simple Linear (SLR)', value: 80.74, max: 100),
                    _visualBar(label: 'Multiple Linear (MLR)', value: 79.71, max: 100),
                    _visualBar(label: 'Ordinary Poly (d=2)', value: 76.23, max: 100),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Visual MAE Error Comparison Chart (Lower is Better)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mean Absolute Error (MAE in mL — Lower is Better)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Proposed model achieves the lowest average prediction error (<0.49 mL)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _visualBar(label: 'Proposed Poly+ln(W)+Ridge', value: 0.4896, max: 0.65, isChampion: true, isError: true),
                    _visualBar(label: 'Simple Linear (SLR)', value: 0.5142, max: 0.65, isError: true),
                    _visualBar(label: 'Multiple Linear (MLR)', value: 0.5288, max: 0.65, isError: true),
                    _visualBar(label: 'Ordinary Poly (d=2)', value: 0.5690, max: 0.65, isError: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Exact Mathematical Equations
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Trained Regression Formulas',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '1. ★ Proposed Model:\nJuice = 2.3179 + 1.1004(W) - 0.01415(W²) - 3.4460·ln(W)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2. Simple Linear Regression:\nJuice = 0.4162 × Weight - 0.0432',
                      style: TextStyle(fontSize: 12, color: Colors.black87, fontFamily: 'monospace'),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '3. Multiple Linear Regression:\nJuice = -0.5423 + 0.4530(Weight) + 0.0098(Size)',
                      style: TextStyle(fontSize: 12, color: Colors.black87, fontFamily: 'monospace'),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '4. Ordinary Polynomial (d=2):\nJuice = 2.1605 + 0.0419(W) + 0.0150(W²)',
                      style: TextStyle(fontSize: 12, color: Colors.black87, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _modelMetricCard({
    required String title,
    required String role,
    required String r2,
    required String mae,
    required String rmse,
    bool isChampion = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isChampion ? const Color(0xFFE8F5E9) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChampion ? const Color(0xFF81C784) : Colors.grey.shade200,
          width: isChampion ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isChampion ? const Color(0xFF1B5E20) : Colors.black87,
                  ),
                ),
              ),
              if (isChampion)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'WINNER',
                    style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(role, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricChip('R²', r2, isChampion),
              _metricChip('MAE', mae, isChampion),
              _metricChip('RMSE', rmse, isChampion),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value, bool isChampion) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isChampion ? const Color(0xFF1B5E20) : Colors.black87,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _visualBar({
    required String label,
    required double value,
    required double max,
    bool isChampion = false,
    bool isError = false,
  }) {
    final double pct = (value / max).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isChampion ? FontWeight.bold : FontWeight.w500,
                  color: isChampion ? const Color(0xFF1B5E20) : Colors.black87,
                ),
              ),
              Text(
                isError ? '${value.toStringAsFixed(4)} mL' : '${value.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isChampion ? const Color(0xFF1B5E20) : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isChampion ? const Color(0xFF2E7D32) : (isError ? Colors.orange.shade600 : Colors.blue.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
