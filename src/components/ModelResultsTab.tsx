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
          <div className="min-w-0">
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-emerald-700 bg-emerald-50 px-2.5 py-0.5 rounded-full border border-emerald-200">
                Weight-Only Model Evaluation
              </span>
              <span className="text-[11px] font-bold text-slate-600 bg-slate-100 px-2 py-0.5 rounded-full">
                Clean samples (N = {RESEARCH_METADATA.clean_samples})
              </span>
            </div>
            <h1 className="text-base sm:text-lg font-extrabold text-slate-900 tracking-tight mt-1">
              Tacloban City Calamansi Harvest Study • Model Evaluation
            </h1>
          </div>
        </div>

        <div className="flex items-center gap-2 text-xs text-slate-600 bg-slate-50 px-3 py-1.5 rounded-xl border border-slate-200 self-start sm:self-auto">
          <ShieldCheck className="w-4 h-4 text-emerald-600 shrink-0" />
          <span className="font-semibold">Leyte Normal University</span>
        </div>
      </div>

      {/* Header Hero Banner: Best-Performing Model */}
      <section className="bg-gradient-to-br from-slate-900 via-emerald-950 to-slate-900 text-white rounded-2xl p-5 sm:p-8 shadow-sm border border-emerald-700/40">
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div className="min-w-0">
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-200 border border-emerald-500/35 text-[11px] font-bold uppercase tracking-wider mb-2">
              <Award className="w-3.5 h-3.5 text-amber-300 shrink-0" />
              <span>Best-Performing Model • 5-Fold CV</span>
            </span>
            <h2 className="text-xl sm:text-3xl font-extrabold tracking-tight">
              {THESIS_MODELS.primary.name}
            </h2>
            <p className="text-emerald-100 text-xs sm:text-sm mt-1.5 max-w-2xl leading-relaxed">
              Evaluated using weight-grouped 5-fold cross-validation on <code className="font-mono text-amber-200 font-bold">{RESEARCH_METADATA.clean_samples}</code> verified clean calamansi samples with in-fold outlier cleaning and L2 Ridge regularization.
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

      {/* 4 Models Comparative Table */}
      <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mb-4">
          <div>
            <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
              Four-Model Cross-Validation Results (N = {RESEARCH_METADATA.clean_samples})
            </h3>
            <p className="text-xs text-slate-500">
              Out-of-fold metrics across all four weight-only regression models evaluated on verified calamansi samples.
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
                <th className="py-3 px-3.5">Regression Model</th>
                <th className="py-3 px-3.5 text-right font-mono">R² (%)</th>
                <th className="py-3 px-3.5 text-right font-mono">MAE</th>
                <th className="py-3 px-3.5 text-right font-mono">RMSE</th>
                <th className="py-3 px-3.5 text-right font-mono">MAPE</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {modelsList.map((m) => {
                const isBest = m.isChampion;
                return (
                  <tr
                    key={m.name}
                    className={`transition ${
                      isBest
                        ? 'bg-emerald-50/80 font-semibold hover:bg-emerald-50 border-t-2 border-emerald-400'
                        : 'hover:bg-slate-50'
                    }`}
                  >
                    <td className="py-3.5 px-3.5 font-bold text-slate-800 flex items-center gap-1.5">
                      {isBest ? (
                        <>
                          <Award className="w-4 h-4 text-emerald-700 shrink-0" />
                          <span className="text-emerald-950">{m.name}</span>
                        </>
                      ) : (
                        <span>{m.name}</span>
                      )}
                    </td>
                    <td
                      className={`py-3.5 px-3.5 text-right font-mono ${
                        isBest ? 'font-extrabold text-emerald-700 text-sm' : 'font-medium text-slate-800'
                      }`}
                    >
                      {m.r2Percent.toFixed(2)}%
                    </td>
                    <td
                      className={`py-3.5 px-3.5 text-right font-mono ${
                        isBest ? 'font-bold text-emerald-800' : 'text-slate-700'
                      }`}
                    >
                      {m.maeMl.toFixed(4)} mL
                    </td>
                    <td
                      className={`py-3.5 px-3.5 text-right font-mono ${
                        isBest ? 'font-bold text-emerald-800' : 'text-slate-700'
                      }`}
                    >
                      {m.rmseMl.toFixed(4)} mL
                    </td>
                    <td
                      className={`py-3.5 px-3.5 text-right font-mono ${
                        isBest ? 'font-bold text-emerald-800' : 'text-slate-700'
                      }`}
                    >
                      {m.mapePercent.toFixed(2)}%
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
            Trained Regression Equations (N = {RESEARCH_METADATA.clean_samples})
          </h3>
        </div>
        <p className="text-xs text-slate-500 mb-5">
          Fitted coefficients and parameters used by the predictor, where W is calamansi weight in grams.
        </p>

        <div className="space-y-4">
          {modelsList.map((model) => {
            const isBest = model.isChampion;
            return (
              <div
                key={model.name}
                className={`p-4 rounded-xl border ${
                  isBest
                    ? 'bg-emerald-50 border-emerald-300'
                    : 'bg-slate-50 border-slate-200'
                }`}
              >
                <div
                  className={`text-xs font-bold mb-1 flex items-center gap-1.5 ${
                    isBest ? 'text-emerald-950' : 'text-slate-700'
                  }`}
                >
                  {isBest && <Award className="w-3.5 h-3.5 text-emerald-700" />}
                  <span>
                    {model.name}
                    {isBest && model.alpha !== undefined &&
                      ` (Ridge α = ${model.alpha})`}
                  </span>
                </div>
                <code
                  className={`block p-3 rounded-lg bg-white border font-mono text-xs sm:text-sm font-bold overflow-x-auto ${
                    isBest
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
