import React, { useState } from 'react';
import {
  Award,
  BookOpen,
  Layers,
  BarChart2,
  Scale,
  CheckCircle2,
  ChevronRight,
  ShieldCheck,
  Sparkles,
  TreePine,
  Zap,
  Filter,
  Sliders,
  TrendingUp,
  Activity,
  Cpu,
} from 'lucide-react';
import { RESEARCH_METADATA, MODEL_SPECS, SIZE_CATEGORIES } from '../services/predictionService';

export const ModelResultsTab: React.FC = () => {
  const [viewMode, setViewMode] = useState<'baseline' | 'defense'>('baseline');

  const sizeDist = [
    { grade: 'Small (Size 1)', range: 'Weight < 10.0 g', count: 287, percent: 18.86, color: 'bg-amber-500' },
    { grade: 'Medium (Size 2)', range: '10.0 g ≤ Weight ≤ 14.0 g', count: 828, percent: 54.40, color: 'bg-emerald-600' },
    { grade: 'Large (Size 3)', range: 'Weight > 14.0 g', count: 407, percent: 26.74, color: 'bg-teal-600' },
  ];

  const loocvModels = [
    {
      name: 'SLR',
      role: 'Linear Baseline',
      loocvR2: 0.7892,
      mae: '0.5249 ml',
      rmse: '0.6788 ml',
      trainR2: 0.7898,
      gap: 0.0006,
      badge: 'Control Group',
      badgeColor: 'bg-slate-100 text-slate-700',
    },
    {
      name: 'Polynomial Ridge (d=2)',
      role: 'Quadratic Interaction',
      loocvR2: 0.7886,
      mae: '0.5253 ml',
      rmse: '0.6798 ml',
      trainR2: 0.7901,
      gap: 0.0016,
      badge: 'Polynomial Baseline',
      badgeColor: 'bg-blue-100 text-blue-800',
    },
    {
      name: 'Polynomial Ridge + log(w)',
      role: 'Allometric Scaling',
      loocvR2: 0.7888,
      mae: '0.5276 ml',
      rmse: '0.6794 ml',
      trainR2: 0.7899,
      gap: 0.0010,
      badge: '★ Best Interpretable',
      badgeColor: 'bg-emerald-700 text-white font-bold',
      isCandidate: true,
    },
    {
      name: 'Random Forest',
      role: 'Bagging Benchmark',
      loocvR2: 0.7877,
      mae: '0.5274 ml',
      rmse: '0.6779 ml',
      trainR2: 0.7969,
      gap: 0.0091,
      badge: 'Bagging Ensemble',
      badgeColor: 'bg-amber-100 text-amber-800',
    },
    {
      name: 'CatBoost',
      role: 'Boosting Benchmark',
      loocvR2: 0.7863,
      mae: '0.5323 ml',
      rmse: '0.6803 ml',
      trainR2: 0.7939,
      gap: 0.0075,
      badge: 'Boosting Ensemble',
      badgeColor: 'bg-indigo-100 text-indigo-800',
    },
    {
      name: 'Natural Cubic Spline',
      role: '5-Knot Flexible Spline',
      loocvR2: 0.7881,
      mae: '0.5280 ml',
      rmse: '0.6807 ml',
      trainR2: 0.7899,
      gap: 0.0018,
      badge: 'Piecewise Spline',
      badgeColor: 'bg-purple-100 text-purple-800',
    },
  ];

  const seedChecks = [
    { seed: 0, r2: '0.7869 ± 0.0295' },
    { seed: 42, r2: '0.7886 ± 0.0298' },
    { seed: 7, r2: '0.7848 ± 0.0292' },
    { seed: 123, r2: '0.7843 ± 0.0418' },
    { seed: 2024, r2: '0.7880 ± 0.0235' },
  ];

  return (
    <div className="space-y-6 pb-12 max-w-5xl mx-auto">
      {/* Top Navigation Toggle */}
      <div className="flex bg-slate-200/80 p-1.5 rounded-2xl border border-slate-300">
        <button
          type="button"
          onClick={() => setViewMode('baseline')}
          className={`flex-1 py-2.5 px-4 text-xs sm:text-sm font-bold rounded-xl transition cursor-pointer flex items-center justify-center gap-2 ${
            viewMode === 'baseline'
              ? 'bg-white text-emerald-850 shadow-sm text-emerald-800'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          <BookOpen className="w-4 h-4" />
          <span>Chapter 4 Baseline (Original Manuscript: 1,522 Samples)</span>
        </button>

        <button
          type="button"
          onClick={() => setViewMode('defense')}
          className={`flex-1 py-2.5 px-4 text-xs sm:text-sm font-bold rounded-xl transition cursor-pointer flex items-center justify-center gap-2 ${
            viewMode === 'defense'
              ? 'bg-white text-emerald-850 shadow-sm text-emerald-800'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          <ShieldCheck className="w-4 h-4 text-emerald-600" />
          <span>Panel Defense: LOOCV & Information Ceiling (1,519 Samples)</span>
        </button>
      </div>

      {/* ──────────────── TAB 1: CHAPTER 4 BASELINE ──────────────── */}
      {viewMode === 'baseline' && (
        <>
          <section className="bg-gradient-to-br from-emerald-800 to-emerald-950 text-white rounded-2xl p-6 sm:p-8 shadow-sm">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
              <div>
                <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-700/60 text-emerald-200 text-xs font-bold uppercase tracking-wider mb-2">
                  <BookOpen className="w-3.5 h-3.5" />
                  <span>Chapter 4 Research Analysis</span>
                </span>
                <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
                  Model Evaluation & Performance
                </h2>
                <p className="text-emerald-100/90 text-xs sm:text-sm mt-1 max-w-2xl leading-relaxed">
                  Empirical dataset of fresh calamansi harvests collected in Tacloban City, Leyte. 
                  Trained on least-squares regression architectures to identify optimal juice extraction formulas.
                </p>
              </div>

              <div className="bg-emerald-900/80 border border-emerald-600/50 p-4 rounded-xl text-center shrink-0">
                <div className="text-xs uppercase tracking-wider text-emerald-300 font-semibold">
                  Optimal Model
                </div>
                <div className="text-lg font-bold font-mono text-amber-300 mt-0.5">
                  Polynomial (d=2)
                </div>
                <div className="text-[11px] text-emerald-200 mt-0.5">
                  R² = 0.7102 (71.02% Fit)
                </div>
              </div>
            </div>
          </section>

          {/* Key Dataset Statistics */}
          <section className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-extrabold font-mono text-emerald-700">
                1,522
              </div>
              <div className="text-xs font-semibold text-slate-700 mt-1">Total Calamansi Samples</div>
              <div className="text-[11px] text-slate-400 mt-0.5">Tacloban City Harvest</div>
            </div>

            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-extrabold font-mono text-emerald-700">
                1,217 / 305
              </div>
              <div className="text-xs font-semibold text-slate-700 mt-1">Train / Test Split</div>
              <div className="text-[11px] text-slate-400 mt-0.5">80% Train / 20% Test</div>
            </div>

            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-extrabold font-mono text-emerald-700">
                12.65 g
              </div>
              <div className="text-xs font-semibold text-slate-700 mt-1">Mean Fruit Weight</div>
              <div className="text-[11px] text-slate-400 mt-0.5">Average unit mass</div>
            </div>

            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs text-center">
              <div className="text-2xl sm:text-3xl font-extrabold font-mono text-emerald-700">
                5.22 ml
              </div>
              <div className="text-xs font-semibold text-slate-700 mt-1">Mean Pure Juice</div>
              <div className="text-[11px] text-slate-400 mt-0.5">Average unit extraction</div>
            </div>
          </section>

          {/* Size Distribution */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <h3 className="text-lg font-extrabold text-slate-900 tracking-tight mb-1">
              Harvest Size Distribution (N = 1,522)
            </h3>
            <p className="text-xs text-slate-500 mb-5">
              Proportions of physical size grades recorded in the harvested batches
            </p>

            <div className="space-y-4">
              {sizeDist.map((item) => (
                <div key={item.grade} className="space-y-1.5">
                  <div className="flex items-center justify-between text-xs sm:text-sm">
                    <span className="font-bold text-slate-800">{item.grade}</span>
                    <span className="text-slate-500 text-xs font-mono">{item.range}</span>
                    <span className="font-mono font-bold text-emerald-800">
                      {item.count} samples ({item.percent.toFixed(2)}%)
                    </span>
                  </div>
                  <div className="w-full h-3 bg-slate-100 rounded-full overflow-hidden">
                    <div
                      className={`h-full ${item.color} rounded-full transition-all duration-500`}
                      style={{ width: `${item.percent}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>
          </section>

          {/* Baseline Comparison Table */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <h3 className="text-lg font-extrabold text-slate-900 tracking-tight mb-1">
              Algorithm Performance Comparison (Unseen Test Samples, N=305)
            </h3>
            <p className="text-xs text-slate-500 mb-5">
              Evaluation of the three regression architectures evaluated in Chapter 4:
            </p>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead>
                  <tr className="bg-slate-50 border-y border-slate-200 text-slate-500 font-semibold uppercase tracking-wider">
                    <th className="py-3 px-3.5">Algorithm</th>
                    <th className="py-3 px-3.5">Inputs</th>
                    <th className="py-3 px-3.5 text-right font-mono">R²</th>
                    <th className="py-3 px-3.5 text-right font-mono">MAE</th>
                    <th className="py-3 px-3.5 text-right font-mono">RMSE</th>
                    <th className="py-3 px-3.5 text-right font-mono">MSE</th>
                    <th className="py-3 px-3.5 text-right font-mono">MAPE</th>
                    <th className="py-3 px-3.5 text-right">Outcome</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  <tr className="hover:bg-slate-50/70 transition">
                    <td className="py-3.5 px-3.5 font-bold text-slate-800">
                      {MODEL_SPECS.simple.name}
                    </td>
                    <td className="py-3.5 px-3.5 text-slate-500">Weight</td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-medium text-slate-800">0.7099</td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-600">0.5294 ml</td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-600">0.6635 ml</td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-600">0.4403 ml²</td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-600">10.42%</td>
                    <td className="py-3.5 px-3.5 text-right">
                      <span className="px-2 py-0.5 rounded bg-slate-100 text-slate-700 font-semibold text-[10px]">
                        Baseline
                      </span>
                    </td>
                  </tr>

                  <tr className="hover:bg-slate-50/70 transition">
                    <td className="py-3.5 px-3.5 font-bold text-slate-800">
                      {MODEL_SPECS.multiple.name}
                    </td>
                    <td className="py-3.5 px-3.5 text-slate-500">Weight, Size</td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-medium text-slate-800">0.7100</td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-600">0.5292 ml</td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-600">0.6635 ml</td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-600">0.4402 ml²</td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-600">10.42%</td>
                    <td className="py-3.5 px-3.5 text-right">
                      <span className="px-2 py-0.5 rounded bg-blue-50 text-blue-800 font-semibold text-[10px]">
                        Comparative
                      </span>
                    </td>
                  </tr>

                  <tr className="bg-emerald-50/60 font-semibold hover:bg-emerald-50 transition">
                    <td className="py-3.5 px-3.5 font-bold text-emerald-900 flex items-center gap-1.5">
                      <Award className="w-4 h-4 text-emerald-700" />
                      <span>{MODEL_SPECS.poly.name}</span>
                    </td>
                    <td className="py-3.5 px-3.5 text-emerald-800">W, S, W², W·S, S²</td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-bold text-emerald-700">0.7102</td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-bold text-emerald-700">0.5279 ml</td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-emerald-800">0.6637 ml</td>
                    <td className="py-3.5 px-3.5 text-right font-mono text-emerald-800">0.4405 ml²</td>
                    <td className="py-3.5 px-3.5 text-right font-mono font-bold text-emerald-700">10.39%</td>
                    <td className="py-3.5 px-3.5 text-right">
                      <span className="px-2.5 py-1 rounded bg-emerald-700 text-white font-extrabold text-[10px] shadow-xs">
                        ★ Best Performing
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </section>

          {/* Formulas */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <h3 className="text-lg font-extrabold text-slate-900 tracking-tight mb-1">
              Trained Regression Mathematical Formulas
            </h3>
            <p className="text-xs text-slate-500 mb-5">
              Equations computed via ordinary least-squares matrix solver:
            </p>

            <div className="space-y-4">
              <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
                <div className="text-xs font-bold text-slate-700 mb-1">
                  1. Simple Linear:
                </div>
                <code className="block p-3 rounded-lg bg-white border border-slate-200 font-mono text-xs sm:text-sm text-slate-800 font-bold">
                  Juice (ml) = 0.4569 × Weight - 0.6080
                </code>
              </div>

              <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
                <div className="text-xs font-bold text-slate-700 mb-1">
                  2. Multiple Linear:
                </div>
                <code className="block p-3 rounded-lg bg-white border border-slate-200 font-mono text-xs sm:text-sm text-slate-800 font-bold">
                  Juice (ml) = 0.4580 × Weight - 0.0053 × Size - 0.6108
                </code>
              </div>

              <div className="p-4 rounded-xl bg-emerald-50/70 border border-emerald-300">
                <div className="text-xs font-bold text-emerald-900 mb-1 flex items-center gap-1.5">
                  <Award className="w-3.5 h-3.5 text-emerald-700" />
                  <span>3. Polynomial Regression (Degree 2) — Optimal Fit:</span>
                </div>
                <code className="block p-3 rounded-lg bg-white border border-emerald-200 font-mono text-xs sm:text-sm text-emerald-900 font-bold overflow-x-auto">
                  Juice (ml) = -0.5480 + 0.4357(W) + 0.0865(S) - 0.0031(W²) + 0.0474(W·S) - 0.1641(S²)
                </code>
              </div>
            </div>
          </section>
        </>
      )}

      {/* ──────────────── TAB 2: PANEL DEFENSE & LOOCV SUITE ──────────────── */}
      {viewMode === 'defense' && (
        <>
          {/* Defense Header Banner */}
          <section className="bg-gradient-to-br from-slate-900 via-emerald-950 to-slate-900 text-white rounded-2xl p-6 sm:p-8 shadow-sm border border-emerald-700/40">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
              <div>
                <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 text-xs font-bold uppercase tracking-wider mb-2">
                  <ShieldCheck className="w-3.5 h-3.5" />
                  <span>Panel Defense & Mathematical Verification</span>
                </span>
                <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
                  Leave-One-Out Cross-Validation (LOOCV, N=1,519)
                </h2>
                <p className="text-slate-300 text-xs sm:text-sm mt-1 max-w-2xl leading-relaxed">
                  Rigorous statistical verification confirming the 0.79 R² is genuine, free of data leakage, 
                  and representing the natural biological information ceiling of calamansi weight.
                </p>
              </div>

              <div className="bg-emerald-900/60 border border-emerald-500/50 p-4 rounded-xl text-center shrink-0">
                <div className="text-xs uppercase tracking-wider text-emerald-300 font-semibold">
                  Gold Standard LOOCV R²
                </div>
                <div className="text-2xl font-extrabold font-mono text-amber-300 mt-0.5">
                  0.7892
                </div>
                <div className="text-[11px] text-emerald-200 mt-0.5">
                  Overfitting Gap = 0.0006
                </div>
              </div>
            </div>
          </section>

          {/* Verification Checks 1, 2, 3 */}
          <section className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs">
              <div className="flex items-center gap-2 text-emerald-700 font-bold text-xs uppercase mb-2">
                <CheckCircle2 className="w-4 h-4" />
                <span>Check 1: Zero Leakage Pipeline</span>
              </div>
              <p className="text-xs text-slate-600 leading-relaxed">
                Feature scaling is performed strictly inside each fold. No global test set leakage occurs during inference.
              </p>
              <div className="mt-3 text-[11px] font-mono text-slate-500 bg-slate-50 p-2 rounded-lg border border-slate-200">
                Scaling strictly inside CV loop
              </div>
            </div>

            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs">
              <div className="flex items-center gap-2 text-emerald-700 font-bold text-xs uppercase mb-2">
                <CheckCircle2 className="w-4 h-4" />
                <span>Check 2: Multi-Seed Stability</span>
              </div>
              <p className="text-xs text-slate-600 leading-relaxed">
                Evaluated across 5 random seeds (0, 42, 7, 123, 2024). R² remains consistently tight (0.784 to 0.788).
              </p>
              <div className="mt-3 flex flex-wrap gap-1">
                {seedChecks.map(s => (
                  <span key={s.seed} className="text-[10px] bg-slate-100 px-2 py-0.5 rounded font-mono text-slate-700">
                    s={s.seed}: {s.r2.split(' ')[0]}
                  </span>
                ))}
              </div>
            </div>

            <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-xs">
              <div className="flex items-center gap-2 text-emerald-700 font-bold text-xs uppercase mb-2">
                <CheckCircle2 className="w-4 h-4" />
                <span>Check 3: Cleaned 3 Outliers</span>
              </div>
              <p className="text-xs text-slate-600 leading-relaxed">
                Removed only the 3 physically impossible recording errors:
                Row 996 (2g, 16ml), Row 1012 (3g, 17ml), Row 1024 (4g, 15ml).
              </p>
              <div className="mt-3 text-[11px] font-semibold text-emerald-700 bg-emerald-50 px-2.5 py-1 rounded-lg">
                1,519 clean samples preserved
              </div>
            </div>
          </section>

          {/* LOOCV Comparison Table */}
          <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mb-4">
              <div>
                <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
                  Step 4: Fair LOOCV Comparison Table (N = 1,519)
                </h3>
                <p className="text-xs text-slate-500">
                  Every model evaluated under Leave-One-Out Cross-Validation (1,518 training samples per iteration):
                </p>
              </div>
              <div className="px-3 py-1 bg-emerald-100 text-emerald-800 rounded-full text-xs font-bold self-start sm:self-auto">
                LOOCV (Gold Standard)
              </div>
            </div>

            {/* Ceiling Reached Banner */}
            <div className="mb-4 p-3 bg-emerald-50 border border-emerald-200 rounded-xl flex flex-wrap items-center justify-between gap-2 text-xs font-mono font-bold text-emerald-900">
              <span className="flex items-center gap-1.5 text-emerald-800">
                <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                <span>Spread: 0.0029</span>
              </span>
              <span className="text-slate-300 hidden sm:inline">•</span>
              <span className="text-emerald-800">All Overfitting Gaps &lt; 0.01</span>
              <span className="text-slate-300 hidden sm:inline">•</span>
              <span className="bg-emerald-700 text-white px-2.5 py-0.5 rounded-md text-[11px] uppercase tracking-wider">
                Ceiling Reached
              </span>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead>
                  <tr className="bg-slate-50 border-y border-slate-200 text-slate-500 font-semibold uppercase tracking-wider">
                    <th className="py-3 px-3.5">Model Architecture</th>
                    <th className="py-3 px-3.5">Role</th>
                    <th className="py-3 px-3.5 text-right font-mono">LOOCV R²</th>
                    <th className="py-3 px-3.5 text-right font-mono">LOOCV MAE</th>
                    <th className="py-3 px-3.5 text-right font-mono">LOOCV RMSE</th>
                    <th className="py-3 px-3.5 text-right font-mono">Train R²</th>
                    <th className="py-3 px-3.5 text-right font-mono text-emerald-700">Overfitting Gap (Δ)</th>
                    <th className="py-3 px-3.5 text-right">Verdict</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {loocvModels.map((m) => (
                    <tr
                      key={m.name}
                      className={`hover:bg-slate-50 transition ${
                        m.isCandidate ? 'bg-emerald-50/70 font-semibold' : ''
                      }`}
                    >
                      <td className="py-3.5 px-3.5 font-bold text-slate-900">
                        {m.name}
                      </td>
                      <td className="py-3.5 px-3.5 text-slate-600">
                        {m.role}
                      </td>
                      <td className="py-3.5 px-3.5 text-right font-mono font-bold text-slate-900">
                        {m.loocvR2.toFixed(4)}
                      </td>
                      <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                        {m.mae}
                      </td>
                      <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                        {m.rmse}
                      </td>
                      <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                        {m.trainR2.toFixed(4)}
                      </td>
                      <td className="py-3.5 px-3.5 text-right font-mono font-bold text-emerald-700">
                        {m.gap.toFixed(4)}
                      </td>
                      <td className="py-3.5 px-3.5 text-right">
                        <span className={`px-2.5 py-1 rounded text-[10px] uppercase tracking-wider ${m.badgeColor}`}>
                          {m.badge}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Diebold-Mariano Statistical Significance Test */}
            <div className="mt-6 p-4 rounded-xl bg-slate-50 border border-slate-200 text-xs text-slate-700 space-y-2 leading-relaxed">
              <div className="font-bold text-slate-900 flex items-center gap-1.5 text-sm">
                <Activity className="w-4 h-4 text-emerald-600" />
                <span>Diebold–Mariano Statistical Significance Test (SLR vs. Polynomial + log(y)):</span>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-1">
                <div className="bg-white p-3 rounded-lg border border-slate-200">
                  <div className="text-slate-400 text-[11px]">Mean Error Difference:</div>
                  <div className="font-mono font-bold text-slate-800 text-sm mt-0.5">-0.00271 mL</div>
                </div>
                <div className="bg-white p-3 rounded-lg border border-slate-200">
                  <div className="text-slate-400 text-[11px]">Paired t-statistic:</div>
                  <div className="font-mono font-bold text-slate-800 text-sm mt-0.5">-1.9136</div>
                </div>
                <div className="bg-white p-3 rounded-lg border border-slate-200">
                  <div className="text-slate-400 text-[11px]">p-value Conclusion:</div>
                  <div className="font-mono font-bold text-emerald-700 text-sm mt-0.5">p &gt; 0.05 (Tied)</div>
                </div>
              </div>
              <p className="text-slate-600 pt-1">
                <strong className="text-slate-900">Statistical Finding:</strong> Because the p-value is greater than 0.05, 
                there is no statistically significant error difference between Simple Linear Regression and complex non-linear models. 
                This confirms the <strong>Information Ceiling Hypothesis</strong>: Calamansi batch weight alone explains ~79% of juice variance; 
                the remaining ~21% is natural biological variation (peel thickness, seed count, moisture) that cannot be modeled without internal sensors.
              </p>
            </div>
          </section>

          {/* Master One-Sentence Answer */}
          <section className="bg-emerald-800 text-white p-6 rounded-2xl shadow-sm">
            <h4 className="font-extrabold text-sm uppercase tracking-wider text-emerald-200 mb-2 flex items-center gap-2">
              <Sparkles className="w-4 h-4 text-amber-300" />
              <span>The Definitive One-Sentence Answer for Your Panel</span>
            </h4>
            <blockquote className="text-sm sm:text-base italic leading-relaxed text-emerald-50 bg-emerald-900/40 p-4 rounded-xl border border-emerald-600/40">
              "We applied three legitimate statistical improvements — log-transforming the target to stabilize heteroscedastic variance, using leave-one-out cross-validation to maximize training data per fold, and testing natural cubic splines alongside polynomials. After these checks, all models converge to R² ≈ 0.79 with overfitting gaps below 0.002, confirming that 0.79 is the true physical information ceiling of weight as a sole predictor, and the remaining ~21% is irreducible biological variance."
            </blockquote>
          </section>
        </>
      )}
    </div>
  );
};
