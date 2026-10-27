import 'package:flutter/material.dart';

class TrainingInfoScreen extends StatelessWidget {
  const TrainingInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        title: const Text('Model Training & Thesis Guide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Leyte Normal University Thesis Capstone',
                    style: TextStyle(color: Color(0xFFA5D6A7), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Live Model Training & Validation Pipeline',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Empirical Field Data: 1,522 harvested calamansi samples from Tacloban City.\nFiltered Clean Specimens: 1,478 verified fruits (via textbook physical ratio <= 0.60 and 98% CI Z-Score <= 2.326).',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 1: Why Size Category was Removed
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('1. Why Fruit Size Was Removed in V2', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text(
                      '• In Version 1, farmers had to categorize each calamansi as Small, Medium, or Large.\n'
                      '• Sorting hundreds of tiny fruits by hand in the field is impractical for farmers.\n'
                      '• Statistical analysis proved Size added less than 0.01% accuracy over Weight alone.\n'
                      '• In Version 2, farmers simply input the total batch weight in kg or grams, and the system automatically calculates fruit count using the study\'s mean fruit mass (12.686 g).',
                      style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Step 2: The Proposed Model Formula
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('2. Proposed Model Formula', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'Juice (mL) = 2.3179 + 1.1004(W) - 0.01415(W²) - 3.4460·ln(W)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 1.1004(W): Linear juice scaling with weight.\n'
                      '• -0.01415(W²): Accounts for thicker peel on large fruits.\n'
                      '• -3.4460·ln(W): Natural logarithm prevents unrealistic extremes for small fruits.\n'
                      '• L2 Ridge (alpha = 0.01): Prevents overfitting and guarantees smooth interpolation.',
                      style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Step 3: Run Training Script in Terminal
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('3. Python Training Command', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'python train_models.py',
                        style: TextStyle(
                          color: Color(0xFF69F0AE),
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Runs full 5-fold cross-validation on dataset.csv and outputs exact matrices without needing external AI or heavy libraries.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
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
}
