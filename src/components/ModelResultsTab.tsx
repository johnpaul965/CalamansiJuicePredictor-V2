import React, { useState } from 'react';
import {
  Award,
  BookOpen,
  Layers,
  BarChart2,
  Scale,
  CheckCircle2,
  ShieldCheck,
  Sparkles,
  TreePine,
  Zap,
  TrendingUp,
  Activity,
  Cpu,
  ArrowLeft,
  FileSpreadsheet,
  AlertTriangle,
  Download,
} from 'lucide-react';
import {
  RESEARCH_METADATA,
  THESIS_MODELS,
  CB_POLY_PIPELINE_LAYERS,
  BATCH_SCALING_BENCHMARK,
} from '../services/predictionService';

interface ModelResultsTabProps {
  onBackToPredict?: () => void;
}

export const ModelResultsTab: React.FC<ModelResultsTabProps> = ({ onBackToPredict }) => {
  const [viewMode, setViewMode] = useState<'baseline' | 'defense'>('defense');

  return (
    <div className="space-y-6 pb-12 max-w-5xl mx-auto">
      {/* Portal Top Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 bg-white p-4 rounded-2xl border border-slate-200 shadow-2xs">
        <div className="flex items-center gap-3">
          {onBackToPredict && (
            <button
              type="button"
              onClick={onBackToPredict}
              className="p-2 text-slate-600 hover:text-emerald-800 hover:bg-emerald-50 rounded-xl transition cursor-pointer flex items-center gap-1.5 text-xs font-bold"
            >
              <ArrowLeft className="w-4 h-4" />
              <span className="hidden sm:inline">Back to Predictor</span>
            </button>
          )}
          <div>
            <span className="text-[11px] font-bold uppercase tracking-wider text-emerald-700 bg-emerald-50 px-2.5 py-0.5 rounded-full border border-emerald-200">
              Isolated Research Analytics Portal
            </span>
            <h1 className="text-base sm:text-lg font-extrabold text-slate-900 tracking-tight mt-0.5">
              Tacloban City Calamansi Harvest Study (Chapter 4 Model Evaluation)
            </h1>
          </div>
        </div>

        {/* Actions & Switcher */}
        <div className="flex items-center gap-2 flex-wrap">
          <a
            href="/Version_1_vs_Version_2_Complete_Changes_and_Differences.docx"
            download="Version_1_vs_Version_2_Complete_Changes_and_Differences.docx"
            className="px-3.5 py-1.5 bg-emerald-700 hover:bg-emerald-800 text-white font-bold rounded-xl text-xs transition shadow-2xs flex items-center gap-1.5 cursor-pointer"
            title="Download complete Version 1 vs Version 2 differences and changes report in Word format"
          >
            <Download className="w-3.5 h-3.5" />
            <span>Download V1 vs V2 Differences (.docx)</span>
          </a>

          {/* View Switcher */}
          <div className="flex bg-slate-100 p-1 rounded-xl border border-slate-200 text-xs">
            <button
              type="button"
              onClick={() => setViewMode('defense')}
              className={`px-3 py-1.5 font-bold rounded-lg transition cursor-pointer flex items-center gap-1.5 ${
                viewMode === 'defense'
                  ? 'bg-white text-emerald-800 shadow-xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <ShieldCheck className="w-3.5 h-3.5 text-emerald-600" />
              <span>LOOCV & Bio-Allometric Model</span>
            </button>
            <button
              type="button"
              onClick={() => setViewMode('baseline')}
              className={`px-3 py-1.5 font-bold rounded-lg transition cursor-pointer flex items-center gap-1.5 ${
                viewMode === 'baseline'
                  ? 'bg-white text-emerald-800 shadow-xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <BookOpen className="w-3.5 h-3.5" />
              <span>Chapter 4 Baseline</span>
            </button>
          </div>
        </div>
      </div>

      {/* ──────────────── TAB 1: DEFENSE & BIO-ALLOMETRIC SUITE ──────────────── */}
      {viewMode === 'defense' && (
        <>
          {/* Header Hero Banner */}
          <section className="bg-gradient-to-br from-slate-900 via-emerald-950 to-slate-900 text-white rounded-2xl p-6 sm:p-8 shadow-sm border border-emerald-700/40">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
              <div>
                <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 text-xs font-bold uppercase tracking-wider mb-2">
                  <Award className="w-3.5 h-3.5 text-amber-300" />
                  <span>Proposed Champion Architecture</span>
                </span>
                <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
                  Calamansi Bio-Allometric Polynomial (CB-Poly)
                </h2>
                <p className="text-slate-300 text-xs sm:text-sm mt-1 max-w-2xl leading-relaxed">
                  Evaluated across all 1,519 clean physical specimens under Leave-One-Out Cross-Validation. 
                  Incorporates citrus juice vesicle power-law growth dynamics via regularized allometric transformations.
                </p>
              </div>

              <div className="bg-emerald-900/60 border border-emerald-500/50 p-4 rounded-xl text-center shrink-0">
                <div className="text-xs uppercase tracking-wider text-emerald-300 font-semibold">
                  Coefficient of Determination (R²)
                </div>
                <div className="text-3xl font-extrabold font-mono text-amber-300 mt-0.5">
                  82.45%
                </div>
                <div className="text-[11px] text-emerald-200 mt-0.5 font-mono">
                  Correlation (r) = 0.9080 (Very Strong)
                </div>
              </div>
            </div>
          </section>

          {/* 4 Authentic Thesis Models Comparative Benchmark Suite */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mb-4">
              <div>
                <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
                  Statistical Model Evaluation & Benchmarking Suite (N = 1,519)
                </h3>
                <p className="text-xs text-slate-500">
                  Direct evaluation of the 4 core models on weight-to-juice continuous fluid estimation:
                </p>
              </div>
              <div className="px-3 py-1 bg-emerald-100 text-emerald-800 rounded-full text-xs font-bold self-start sm:self-auto">
                Leave-One-Out Cross-Validation (LOOCV)
              </div>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead>
                  <tr className="bg-slate-50 border-y border-slate-200 text-slate-500 font-semibold uppercase tracking-wider">
                    <th className="py-3 px-3.5">Model Architecture</th>
                    <th className="py-3 px-3.5">Role in Study</th>
                    <th className="py-3 px-3.5 text-right font-mono">Correlation (r)</th>
                    <th className="py-3 px-3.5 text-right font-mono">R² (%)</th>
                    <th className="py-3 px-3.5 text-right font-mono">MAE</th>
                    <th className="py-3 px-3.5 text-right font-mono">RMSE</th>
                    <th className="py-3 px-3.5 text-right font-mono">MAPE</th>
                    <th className="py-3 px-3.5 text-right">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {/* 1. SLR */}
                  <tr className="hover:bg-slate-50 transition">
                    <td className="py-3.5 px-3.5 font-bold text-slate-800">
                      {THESIS_MODELS.slr.name}
                    </td>
                    <td className="py-3.5 px-3.5 text-slate-600">
                      {THESIS_MODELS.slr.role}
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.slr.correlationR.toFixed(4)}
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-medium text-slate-800">
                      {THESIS_MODELS.slr.r2Percent.toFixed(2)}%
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.slr.maeMl.toFixed(4)} mL
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.slr.rmseMl.toFixed(4)} mL
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.slr.mapePercent.toFixed(2)}%
                    </td>
                    <td className="py-3.5 px-3.5 text-right">
                      <span className="px-2 py-0.5 rounded bg-slate-100 text-slate-700 font-semibold text-[10px]">
                        Control Baseline
                      </span>
                    </td>
                  </tr>

                  {/* 2. Poly (d=2) */}
                  <tr className="hover:bg-slate-50 transition">
                    <td className="py-3.5 px-3.5 font-bold text-slate-800">
                      {THESIS_MODELS.poly.name}
                    </td>
                    <td className="py-3.5 px-3.5 text-slate-600">
                      {THESIS_MODELS.poly.role}
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.poly.correlationR.toFixed(4)}
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-medium text-slate-800">
                      {THESIS_MODELS.poly.r2Percent.toFixed(2)}%
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.poly.maeMl.toFixed(4)} mL
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.poly.rmseMl.toFixed(4)} mL
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.poly.mapePercent.toFixed(2)}%
                    </td>
                    <td className="py-3.5 px-3.5 text-right">
                      <span className="px-2 py-0.5 rounded bg-blue-50 text-blue-800 font-semibold text-[10px]">
                        Quadratic Curve
                      </span>
                    </td>
                  </tr>

                  {/* 3. CatBoost / XGBoost */}
                  <tr className="hover:bg-slate-50 transition">
                    <td className="py-3.5 px-3.5 font-bold text-slate-800">
                      {THESIS_MODELS.catboost.name}
                    </td>
                    <td className="py-3.5 px-3.5 text-slate-600">
                      {THESIS_MODELS.catboost.role}
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.catboost.correlationR.toFixed(4)}
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-medium text-slate-800">
                      {THESIS_MODELS.catboost.r2Percent.toFixed(2)}%
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.catboost.maeMl.toFixed(4)} mL
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.catboost.rmseMl.toFixed(4)} mL
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.catboost.mapePercent.toFixed(2)}%
                    </td>
                    <td className="py-3.5 px-3.5 text-right">
                      <span className="px-2 py-0.5 rounded bg-indigo-50 text-indigo-800 font-semibold text-[10px]">
                        Boosting Benchmark
                      </span>
                    </td>
                  </tr>

                  {/* 4. Random Forest */}
                  <tr className="hover:bg-slate-50 transition">
                    <td className="py-3.5 px-3.5 font-bold text-slate-800">
                      {THESIS_MODELS.rf.name}
                    </td>
                    <td className="py-3.5 px-3.5 text-slate-600">
                      {THESIS_MODELS.rf.role}
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.rf.correlationR.toFixed(4)}
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-medium text-slate-800">
                      {THESIS_MODELS.rf.r2Percent.toFixed(2)}%
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.rf.maeMl.toFixed(4)} mL
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.rf.rmseMl.toFixed(4)} mL
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {THESIS_MODELS.rf.mapePercent.toFixed(2)}%
                    </td>
                    <td className="py-3.5 px-3.5 text-right">
                      <span className="px-2 py-0.5 rounded bg-amber-50 text-amber-800 font-semibold text-[10px]">
                        ML Benchmark
                      </span>
                    </td>
                  </tr>

                  {/* 4. CB-Poly Champion */}
                  <tr className="bg-emerald-50/80 font-semibold hover:bg-emerald-50 transition border-t-2 border-emerald-400">
                    <td className="py-3.5 px-3.5 font-bold text-emerald-950 flex items-center gap-1.5">
                      <Award className="w-4 h-4 text-emerald-700 shrink-0" />
                      <span>{THESIS_MODELS.cbPoly.name}</span>
                    </td>
                    <td className="py-3.5 px-3.5 text-emerald-900 font-bold">
                      {THESIS_MODELS.cbPoly.role}
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-bold text-emerald-800">
                      {THESIS_MODELS.cbPoly.correlationR.toFixed(4)}
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-extrabold text-emerald-700 text-sm">
                      {THESIS_MODELS.cbPoly.r2Percent.toFixed(2)}%
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-bold text-emerald-800">
                      {THESIS_MODELS.cbPoly.maeMl.toFixed(4)} mL
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-bold text-emerald-800">
                      {THESIS_MODELS.cbPoly.rmseMl.toFixed(4)} mL
                    </td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-bold text-emerald-800">
                      {THESIS_MODELS.cbPoly.mapePercent.toFixed(2)}%
                    </td>
                    <td className="py-3.5 px-3.5 text-right">
                      <span className="px-2.5 py-1 rounded bg-emerald-700 text-white font-extrabold text-[10px] shadow-xs">
                        ★ TOP 1 CHAMPION
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div className="mt-4 p-3.5 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-600 flex flex-wrap items-center justify-between gap-2">
              <span>Thesis Institutional Standard: Target R² ≥ 80.00%</span>
              <span className="font-bold text-emerald-700 font-mono">
                CB-Poly: 82.45% (+3.47% over Linear, +4.05% over Random Forest)
              </span>
            </div>
          </section>

          {/* 4-Layer Bio-Allometric Architecture Pipeline */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <div className="flex items-center gap-2 mb-2">
              <Layers className="w-5 h-5 text-emerald-700" />
              <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
                Bio-Allometric Architectural Pipeline
              </h3>
            </div>
            <p className="text-xs text-slate-500 mb-5">
              Structural layers connecting raw harvest mass measurements to regularized continuous juice yield:
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {CB_POLY_PIPELINE_LAYERS.map((layer, index) => (
                <div key={layer.step} className="p-4 rounded-xl border border-slate-200 bg-slate-50/70 space-y-1.5">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-slate-900">{layer.step}</span>
                    <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-mono">
                      {layer.status}
                    </span>
                  </div>
                  <p className="text-xs text-slate-600 leading-relaxed">
                    {layer.desc}
                  </p>
                </div>
              ))}
            </div>

            {/* Formula Block */}
            <div className="mt-5 p-4 rounded-xl bg-emerald-50 border border-emerald-200 space-y-1.5">
              <div className="text-xs font-bold text-emerald-950 uppercase tracking-wider">
                Champion Algebraic Specification
              </div>
              <code className="block p-3 rounded-lg bg-white border border-emerald-300 font-mono text-xs sm:text-sm text-emerald-900 font-bold overflow-x-auto">
                Juice (mL) = -0.2805 + 0.6002(W) - 0.00410(W²) - 0.5700·ln(W)
              </code>
              <p className="text-[11px] text-emerald-800 mt-1">
                Where <strong>W</strong> represents sample mass in grams, <strong>W²</strong> damps high-mass compression resistance, and <strong>ln(W)</strong> incorporates the biological allometric expansion rate of citrus vesicles.
              </p>
            </div>
          </section>

          {/* Central Limit Theorem & Monte Carlo Batch Scaling Table */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mb-4">
              <div>
                <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
                  Central Limit Theorem & Batch Scale Accuracy (5,000-Run Monte Carlo Simulation)
                </h3>
                <p className="text-xs text-slate-500">
                  Empirical simulation demonstrating how random single-fruit peel variance is canceled out across commercial harvest batches:
                </p>
              </div>
              <div className="px-3 py-1 bg-emerald-100 text-emerald-800 rounded-full text-xs font-bold self-start sm:self-auto">
                N = 5,000 Iterations
              </div>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead>
                  <tr className="bg-slate-50 border-y border-slate-200 text-slate-500 font-semibold uppercase tracking-wider">
                    <th className="py-3 px-3.5">Harvest Scale</th>
                    <th className="py-3 px-3.5">Batch Weight</th>
                    <th className="py-3 px-3.5 text-right font-mono">Calamansi Count</th>
                    <th className="py-3 px-3.5 text-right font-mono">Mean Error (MAPE)</th>
                    <th className="py-3 px-3.5 text-right font-mono text-emerald-700">Operational Precision</th>
                    <th className="py-3 px-3.5 text-right">Physical Mechanism</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {BATCH_SCALING_BENCHMARK.map((b) => (
                    <tr key={b.scale} className="hover:bg-slate-50 transition">
                      <td className="py-3.5 px-3.5 font-bold text-slate-800">
                        {b.scale}
                      </td>
                      <td className="py-3.5 px-3.5 text-slate-600 font-mono">
                        {b.weightKg >= 1 ? `${b.weightKg.toFixed(2)} kg` : `${b.weightG.toFixed(1)} g`}
                      </td>
                      <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                        ~{b.count} fruits
                      </td>
                      <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                        {b.mape.toFixed(2)}%
                      </td>
                      <td className="py-3.5 px-3.5 text-right font-mono font-bold text-emerald-700 text-sm">
                        {b.accuracy.toFixed(2)}%
                      </td>
                      <td className="py-3.5 px-3.5 text-right text-slate-500">
                        {b.count === 1
                          ? 'Single peel thickness variance'
                          : b.count < 100
                          ? 'Partial error compensation'
                          : 'Asymptotic variance cancellation'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <p className="mt-4 text-xs text-slate-500 leading-relaxed">
              <strong>Finding:</strong> Although isolated individual calamansi fruits exhibit ~10.85% biological variance due to unmeasured peel thickness, processing in batches leverages the Central Limit Theorem. On commercial crates (6.33 kg / ~500 fruits), errors between thick-peeled and thin-peeled fruits cancel out, yielding <strong>99.44% operational precision</strong>.
            </p>
          </section>
        </>
      )}

      {/* ──────────────── TAB 2: CHAPTER 4 RESEARCH BASELINE ──────────────── */}
      {viewMode === 'baseline' && (
        <>
          <section className="bg-gradient-to-br from-emerald-800 to-emerald-950 text-white rounded-2xl p-6 sm:p-8 shadow-sm">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
              <div>
                <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-700/60 text-emerald-200 text-xs font-bold uppercase tracking-wider mb-2">
                  <BookOpen className="w-3.5 h-3.5" />
                  <span>Chapter 4 Manuscript Records</span>
                </span>
                <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
                  Tacloban City Calamansi Harvest Study
                </h2>
                <p className="text-emerald-100/90 text-xs sm:text-sm mt-1 max-w-2xl leading-relaxed">
                  Dataset collected from fresh calamansi harvests in Tacloban City, Leyte. 
                  Initial manuscript partition based on 80% training (N=1,217) and 20% testing (N=305).
                </p>
              </div>

              <div className="bg-emerald-900/80 border border-emerald-600/50 p-4 rounded-xl text-center shrink-0">
                <div className="text-xs uppercase tracking-wider text-emerald-300 font-semibold">
                  Field Sample Harvest
                </div>
                <div className="text-2xl font-bold font-mono text-amber-300 mt-0.5">
                  1,522 Fruits
                </div>
                <div className="text-[11px] text-emerald-200 mt-0.5">
                  1,519 Clean Physical Specimens
                </div>
              </div>
            </div>
          </section>

          {/* Dataset Descriptive Metrics */}
          <section className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-extrabold font-mono text-emerald-700">
                1,522
              </div>
              <div className="text-xs font-semibold text-slate-700 mt-1">Total Harvest Records</div>
              <div className="text-[11px] text-slate-400 mt-0.5">Field Collection Logs</div>
            </div>

            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-extrabold font-mono text-emerald-700">
                1,519
              </div>
              <div className="text-xs font-semibold text-slate-700 mt-1">Clean Physical Fruits</div>
              <div className="text-[11px] text-slate-400 mt-0.5">3 recording typos filtered</div>
            </div>

            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-extrabold font-mono text-emerald-700">
                12.65 g
              </div>
              <div className="text-xs font-semibold text-slate-700 mt-1">Mean Calamansi Weight</div>
              <div className="text-[11px] text-slate-400 mt-0.5">Standard error: ±0.07 g</div>
            </div>

            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-extrabold font-mono text-emerald-700">
                5.22 mL
              </div>
              <div className="text-xs font-semibold text-slate-700 mt-1">Mean Pure Juice</div>
              <div className="text-[11px] text-slate-400 mt-0.5">41.26% extraction ratio</div>
            </div>
          </section>

          {/* Data Hygiene Audit Section */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <div className="flex items-center gap-2 mb-2">
              <AlertTriangle className="w-5 h-5 text-amber-600" />
              <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
                Section 4.5 Data Hygiene Audit (Outlier Identification)
              </h3>
            </div>
            <p className="text-xs text-slate-500 mb-4">
              Comprehensive audit of the 1,522 field records identified 3 human manual recording transcription errors:
            </p>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div className="p-3.5 bg-red-50 border border-red-200 rounded-xl text-xs space-y-1">
                <div className="font-bold text-red-900">Row 997: Physically Impossible</div>
                <div className="font-mono text-red-700">Weight: 2.0g | Juice: 16.0 mL</div>
                <div className="text-[11px] text-red-600">800% extraction ratio (transcription typo)</div>
              </div>
              <div className="p-3.5 bg-red-50 border border-red-200 rounded-xl text-xs space-y-1">
                <div className="font-bold text-red-900">Row 1013: Physically Impossible</div>
                <div className="font-mono text-red-700">Weight: 3.0g | Juice: 17.0 mL</div>
                <div className="text-[11px] text-red-600">567% extraction ratio (transcription typo)</div>
              </div>
              <div className="p-3.5 bg-red-50 border border-red-200 rounded-xl text-xs space-y-1">
                <div className="font-bold text-red-900">Row 1025: Physically Impossible</div>
                <div className="font-mono text-red-700">Weight: 4.0g | Juice: 15.0 mL</div>
                <div className="text-[11px] text-red-600">375% extraction ratio (transcription typo)</div>
              </div>
            </div>

            <p className="mt-4 text-xs text-slate-600 leading-relaxed">
              Filtering these three data-entry transcription errors preserves 1,519 genuine biological calamansi samples and removes artificial distortion from the regression solver.
            </p>
          </section>

          {/* Mathematical Regression Equations */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <h3 className="text-lg font-extrabold text-slate-900 tracking-tight mb-1">
              Trained Mathematical Regression Equations
            </h3>
            <p className="text-xs text-slate-500 mb-5">
              Standardized algebraic formulas for single-fruit mass-to-juice yield estimation:
            </p>

            <div className="space-y-4">
              <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
                <div className="text-xs font-bold text-slate-700 mb-1">
                  1. Simple Linear Regression (SLR):
                </div>
                <code className="block p-3 rounded-lg bg-white border border-slate-200 font-mono text-xs sm:text-sm text-slate-800 font-bold">
                  Juice (mL) = 0.4493 × Weight - 0.4927
                </code>
              </div>

              <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
                <div className="text-xs font-bold text-slate-700 mb-1">
                  2. Polynomial Regression (Degree 2):
                </div>
                <code className="block p-3 rounded-lg bg-white border border-slate-200 font-mono text-xs sm:text-sm text-slate-800 font-bold">
                  Juice (mL) = -0.8195 + 0.5043(W) - 0.00219(W²)
                </code>
              </div>

              <div className="p-4 rounded-xl bg-emerald-50 border border-emerald-300">
                <div className="text-xs font-bold text-emerald-950 mb-1 flex items-center gap-1.5">
                  <Award className="w-3.5 h-3.5 text-emerald-700" />
                  <span>3. Calamansi Bio-Allometric Polynomial (CB-Poly) — Champion:</span>
                </div>
                <code className="block p-3 rounded-lg bg-white border border-emerald-200 font-mono text-xs sm:text-sm text-emerald-900 font-bold overflow-x-auto">
                  Juice (mL) = -0.2805 + 0.6002(W) - 0.00410(W²) - 0.5700·ln(W)
                </code>
              </div>
            </div>
          </section>
        </>
      )}
    </div>
  );
};
