import React, { useState } from 'react';
import {
  Zap,
  RotateCcw,
  Sparkles,
  Award,
  Layers,
  Scale,
  FlaskConical,
  PackageCheck,
  AlertCircle,
  CheckCircle2,
} from 'lucide-react';
import { AppUser, PredictionLog, PredictionResult } from '../types';
import {
  MODEL_SPECS,
  runCalculationEngine,
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
  const [weightValue, setWeightValue] = useState<string>('1');
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<PredictionResult | null>(() => {
    return runCalculationEngine(1000);
  });

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
      setError('Please enter a valid calamansi batch weight greater than zero.');
      return;
    }

    const weightG = unit === 'kg' ? rawVal * 1000 : rawVal;
    const calc = runCalculationEngine(weightG);
    setResult(calc);

    // Save record to logs
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
      size: 'Harvest Batch',
      slr: `${calc.slrTotalMl.toFixed(2)} ml`,
      mlr: `${calc.mlrTotalMl.toFixed(2)} ml`,
      poly: `${calc.polyTotalMl.toFixed(2)} ml`,
      slrMl: calc.slrTotalMl,
      mlrMl: calc.mlrTotalMl,
      polyMl: calc.polyTotalMl,
      count: calc.count,
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
          { label: '250 g', val: 250 },
          { label: '500 g', val: 500 },
          { label: '1000 g', val: 1000 },
          { label: '2500 g', val: 2500 },
          { label: '5000 g', val: 5000 },
        ];

  const userRecentLogs = logs
    .filter((l) => currentUser.role === 'admin' || l.user === currentUser.username)
    .slice(0, 10);

  return (
    <div className="space-y-6 pb-12 max-w-5xl mx-auto">
      {/* 1. INPUT ESTIMATION CARD (WEIGHT-ONLY: NO SIZE SORTING NEEDED) */}
      <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-5 border-b border-slate-100">
          <div>
            <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
              <span>Estimate Your Yield</span>
              <span className="text-xs font-semibold px-2.5 py-0.5 rounded-full bg-emerald-100 text-emerald-800">
                Weight-Based Forecasting
              </span>
            </h2>
            <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
              Enter total calamansi batch weight. No tedious manual sorting by small or medium required.
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
              placeholder={unit === 'kg' ? 'e.g. 10' : 'e.g. 10000'}
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
            <span className="text-xs font-medium text-slate-400 mr-1">Quick Select:</span>
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
              <span>Run all 3 models</span>
            </button>
          </div>
        </div>
      </section>

      {/* 2. RESULTS COMPARISON SECTION */}
      {result ? (
        <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7 space-y-6">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-100">
            <div>
              <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
                <span>Prediction Results</span>
              </h2>
              <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
                Simultaneous comparative evaluation of the three regression models:
              </p>
            </div>
            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-emerald-50 border border-emerald-200 text-xs font-semibold text-emerald-900 self-start sm:self-auto">
              <span>🍋</span>
              <span>Total Batch Harvest:</span>
              <span className="font-mono font-bold text-emerald-800">
                {unit === 'kg' ? `${weightValue} kg` : `${weightValue} g`}
              </span>
              <span className="text-slate-300">•</span>
              <span className="font-mono font-bold text-emerald-700">~{result.count} calamansi fruits</span>
            </div>
          </div>

          {/* 3 Model Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
            {/* 1. Simple Linear Regression */}
            <div className="bg-slate-50/70 rounded-2xl border border-slate-200 p-5 flex flex-col justify-between hover:border-slate-300 transition">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">
                    Model 1
                  </span>
                  <span className="text-[10px] font-bold px-2 py-0.5 bg-slate-200 text-slate-700 rounded-full">
                    {MODEL_SPECS.simple.badge}
                  </span>
                </div>
                <h3 className="font-bold text-slate-900 text-sm mb-3">
                  Simple Linear Regression
                </h3>

                <div className="mb-4">
                  <div className="text-2xl sm:text-3xl font-extrabold font-mono text-slate-800 tracking-tight">
                    {result.slrTotalMl.toFixed(2)} ml
                  </div>
                  <div className="text-xs font-mono text-slate-500 mt-0.5">
                    ~{(result.slrTotalMl / 1000).toFixed(4)} Liters
                  </div>
                </div>
              </div>

              <div className="pt-3 border-t border-slate-200 space-y-2 text-xs">
                <div className="flex justify-between text-slate-600">
                  <span>Input:</span>
                  <span className="font-medium text-slate-900">Batch Weight only</span>
                </div>
                <div className="flex justify-between text-slate-600">
                  <span>CV R²:</span>
                  <span className="font-mono font-bold text-slate-900">0.7892</span>
                </div>
                <div className="flex justify-between text-slate-600">
                  <span>Test MAE:</span>
                  <span className="font-mono text-slate-700">0.5249 ml</span>
                </div>
                <div className="flex justify-between text-slate-600">
                  <span>RMSE:</span>
                  <span className="font-mono text-slate-700">0.6788 ml</span>
                </div>
                <div className="flex justify-between text-slate-600">
                  <span>Formula:</span>
                  <span className="font-mono text-[11px] text-slate-700">0.4569(W) - 0.608</span>
                </div>
              </div>
            </div>

            {/* 2. Multiple Linear Regression */}
            <div className="bg-slate-50/70 rounded-2xl border border-slate-200 p-5 flex flex-col justify-between hover:border-slate-300 transition">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">
                    Model 2
                  </span>
                  <span className="text-[10px] font-bold px-2 py-0.5 bg-blue-100 text-blue-800 rounded-full">
                    {MODEL_SPECS.multiple.badge}
                  </span>
                </div>
                <h3 className="font-bold text-slate-900 text-sm mb-3">
                  Multiple Linear Regression
                </h3>

                <div className="mb-4">
                  <div className="text-2xl sm:text-3xl font-extrabold font-mono text-slate-800 tracking-tight">
                    {result.mlrTotalMl.toFixed(2)} ml
                  </div>
                  <div className="text-xs font-mono text-slate-500 mt-0.5">
                    ~{(result.mlrTotalMl / 1000).toFixed(4)} Liters
                  </div>
                </div>
              </div>

              <div className="pt-3 border-t border-slate-200 space-y-2 text-xs">
                <div className="flex justify-between text-slate-600">
                  <span>Calibration:</span>
                  <span className="font-medium text-slate-900">Harvest Empirical Index</span>
                </div>
                <div className="flex justify-between text-slate-600">
                  <span>CV R²:</span>
                  <span className="font-mono font-bold text-slate-900">0.7886</span>
                </div>
                <div className="flex justify-between text-slate-600">
                  <span>Test MAE:</span>
                  <span className="font-mono text-slate-700">0.5253 ml</span>
                </div>
                <div className="flex justify-between text-slate-600">
                  <span>RMSE:</span>
                  <span className="font-mono text-slate-700">0.6798 ml</span>
                </div>
                <div className="flex justify-between text-slate-600">
                  <span>Multicollinearity:</span>
                  <span className="font-medium text-amber-700">Tied with SLR</span>
                </div>
              </div>
            </div>

            {/* 3. Polynomial Regression (d=2) - BEST */}
            <div className="bg-emerald-50/70 rounded-2xl border-2 border-emerald-500 p-5 flex flex-col justify-between shadow-sm relative overflow-hidden">
              <div className="absolute top-0 right-0 bg-emerald-600 text-white text-[10px] font-extrabold px-3 py-1 rounded-bl-xl uppercase tracking-wider flex items-center gap-1">
                <Award className="w-3 h-3 text-amber-300" />
                <span>★ Best Model</span>
              </div>

              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs font-bold text-emerald-800 uppercase tracking-wider">
                    Model 3 (Optimal Fit)
                  </span>
                </div>
                <h3 className="font-bold text-emerald-950 text-sm mb-3">
                  Polynomial Regression (d=2)
                </h3>

                <div className="mb-4">
                  <div className="text-3xl sm:text-4xl font-extrabold font-mono text-emerald-700 tracking-tight">
                    {result.polyTotalMl.toFixed(2)} ml
                  </div>
                  <div className="text-xs font-mono text-emerald-800/80 font-semibold mt-0.5">
                    ~{(result.polyTotalMl / 1000).toFixed(4)} Liters
                  </div>
                </div>
              </div>

              <div className="pt-3 border-t border-emerald-200/80 space-y-2 text-xs">
                <div className="flex justify-between text-emerald-900">
                  <span>Architecture:</span>
                  <span className="font-medium text-emerald-950">Quadratic Interactions</span>
                </div>
                <div className="flex justify-between text-emerald-900 font-bold">
                  <span>CV R²:</span>
                  <span className="font-mono text-emerald-700">0.7888</span>
                </div>
                <div className="flex justify-between text-emerald-900 font-bold">
                  <span>Test MAE:</span>
                  <span className="font-mono text-emerald-700">0.5276 ml</span>
                </div>
                <div className="flex justify-between text-emerald-900">
                  <span>Overfitting Gap:</span>
                  <span className="font-mono text-emerald-800 font-bold">&lt; 0.002</span>
                </div>
                <div className="flex justify-between text-emerald-900">
                  <span>Status:</span>
                  <span className="font-bold text-emerald-700">Information Ceiling</span>
                </div>
              </div>
            </div>
          </div>

          {/* Commercial Bottling and Packaging Yields */}
          <div className="bg-slate-50 border border-slate-200/90 rounded-2xl p-5">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-700 mb-3 flex items-center gap-1.5">
              <PackageCheck className="w-4 h-4 text-emerald-700" />
              <span>Commercial Bottling & Inventory Estimates</span>
            </h4>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div className="bg-white p-3.5 rounded-xl border border-slate-200 text-center">
                <div className="text-xs text-slate-500 font-medium">330 ml Bottles</div>
                <div className="text-xl font-bold font-mono text-emerald-700 mt-1">
                  ~{result.bottles330}
                </div>
                <div className="text-[11px] text-slate-400 mt-0.5">Ready-to-drink format</div>
              </div>

              <div className="bg-white p-3.5 rounded-xl border border-slate-200 text-center">
                <div className="text-xs text-slate-500 font-medium">500 ml Bottles</div>
                <div className="text-xl font-bold font-mono text-emerald-700 mt-1">
                  ~{result.bottles500}
                </div>
                <div className="text-[11px] text-slate-400 mt-0.5">Retail concentrate</div>
              </div>

              <div className="bg-white p-3.5 rounded-xl border border-slate-200 text-center">
                <div className="text-xs text-slate-500 font-medium">1.0 Liter Jugs</div>
                <div className="text-xl font-bold font-mono text-emerald-700 mt-1">
                  ~{result.bottles1000}
                </div>
                <div className="text-[11px] text-slate-400 mt-0.5">Commercial pure puree</div>
              </div>
            </div>
          </div>
        </section>
      ) : null}

      {/* 3. RECENT HARVEST RECORDS TABLE */}
      <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
        <div className="flex items-center justify-between pb-4 border-b border-slate-100">
          <div>
            <h3 className="text-lg font-extrabold text-slate-900 tracking-tight">
              Your Recent Harvests
            </h3>
            <p className="text-xs text-slate-500 mt-0.5">
              Recent batch calculations logged in system
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
                <th className="py-2.5 px-3 font-mono">Estimated Fruit Count</th>
                <th className="py-2.5 px-3 font-mono">Simple Linear</th>
                <th className="py-2.5 px-3 font-mono">Multiple Linear</th>
                <th className="py-2.5 px-3 font-mono text-emerald-700">Polynomial (Best)</th>
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
                    <td className="py-3 px-3 font-mono text-slate-600">{log.mlr}</td>
                    <td className="py-3 px-3 font-mono font-bold text-emerald-700">{log.poly}</td>
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
