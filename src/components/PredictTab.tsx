import React, { useState } from 'react';
import {
  Zap,
  RotateCcw,
  Award,
  PackageCheck,
  AlertCircle,
  Scale,
  BarChart2,
  TrendingUp,
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
    .slice(0, 6);

  const currentWeightG = unit === 'kg' ? (parseFloat(weightValue) || 1) * 1000 : (parseFloat(weightValue) || 1000);
  const batchAccuracy = getBatchOperationalAccuracy(currentWeightG);

  return (
    <div className="space-y-6 pb-12 max-w-5xl mx-auto">
      {/* ──────────────── 1. INPUT ESTIMATION CARD (V1 PLACING) ──────────────── */}
      <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-5 border-b border-slate-100">
          <div>
            <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
              <Scale className="w-5 h-5 text-emerald-700" />
              <span>Calamansi Batch Yield Estimator</span>
            </h2>
            <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
              Input total harvested batch weight. Piece count and pure juice are projected automatically (manual fruit size sorting removed).
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
            Total Harvest Weight ({unit})
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
            <span className="text-xs font-medium text-slate-400 mr-1">Quick Presets:</span>
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
              <span>Calculate Juice Yield</span>
            </button>
          </div>
        </div>
      </section>

      {/* ──────────────── 2. PREDICTION RESULTS CARD (EXACT VERSION 1 PLACING) ──────────────── */}
      {result ? (
        <section className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7 space-y-6">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-100">
            <div>
              <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
                <span>Prediction Results</span>
              </h2>
              <p className="text-xs text-slate-500 mt-0.5">
                Results from all regression architectures evaluated in the research study:
              </p>
            </div>
            <div className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-xs font-semibold self-start sm:self-auto">
              <span>🌿 Pure Weight-Driven Harvest</span>
              <span>•</span>
              <span className="font-mono font-bold">~{result.count} calamansi</span>
            </div>
          </div>

          {/* 4-Model Comparison Grid Matching Version 1 */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {/* Card 1: Simple Linear Regression */}
            <div className="bg-white rounded-2xl border border-slate-200 p-5 flex flex-col justify-between shadow-xs hover:border-slate-300 transition">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">
                    Model 1
                  </span>
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-slate-100 text-slate-700 border border-slate-200">
                    Linear Baseline
                  </span>
                </div>
                <h3 className="font-bold text-slate-900 text-sm">Simple Linear Regression</h3>
                <div className="text-2xl font-extrabold font-mono text-slate-800 tracking-tight mt-2.5">
                  {result.slrTotalMl.toFixed(2)} ml
                </div>
                <div className="text-xs font-mono text-slate-500 mt-0.5">
                  ~{(result.slrTotalMl / 1000).toFixed(4)} L
                </div>
              </div>

              <div className="pt-3.5 border-t border-slate-100 space-y-1.5 text-xs text-slate-600 mt-4">
                <div className="flex justify-between">
                  <span className="text-slate-500">Input Feature:</span>
                  <span className="font-medium text-slate-800">Weight only</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">R² Score:</span>
                  <span className="font-mono font-bold text-slate-800">0.7099 (70.99%)</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">MAE Test:</span>
                  <span className="font-mono text-slate-700">0.5294 ml</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">RMSE:</span>
                  <span className="font-mono text-slate-700">0.6635 ml</span>
                </div>
                <div className="text-[10px] text-slate-400 font-mono truncate pt-1 border-t border-slate-50">
                  Juice = 0.4569·W - 0.6080
                </div>
              </div>
            </div>

            {/* Card 2: Multiple Linear Regression */}
            <div className="bg-white rounded-2xl border border-slate-200 p-5 flex flex-col justify-between shadow-xs hover:border-slate-300 transition">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">
                    Model 2
                  </span>
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-blue-50 text-blue-800 border border-blue-200">
                    Comparative
                  </span>
                </div>
                <h3 className="font-bold text-slate-900 text-sm">Multiple Linear Regression</h3>
                <div className="text-2xl font-extrabold font-mono text-slate-800 tracking-tight mt-2.5">
                  {result.mlrTotalMl.toFixed(2)} ml
                </div>
                <div className="text-xs font-mono text-slate-500 mt-0.5">
                  ~{(result.mlrTotalMl / 1000).toFixed(4)} L
                </div>
              </div>

              <div className="pt-3.5 border-t border-slate-100 space-y-1.5 text-xs text-slate-600 mt-4">
                <div className="flex justify-between">
                  <span className="text-slate-500">Input Feature:</span>
                  <span className="font-medium text-slate-800">Weight + Size</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">R² Score:</span>
                  <span className="font-mono font-bold text-slate-800">0.7100 (71.00%)</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">MAE Test:</span>
                  <span className="font-mono text-slate-700">0.5292 ml</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">RMSE:</span>
                  <span className="font-mono text-slate-700">0.6635 ml</span>
                </div>
                <div className="text-[10px] text-slate-400 font-mono truncate pt-1 border-t border-slate-50">
                  Juice = 0.4580·W - 0.0053·S - 0.6108
                </div>
              </div>
            </div>

            {/* Card 3: Polynomial Regression (Degree 2) - Original V1 */}
            <div className="bg-white rounded-2xl border border-slate-200 p-5 flex flex-col justify-between shadow-xs hover:border-slate-300 transition">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">
                    Model 3
                  </span>
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-slate-100 text-slate-700 border border-slate-200">
                    Original V1 Baseline
                  </span>
                </div>
                <h3 className="font-bold text-slate-900 text-sm">Polynomial Regression (Degree 2)</h3>
                <div className="text-2xl font-extrabold font-mono text-slate-800 tracking-tight mt-2.5">
                  {result.polyTotalMl.toFixed(2)} ml
                </div>
                <div className="text-xs font-mono text-slate-500 mt-0.5">
                  ~{(result.polyTotalMl / 1000).toFixed(4)} L
                </div>
              </div>

              <div className="pt-3.5 border-t border-slate-100 space-y-1.5 text-xs text-slate-600 mt-4">
                <div className="flex justify-between">
                  <span className="text-slate-500">Input Feature:</span>
                  <span className="font-medium text-slate-800">Weight, Size, W², W·S, S²</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">R² Score:</span>
                  <span className="font-mono font-bold text-slate-800">0.7102 (71.02%)</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">MAE Test:</span>
                  <span className="font-mono text-slate-700">0.5279 ml</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">RMSE:</span>
                  <span className="font-mono text-slate-700">0.6637 ml</span>
                </div>
                <div className="text-[10px] text-slate-400 font-mono truncate pt-1 border-t border-slate-50">
                  Juice = -0.5480 + 0.4357·W + 0.0865·S - 0.0031·W² ...
                </div>
              </div>
            </div>

            {/* Card 4: ★ Proposed Champion Model (V2 Upgrade) */}
            <div className="bg-emerald-50/70 rounded-2xl border-2 border-emerald-600 p-5 flex flex-col justify-between shadow-xs relative overflow-hidden">
              <div className="absolute top-0 right-0 w-16 h-16 bg-emerald-500/10 rounded-bl-full pointer-events-none" />
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-[11px] font-black text-emerald-800 uppercase tracking-wider flex items-center gap-1">
                    <Award className="w-3.5 h-3.5 text-amber-500" />
                    <span>★ Model 4 (V2)</span>
                  </span>
                  <span className="text-[10px] font-black px-2.5 py-0.5 rounded-full bg-emerald-700 text-white shadow-xs">
                    ★ #1 BEST PERFORMING
                  </span>
                </div>
                <h3 className="font-black text-emerald-950 text-sm">
                  Proposed Polynomial Champion
                </h3>
                <div className="text-xs text-emerald-800 font-medium mt-0.5">
                  Poly (d=2) + ln(W) & L2 Ridge
                </div>
                <div className="text-3xl font-extrabold font-mono text-emerald-700 tracking-tight mt-2">
                  {result.cbPolyTotalMl.toFixed(2)} ml
                </div>
                <div className="text-xs font-mono text-emerald-900 font-semibold mt-0.5">
                  ~{(result.cbPolyTotalMl / 1000).toFixed(4)} Liters Pure Juice
                </div>
              </div>

              <div className="pt-3.5 border-t border-emerald-200/80 space-y-1.5 text-xs text-emerald-950 mt-4">
                <div className="flex justify-between">
                  <span className="font-medium text-emerald-800">Input Feature:</span>
                  <span className="font-bold text-emerald-900">Weight, W², ln(W) + Ridge</span>
                </div>
                <div className="flex justify-between">
                  <span className="font-bold text-emerald-900">R² Score:</span>
                  <span className="font-mono font-black text-emerald-800 text-sm">
                    0.8228 (82.28%)
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="font-bold text-emerald-900">MAE Test:</span>
                  <span className="font-mono font-black text-emerald-800">0.4896 ml</span>
                </div>
                <div className="flex justify-between">
                  <span className="font-medium text-emerald-800">Difference:</span>
                  <span className="font-mono font-black text-emerald-700">
                    +11.26% vs V1 Baseline
                  </span>
                </div>
                <div className="text-[10px] text-emerald-700 font-mono truncate pt-1 border-t border-emerald-200/60 font-semibold">
                  Juice = 2.3179 + 1.1004·W - 0.0141·W² - 3.446·ln(W)
                </div>
              </div>
            </div>
          </div>

          {/* Research Callout Box (Exact match from Version 1) */}
          <div className="p-4 bg-amber-50/80 border border-amber-200 rounded-2xl flex items-start gap-3">
            <span className="text-xl">💡</span>
            <div className="text-xs text-amber-950 leading-relaxed">
              <strong className="text-amber-900">
                Why the Proposed Polynomial Model is Recommended:
              </strong>{' '}
              Evaluated across verified calamansi harvest data, 2nd-degree polynomial regression
              augmented with the natural-log term <code className="font-mono font-bold bg-amber-100/80 px-1 py-0.5 rounded">ln(W)</code> and L2 Ridge regularization achieves the highest coefficient of determination (<strong className="font-mono text-emerald-800">R² = 82.28%</strong>) and lowest test error (<strong className="font-mono text-emerald-800">MAE = 0.4896 ml</strong>). It demonstrates a clear <strong className="text-emerald-800">+11.26% improvement</strong> over the baseline models (70.99% – 71.02%) while operating purely on harvest weight without manual fruit grading.
            </div>
          </div>

          {/* ──────────────── 3. COMMERCIAL PACKAGING YIELDS (V1 PLACING) ──────────────── */}
          <div className="pt-2 border-t border-slate-100">
            <h3 className="text-sm font-extrabold text-slate-800 uppercase tracking-wider mb-3 flex items-center gap-2">
              <PackageCheck className="w-4 h-4 text-emerald-700" />
              <span>Commercial Bottling & Inventory Yields</span>
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div className="bg-emerald-50/60 p-4 rounded-xl border border-emerald-100 text-center">
                <div className="text-xs text-slate-600 font-semibold">330 mL Bottles</div>
                <div className="text-2xl font-extrabold font-mono text-emerald-800 mt-1">
                  ~{result.bottles330}
                </div>
                <div className="text-[11px] text-slate-500 mt-0.5">Ready-to-drink size</div>
              </div>

              <div className="bg-emerald-50/60 p-4 rounded-xl border border-emerald-100 text-center">
                <div className="text-xs text-slate-600 font-semibold">500 mL Bottles</div>
                <div className="text-2xl font-extrabold font-mono text-emerald-800 mt-1">
                  ~{result.bottles500}
                </div>
                <div className="text-[11px] text-slate-500 mt-0.5">Retail concentrate format</div>
              </div>

              <div className="bg-emerald-50/60 p-4 rounded-xl border border-emerald-100 text-center">
                <div className="text-xs text-slate-600 font-semibold">1.0 Liter Commercial Jugs</div>
                <div className="text-2xl font-extrabold font-mono text-emerald-800 mt-1">
                  ~{result.bottles1000}
                </div>
                <div className="text-[11px] text-slate-500 mt-0.5">Pure juice catering volume</div>
              </div>
            </div>
          </div>

          {/* ──────────────── 4. DIRECT VISUAL COMPARISON BAR CHARTS (V1 PLACING) ──────────────── */}
          <div className="pt-2 border-t border-slate-100 space-y-3">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-sm font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
                  <TrendingUp className="w-4 h-4 text-emerald-700" />
                  <span>Visual Performance Comparison (Higher R² & Lower MAE)</span>
                </h3>
                <p className="text-xs text-slate-500">
                  Clearly shows the teacher and defense panel the superior performance of the Proposed Champion Model
                </p>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-1">
              {/* Chart 1: R² Bar Chart */}
              <div className="space-y-3 bg-slate-50 p-4 rounded-xl border border-slate-200">
                <div className="text-xs font-bold text-slate-700 uppercase tracking-wider flex justify-between">
                  <span>R² Determination (Higher is Better)</span>
                  <span className="text-emerald-700 font-bold">Target ≥ 80%</span>
                </div>
                <div className="space-y-2.5">
                  {[
                    { name: '★ Proposed Champion (V2)', val: 82.28, isChamp: true },
                    { name: 'Simple Linear Regression (SLR)', val: 70.99 },
                    { name: 'Multiple Linear Regression (MLR)', val: 71.00 },
                    { name: 'Polynomial Regression (Degree 2)', val: 71.02 },
                  ].map((item) => (
                    <div key={item.name} className="space-y-1">
                      <div className="flex justify-between text-xs">
                        <span className={`font-semibold ${item.isChamp ? 'text-emerald-900 font-bold' : 'text-slate-700'}`}>
                          {item.name}
                        </span>
                        <span className={`font-mono font-bold ${item.isChamp ? 'text-emerald-800' : 'text-slate-700'}`}>
                          {item.val.toFixed(2)}%
                        </span>
                      </div>
                      <div className="w-full bg-slate-200 h-3 rounded-full overflow-hidden">
                        <div
                          className={`h-full rounded-full transition-all duration-500 ${
                            item.isChamp ? 'bg-emerald-600' : 'bg-slate-400'
                          }`}
                          style={{ width: `${(item.val / 90) * 100}%` }}
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Chart 2: MAE Error Bar Chart */}
              <div className="space-y-3 bg-slate-50 p-4 rounded-xl border border-slate-200">
                <div className="text-xs font-bold text-slate-700 uppercase tracking-wider flex justify-between">
                  <span>Mean Absolute Error MAE (Lower is Better)</span>
                  <span className="text-emerald-700 font-bold">mL per fruit</span>
                </div>
                <div className="space-y-2.5">
                  {[
                    { name: '★ Proposed Champion (V2)', val: 0.4896, isChamp: true },
                    { name: 'Polynomial Regression (Degree 2)', val: 0.5279 },
                    { name: 'Multiple Linear Regression (MLR)', val: 0.5292 },
                    { name: 'Simple Linear Regression (SLR)', val: 0.5294 },
                  ].map((item) => (
                    <div key={item.name} className="space-y-1">
                      <div className="flex justify-between text-xs">
                        <span className={`font-semibold ${item.isChamp ? 'text-emerald-900 font-bold' : 'text-slate-700'}`}>
                          {item.name}
                        </span>
                        <span className={`font-mono font-bold ${item.isChamp ? 'text-emerald-800' : 'text-slate-700'}`}>
                          {item.val.toFixed(4)} mL
                        </span>
                      </div>
                      <div className="w-full bg-slate-200 h-3 rounded-full overflow-hidden">
                        <div
                          className={`h-full rounded-full transition-all duration-500 ${
                            item.isChamp ? 'bg-emerald-600' : 'bg-amber-500'
                          }`}
                          style={{ width: `${(item.val / 0.60) * 100}%` }}
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </section>
      ) : (
        <div className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-10 text-center">
          <div className="w-12 h-12 bg-emerald-50 rounded-full flex items-center justify-center mx-auto text-emerald-600 mb-3 text-xl">
            📊
          </div>
          <h3 className="font-bold text-slate-800 text-base">Ready to predict.</h3>
          <p className="text-xs text-slate-500 mt-1">
            Enter your calamansi batch weight above and tap &quot;Calculate Juice Yield&quot;.
          </p>
        </div>
      )}

      {/* ──────────────── 5. RECENT HARVEST LOGS (V1 PLACING) ──────────────── */}
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
