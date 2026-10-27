import React, { useState } from 'react';
import {
  FlaskConical,
  Sparkles,
  CheckCircle2,
  HelpCircle,
  Thermometer,
  PackageCheck,
  Droplet,
  Coffee,
  ArrowRight,
  Flame,
  ShieldCheck,
  Scale,
  RotateCcw,
} from 'lucide-react';

interface DostSugarFormulatorProps {
  initialJuiceMl?: number;
  initialWeightKg?: number;
  onNavigateToProfit?: (weightKg: number, bottles: number) => void;
}

export const DostSugarFormulator: React.FC<DostSugarFormulatorProps> = ({
  initialJuiceMl = 1000,
  initialWeightKg,
  onNavigateToProfit,
}) => {
  // Mode: Enter Pure Juice Volume OR Enter Calamansi Fruit Weight
  const [inputMode, setInputMode] = useState<'juice' | 'fruit'>('juice');
  const [pureJuiceLiters, setPureJuiceLiters] = useState<number>(
    initialJuiceMl ? initialJuiceMl / 1000 : 1.0
  );
  const [fruitWeightKg, setFruitWeightKg] = useState<number>(initialWeightKg || 10);

  // Formulation ratio: DOST standard is 1.5 kg sugar per 1.0 L pure juice
  const [sugarRatioKgPerLiter, setSugarRatioKgPerLiter] = useState<number>(1.5);
  const [bottleSizeMl, setBottleSizeMl] = useState<number>(350); // 350 mL retail bottle
  const [sugarPricePerKg, setSugarPricePerKg] = useState<number>(80); // ₱80/kg cane sugar

  // If in fruit mode, compute pure juice via calibrated ~41.2% yield
  const effectiveJuiceLiters =
    inputMode === 'fruit' ? fruitWeightKg * 0.412 : pureJuiceLiters;

  // Formula calculations based on DOST-ITDI specifications:
  // 1 L pure juice + 1.5 kg sugar dissolved yields ~2.05 L finished concentrate (~50-55° Brix)
  const concentrateFactor = 1.0 + (sugarRatioKgPerLiter * 0.70); // 1kg sugar dissolved adds ~0.7L displacement volume
  const finishedConcentrateLiters = +(effectiveJuiceLiters * concentrateFactor).toFixed(2);
  const finishedConcentrateMl = Math.round(finishedConcentrateLiters * 1000);

  // Sugar required
  const totalSugarKg = +(effectiveJuiceLiters * sugarRatioKgPerLiter).toFixed(2);
  const totalSugarCost = +(totalSugarKg * sugarPricePerKg).toFixed(2);

  // Bottles yielded
  const bottlesYielded = Math.max(1, Math.round(finishedConcentrateMl / bottleSizeMl));

  // Dilution guide: 1 part concentrate + 4 parts water (1:4 ratio)
  const readyToDrinkLiters = +(finishedConcentrateLiters * 5.0).toFixed(1);
  const totalGlasses200ml = Math.round((readyToDrinkLiters * 1000) / 200);

  // Quick 1-click DOST reference preset
  const handleLoadDostStandard = () => {
    setInputMode('juice');
    setPureJuiceLiters(1.0);
    setSugarRatioKgPerLiter(1.5);
    setBottleSizeMl(350);
  };

  return (
    <div className="space-y-6 pb-12 max-w-5xl mx-auto">
      {/* 1. WHY THIS WINS THE DEFENSE PANEL */}
      <div className="bg-gradient-to-r from-teal-900 via-emerald-950 to-slate-900 text-white rounded-3xl p-6 sm:p-7 shadow-sm border border-teal-700/50 relative overflow-hidden">
        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div className="space-y-2 max-w-2xl">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-teal-500/20 border border-teal-400/40 text-teal-300 text-xs font-extrabold uppercase tracking-wider">
              <FlaskConical className="w-3.5 h-3.5 text-amber-300" />
              <span>DOST-ITDI Food Processing Formulation</span>
            </div>
            <h2 className="text-xl sm:text-2xl font-black tracking-tight text-white">
              DOST Sugar Recipe Formulator (Juice Concentrate)
            </h2>
            <p className="text-teal-100/90 text-xs sm:text-sm leading-relaxed">
              <strong className="text-amber-300">Answers the Panel&apos;s Practical Question:</strong>{' '}
              <em>&ldquo;What does the farmer actually do with the pure juice after extracting it?&rdquo;</em>
            </p>
            <p className="text-teal-200/75 text-xs">
              Raw calamansi juice is naturally high in citric acid (5%–6%) with an aggressive pH of ~2.2.
              Drinking it pure is too sour and causes throat irritation. By compounding with DOST&apos;s 1:1.5 standard sugar ratio,
              the juice forms a 50°–55° Brix concentrate that naturally preserves for 6–12 months without chemical preservatives!
            </p>
          </div>

          <div className="shrink-0 flex flex-col gap-2">
            <button
              type="button"
              onClick={handleLoadDostStandard}
              className="px-4 py-2.5 bg-amber-400 hover:bg-amber-300 active:bg-amber-500 text-slate-950 font-black rounded-xl text-xs sm:text-sm shadow-md transition flex items-center justify-center gap-2 cursor-pointer"
            >
              <span>⭐ Load DOST Standard (1 L)</span>
            </button>
            <span className="text-[11px] text-teal-300 text-center">
              1 Liter Pure Juice ➔ 1.5 kg Sugar ➔ ~2 Liters
            </span>
          </div>
        </div>
      </div>

      {/* 2. THE DOST SIMPLE EXAMPLE CALLOUT */}
      <div className="bg-emerald-50/90 border border-emerald-200/90 rounded-2xl p-5 text-slate-800">
        <div className="flex items-center gap-2 mb-2 font-black text-xs uppercase tracking-wider text-emerald-900">
          <CheckCircle2 className="w-4 h-4 text-emerald-700" />
          <span>DOST-ITDI Official Formulation Baseline:</span>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3 text-xs sm:text-sm">
          <div className="bg-white/90 p-3.5 rounded-xl border border-emerald-200">
            <div className="text-slate-500 text-xs font-semibold">1. Pure Calamansi Juice</div>
            <div className="text-xl font-mono font-black text-slate-900 mt-0.5">1.0 Liter</div>
            <div className="text-[11px] text-slate-500 mt-1">Strained, unpasteurized 100% natural pure juice</div>
          </div>
          <div className="bg-white/90 p-3.5 rounded-xl border border-emerald-200">
            <div className="text-slate-500 text-xs font-semibold">2. Add Refined White Sugar</div>
            <div className="text-xl font-mono font-black text-amber-700 mt-0.5">+1.5 kg Sugar</div>
            <div className="text-[11px] text-slate-500 mt-1">DOST 1 : 1.5 food preservation sweetening ratio</div>
          </div>
          <div className="bg-emerald-900 text-white p-3.5 rounded-xl border border-emerald-700">
            <div className="text-emerald-200 text-xs font-semibold">3. Finished Concentrate Yield</div>
            <div className="text-xl font-mono font-black text-amber-300 mt-0.5">~2.0 Liters</div>
            <div className="text-[11px] text-emerald-200 mt-1">Sweet concentrate (50–55° Brix, shelf-stable)</div>
          </div>
        </div>
      </div>

      {/* 3. INTERACTIVE FORMULATION CALCULATOR */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Form: Inputs (5 Cols) */}
        <div className="lg:col-span-5 bg-white rounded-2xl border border-slate-200/90 p-6 shadow-xs space-y-5">
          <div className="flex items-center justify-between pb-3 border-b border-slate-100">
            <h3 className="text-base font-extrabold text-slate-900 flex items-center gap-2">
              <Scale className="w-4 h-4 text-teal-700" />
              <span>Batch Formulation Inputs</span>
            </h3>
            {/* Input Mode Toggle */}
            <div className="flex bg-slate-100 p-0.5 rounded-lg text-xs">
              <button
                type="button"
                onClick={() => setInputMode('juice')}
                className={`px-2.5 py-1 rounded font-bold transition cursor-pointer ${
                  inputMode === 'juice'
                    ? 'bg-teal-700 text-white shadow-xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                By Juice (L)
              </button>
              <button
                type="button"
                onClick={() => setInputMode('fruit')}
                className={`px-2.5 py-1 rounded font-bold transition cursor-pointer ${
                  inputMode === 'fruit'
                    ? 'bg-teal-700 text-white shadow-xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                By Fruit (kg)
              </button>
            </div>
          </div>

          {/* Conditional Juice or Fruit Input */}
          {inputMode === 'juice' ? (
            <div className="space-y-1.5">
              <label className="text-xs font-bold uppercase tracking-wider text-slate-600 flex justify-between">
                <span>Extracted Pure Juice Volume</span>
                <span className="text-slate-400 font-normal">
                  {(pureJuiceLiters * 1000).toLocaleString()} mL
                </span>
              </label>
              <div className="relative">
                <input
                  type="number"
                  min="0.1"
                  step="0.1"
                  value={pureJuiceLiters}
                  onChange={(e) => setPureJuiceLiters(Math.max(0.05, parseFloat(e.target.value) || 0))}
                  className="w-full text-lg font-mono font-bold px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-slate-900 focus:bg-white focus:outline-none focus:border-teal-600 transition"
                />
                <span className="absolute right-3.5 top-3 text-xs font-mono font-bold text-slate-400">
                  Liters
                </span>
              </div>
            </div>
          ) : (
            <div className="space-y-1.5">
              <label className="text-xs font-bold uppercase tracking-wider text-slate-600 flex justify-between">
                <span>Harvested Fruit Weight (kg)</span>
                <span className="text-emerald-700 font-bold">
                  ~{(fruitWeightKg * 0.412).toFixed(2)} L juice est.
                </span>
              </label>
              <div className="relative">
                <input
                  type="number"
                  min="0.5"
                  step="0.5"
                  value={fruitWeightKg}
                  onChange={(e) => setFruitWeightKg(Math.max(0.1, parseFloat(e.target.value) || 0))}
                  className="w-full text-lg font-mono font-bold px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-slate-900 focus:bg-white focus:outline-none focus:border-teal-600 transition"
                />
                <span className="absolute right-3.5 top-3 text-xs font-mono font-bold text-slate-400">
                  kg raw fruit
                </span>
              </div>
              <p className="text-[11px] text-slate-400">
                Calculated using calibrated 41.2% juice extraction density.
              </p>
            </div>
          )}

          {/* Sugar Formulation Presets */}
          <div className="space-y-1.5">
            <label className="text-xs font-bold uppercase tracking-wider text-slate-600">
              DOST Recipe Formulation:
            </label>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
              {[
                { label: 'Mild (1 : 1.2)', ratio: 1.2, note: '~45° Brix' },
                { label: 'DOST (1 : 1.5)', ratio: 1.5, note: 'Standard ~55° Brix' },
                { label: 'Rich (1 : 1.8)', ratio: 1.8, note: 'Cordial ~60° Brix' },
              ].map((r) => (
                <button
                  key={r.label}
                  type="button"
                  onClick={() => setSugarRatioKgPerLiter(r.ratio)}
                  className={`p-2.5 rounded-xl border text-left transition cursor-pointer ${
                    sugarRatioKgPerLiter === r.ratio
                      ? 'bg-teal-50 border-teal-600 text-teal-950 shadow-2xs'
                      : 'bg-slate-50 border-slate-200 text-slate-600 hover:bg-slate-100'
                  }`}
                >
                  <div className="font-bold text-xs">{r.label}</div>
                  <div className="text-[10px] text-slate-400 mt-0.5">{r.note}</div>
                </button>
              ))}
            </div>
          </div>

          {/* Bottle Size Selector */}
          <div className="space-y-1.5">
            <label className="text-xs font-bold uppercase tracking-wider text-slate-600">
              Packaging Format (Bottle Size):
            </label>
            <div className="grid grid-cols-3 gap-2 text-xs">
              {[
                { label: '330 mL', ml: 330, desc: 'Compact' },
                { label: '350 mL', ml: 350, desc: 'Standard PET' },
                { label: '500 mL', ml: 500, desc: 'Family Size' },
              ].map((b) => (
                <button
                  key={b.label}
                  type="button"
                  onClick={() => setBottleSizeMl(b.ml)}
                  className={`p-2 rounded-xl border text-center transition cursor-pointer ${
                    bottleSizeMl === b.ml
                      ? 'bg-teal-700 text-white border-teal-700 shadow-xs'
                      : 'bg-slate-50 border-slate-200 text-slate-700 hover:bg-slate-100'
                  }`}
                >
                  <div className="font-bold">{b.label}</div>
                  <div className={`text-[10px] ${bottleSizeMl === b.ml ? 'text-teal-200' : 'text-slate-400'}`}>
                    {b.desc}
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Sugar Price */}
          <div className="space-y-1.5">
            <label className="text-xs font-bold uppercase tracking-wider text-slate-600 flex justify-between">
              <span>White Refined Sugar Price</span>
              <span className="text-slate-400 font-normal">Market rate</span>
            </label>
            <div className="relative">
              <span className="absolute left-3.5 top-2.5 text-slate-400 font-mono font-bold text-base">₱</span>
              <input
                type="number"
                min="10"
                step="1"
                value={sugarPricePerKg}
                onChange={(e) => setSugarPricePerKg(Math.max(1, parseFloat(e.target.value) || 0))}
                className="w-full text-base font-mono font-bold pl-8 pr-3.5 py-2 bg-slate-50 border border-slate-200 rounded-xl text-slate-900 focus:bg-white focus:outline-none focus:border-teal-600 transition"
              />
              <span className="absolute right-3.5 top-2.5 text-xs font-mono font-bold text-slate-400">
                / kg
              </span>
            </div>
          </div>
        </div>

        {/* Right Output: Batch Recipe & Commercial Yields (7 Cols) */}
        <div className="lg:col-span-7 space-y-5">
          {/* Main Recipe Card */}
          <div className="bg-white rounded-2xl border-2 border-teal-600 p-6 shadow-sm space-y-5">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-100">
              <div>
                <span className="text-[11px] font-extrabold uppercase tracking-wider text-teal-800 bg-teal-100 px-2.5 py-0.5 rounded-full">
                  Batch Production Sheet
                </span>
                <h3 className="text-xl font-extrabold text-slate-900 mt-1">
                  Finished Sweet Concentrate: ~{finishedConcentrateLiters} Liters
                </h3>
              </div>
              <div className="bg-teal-800 text-white px-4 py-2 rounded-xl text-center self-start sm:self-auto shadow-xs">
                <div className="text-[10px] uppercase font-bold text-teal-200">Yield Count</div>
                <div className="text-2xl font-black font-mono">~{bottlesYielded} Bottles</div>
              </div>
            </div>

            {/* Recipe Quantities Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
              <div className="bg-teal-50/70 p-3.5 rounded-xl border border-teal-200 flex items-center justify-between">
                <div>
                  <div className="text-slate-500 font-medium">Pure Calamansi Juice:</div>
                  <div className="text-lg font-mono font-black text-teal-900 mt-0.5">
                    {effectiveJuiceLiters.toFixed(2)} Liters
                  </div>
                </div>
                <Droplet className="w-6 h-6 text-teal-600 shrink-0" />
              </div>

              <div className="bg-amber-50/70 p-3.5 rounded-xl border border-amber-200 flex items-center justify-between">
                <div>
                  <div className="text-slate-500 font-medium">Refined Sugar Needed:</div>
                  <div className="text-lg font-mono font-black text-amber-900 mt-0.5">
                    {totalSugarKg} kg <span className="text-xs text-amber-700 font-normal">(@ ₱{sugarPricePerKg}/kg)</span>
                  </div>
                </div>
                <Scale className="w-6 h-6 text-amber-600 shrink-0" />
              </div>
            </div>

            {/* Serving & Dilution Output */}
            <div className="bg-slate-50 rounded-xl border border-slate-200 p-4 space-y-2 text-xs">
              <div className="font-bold text-slate-800 flex items-center gap-1.5">
                <Coffee className="w-4 h-4 text-emerald-700" />
                <span>Customer Dilution &amp; Serving Guide:</span>
              </div>
              <p className="text-slate-600 text-xs">
                The concentrate is diluted at <strong className="text-emerald-800">1 part concentrate to 4 parts chilled water</strong> (or 1:5 for light refreshment).
              </p>
              <div className="grid grid-cols-2 gap-2 pt-1 font-mono text-xs">
                <div className="bg-white p-2 rounded-lg border border-slate-200">
                  <span className="text-slate-500 block text-[11px]">Ready-to-Drink Volume:</span>
                  <span className="font-bold text-slate-800 text-sm">~{readyToDrinkLiters} Liters</span>
                </div>
                <div className="bg-white p-2 rounded-lg border border-slate-200">
                  <span className="text-slate-500 block text-[11px]">Glasses Served (200 mL):</span>
                  <span className="font-bold text-emerald-700 text-sm">~{totalGlasses200ml} glasses</span>
                </div>
              </div>
            </div>

            {/* Link to Profit Calculator */}
            {onNavigateToProfit && (
              <div className="pt-2">
                <button
                  type="button"
                  onClick={() => onNavigateToProfit(fruitWeightKg, bottlesYielded)}
                  className="w-full py-3 px-4 bg-emerald-700 hover:bg-emerald-800 active:bg-emerald-900 text-white font-bold rounded-xl text-xs sm:text-sm shadow-xs transition flex items-center justify-center gap-2 cursor-pointer"
                >
                  <span>💰 Calculate Farmgate vs Bottling Profit for these {bottlesYielded} Bottles</span>
                  <ArrowRight className="w-4 h-4" />
                </button>
              </div>
            )}
          </div>

          {/* DOST 5-Step Pasteurization Standard Protocol */}
          <div className="bg-white rounded-2xl border border-slate-200/90 p-5 shadow-xs space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-700 flex items-center gap-1.5">
              <Thermometer className="w-4 h-4 text-teal-700" />
              <span>DOST-ITDI 5-Step Safe Processing Protocol (SOP)</span>
            </h4>
            <div className="space-y-2 text-xs text-slate-600">
              <div className="flex items-start gap-2.5 p-2 rounded-lg bg-slate-50 border border-slate-100">
                <span className="w-5 h-5 rounded-full bg-teal-100 text-teal-800 font-bold flex items-center justify-center shrink-0 text-[11px]">
                  1
                </span>
                <div>
                  <strong className="text-slate-800">Careful Extraction &amp; Filtration:</strong> Slice the top third of the calamansi. Squeeze gently by hand or food-grade press without piercing the peel (to prevent bitter essential oil contamination). Strain through fine nylon/stainless mesh.
                </div>
              </div>
              <div className="flex items-start gap-2.5 p-2 rounded-lg bg-slate-50 border border-slate-100">
                <span className="w-5 h-5 rounded-full bg-teal-100 text-teal-800 font-bold flex items-center justify-center shrink-0 text-[11px]">
                  2
                </span>
                <div>
                  <strong className="text-slate-800">Sugar Blending:</strong> Stir in {sugarRatioKgPerLiter} kg refined sugar per 1 L pure juice in a stainless steel kettle until completely dissolved.
                </div>
              </div>
              <div className="flex items-start gap-2.5 p-2 rounded-lg bg-slate-50 border border-slate-100">
                <span className="w-5 h-5 rounded-full bg-teal-100 text-teal-800 font-bold flex items-center justify-center shrink-0 text-[11px]">
                  3
                </span>
                <div>
                  <strong className="text-slate-800">Low-Heat Pasteurization (65°C - 70°C for 5 mins):</strong> Heat with continuous stirring. <span className="text-amber-800 font-semibold">Never boil</span>—boiling destroys natural Vitamin C and degrades the fresh citrus aroma.
                </div>
              </div>
              <div className="flex items-start gap-2.5 p-2 rounded-lg bg-slate-50 border border-slate-100">
                <span className="w-5 h-5 rounded-full bg-teal-100 text-teal-800 font-bold flex items-center justify-center shrink-0 text-[11px]">
                  4
                </span>
                <div>
                  <strong className="text-slate-800">Hot Filling &amp; Airtight Capping:</strong> Pour concentrate while warm (~65°C) into pre-sterilized bottles leaving 1 cm headspace. Cap tightly with tamper-evident seals.
                </div>
              </div>
              <div className="flex items-start gap-2.5 p-2 rounded-lg bg-slate-50 border border-slate-100">
                <span className="w-5 h-5 rounded-full bg-teal-100 text-teal-800 font-bold flex items-center justify-center shrink-0 text-[11px]">
                  5
                </span>
                <div>
                  <strong className="text-slate-800">Water-Bath Cooling &amp; Ambient Storage:</strong> Immediately submerge capped bottles in cold running water to halt residual heating. Shelf-life: 6 months at room temperature, 12 months chilled.
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
