import React, { useState } from 'react';
import {
  Award,
  BookOpen,
  Layers,
  ShieldCheck,
  ArrowLeft,
  AlertTriangle,
} from 'lucide-react';
import {
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
              <span>4-Model Benchmark & Layers</span>
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
              <span>Chapter 4 Data Cleaning & Formulas</span>
            </button>
          </div>
        </div>
      </div>

      {/* ──────────────── TAB 1: DEFENSE & 4-MODEL SUITE ──────────────── */}
      {viewMode === 'defense' && (
        <>
          {/* Header Hero Banner */}
          <section className="bg-gradient-to-br from-slate-900 via-emerald-950 to-slate-900 text-white rounded-2xl p-6 sm:p-8 shadow-sm border border-emerald-700/40">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
              <div>
                <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 text-xs font-bold uppercase tracking-wider mb-2">
                  <Award className="w-3.5 h-3.5 text-amber-300" />
                  <span>Best Performing Model (Weight-Grouped 5-Fold Cross-Validation)</span>
                </span>
                <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
                  Polynomial Regression (d=2) + ln(W) & L2 Ridge
                </h2>
                <p className="text-slate-300 text-xs sm:text-sm mt-1 max-w-2xl leading-relaxed">
                  All 4 models receive the exact same training folds and are tested on the exact same <code className="font-mono text-emerald-200">N = 1,478</code> verified clean ground-truth fruits under <strong>Weight-Grouped 5-Fold Cross-Validation</strong> (testing unseen fruit weights). Models 1–3 run as ordinary baselines (no extra layers), while Model 4 applies in-fold training hygiene + <code className="font-mono text-emerald-200">ln(W)</code> + <code className="font-mono text-emerald-200">L2 Ridge (α = 0.01)</code>.
                </p>
              </div>

              <div className="bg-emerald-900/60 border border-emerald-500/50 p-4 rounded-xl text-center shrink-0">
                <div className="text-xs uppercase tracking-wider text-emerald-300 font-semibold">
                  Weight-Grouped 5-Fold R²
                </div>
                <div className="text-3xl font-extrabold font-mono text-amber-300 mt-0.5">
                  82.28%
                </div>
                <div className="text-[11px] text-emerald-200 mt-0.5 font-mono">
                  MAE = 0.4896 mL • RMSE = 0.6160 mL
                </div>
              </div>
            </div>
          </section>

          {/* 4 Authentic Thesis Models Comparative Benchmark Suite */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mb-4">
              <div>
                <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
                  4-Model Benchmark Suite: 3 Ordinary Baselines vs. 1 Layered Model (N = 1,478)
                </h3>
                <p className="text-xs text-slate-500">
                  Evaluated fairly on the exact same N = 1,478 test fruits using Weight-Grouped 5-Fold Cross-Validation (<code className="font-mono">((W + 1) // 2) % 5</code>) so models must predict unseen fruit weights:
                </p>
              </div>
              <div className="px-3 py-1 bg-emerald-100 text-emerald-800 rounded-full text-xs font-bold self-start sm:self-auto">
                Unseen-Weight 5-Fold CV
              </div>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead>
                  <tr className="bg-slate-50 border-y border-slate-200 text-slate-500 font-semibold uppercase tracking-wider">
                    <th className="py-3 px-3.5">Model Architecture</th>
                    <th className="py-3 px-3.5">Configuration & Layers</th>
                    <th className="py-3 px-3.5 text-right font-mono">R² (%)</th>
                    <th className="py-3 px-3.5 text-right font-mono">MAE</th>
                    <th className="py-3 px-3.5 text-right font-mono">RMSE</th>
                    <th className="py-3 px-3.5 text-right font-mono">MAPE</th>
                    <th className="py-3 px-3.5 text-right">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {[
                    { m: THESIS_MODELS.slr, cls: 'bg-slate-100 text-slate-700', tag: 'No Layers (-1.54%)' },
                    { m: THESIS_MODELS.svr, cls: 'bg-purple-50 text-purple-800', tag: 'No Layers (-1.75%)' },
                    { m: THESIS_MODELS.poly, cls: 'bg-blue-50 text-blue-800', tag: 'No Layers (-6.05%)' },
                  ].map(({ m, cls, tag }) => (
                    <tr key={m.name} className="hover:bg-slate-50 transition">
                      <td className="py-3.5 px-3.5 font-bold text-slate-800">{m.name}</td>
                      <td className="py-3.5 px-3.5 text-slate-600">{m.role}</td>
                      <td className="py-3.5 px-3.5 text-right font-mono font-medium text-slate-800">
                        {m.r2Percent.toFixed(2)}%
                      </td>
                      <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                        {m.maeMl.toFixed(4)} mL
                      </td>
                      <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                        {m.rmseMl.toFixed(4)} mL
                      </td>
                      <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                        {m.mapePercent.toFixed(2)}%
                      </td>
                      <td className="py-3.5 px-3.5 text-right">
                        <span className={`px-2 py-0.5 rounded font-semibold text-[10px] ${cls}`}>
                          {tag}
                        </span>
                      </td>
                    </tr>
                  ))}

                  {/* 4. Polynomial Regression (d=2) + ln(W) & L2 Ridge */}
                  <tr className="bg-emerald-50/80 font-semibold hover:bg-emerald-50 transition border-t-2 border-emerald-400">
                    <td className="py-3.5 px-3.5 font-bold text-emerald-950 flex items-center gap-1.5">
                      <Award className="w-4 h-4 text-emerald-700 shrink-0" />
                      <span>{THESIS_MODELS.cbPoly.name}</span>
                    </td>
                    <td className="py-3.5 px-3.5 text-emerald-900 font-bold">
                      {THESIS_MODELS.cbPoly.role}
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
                        ★ BEST FIT
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-3 text-xs">
              <div className="p-3.5 bg-purple-50/60 border border-purple-200 rounded-xl text-slate-700 leading-relaxed">
                <strong className="text-purple-950">Why Ordinary Polynomial Drops to 76.23%:</strong>{' '}
                Without in-fold training cleaning and L2 Ridge, squaring weight (<code className="font-mono">W²</code>) bends the ordinary quadratic curve toward raw field typos (<code className="font-mono">2g→16mL</code>), dropping it <code className="font-mono">-6.05%</code> behind Model 4.
              </div>
              <div className="p-3.5 bg-emerald-50/60 border border-emerald-200 rounded-xl text-slate-700 leading-relaxed">
                <strong className="text-emerald-950">Why SVR & SLR Lag Behind Proposed Model:</strong>{' '}
                While SVR (<code className="font-mono">80.53%</code>) and SLR (<code className="font-mono">80.74%</code>) offer solid baselines on raw weight, they miss the natural logarithmic term <code className="font-mono">ln(W)</code> and botanical mass-balance screening, which deliver <code className="font-mono">82.28% R²</code> in Model 4.
              </div>
            </div>

            <div className="mt-3 p-3.5 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-600 flex flex-wrap items-center justify-between gap-2">
              <span>Thesis Institutional Standard: Target R² ≥ 80.00% (Unseen-Weight 5-Fold CV)</span>
              <span className="font-bold text-emerald-700 font-mono">
                Poly (d=2) + ln(W) + Ridge: 82.28% (MAE = 0.4896 mL, RMSE = 0.6160 mL — #1 Winner)
              </span>
            </div>
          </section>

          {/* Scientific Dataset Protocol + Targeted Layers */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <div className="flex items-center gap-2 mb-2">
              <Layers className="w-5 h-5 text-emerald-700" />
              <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
                4-Layer Pipeline Inside Proposed Model (.fit() Only — Same Test Set Across All 4 Models)
              </h3>
            </div>
            <p className="text-xs text-slate-500 mb-5">
              All 4 models are tested on the exact same N = 1,478 clean ground-truth set; only Model 4 applies these 4 layers during training:
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {CB_POLY_PIPELINE_LAYERS.map((layer) => (
                <div key={layer.step} className="p-4 rounded-xl border border-slate-200 bg-slate-50/70 space-y-1.5">
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-xs font-bold text-slate-900">{layer.step}</span>
                    <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-mono shrink-0">
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
                Polynomial Regression (d=2) + ln(W) & L2 Ridge — Final Calibrated Equation (N = 1,478)
              </div>
              <code className="block p-3 rounded-lg bg-white border border-emerald-300 font-mono text-xs sm:text-sm text-emerald-900 font-bold overflow-x-auto">
                Juice (mL) = 2.3179 + 1.1004(W) - 0.01415(W²) - 3.4460·ln(W)
              </code>
              <p className="text-[11px] text-emerald-800 mt-1">
                Exact <code className="font-mono">scikit-learn Ridge(alpha=0.01)</code> closed-form solution on <code className="font-mono">[W, W², ln(W)]</code>.
              </p>
            </div>
          </section>

          {/* Central Limit Theorem & Monte Carlo Batch Scaling Table */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mb-4">
              <div>
                <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
                  Central Limit Theorem & Batch Scale Accuracy (Monte Carlo Simulation)
                </h3>
                <p className="text-xs text-slate-500">
                  Empirical simulation demonstrating how random single-fruit peel variance cancels out across commercial harvest batches:
                </p>
              </div>
              <div className="px-3 py-1 bg-emerald-100 text-emerald-800 rounded-full text-xs font-bold self-start sm:self-auto">
                N = 1,478 Empirical Sampling
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
                      <td className="py-3.5 px-3.5 font-bold text-slate-800">{b.scale}</td>
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
              <strong>Finding:</strong> Although isolated individual calamansi fruits exhibit ~10.55% biological variance due to unmeasured peel thickness, processing in batches leverages the Central Limit Theorem. On commercial crates (6.34 kg / ~500 fruits), errors between thick-peeled and thin-peeled fruits cancel out, yielding <strong>99.45% operational precision</strong>.
            </p>
          </section>
        </>
      )}

      {/* ──────────────── TAB 2: CHAPTER 4 MANUAL DATA AUDIT ──────────────── */}
      {viewMode === 'baseline' && (
        <>
          <section className="bg-gradient-to-br from-emerald-800 to-emerald-950 text-white rounded-2xl p-6 sm:p-8 shadow-sm">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
              <div>
                <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-700/60 text-emerald-200 text-xs font-bold uppercase tracking-wider mb-2">
                  <BookOpen className="w-3.5 h-3.5" />
                  <span>Chapter 4 Manuscript & Manual Cleaning Protocol</span>
                </span>
                <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
                  Tacloban City Calamansi Harvest Study
                </h2>
                <p className="text-emerald-100/90 text-xs sm:text-sm mt-1 max-w-2xl leading-relaxed">
                  Dataset collected from fresh calamansi harvests in Tacloban City, Leyte (1,522 raw field logs; 1,478 verified clean ground-truth specimens via manual/statistical non-AI screening).
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
                  1,478 Clean Specimens (97.1% Retained)
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
              <div className="text-[11px] text-slate-400 mt-0.5">Raw Field Collection Logs</div>
            </div>

            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-extrabold font-mono text-emerald-700">
                1,478
              </div>
              <div className="text-xs font-semibold text-slate-700 mt-1">Verified Clean Ground-Truth</div>
              <div className="text-[11px] text-slate-400 mt-0.5">8 mass-balance + 36 98%-CI filtered</div>
            </div>

            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-extrabold font-mono text-emerald-700">
                12.69 g
              </div>
              <div className="text-xs font-semibold text-slate-700 mt-1">Mean Calamansi Weight</div>
              <div className="text-[11px] text-slate-400 mt-0.5">Clean sample mean</div>
            </div>

            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-extrabold font-mono text-emerald-700">
                5.22 mL
              </div>
              <div className="text-xs font-semibold text-slate-700 mt-1">Mean Pure Juice</div>
              <div className="text-[11px] text-slate-400 mt-0.5">41.19% extraction ratio</div>
            </div>
          </section>

          {/* Data Hygiene Audit Section */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <div className="flex items-center gap-2 mb-2">
              <AlertTriangle className="w-5 h-5 text-amber-600" />
              <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
                Section 4.5 Non-AI Manual & Statistical Data Cleaning Protocol (Excel / Python)
              </h3>
            </div>
            <p className="text-xs text-slate-500 mb-4">
              Zero AI was used to clean the data. Every removed row is identified deterministically in Microsoft Excel or Python using two textbook rules:
            </p>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div className="p-3.5 bg-red-50 border border-red-200 rounded-xl text-xs space-y-1">
                <div className="font-bold text-red-900">Excel Row 997: Impossible Typo</div>
                <div className="font-mono text-red-700">Weight: 2.0g | Juice: 16.0 mL</div>
                <div className="text-[11px] text-red-600">Ratio = 16/2 = 800% (&gt;60% limit)</div>
              </div>
              <div className="p-3.5 bg-red-50 border border-red-200 rounded-xl text-xs space-y-1">
                <div className="font-bold text-red-900">Excel Row 1013: Impossible Typo</div>
                <div className="font-mono text-red-700">Weight: 3.0g | Juice: 17.0 mL</div>
                <div className="text-[11px] text-red-600">Ratio = 17/3 = 567% (&gt;60% limit)</div>
              </div>
              <div className="p-3.5 bg-red-50 border border-red-200 rounded-xl text-xs space-y-1">
                <div className="font-bold text-red-900">Excel Row 1025: Impossible Typo</div>
                <div className="font-mono text-red-700">Weight: 4.0g | Juice: 15.0 mL</div>
                <div className="text-[11px] text-red-600">Ratio = 15/4 = 375% (&gt;60% limit)</div>
              </div>
            </div>

            <div className="mt-4 p-4 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-700 space-y-2 leading-relaxed">
              <div>
                <strong>1. Manual Excel Formula — Step 1A (Botanical Mass-Balance Law, 1,522 → 1,514):</strong>{' '}
                In Column D, compute <code className="font-mono bg-white px-1.5 py-0.5 rounded border border-slate-200">=C2/A2</code> (Juice ÷ Weight). Because calamansi peel, pith, membranes, and seeds account for ≥40% of whole fruit weight, any row with <code className="font-mono">Ratio &gt; 0.60</code> (3 typos &gt;100% + 5 cylinder-carryover readings at 62%–77%) is filtered out.
              </div>
              <div>
                <strong>2. Manual Excel Formula — Step 1B (Textbook 98% Confidence Interval, α = 0.02, 1,514 → 1,478):</strong>{' '}
                Within each gram weight group, compute <code className="font-mono bg-white px-1.5 py-0.5 rounded border border-slate-200">Z = ABS(Juice - GroupMean) / GroupStdDev</code> using <code className="font-mono">AVERAGEIFS</code> and <code className="font-mono">STDEV.S</code>. From any introductory Statistics Z-table, a two-tailed 98% Confidence Interval (<code className="font-mono">α = 0.02</code>) has critical value <code className="font-mono">Z = 2.326</code>, removing 36 extreme anomalies.
              </div>
            </div>
          </section>

          {/* Mathematical Regression Equations */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <h3 className="text-lg font-extrabold text-slate-900 tracking-tight mb-1">
              Trained Mathematical Regression Equations
            </h3>
            <p className="text-xs text-slate-500 mb-5">
              Closed-form equations for Ordinary Raw Baselines (N = 1,522) vs. Proposed Layered Pipeline (N = 1,478):
            </p>

            <div className="space-y-4">
              <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
                <div className="text-xs font-bold text-slate-700 mb-1">
                  1. Simple Linear Regression (Ordinary Baseline — Raw Fit, No Layers):
                </div>
                <code className="block p-3 rounded-lg bg-white border border-slate-200 font-mono text-xs sm:text-sm text-slate-800 font-bold">
                  Juice (mL) = 0.4162 × Weight - 0.0432
                </code>
              </div>

              <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
                <div className="text-xs font-bold text-slate-700 mb-1">
                  2. Support Vector Regression (Ordinary Baseline — Default RBF Kernel, No Layers):
                </div>
                <code className="block p-3 rounded-lg bg-white border border-slate-200 font-mono text-xs sm:text-sm text-slate-800 font-bold">
                  Kernel: Radial Basis Function (RBF), C = 1.0, ε = 0.1 on raw Weight (W)
                </code>
              </div>

              <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
                <div className="text-xs font-bold text-slate-700 mb-1">
                  3. Polynomial Regression Degree 2 (Ordinary Baseline — Raw Fit, No Extra Layers):
                </div>
                <code className="block p-3 rounded-lg bg-white border border-slate-200 font-mono text-xs sm:text-sm text-slate-800 font-bold">
                  Juice (mL) = 2.1605 + 0.0419(W) + 0.01500(W²)
                </code>
              </div>

              <div className="p-4 rounded-xl bg-emerald-50 border border-emerald-300">
                <div className="text-xs font-bold text-emerald-950 mb-1 flex items-center gap-1.5">
                  <Award className="w-3.5 h-3.5 text-emerald-700" />
                  <span>4. Polynomial Regression (Degree 2) + ln(W) & L2 Ridge (Proposed Pipeline, α = 0.01):</span>
                </div>
                <code className="block p-3 rounded-lg bg-white border border-emerald-200 font-mono text-xs sm:text-sm text-emerald-900 font-bold overflow-x-auto">
                  Juice (mL) = 2.3179 + 1.1004(W) - 0.01415(W²) - 3.4460·ln(W)
                </code>
              </div>
            </div>
          </section>
        </>
      )}
    </div>
  );
};
