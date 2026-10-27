import 'package:flutter/material.dart';
import '../models/prediction_result.dart';
import '../services/prediction_service.dart';

class ModelComparisonScreen extends StatelessWidget {
  const ModelComparisonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF15803D),
          elevation: 0,
          title: const Text(
            '4-Model Benchmark Suite',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'Benchmarks (N=1,478)'),
              Tab(text: 'Data Hygiene'),
              Tab(text: 'Formulas'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BenchmarkTab(),
            _DataHygieneTab(),
            _FormulasTab(),
          ],
        ),
      ),
    );
  }
}

class _BenchmarkTab extends StatelessWidget {
  const _BenchmarkTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final benchmarks = PredictionService.benchmarks;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '4-Model Benchmark Suite: 3 Ordinary Baselines vs. 1 Layered Model',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 6),
                Text(
                  'Evaluated fairly on the exact same N = 1,478 test fruits using Weight-Grouped 5-Fold Cross-Validation (((W + 1) // 2) % 5) so models must predict unseen fruit weights.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4 Model Cards
          ...benchmarks.map((item) {
            final isChamp = item.isChampion;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isChamp ? const Color(0xFFECFDF5) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isChamp ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                  width: isChamp ? 2 : 1,
                ),
                boxShadow: isChamp
                    ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isChamp ? const Color(0xFF065F46) : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.configuration,
                              style: TextStyle(
                                fontSize: 11,
                                color: isChamp ? const Color(0xFF047857) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isChamp ? const Color(0xFF15803D) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isChamp ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isChamp ? Colors.white.withOpacity(0.8) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isChamp ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      item.formula,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isChamp ? const Color(0xFF047857) : const Color(0xFF334155),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricCol('R² (%)', '${item.r2.toStringAsFixed(2)}%', isChamp: isChamp),
                      _buildMetricCol('MAE', '${item.mae.toStringAsFixed(4)} mL', isChamp: isChamp),
                      _buildMetricCol('RMSE', '${item.rmse.toStringAsFixed(4)} mL', isChamp: isChamp),
                      _buildMetricCol('MAPE', '${item.mape.toStringAsFixed(2)}%', isChamp: isChamp),
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

  static Widget _buildMetricCol(String label, String value, {bool isChamp = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: isChamp ? const Color(0xFF065F46) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _DataHygieneTab extends StatelessWidget {
  const _DataHygieneTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final steps = PredictionService.dataHygieneSteps;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Chapter 4: Data Cleaning & Hygiene Audit',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 6),
                Text(
                  'Rigorous 3-step filtering pipeline designed to eliminate physical harvesting artifacts while preserving genuine biological variance in calamansi fruits.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...steps.map((s) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF15803D),
                        child: Text(
                          '${s.step}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.description,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Input', '${s.inputCount}'),
                        const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF94A3B8)),
                        _buildStat('Output', '${s.outputCount}'),
                        const Icon(Icons.remove_circle_outline, size: 16, color: Color(0xFFEF4444)),
                        _buildStat('Dropped', '-${s.dropCount}', color: const Color(0xFFEF4444)),
                        _buildStat('Retained', '${s.percentageRetained.toStringAsFixed(1)}%', color: const Color(0xFF15803D)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified, color: Color(0xFF15803D), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chapter 4 Audit Confirmed: N = 1,478 pristine data points ready for benchmark regression without data leakage.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStat(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: color ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _FormulasTab extends StatelessWidget {
  const _FormulasTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormulaCard(
            title: '1. Simple Linear Regression (SLR)',
            badge: 'Ordinary Baseline',
            equation: 'Juice = 0.416169 · W - 0.043154',
            notes: 'Unconstrained ordinary least squares regression directly connecting fresh weight to juice output.',
          ),
          const SizedBox(height: 12),
          _buildFormulaCard(
            title: '2. Support Vector Regression (SVR - RBF)',
            badge: 'Kernel ML',
            equation: 'f(W) = Σ (αᵢ - αᵢ*) · K(Wᵢ, W) + b\nK(Wᵢ, W) = exp(-γ · ||Wᵢ - W||²)',
            notes: 'Radial Basis Function kernel with epsilon-insensitive loss margin (ε = 0.1, C = 1.0).',
          ),
          const SizedBox(height: 12),
          _buildFormulaCard(
            title: '3. Polynomial Regression (Degree 2)',
            badge: 'Quadratic Baseline',
            equation: 'Juice = 2.160503 + 0.041943(W) + 0.014995(W²)',
            notes: 'Captures peel-to-volume curvature without natural logarithm transformation.',
          ),
          const SizedBox(height: 12),
          _buildFormulaCard(
            title: '4. Proposed Model: Poly (d=2) + ln(W) & L2 Ridge',
            badge: '★ Champion Architecture',
            isChampion: true,
            equation: 'Juice = 2.317885 + 1.100407(W) - 0.014151(W²) - 3.445975·ln(W)\nLoss = ||Y - Xβ||₂² + 0.01 · ||β||₂²',
            notes: 'Combines biological volume physics (ln W peel boundary) with L2 Ridge shrinkage (α = 0.01) to eliminate multicollinearity.',
          ),
        ],
      ),
    );
  }

  static Widget _buildFormulaCard({
    required String title,
    required String badge,
    required String equation,
    required String notes,
    bool isChampion = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isChampion ? const Color(0xFFECFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isChampion ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
          width: isChampion ? 2 : 1,
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isChampion ? const Color(0xFF065F46) : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isChampion ? const Color(0xFF15803D) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isChampion ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isChampion ? Colors.white.withOpacity(0.85) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isChampion ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0)),
            ),
            child: Text(
              equation,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isChampion ? const Color(0xFF047857) : const Color(0xFF1E293B),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
          ),
        ],
      ),
    );
  }
}
