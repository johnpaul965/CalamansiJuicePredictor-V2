import React, { useState } from 'react';
import { Clock, Search, Trash2, Award, Calendar, Scale, Download } from 'lucide-react';
import { AppUser, PredictionLog } from '../types';
import { ConfirmModal } from './Modals';
import { exportLogsToCsv } from '../services/storageService';

interface HistoryTabProps {
  currentUser: AppUser;
  logs: PredictionLog[];
  onClearLogs: () => void;
}

export const HistoryTab: React.FC<HistoryTabProps> = ({
  currentUser,
  logs,
  onClearLogs,
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [showClearConfirm, setShowClearConfirm] = useState(false);

  // Filter for current user if not admin
  const userLogs = logs.filter(
    (l) => currentUser.role === 'admin' || l.user === currentUser.username
  );

  const filteredLogs = userLogs.filter((l) => {
    const q = searchQuery.toLowerCase();
    const primaryResult = l.primary ?? l.cbPoly ?? '';
    return (
      l.weight.toLowerCase().includes(q) ||
      l.date.toLowerCase().includes(q) ||
      primaryResult.toLowerCase().includes(q) ||
      l.user.toLowerCase().includes(q)
    );
  });

  return (
    <div className="space-y-6 pb-12 max-w-4xl mx-auto">
      {/* Top Controls */}
      <div className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-5 sm:p-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div>
            <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
              <Clock className="w-5 h-5 text-emerald-700" />
              <span>Harvest Prediction History</span>
            </h2>
            <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
              Review and audit logged calamansi batch calculations and juice yield outputs
            </p>
          </div>

          <div className="flex items-center gap-2 flex-wrap self-start sm:self-auto">
            {userLogs.length > 0 && (
              <>
                <button
                  type="button"
                  onClick={() => exportLogsToCsv(userLogs)}
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 text-xs font-semibold transition cursor-pointer shadow-2xs"
                >
                  <Download className="w-3.5 h-3.5 text-slate-500" />
                  <span>Export CSV</span>
                </button>

                <button
                  type="button"
                  onClick={() => setShowClearConfirm(true)}
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-red-200 text-red-700 hover:bg-red-50 text-xs font-semibold transition cursor-pointer"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                  <span>Clear History</span>
                </button>
              </>
            )}
          </div>
        </div>

        {/* Search Bar */}
        {userLogs.length > 0 && (
          <div className="mt-4 relative flex items-center">
            <Search className="absolute left-3 w-4 h-4 text-slate-400" />
            <input
              type="text"
              placeholder="Search by weight, fruit count, or date..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-emerald-600 focus:bg-white transition"
            />
          </div>
        )}
      </div>

      {/* History Items List */}
      <div className="space-y-3">
        {filteredLogs.length === 0 ? (
          <div className="bg-white rounded-2xl border border-slate-200 p-12 text-center">
            <div className="w-14 h-14 rounded-2xl bg-slate-100 flex items-center justify-center mx-auto mb-3 text-slate-400">
              <Clock className="w-7 h-7" />
            </div>
            <h3 className="text-base font-bold text-slate-800">
              {searchQuery ? 'No matching predictions found' : 'No predictions yet'}
            </h3>
            <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
              {searchQuery
                ? 'Try searching with a different batch weight or date keyword.'
                : 'Run a calculation from the Predict tab to see your extraction records logged here.'}
            </p>
          </div>
        ) : (
          filteredLogs.map((item) => (
            <div
              key={item.id}
              className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-5 hover:border-emerald-300 transition flex flex-col sm:flex-row sm:items-center justify-between gap-4"
            >
              <div className="flex items-start gap-3.5">
                <div className="w-11 h-11 rounded-xl bg-emerald-100 flex items-center justify-center shrink-0 text-xl shadow-inner">
                  🍋
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-bold text-slate-900 text-sm">
                      {item.weight}
                    </span>
                    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-bold">
                      <Award className="w-2.5 h-2.5" /> Weight-only primary model
                    </span>
                  </div>

                  <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-slate-500 mt-1">
                    <span className="text-emerald-700 font-medium font-mono">
                      ~{item.count} calamansi fruits
                    </span>
                    <span>•</span>
                    <span className="font-mono text-[11px] text-slate-400">{item.date}</span>
                    {currentUser.role === 'admin' && (
                      <>
                        <span>•</span>
                        <span className="text-slate-400">User: {item.user}</span>
                      </>
                    )}
                  </div>
                </div>
              </div>

              <div className="sm:text-right shrink-0 border-t sm:border-t-0 pt-2 sm:pt-0 border-slate-100">
                <div className="text-xl font-extrabold font-mono text-emerald-700">
                  {item.primary ?? item.cbPoly ?? '—'}
                </div>
                <div className="text-[11px] font-mono text-slate-400 mt-0.5">
                  SLR: {item.slr} · Quadratic: {item.poly ?? '—'} · RBF SVR: {item.rbf ?? '—'}
                </div>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Clear Confirmation Modal */}
      <ConfirmModal
        isOpen={showClearConfirm}
        title="Clear Prediction History?"
        message="Are you sure you want to clear your prediction history records? This cannot be undone."
        confirmLabel="Clear All Records"
        onConfirm={() => {
          onClearLogs();
          setShowClearConfirm(false);
        }}
        onCancel={() => setShowClearConfirm(false)}
      />
    </div>
  );
};
