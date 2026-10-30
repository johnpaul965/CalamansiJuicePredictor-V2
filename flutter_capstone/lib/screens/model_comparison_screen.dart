import 'package:flutter/material.dart';
import '../services/prediction_service.dart';
import '../theme/app_colors.dart';

class ModelComparisonScreen extends StatelessWidget {
  final VoidCallback? onBackToPredict;

  const ModelComparisonScreen({
    super.key,
    this.onBackToPredict,
  });

  @override
  Widget build(BuildContext context) {
    const modelsList = ThesisModels.all;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1024),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Portal Top Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
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
                      if (onBackToPredict != null) ...[
                        TextButton.icon(
                          onPressed: onBackToPredict,
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Predictor'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.slate600,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.emerald50,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: AppColors.emerald200,
                                    ),
                                  ),
                                  child: const Text(
                                    'WEIGHT-ONLY MODEL EVALUATION',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.emerald700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate100,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Clean samples (N = ${ResearchMetadata.cleanSamples})',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.slate500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tacloban City Calamansi Harvest Study • Model Evaluation',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.slate900,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: AppColors.emerald600,
                        ),
                        SizedBox(width: 6),
                        Text(
                          ResearchMetadata.institution,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Header Hero Banner: Best-Performing Model
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.slate900,
                    AppColors.emerald950,
                    AppColors.slate900,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.emerald700.withOpacity(0.45),
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emerald500.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.emerald500.withOpacity(0.35),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                size: 15,
                                color: AppColors.amber300,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'BEST-PERFORMING MODEL (WEIGHT-GROUPED 5-FOLD CV)',
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
                        Text(
                          ThesisModels.primary.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Evaluated using weight-grouped 5-fold cross-validation on ${ResearchMetadata.cleanSamples} verified clean calamansi samples with in-fold outlier cleaning and L2 Ridge regularization.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.slate300,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emerald900.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.emerald500.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'OUT-OF-FOLD R²',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emerald300,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ThesisModels.primary.r2Percent.toStringAsFixed(2)}%',
                          style: const TextStyle(
                            fontFamily: AppColors.monoFont,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amber300,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'MAE = ${ThesisModels.primary.maeMl.toStringAsFixed(4)} mL • RMSE = ${ThesisModels.primary.rmseMl.toStringAsFixed(4)} mL',
                          style: const TextStyle(
                            fontFamily: AppColors.monoFont,
                            fontSize: 11,
                            color: AppColors.emerald200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4 Models Comparative Table (Clean 5 columns: Regression Model | R² (%) | MAE | RMSE | MAPE)
            Container(
              padding: const EdgeInsets.all(24),
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
                    runSpacing: 8,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Four-Model Cross-Validation Results (N = ${ResearchMetadata.cleanSamples})',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slate900,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Out-of-fold metrics across all four weight-only regression models evaluated on verified calamansi samples.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.emerald100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Grouped 5-Fold CV',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emerald800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 720),
                      child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FlexColumnWidth(2.4),
                          1: FlexColumnWidth(1.1),
                          2: FlexColumnWidth(1.2),
                          3: FlexColumnWidth(1.2),
                          4: FlexColumnWidth(1.1),
                        },
                        border: const TableBorder(
                          top: BorderSide(color: AppColors.slate200),
                          bottom: BorderSide(color: AppColors.slate200),
                          horizontalInside:
                              BorderSide(color: AppColors.slate100),
                        ),
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: AppColors.slate50),
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Text(
                                  'REGRESSION MODEL',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slate500,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Text(
                                  'R² (%)',
                                  textAlign: TextAlign.right,
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
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Text(
                                  'MAE',
                                  textAlign: TextAlign.right,
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
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Text(
                                  'RMSE',
                                  textAlign: TextAlign.right,
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
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Text(
                                  'MAPE',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: AppColors.monoFont,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slate500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ...modelsList.map((m) {
                            final isBest = m.isBest;
                            return TableRow(
                              decoration: isBest
                                  ? const BoxDecoration(
                                      color: AppColors.emerald50,
                                    )
                                  : null,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isBest) ...[
                                        const Icon(
                                          Icons.workspace_premium,
                                          size: 16,
                                          color: AppColors.emerald700,
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Flexible(
                                        child: Text(
                                          m.name,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: isBest
                                                ? AppColors.emerald950
                                                : AppColors.slate800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                  child: Text(
                                    '${m.r2Percent.toStringAsFixed(2)}%',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: AppColors.monoFont,
                                      fontSize: isBest ? 13.5 : 12.5,
                                      fontWeight: isBest
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isBest
                                          ? AppColors.emerald700
                                          : AppColors.slate800,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                  child: Text(
                                    '${m.maeMl.toStringAsFixed(4)} mL',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: AppColors.monoFont,
                                      fontSize: 12.5,
                                      fontWeight: isBest
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isBest
                                          ? AppColors.emerald800
                                          : AppColors.slate700,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                  child: Text(
                                    '${m.rmseMl.toStringAsFixed(4)} mL',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: AppColors.monoFont,
                                      fontSize: 12.5,
                                      fontWeight: isBest
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isBest
                                          ? AppColors.emerald800
                                          : AppColors.slate700,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                  child: Text(
                                    '${m.mapePercent.toStringAsFixed(2)}%',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: AppColors.monoFont,
                                      fontSize: 12.5,
                                      fontWeight: isBest
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isBest
                                          ? AppColors.emerald800
                                          : AppColors.slate700,
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

            // Mathematical Regression Equations
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.functions,
                        size: 20,
                        color: AppColors.emerald700,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Trained Regression Equations (N = ${ResearchMetadata.cleanSamples})',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate900,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fitted coefficients and parameters used by the predictor, where W is calamansi weight in grams.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...modelsList.map((model) {
                    final isBest = model.isBest;
                    final titleLabel = isBest && model.alpha != null
                        ? '${model.name} (Ridge α = ${model.alpha})'
                        : model.name;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isBest
                              ? AppColors.emerald50
                              : AppColors.slate50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isBest
                                ? AppColors.emerald300
                                : AppColors.slate200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                if (isBest) ...[
                                  const Icon(
                                    Icons.workspace_premium,
                                    size: 15,
                                    color: AppColors.emerald700,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Expanded(
                                  child: Text(
                                    titleLabel,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: isBest
                                          ? AppColors.emerald950
                                          : AppColors.slate700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isBest
                                      ? AppColors.emerald200
                                      : AppColors.slate200,
                                ),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SelectableText(
                                  model.formula,
                                  style: TextStyle(
                                    fontFamily: AppColors.monoFont,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isBest
                                        ? AppColors.emerald900
                                        : AppColors.slate800,
                                  ),
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
