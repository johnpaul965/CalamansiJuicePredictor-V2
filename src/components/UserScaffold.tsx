import React, { useState } from 'react';
import { Zap, BarChart3, Clock, LogOut, FlaskConical } from 'lucide-react';
import { AppUser, PredictionLog } from '../types';
import { PredictTab } from './PredictTab';
import { ModelResultsTab } from './ModelResultsTab';
import { HistoryTab } from './HistoryTab';

interface UserScaffoldProps {
  currentUser: AppUser;
  logs: PredictionLog[];
  onRefreshLogs: () => void;
  onClearLogs: () => void;
  onSignOut: () => void;
}

export const UserScaffold: React.FC<UserScaffoldProps> = ({
  currentUser,
  logs,
  onRefreshLogs,
  onClearLogs,
  onSignOut,
}) => {
  const [activeTab, setActiveTab] = useState<'predict' | 'results' | 'history'>('predict');

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col">
      {/* Flutter-style AppBar */}
      <header className="bg-emerald-800 text-white shadow-sm sticky top-0 z-30">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-white/10 flex items-center justify-center text-2xl shadow-inner select-none">
              🍋
            </div>
            <div>
              <div className="font-extrabold text-base sm:text-lg leading-tight tracking-tight">
                Calamansi Yield Predictor
              </div>
              <div className="text-[11px] text-emerald-200/90 font-medium">
                Leyte Normal University • Tacloban City Study
              </div>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2 bg-emerald-900/60 py-1.5 px-3 rounded-full border border-emerald-700/50">
              <span className="bg-emerald-500 text-emerald-950 font-extrabold text-[10px] px-2 py-0.5 rounded-full uppercase tracking-wider">
                {currentUser.role}
              </span>
              <span className="text-xs font-semibold text-white">
                {currentUser.username}
              </span>
            </div>

            <button
              type="button"
              onClick={onSignOut}
              className="p-2 text-emerald-200 hover:text-white hover:bg-emerald-700/60 rounded-xl transition cursor-pointer"
              title="Sign Out"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>
        </div>
      </header>

      {/* Navigation Tabs Bar */}
      <nav className="bg-white border-b border-slate-200 sticky top-16 z-20 shadow-2xs">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 flex gap-2 sm:gap-4 overflow-x-auto">
          <button
            type="button"
            onClick={() => setActiveTab('predict')}
            className={`py-3.5 px-4 font-bold text-xs sm:text-sm border-b-2 flex items-center gap-2 transition whitespace-nowrap cursor-pointer ${
              activeTab === 'predict'
                ? 'border-emerald-700 text-emerald-800'
                : 'border-transparent text-slate-500 hover:text-slate-900'
            }`}
          >
            <Zap className={`w-4 h-4 ${activeTab === 'predict' ? 'text-amber-500 fill-amber-500' : ''}`} />
            <span>Yield Estimator</span>
          </button>

          <button
            type="button"
            onClick={() => setActiveTab('history')}
            className={`py-3.5 px-4 font-bold text-xs sm:text-sm border-b-2 flex items-center gap-2 transition whitespace-nowrap cursor-pointer ${
              activeTab === 'history'
                ? 'border-emerald-700 text-emerald-800'
                : 'border-transparent text-slate-500 hover:text-slate-900'
            }`}
          >
            <Clock className="w-4 h-4" />
            <span>Harvest History</span>
          </button>

          <button
            type="button"
            onClick={() => setActiveTab('results')}
            className={`py-3.5 px-4 font-bold text-xs sm:text-sm border-b-2 flex items-center gap-2 transition whitespace-nowrap cursor-pointer ${
              activeTab === 'results'
                ? 'border-emerald-700 text-emerald-800'
                : 'border-transparent text-slate-500 hover:text-slate-900'
            }`}
          >
            <FlaskConical className="w-4 h-4 text-emerald-600" />
            <span>Research Analytics Portal</span>
          </button>
        </div>
      </nav>

      {/* Main Content Area */}
      <main className="flex-1 max-w-6xl w-full mx-auto p-4 sm:p-6 mt-2">
        {activeTab === 'predict' && (
          <PredictTab
            currentUser={currentUser}
            logs={logs}
            onRefreshLogs={onRefreshLogs}
            onOpenResearchPortal={() => setActiveTab('results')}
          />
        )}
        {activeTab === 'results' && (
          <ModelResultsTab onBackToPredict={() => setActiveTab('predict')} />
        )}
        {activeTab === 'history' && (
          <HistoryTab
            currentUser={currentUser}
            logs={logs}
            onClearLogs={onClearLogs}
          />
        )}
      </main>
    </div>
  );
};
