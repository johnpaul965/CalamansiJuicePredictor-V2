import React, { useState } from 'react';
import {
  Zap,
  RotateCcw,
  Award,
  PackageCheck,
  AlertCircle,
} from 'lucide-react';
import { AppUser, PredictionLog, PredictionResult } from '../types';
import {
  runCalculationEngine,
  getBatchOperationalAccuracy,
  THESIS_MODELS,
} from '../services/predictionService';
import { addLog } from '../services/storageService';

interface PredictTabProps {
  currentUser: AppUser;
  logs: PredictionLog[];
  onRefreshLogs: () => void;
}

export const PredictTab: React.FC<PredictTabProps> = ({
  currentUser,
  logs,
  onRefreshLogs,
}) => {
  const [unit, setUnit] = useState<'kg' | 'g'>('kg');
  const [weightValue, setWeightValue] = useState<string>('5');
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<PredictionResult | null>(() => {
    return runCalculationEngine(5000);
  });
  const [activeModelView, setActiveModelView] = useState<'champion' | 'compare'>('champion');

  const handleUnitToggle = (newUnit: 'kg' | 'g') => {
    if (newUnit === unit) return;
    const currentVal = parseFloat(weightValue);
    if (!isNaN(currentVal) && currentVal > 0) {
      if (newUnit === 'g') {
        setWeightValue((currentVal * 1000).toFixed(0));
      } else {
        setWeightValue((currentVal / 1000).toFixed(2));
      }
    }
    setUnit(newUnit);
  };

  const handleExecute = (customWeight?: number) => {
    setError(null);
    const rawVal = customWeight !== undefined ? customWeight : parseFloat(weightValue);

    if (isNaN(rawVal) || rawVal <= 0) {
      setError('Please enter a valid batch weight greater than zero.');
      return;
    }

    const weightG = unit === 'kg' ? rawVal * 1000 : rawVal;
    const calc = runCalculationEngine(weightG);
    setResult(calc);

    const now = new Date();
    const dateStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(
      now.getDate()
    ).padStart(2, '0')} ${String(now.getHours()).padStart(2, '0')}:${String(
      now.getMinutes()
    ).padStart(2, '0')}`;

    const weightDisplay =
      weightG >= 1000
        ? `${(weightG / 1000).toFixed(2)} kg (${weightG.toFixed(0)}g)`
        : `${weightG.toFixed(0)} g`;

    const newLog: PredictionLog = {
      id: `log-${Date.now()}`,
      date: dateStr,
      user: currentUser.username,
      weightG,
      weight: weightDisplay,
      count: calc.count,
      slr: `${calc.slrTotalMl.toFixed(2)} ml`,
      poly: `${calc.polyTotalMl.toFixed(2)} ml`,
      cbPoly: `${calc.cbPolyTotalMl.toFixed(2)} ml`,
      slrMl: calc.slrTotalMl,
      polyMl: calc.polyTotalMl,
      cbPolyMl: calc.cbPolyTotalMl,
    };

    addLog(newLog);
    onRefreshLogs();
  };

  const quickPresets =
    unit === 'kg'
      ? [
          { label: '1 kg', val: 1 },
          { label: '5 kg', val: 5 },
          { label: '10 kg', val: 10 },
          { label: '25 kg', val: 25 },
          { label: '50 kg', val: 50 },
        ]
      : [
          { label: '500 g', val: 500 },
          { label: '1000 g', val: 1000 },
          { label: '2500 g', val: 2500 },
          { label: '5000 g', val: 5000 },
          { label: '10000 g', val: 10000 },
        ];

  const userRecentLogs = logs
    .filter((l) => currentUser.role === 'admin' || l.user === currentUser.username)
    .slice(0, 8);

  const currentWeightG = unit === 'kg' ? (parseFloat(weightValue) || 1) * 1000 : (parseFloat(weightValue) || 1000);
  const batchAccuracy = getBatchOperationalAccuracy(currentWeightG);

  return (
    <div className="space-y-6 pb-12 max-w-5xl mx-auto">
      {/* 1. INPUT ESTIMATION CARD */}
      <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-5 border-b border-slate-100">
          <div>
            <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
              <span>Calamansi Batch Yield Estimator</span>
              <span className="text-xs font-semibold px-2.5 py-0.5 rounded-full bg-emerald-100 text-emerald-800">
                Direct Weight Input
              </span>
            </h2>
            <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
              Enter total harvested batch weight. Pure juice projection is calculated automatically without manual fruit sorting.
            </p>
          </div>

          {/* Unit Toggle */}
          <div className="flex items-center gap-2 self-start sm:self-auto">
            <span className="text-xs font-semibold text-slate-500">Unit:</span>
            <div className="flex bg-slate-100 p-0.5 rounded-xl border border-slate-200">
              <button
                type="button"
                onClick={() => handleUnitToggle('kg')}
                className={`px-3 py-1 text-xs font-bold rounded-lg transition cursor-pointer ${
                  unit === 'kg'
                    ? 'bg-emerald-700 text-white shadow-xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                kg
              </button>
              <button
                type="button"
                onClick={() => handleUnitToggle('g')}
                className={`px-3 py-1 text-xs font-bold rounded-lg transition cursor-pointer ${
                  unit === 'g'
                    ? 'bg-emerald-700 text-white shadow-xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                g
              </button>
            </div>
          </div>
        </div>

        <div className="pt-5 space-y-4">
          <label className="block text-xs font-bold uppercase tracking-wider text-slate-600">
            Total Calamansi Batch Weight
          </label>
          <div className="relative flex items-center max-w-2xl">
            <input
              type="number"
              step="any"
              min="0.01"
              placeholder={unit === 'kg' ? 'e.g. 5' : 'e.g. 5000'}
              value={weightValue}
              onChange={(e) => {
                setWeightValue(e.target.value);
                setError(null);
              }}
              onKeyDown={(e) => {
                if (e.key === 'Enter') handleExecute();
              }}
              className="w-full text-2xl sm:text-3xl font-mono font-bold px-4 py-3 bg-slate-50 border-2 border-slate-200 rounded-2xl text-slate-900 focus:bg-white focus:outline-none focus:border-emerald-600 transition"
            />
            <span className="absolute right-4 font-mono font-bold text-slate-400 text-lg">
              {unit}
            </span>
          </div>

          {/* Quick Presets */}
          <div className="flex items-center gap-1.5 flex-wrap pt-1">
            <span className="text-xs font-medium text-slate-400 mr-1">Presets:</span>
            {quickPresets.map((p) => (
              <button
                key={p.label}
                type="button"
                onClick={() => {
                  setWeightValue(String(p.val));
                  handleExecute(p.val);
                }}
                className="px-3.5 py-1.5 bg-slate-100 hover:bg-emerald-50 hover:text-emerald-800 hover:border-emerald-300 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 transition cursor-pointer"
              >
                {p.label}
              </button>
            ))}
          </div>

          {error && (
            <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-700">
              <AlertCircle className="w-4 h-4 shrink-0 text-red-500" />
              <span>{error}</span>
            </div>
          )}

          {/* Action Button */}
          <div className="pt-2">
            <button
              type="button"
              onClick={() => handleExecute()}
              className="w-full py-3.5 px-6 bg-emerald-700 hover:bg-emerald-800 active:bg-emerald-900 text-white font-bold rounded-2xl text-base shadow-sm hover:shadow transition flex items-center justify-center gap-2 cursor-pointer"
            >
              <Zap className="w-5 h-5 text-amber-300 fill-amber-300" />
              <span>Calculate Batch Forecast</span>
            </button>
          </div>
        </div>
      </section>

      {/* 2. RESULTS & COMMERCIAL FORECAST */}
      {result && (
        <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7 space-y-6">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-100">
            <div>
              <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
                <span>Forecast Summary</span>
              </h2>
              <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
                Calibrated extraction metrics based on empirical calamansi density:
              </p>
            </div>

            <div className="flex items-center gap-2 flex-wrap">
              {/* Batch Scale Reliability Indicator */}
              <div className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-emerald-50 border border-emerald-200 text-xs font-semibold text-emerald-900">
                <span className="font-bold text-emerald-700 font-mono">
                  {batchAccuracy.accuracyPercent}% Accuracy
                </span>
                <span className="text-slate-400">•</span>
                <span className="text-slate-600">{batchAccuracy.label}</span>
              </div>

              {/* View Toggle */}
              <div className="flex bg-slate-100 p-0.5 rounded-xl border border-slate-200 text-xs">
                <button
                  type="button"
                  onClick={() => setActiveModelView('champion')}
                  className={`px-2.5 py-1 rounded-lg font-bold transition cursor-pointer ${
                    activeModelView === 'champion'
                      ? 'bg-white text-emerald-850 shadow-xs text-emerald-800'
                      : 'text-slate-600 hover:text-slate-900'
                  }`}
                >
                  Champion Forecast
                </button>
                <button
                  type="button"
                  onClick={() => setActiveModelView('compare')}
                  className={`px-2.5 py-1 rounded-lg font-bold transition cursor-pointer ${
                    activeModelView === 'compare'
                      ? 'bg-white text-emerald-850 shadow-xs text-emerald-800'
                      : 'text-slate-600 hover:text-slate-900'
                  }`}
                >
                  Compare All 7
                </button>
              </div>
            </div>
          </div>

          {/* Primary Champion Highlight */}
          {activeModelView === 'champion' ? (
            <div className="bg-gradient-to-br from-emerald-800 via-emerald-900 to-slate-900 text-white rounded-2xl p-6 sm:p-7 shadow-sm">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-emerald-700/60">
                <div>
                  <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-emerald-500/30 text-emerald-200 text-[11px] font-bold uppercase tracking-wider mb-2">
                    <Award className="w-3 h-3 text-amber-300" />
                    <span>Polynomial Regression (d=2) + ln(W) & L2 Ridge</span>
                  </div>
                  <div className="text-3xl sm:text-4xl font-extrabold font-mono tracking-tight text-white">
                    {result.cbPolyTotalMl.toFixed(2)} mL
                  </div>
                  <div className="text-sm font-mono text-emerald-200 font-medium mt-1">
                    ~{(result.cbPolyTotalMl / 1000).toFixed(3)} Liters Pure Juice
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3 sm:text-right">
                  <div className="bg-emerald-950/50 p-3 rounded-xl border border-emerald-700/50">
                    <div className="text-[11px] text-emerald-300">Estimated Calamansi</div>
                    <div className="text-lg font-bold font-mono text-white mt-0.5">
                      ~{result.count} fruits
                    </div>
                  </div>
                  <div className="bg-emerald-950/50 p-3 rounded-xl border border-emerald-700/50">
                    <div className="text-[11px] text-emerald-300">Extraction Ratio</div>
                    <div className="text-lg font-bold font-mono text-emerald-300 mt-0.5">
                      {result.extractionRatioPercent}%
                    </div>
                  </div>
                </div>
              </div>

              <div className="pt-3 flex flex-wrap items-center justify-between gap-2 text-xs text-emerald-200">
                <span>
                  Model Calibration: R² = {THESIS_MODELS.cbPoly.r2Percent.toFixed(2)}% • Correlation (r) = {THESIS_MODELS.cbPoly.correlationR.toFixed(4)}
                </span>
                <span className="font-mono text-emerald-300 text-[11px]">
                  Batch Variance Damping: {batchAccuracy.tag}
                </span>
              </div>
            </div>
          ) : (
            /* 7-Model Live Comparison Grid */
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {[
                {
                  label: 'Model 1',
                  badge: 'Ordinary Baseline (W)',
                  badgeCls: 'bg-slate-200 text-slate-700',
                  title: 'Simple Linear (SLR)',
                  totalMl: result.slrTotalMl,
                  meta: THESIS_MODELS.slr,
                },
                {
                  label: 'Model 2',
                  badge: 'Ordinary Quadratic (W, W²)',
                  badgeCls: 'bg-blue-100 text-blue-800',
                  title: 'Polynomial (d=2)',
                  totalMl: result.polyTotalMl,
                  meta: THESIS_MODELS.poly,
                },
                {
                  label: 'Model 3',
                  badge: 'Default RBF (No Layers)',
                  badgeCls: 'bg-purple-100 text-purple-800',
                  title: 'SVR (Ordinary Default)',
                  totalMl: result.svrTotalMl,
                  meta: THESIS_MODELS.svr,
                },
                {
                  label: 'Model 4',
                  badge: 'Default Trees (No Layers)',
                  badgeCls: 'bg-cyan-100 text-cyan-800',
                  title: 'CatBoost (Ordinary Default)',
                  totalMl: result.catboostTotalMl,
                  meta: THESIS_MODELS.catboost,
                },
                {
                  label: 'Model 5',
                  badge: 'Default Trees (No Layers)',
                  badgeCls: 'bg-indigo-100 text-indigo-800',
                  title: 'XGBoost (Ordinary Default)',
                  totalMl: result.xgbTotalMl,
                  meta: THESIS_MODELS.xgboost,
                },
                {
                  label: 'Model 6',
                  badge: 'Default Bagging (No Layers)',
                  badgeCls: 'bg-amber-100 text-amber-800',
                  title: 'Random Forest (Ordinary Default)',
                  totalMl: result.rfTotalMl,
                  meta: THESIS_MODELS.rf,
                },
              ].map((m) => (
                <div
                  key={m.title}
                  className="bg-slate-50 rounded-2xl border border-slate-200 p-5 flex flex-col justify-between"
                >
                  <div>
                    <div className="flex items-center justify-between mb-1.5">
                      <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">
                        {m.label}
                      </span>
                      <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${m.badgeCls}`}>
                        {m.badge}
                      </span>
                    </div>
                    <h3 className="font-bold text-slate-900 text-sm mb-3">{m.title}</h3>
                    <div className="text-2xl font-extrabold font-mono text-slate-800 tracking-tight">
                      {m.totalMl.toFixed(2)} mL
                    </div>
                    <div className="text-xs font-mono text-slate-500 mt-0.5">
                      ~{(m.totalMl / 1000).toFixed(3)} L
                    </div>
                  </div>

                  <div className="pt-3 border-t border-slate-200 space-y-1.5 text-xs text-slate-600 mt-4">
                    <div className="flex justify-between">
                      <span>Correlation (r):</span>
                      <span className="font-mono font-bold text-slate-800">
                        {m.meta.correlationR.toFixed(4)}
                      </span>
                    </div>
                    <div className="flex justify-between">
                      <span>R² Fit:</span>
                      <span className="font-mono font-bold text-slate-800">
                        {m.meta.r2Percent.toFixed(2)}%
                      </span>
                    </div>
                    <div className="flex justify-between">
                      <span>MAE:</span>
                      <span className="font-mono text-slate-700">
                        {m.meta.maeMl.toFixed(4)} mL
                      </span>
                    </div>
                  </div>
                </div>
              ))}

              {/* 7. Polynomial Regression (d=2) + ln(W) & L2 Ridge */}
              <div className="bg-emerald-50 rounded-2xl border-2 border-emerald-600 p-5 flex flex-col justify-between shadow-xs sm:col-span-2 lg:col-span-3">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                  <div>
                    <div className="flex items-center gap-2 mb-1.5">
                      <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider">
                        Model 7
                      </span>
                      <span className="text-[10px] font-bold px-2.5 py-0.5 bg-emerald-700 text-white rounded-full">
                        ★ Best Performing Fit
                      </span>
                    </div>
                    <h3 className="font-bold text-emerald-950 text-base mb-1">
                      Polynomial Regression (d=2) + ln(W) & L2 Ridge
                    </h3>
                    <div className="text-3xl font-extrabold font-mono text-emerald-700 tracking-tight">
                      {result.cbPolyTotalMl.toFixed(2)} mL{' '}
                      <span className="text-sm font-semibold text-emerald-800/80">
                        (~{(result.cbPolyTotalMl / 1000).toFixed(3)} L)
                      </span>
                    </div>
                  </div>

                  <div className="grid grid-cols-3 gap-3 text-xs text-emerald-900 bg-white/80 p-3.5 rounded-xl border border-emerald-200">
                    <div>
                      <div className="text-emerald-700/80">Correlation (r)</div>
                      <div className="font-mono font-bold text-emerald-800 text-sm mt-0.5">
                        {THESIS_MODELS.cbPoly.correlationR.toFixed(4)}
                      </div>
                    </div>
                    <div>
                      <div className="text-emerald-700/80">R² Fit</div>
                      <div className="font-mono font-bold text-emerald-800 text-sm mt-0.5">
                        {THESIS_MODELS.cbPoly.r2Percent.toFixed(2)}%
                      </div>
                    </div>
                    <div>
                      <div className="text-emerald-700/80">MAE</div>
                      <div className="font-mono font-bold text-emerald-800 text-sm mt-0.5">
                        {THESIS_MODELS.cbPoly.maeMl.toFixed(4)} mL
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Commercial Packaging Yields */}
          <div className="bg-slate-50 border border-slate-200/90 rounded-2xl p-5">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-700 mb-3 flex items-center gap-1.5">
              <PackageCheck className="w-4 h-4 text-emerald-700" />
              <span>Commercial Bottling & Inventory Yields</span>
            </h4>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div className="bg-white p-3.5 rounded-xl border border-slate-200 text-center">
                <div className="text-xs text-slate-500 font-medium">330 mL Bottles</div>
                <div className="text-xl font-bold font-mono text-emerald-700 mt-1">
                  ~{result.bottles330}
                </div>
                <div className="text-[11px] text-slate-400 mt-0.5">Ready-to-drink size</div>
              </div>

              <div className="bg-white p-3.5 rounded-xl border border-slate-200 text-center">
                <div className="text-xs text-slate-500 font-medium">500 mL Bottles</div>
                <div className="text-xl font-bold font-mono text-emerald-700 mt-1">
                  ~{result.bottles500}
                </div>
                <div className="text-[11px] text-slate-400 mt-0.5">Retail concentrate format</div>
              </div>

              <div className="bg-white p-3.5 rounded-xl border border-slate-200 text-center">
                <div className="text-xs text-slate-500 font-medium">1.0 Liter Commercial Jugs</div>
                <div className="text-xl font-bold font-mono text-emerald-700 mt-1">
                  ~{result.bottles1000}
                </div>
                <div className="text-[11px] text-slate-400 mt-0.5">Pure juice catering volume</div>
              </div>
            </div>
          </div>
        </section>
      )}

      {/* 3. RECENT HARVEST LOGS */}
      <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
        <div className="flex items-center justify-between pb-4 border-b border-slate-100">
          <div>
            <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
              Recent Batch Harvest Records
            </h3>
            <p className="text-xs text-slate-500 mt-0.5">
              Recent batch calculations logged in this session
            </p>
          </div>
          <button
            type="button"
            onClick={onRefreshLogs}
            className="p-2 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded-xl transition cursor-pointer"
            title="Refresh records"
          >
            <RotateCcw className="w-4 h-4" />
          </button>
        </div>

        <div className="overflow-x-auto mt-4">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="bg-slate-50 border-y border-slate-200 text-slate-500 font-semibold uppercase tracking-wider">
                <th className="py-2.5 px-3">Date & Time</th>
                <th className="py-2.5 px-3">Batch Weight</th>
                <th className="py-2.5 px-3 font-mono">Est. Fruits</th>
                <th className="py-2.5 px-3 font-mono">Simple Linear</th>
                <th className="py-2.5 px-3 font-mono">Polynomial (d=2)</th>
                <th className="py-2.5 px-3 font-mono text-emerald-700">Poly + ln(W) + Ridge</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {userRecentLogs.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-8 text-center text-slate-400">
                    No harvest predictions recorded yet.
                  </td>
                </tr>
              ) : (
                userRecentLogs.map((log) => (
                  <tr key={log.id} className="hover:bg-slate-50/80 transition">
                    <td className="py-3 px-3 font-mono text-slate-500">{log.date}</td>
                    <td className="py-3 px-3 font-bold text-slate-900">{log.weight}</td>
                    <td className="py-3 px-3 font-mono text-slate-700">
                      ~{log.count} calamansi
                    </td>
                    <td className="py-3 px-3 font-mono text-slate-600">{log.slr}</td>
                    <td className="py-3 px-3 font-mono text-slate-600">{log.poly}</td>
                    <td className="py-3 px-3 font-mono font-bold text-emerald-700">{log.cbPoly}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
};
