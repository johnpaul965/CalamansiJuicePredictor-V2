import React from 'react';
import {
  Award,
  ShieldCheck,
  ArrowLeft,
  Sparkles,
  Binary,
} from 'lucide-react';
import {
  THESIS_MODELS,
  BATCH_SCALING_BENCHMARK,
  RESEARCH_METADATA,
} from '../services/predictionService';

interface ModelResultsTabProps {
  onBackToPredict?: () => void;
}

export const ModelResultsTab: React.FC<ModelResultsTabProps> = ({ onBackToPredict }) => {
  const modelsList = [
    THESIS_MODELS.slr,
    THESIS_MODELS.poly,
    THESIS_MODELS.svr,
    THESIS_MODELS.cbPoly,
  ];

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
            <div className="flex items-center gap-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-emerald-700 bg-emerald-50 px-2.5 py-0.5 rounded-full border border-emerald-200">
                Chapter 4 Model Evaluation
              </span>
              <span className="text-[11px] font-bold text-slate-500 bg-slate-100 px-2 py-0.5 rounded-full">
                Clean Ground-Truth (N = {RESEARCH_METADATA.clean_samples})
              </span>
            </div>
            <h1 className="text-base sm:text-lg font-extrabold text-slate-900 tracking-tight mt-1">
              Tacloban City Calamansi Harvest Study • Model Benchmark & Engineering Defense
            </h1>
          </div>
        </div>

        <div className="flex items-center gap-2 text-xs text-slate-600 bg-slate-50 px-3 py-1.5 rounded-xl border border-slate-200">
          <ShieldCheck className="w-4 h-4 text-emerald-600" />
          <span className="font-semibold">Leyte Normal University</span>
        </div>
      </div>

      {/* Header Hero Banner: Validated Champion Model */}
      <section className="bg-gradient-to-br from-slate-900 via-emerald-950 to-slate-900 text-white rounded-2xl p-6 sm:p-8 shadow-sm border border-emerald-700/40">
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div>
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 text-xs font-bold uppercase tracking-wider mb-2">
              <Award className="w-3.5 h-3.5 text-amber-300" />
              <span>Validated Best-Performing Architecture (Stratified 5-Fold Cross-Validation)</span>
            </span>
            <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
              {THESIS_MODELS.cbPoly.name}
            </h2>
            <p className="text-slate-300 text-xs sm:text-sm mt-1 max-w-2xl leading-relaxed">
              Evaluated under rigorous <strong>Stratified 5-Fold Cross-Validation</strong> across verified clean calamansi harvest specimens (<code className="font-mono text-emerald-200">N = {RESEARCH_METADATA.clean_samples}</code>). Features are standardized prior to Ridge shrinkage (α = 0.005) to eliminate multi-collinearity between W, W², and ln(W), achieving superior predictive accuracy and minimum estimation error.
            </p>
          </div>

          <div className="bg-emerald-900/60 border border-emerald-500/50 p-4 rounded-xl text-center shrink-0 w-full sm:w-auto">
            <div className="text-xs uppercase tracking-wider text-emerald-300 font-semibold">
              Stratified 5-Fold R²
            </div>
            <div className="text-3xl font-extrabold font-mono text-amber-300 mt-0.5">
              {THESIS_MODELS.cbPoly.r2Percent.toFixed(2)}%
            </div>
            <div className="text-[11px] text-emerald-200 mt-0.5 font-mono">
              MAE = {THESIS_MODELS.cbPoly.maeMl.toFixed(4)} mL • RMSE = {THESIS_MODELS.cbPoly.rmseMl.toFixed(4)} mL
            </div>
          </div>
        </div>
      </section>

      {/* 4 Models Comparative Benchmark Suite */}
      <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mb-4">
          <div>
            <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
              4-Model Cross-Validation Benchmark Suite (Clean Ground-Truth N = {RESEARCH_METADATA.clean_samples})
            </h3>
            <p className="text-xs text-slate-500">
              Trained and cross-validated on identical clean harvest data using Stratified 5-Fold Cross-Validation to guarantee equal, unbiased evaluation:
            </p>
          </div>
          <div className="px-3 py-1 bg-emerald-100 text-emerald-800 rounded-full text-xs font-bold self-start sm:self-auto">
            Stratified 5-Fold CV
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="bg-slate-50 border-y border-slate-200 text-slate-500 font-semibold uppercase tracking-wider">
                <th className="py-3 px-3.5">Model Architecture</th>
                <th className="py-3 px-3.5">Configuration & Features</th>
                <th className="py-3 px-3.5 text-right font-mono">R² (%)</th>
                <th className="py-3 px-3.5 text-right font-mono">MAE</th>
                <th className="py-3 px-3.5 text-right font-mono">RMSE</th>
                <th className="py-3 px-3.5 text-right font-mono">MAPE</th>
                <th className="py-3 px-3.5 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {modelsList.map((m) => {
                const isChampion = m.isChampion;
                return (
                  <tr
                    key={m.name}
                    className={`transition ${
                      isChampion
                        ? 'bg-emerald-50/80 font-semibold hover:bg-emerald-50 border-t-2 border-emerald-400'
                        : 'hover:bg-slate-50'
                    }`}
                  >
                    <td className="py-3.5 px-3.5 font-bold text-slate-800 flex items-center gap-1.5">
                      {isChampion ? (
                        <>
                          <Award className="w-4 h-4 text-emerald-700 shrink-0" />
                          <span className="text-emerald-950">{m.name}</span>
                        </>
                      ) : (
                        <span>{m.name}</span>
                      )}
                    </td>
                    <td className={`py-3.5 px-3.5 ${isChampion ? 'text-emerald-900 font-semibold' : 'text-slate-600'}`}>
                      {m.role}
                    </td>
                    <td
                      className={`py-3.5 px-3.5 text-right font-mono ${
                        isChampion ? 'font-extrabold text-emerald-700 text-sm' : 'font-medium text-slate-800'
                      }`}
                    >
                      {m.r2Percent.toFixed(2)}%
                    </td>
                    <td
                      className={`py-3.5 px-3.5 text-right font-mono ${
                        isChampion ? 'font-bold text-emerald-800' : 'text-slate-700'
                      }`}
                    >
                      {m.maeMl.toFixed(4)} mL
                    </td>
                    <td
                      className={`py-3.5 px-3.5 text-right font-mono ${
                        isChampion ? 'font-bold text-emerald-800' : 'text-slate-700'
                      }`}
                    >
                      {m.rmseMl.toFixed(4)} mL
                    </td>
                    <td
                      className={`py-3.5 px-3.5 text-right font-mono ${
                        isChampion ? 'font-bold text-emerald-800' : 'text-slate-700'
                      }`}
                    >
                      {m.mapePercent.toFixed(2)}%
                    </td>
                    <td className="py-3.5 px-3.5 text-right">
                      {isChampion ? (
                        <span className="px-2.5 py-1 rounded bg-emerald-700 text-white font-extrabold text-[10px] shadow-xs">
                          ★ BEST FIT
                        </span>
                      ) : (
                        <span className="px-2 py-0.5 rounded font-semibold text-[10px] bg-slate-100 text-slate-700">
                          {m.badge}
                        </span>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </section>

      {/* Mathematical Regression Equations */}
      <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
        <div className="flex items-center gap-2 mb-1">
          <Binary className="w-5 h-5 text-emerald-700" />
          <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
            Trained Mathematical Regression Equations (Clean Dataset N = {RESEARCH_METADATA.clean_samples})
          </h3>
        </div>
        <p className="text-xs text-slate-500 mb-5">
          Derived via standardized Ridge / OLS normal equations from the verified harvest data:
        </p>

        <div className="space-y-4">
          <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
            <div className="text-xs font-bold text-slate-700 mb-1">
              1. Simple Linear Regression (SLR):
            </div>
            <code className="block p-3 rounded-lg bg-white border border-slate-200 font-mono text-xs sm:text-sm text-slate-800 font-bold overflow-x-auto">
              {THESIS_MODELS.slr.formula}
            </code>
          </div>

          <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
            <div className="text-xs font-bold text-slate-700 mb-1">
              2. Polynomial Regression Degree 2 (Quadratic Baseline):
            </div>
            <code className="block p-3 rounded-lg bg-white border border-slate-200 font-mono text-xs sm:text-sm text-slate-800 font-bold overflow-x-auto">
              {THESIS_MODELS.poly.formula}
            </code>
          </div>

          <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
            <div className="text-xs font-bold text-slate-700 mb-1">
              3. Support Vector Regression (RBF Gaussian Kernel):
            </div>
            <code className="block p-3 rounded-lg bg-white border border-slate-200 font-mono text-xs sm:text-sm text-slate-800 font-bold overflow-x-auto">
              {THESIS_MODELS.svr.formula}
            </code>
          </div>

          <div className="p-4 rounded-xl bg-emerald-50 border border-emerald-300">
            <div className="text-xs font-bold text-emerald-950 mb-1 flex items-center gap-1.5">
              <Award className="w-3.5 h-3.5 text-emerald-700" />
              <span>4. Polynomial Regression (Degree 2) + ln(W) & L2 Ridge (Proposed Champion, α = 0.005):</span>
            </div>
            <code className="block p-3 rounded-lg bg-white border border-emerald-200 font-mono text-xs sm:text-sm text-emerald-900 font-bold overflow-x-auto">
              {THESIS_MODELS.cbPoly.formula}
            </code>
          </div>
        </div>
      </section>

      {/* Empirical Monte Carlo Batch Scaling Resampling */}
      <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mb-2">
          <div className="flex items-center gap-2">
            <Sparkles className="w-5 h-5 text-amber-600" />
            <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
              Empirical Monte Carlo Batch Harvest Accuracy (200 Resampling Trials per Scale)
            </h3>
          </div>
          <span className="px-3 py-1 bg-amber-50 text-amber-800 border border-amber-200 rounded-full text-xs font-bold self-start sm:self-auto">
            Empirical Resampling Data
          </span>
        </div>
        <p className="text-xs text-slate-500 mb-4">
          Directly measured by repeatedly drawing random fruit batches from held-out harvest data (200 Monte Carlo runs per tier). Real-world batch error drops below 1% as positive and negative fruit deviations naturally offset:
        </p>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="bg-slate-50 border-y border-slate-200 text-slate-500 font-semibold uppercase tracking-wider">
                <th className="py-3 px-3">Commercial Scale Tier</th>
                <th className="py-3 px-3">Batch Size</th>
                <th className="py-3 px-3">Equivalent Weight</th>
                <th className="py-3 px-3 text-right font-mono">Empirical Error (MAPE)</th>
                <th className="py-3 px-3 text-right font-mono">Batch Accuracy</th>
                <th className="py-3 px-3 text-right">Reliability Tier</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {BATCH_SCALING_BENCHMARK.map((tier) => (
                <tr key={tier.scale} className="hover:bg-slate-50 transition">
                  <td className="py-3 px-3 font-bold text-slate-800">{tier.scale}</td>
                  <td className="py-3 px-3 font-mono text-slate-600">~{tier.count} fruits</td>
                  <td className="py-3 px-3 font-mono text-slate-600">
                    {tier.weightKg >= 1 ? `${tier.weightKg} kg` : `${tier.weightG} g`}
                  </td>
                  <td className="py-3 px-3 text-right font-mono text-slate-800 font-medium">
                    {tier.mape.toFixed(2)}%
                  </td>
                  <td className="py-3 px-3 text-right font-mono font-bold text-emerald-700">
                    {tier.accuracy.toFixed(2)}%
                  </td>
                  <td className="py-3 px-3 text-right">
                    <span className="px-2 py-0.5 rounded text-[10px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                      {tier.count >= 100 ? 'Commercial Grade (99%+)' : 'Operational'}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
};
