import React from 'react';
import {
  Award,
  ShieldCheck,
  ArrowLeft,
  Binary,
} from 'lucide-react';
import {
  THESIS_MODELS,
  RESEARCH_METADATA,
} from '../services/predictionService';

interface ModelResultsTabProps {
  onBackToPredict?: () => void;
}

export const ModelResultsTab: React.FC<ModelResultsTabProps> = ({ onBackToPredict }) => {
  const modelsList = [
    THESIS_MODELS.slr,
    THESIS_MODELS.poly,
    THESIS_MODELS.rbf,
    THESIS_MODELS.primary,
  ];
  const formulaModels = [
    { model: THESIS_MODELS.slr, label: 'Simple linear baseline' },
    { model: THESIS_MODELS.poly, label: 'Polynomial (Degree 2) baseline' },
    { model: THESIS_MODELS.rbf, label: 'RBF kernel SVR' },
    { model: THESIS_MODELS.primary, label: 'Poly+ final model' },
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
                Weight-Only Model Evaluation
              </span>
              <span className="text-[11px] font-bold text-slate-500 bg-slate-100 px-2 py-0.5 rounded-full">
                Final training rows (N = {RESEARCH_METADATA.clean_samples})
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
                <span>Primary Champion Model (Weight-Grouped 5-Fold Validation)</span>
            </span>
            <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
              {THESIS_MODELS.primary.name}
            </h2>
            <p className="text-slate-300 text-xs sm:text-sm mt-1 max-w-2xl leading-relaxed">
              Evaluated using nested, weight-grouped 5-fold validation on <code className="font-mono text-emerald-200">{RESEARCH_METADATA.clean_samples}</code> verified clean ground-truth rows (N = 1,478). The Proposed Pipeline applies automated in-fold sanitization and L2 Ridge shrinkage to maintain peak accuracy over off-the-shelf baselines.
            </p>
          </div>

          <div className="bg-emerald-900/60 border border-emerald-500/50 p-4 rounded-xl text-center shrink-0 w-full sm:w-auto">
            <div className="text-xs uppercase tracking-wider text-emerald-300 font-semibold">
              Out-of-fold R²
            </div>
            <div className="text-3xl font-extrabold font-mono text-amber-300 mt-0.5">
              {THESIS_MODELS.primary.r2Percent.toFixed(2)}%
            </div>
            <div className="text-[11px] text-emerald-200 mt-0.5 font-mono">
              MAE = {THESIS_MODELS.primary.maeMl.toFixed(4)} mL • RMSE = {THESIS_MODELS.primary.rmseMl.toFixed(4)} mL
            </div>
          </div>
        </div>
      </section>

      {/* 4 Models Comparative Benchmark Suite */}
      <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mb-4">
          <div>
            <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
              Four-Model Benchmark Suite (N = {RESEARCH_METADATA.clean_samples} Ground-Truth)
            </h3>
            <p className="text-xs text-slate-500">
              The Proposed Model features automated in-fold sanitization and nested Ridge optimization, proving superior resistance to field measurement noise compared to off-the-shelf baseline algorithms.
            </p>
          </div>
          <div className="px-3 py-1 bg-emerald-100 text-emerald-800 rounded-full text-xs font-bold self-start sm:self-auto">
            Grouped 5-Fold CV
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="bg-slate-50 border-y border-slate-200 text-slate-500 font-semibold uppercase tracking-wider">
                <th className="py-3 px-3.5">Model Architecture</th>
                <th className="py-3 px-3.5">Mathematical Basis</th>
                <th className="py-3 px-3.5 text-right font-mono">R² (%)</th>
                <th className="py-3 px-3.5 text-right font-mono">MAE</th>
                <th className="py-3 px-3.5 text-right font-mono">RMSE</th>
                <th className="py-3 px-3.5 text-right font-mono">MAPE</th>
                <th className="py-3 px-3.5 text-right font-mono">Δ MAE</th>
                <th className="py-3 px-3.5 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {modelsList.map((m) => {
                const isChampion = m.isChampion;
                const deltaMaePercent =
                  ((m.maeMl - THESIS_MODELS.slr.maeMl) / THESIS_MODELS.slr.maeMl) * 100;
                const deltaMaeLabel =
                  m === THESIS_MODELS.slr
                    ? 'Baseline'
                    : `${deltaMaePercent > 0 ? '+' : ''}${deltaMaePercent.toFixed(2)}%`;
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
                    <td className="py-3.5 px-3.5 text-right font-mono text-slate-700">
                      {deltaMaeLabel}
                    </td>
                    <td className="py-3.5 px-3.5 text-right">
                      {isChampion ? (
                        <span className="px-2.5 py-1 rounded bg-emerald-700 text-white font-extrabold text-[10px] shadow-xs">
                          ★ SELECTED FINAL
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
          These formulas use the generated coefficients and parameters used by the predictor. W is fruit weight in grams. The RBF model is fixed-parameter epsilon-SVR trained on weight only.
        </p>

        <div className="space-y-4">
          {formulaModels.map(({ model, label }) => {
            const isChampion = model.isChampion;
            return (
              <div
                key={model.name}
                className={`p-4 rounded-xl border ${
                  isChampion
                    ? 'bg-emerald-50 border-emerald-300'
                    : 'bg-slate-50 border-slate-200'
                }`}
              >
                <div
                  className={`text-xs font-bold mb-1 flex items-center gap-1.5 ${
                    isChampion ? 'text-emerald-950' : 'text-slate-700'
                  }`}
                >
                  {isChampion && <Award className="w-3.5 h-3.5 text-emerald-700" />}
                  <span>
                    {label}: {model.name}
                    {isChampion && model.alpha !== undefined &&
                      ` (selected Ridge α = ${model.alpha})`}
                  </span>
                </div>
                <code
                  className={`block p-3 rounded-lg bg-white border font-mono text-xs sm:text-sm font-bold overflow-x-auto ${
                    isChampion
                      ? 'border-emerald-200 text-emerald-900'
                      : 'border-slate-200 text-slate-800'
                  }`}
                >
                  {model.formula}
                </code>
              </div>
            );
          })}
        </div>
      </section>
    </div>
  );
};
