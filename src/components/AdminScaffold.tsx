import React, { useState } from 'react';
import {
  Shield,
  Users,
  FileSpreadsheet,
  BarChart3,
  LogOut,
  UserPlus,
  Download,
  Trash2,
  KeyRound,
  CheckCircle,
  Ban,
  FlaskConical,
  Smartphone,
} from 'lucide-react';
import { AppUser, PredictionLog, UserRole } from '../types';
import { ModelResultsTab } from './ModelResultsTab';
import { FlutterCodeTab } from './FlutterCodeTab';
import { exportLogsToCsv } from '../services/storageService';
import { ConfirmModal, ResetPasswordModal, AddUserModal } from './Modals';

interface AdminScaffoldProps {
  currentUser: AppUser;
  users: AppUser[];
  logs: PredictionLog[];
  onUpdateUsers: (newUsers: AppUser[]) => void;
  onClearLogs: () => void;
  onRefreshLogs: () => void;
  onSignOut: () => void;
  onShowToast: (msg: string) => void;
}

export const AdminScaffold: React.FC<AdminScaffoldProps> = ({
  currentUser,
  users,
  logs,
  onUpdateUsers,
  onClearLogs,
  onRefreshLogs,
  onSignOut,
  onShowToast,
}) => {
  const [activeTab, setActiveTab] = useState<'users' | 'audit' | 'research' | 'flutter'>('users');

  // Modals state
  const [isAddUserOpen, setIsAddUserOpen] = useState(false);
  const [resetTargetUser, setResetTargetUser] = useState<string | null>(null);
  const [deleteTargetUser, setDeleteTargetUser] = useState<string | null>(null);
  const [showClearLogsConfirm, setShowClearLogsConfirm] = useState(false);

  // User Actions
  const handleToggleStatus = (targetUsername: string) => {
    const updated = users.map((u) => {
      if (u.username === targetUsername) {
        const nextStatus = u.status === 'Active' ? 'Suspended' : 'Active';
        return { ...u, status: nextStatus as 'Active' | 'Suspended' };
      }
      return u;
    });
    onUpdateUsers(updated);
    onShowToast(`Updated account status for ${targetUsername}`);
  };

  const handleToggleRole = (targetUsername: string) => {
    const updated = users.map((u) => {
      if (u.username === targetUsername) {
        const nextRole = u.role === 'admin' ? 'user' : 'admin';
        return { ...u, role: nextRole as UserRole };
      }
      return u;
    });
    onUpdateUsers(updated);
    onShowToast(`Updated role for ${targetUsername}`);
  };

  const handleResetPassword = (newPassword: string) => {
    if (!resetTargetUser) return;
    const updated = users.map((u) => {
      if (u.username === resetTargetUser) {
        return { ...u, password: newPassword };
      }
      return u;
    });
    onUpdateUsers(updated);
    onShowToast(`Password reset successfully for ${resetTargetUser}`);
    setResetTargetUser(null);
  };

  const handleDeleteUser = () => {
    if (!deleteTargetUser) return;
    const updated = users.filter((u) => u.username !== deleteTargetUser);
    onUpdateUsers(updated);
    onShowToast(`Deleted account ${deleteTargetUser}`);
    setDeleteTargetUser(null);
  };

  const handleCreateUser = (username: string, pass: string, role: UserRole): string | null => {
    const trimmed = username.trim().toLowerCase();
    if (!trimmed) return 'Username cannot be blank.';
    if (users.some((u) => u.username.toLowerCase() === trimmed)) {
      return 'That username already exists in the system.';
    }
    if (pass.length < 4) {
      return 'Password must be at least 4 characters.';
    }

    const newUser: AppUser = {
      id: `user-${Date.now()}`,
      username: trimmed,
      password: pass,
      role,
      status: 'Active',
      joined: new Date().toISOString().split('T')[0],
    };

    onUpdateUsers([...users, newUser]);
    onShowToast(`Created ${role} account: ${trimmed}`);
    setIsAddUserOpen(false);
    return null;
  };

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col">
      {/* Admin AppBar */}
      <header className="bg-slate-900 text-white shadow-sm sticky top-0 z-30 border-b border-slate-800">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-emerald-600/20 border border-emerald-500/40 flex items-center justify-center text-xl shadow-inner select-none">
              🛡️
            </div>
            <div>
              <div className="font-extrabold text-base sm:text-lg leading-tight tracking-tight flex items-center gap-2">
                <span>Calamansi Yield Engine</span>
                <span className="text-[10px] bg-emerald-500/20 border border-emerald-500/40 text-emerald-300 font-bold px-2 py-0.5 rounded-full uppercase tracking-wider">
                  Admin Console
                </span>
              </div>
              <div className="text-[11px] text-slate-400 font-medium">
                Leyte Normal University • Tacloban City Study
              </div>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2 bg-slate-800 py-1.5 px-3 rounded-full border border-slate-700">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              <span className="text-xs font-semibold text-slate-200">
                {currentUser.username}
              </span>
            </div>

            <button
              type="button"
              onClick={onSignOut}
              className="p-2 text-slate-400 hover:text-white hover:bg-slate-800 rounded-xl transition cursor-pointer"
              title="Sign Out"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>
        </div>
      </header>

      {/* Admin Navigation Bar - Strictly Administrative Roles */}
      <nav className="bg-white border-b border-slate-200 sticky top-16 z-20 shadow-2xs">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 flex gap-1 sm:gap-3 overflow-x-auto">
          <button
            type="button"
            onClick={() => setActiveTab('users')}
            className={`py-3.5 px-4 font-bold text-xs sm:text-sm border-b-2 flex items-center gap-2 transition whitespace-nowrap cursor-pointer ${
              activeTab === 'users'
                ? 'border-emerald-700 text-emerald-800'
                : 'border-transparent text-slate-500 hover:text-slate-900'
            }`}
          >
            <Users className="w-4 h-4" />
            <span>User Management</span>
            <span className="text-[10px] font-mono px-1.5 py-0.2 bg-slate-100 rounded-full text-slate-600">
              {users.length}
            </span>
          </button>

          <button
            type="button"
            onClick={() => setActiveTab('audit')}
            className={`py-3.5 px-4 font-bold text-xs sm:text-sm border-b-2 flex items-center gap-2 transition whitespace-nowrap cursor-pointer ${
              activeTab === 'audit'
                ? 'border-emerald-700 text-emerald-800'
                : 'border-transparent text-slate-500 hover:text-slate-900'
            }`}
          >
            <FileSpreadsheet className="w-4 h-4" />
            <span>Batch Audit Logs</span>
            <span className="text-[10px] font-mono px-1.5 py-0.2 bg-slate-100 rounded-full text-slate-600">
              {logs.length}
            </span>
          </button>

          <button
            type="button"
            onClick={() => setActiveTab('research')}
            className={`py-3.5 px-4 font-bold text-xs sm:text-sm border-b-2 flex items-center gap-2 transition whitespace-nowrap cursor-pointer ${
              activeTab === 'research'
                ? 'border-emerald-700 text-emerald-800'
                : 'border-transparent text-slate-500 hover:text-slate-900'
            }`}
          >
            <FlaskConical className="w-4 h-4 text-emerald-600" />
            <span>Research Analytics Portal</span>
          </button>

          <button
            type="button"
            onClick={() => setActiveTab('flutter')}
            className={`py-3.5 px-4 font-bold text-xs sm:text-sm border-b-2 flex items-center gap-2 transition whitespace-nowrap cursor-pointer ${
              activeTab === 'flutter'
                ? 'border-emerald-700 text-emerald-800'
                : 'border-transparent text-slate-500 hover:text-slate-900'
            }`}
          >
            <Smartphone className="w-4 h-4 text-emerald-600" />
            <span>Flutter Mobile Code (Dart)</span>
          </button>
        </div>
      </nav>

      {/* Main Content */}
      <main className="flex-1 max-w-6xl w-full mx-auto p-4 sm:p-6 mt-2">
        {/* Tab 1: User Management */}
        {activeTab === 'users' && (
          <div className="space-y-6 pb-12 max-w-5xl mx-auto">
            <div className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-5 border-b border-slate-100">
                <div>
                  <h2 className="text-xl font-extrabold text-slate-900 tracking-tight">
                    User Accounts & Access Control
                  </h2>
                  <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
                    Manage system credentials, activation status, and role permissions
                  </p>
                </div>

                <button
                  type="button"
                  onClick={() => setIsAddUserOpen(true)}
                  className="inline-flex items-center gap-2 px-4 py-2.5 bg-emerald-700 hover:bg-emerald-800 text-white font-bold rounded-xl text-xs sm:text-sm transition shadow-xs cursor-pointer self-start sm:self-auto"
                >
                  <UserPlus className="w-4 h-4" />
                  <span>Create Account</span>
                </button>
              </div>

              {/* Users List */}
              <div className="divide-y divide-slate-100 mt-2">
                {users.map((u) => {
                  const isSelf = u.username === currentUser.username;
                  const isAdmin = u.role === 'admin';
                  const isSuspended = u.status === 'Suspended';
                  const isRootAdmin = u.username === 'admin';

                  return (
                    <div
                      key={u.id}
                      className="py-4 flex flex-col sm:flex-row sm:items-center justify-between gap-4"
                    >
                      <div className="flex items-center gap-3.5">
                        <div
                          className={`w-10 h-10 rounded-xl flex items-center justify-center font-bold text-sm shadow-inner ${
                            isAdmin
                              ? 'bg-emerald-100 text-emerald-800'
                              : 'bg-slate-100 text-slate-700'
                          }`}
                        >
                          {u.username.slice(0, 2).toUpperCase()}
                        </div>
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="font-bold text-slate-900 text-sm">
                              {u.username}
                            </span>
                            <span
                              className={`text-[10px] font-extrabold px-2 py-0.5 rounded-full uppercase tracking-wider ${
                                isAdmin
                                  ? 'bg-emerald-100 text-emerald-800'
                                  : 'bg-slate-100 text-slate-600'
                              }`}
                            >
                              {u.role}
                            </span>
                            <span
                              className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                                isSuspended
                                  ? 'bg-red-100 text-red-700'
                                  : 'bg-emerald-50 text-emerald-700'
                              }`}
                            >
                              {u.status}
                            </span>
                          </div>
                          <div className="text-[11px] text-slate-400 mt-0.5">
                            Member since {u.joined}
                          </div>
                        </div>
                      </div>

                      {/* Action buttons */}
                      <div className="flex items-center gap-2 flex-wrap text-xs">
                        {!isSelf ? (
                          <>
                            <button
                              type="button"
                              onClick={() => handleToggleStatus(u.username)}
                              className={`px-3 py-1.5 rounded-lg border font-semibold transition cursor-pointer ${
                                isSuspended
                                  ? 'border-emerald-300 bg-emerald-50 text-emerald-800 hover:bg-emerald-100'
                                  : 'border-slate-200 text-slate-700 hover:bg-slate-100'
                              }`}
                            >
                              {isSuspended ? 'Activate' : 'Suspend'}
                            </button>

                            <button
                              type="button"
                              onClick={() => handleToggleRole(u.username)}
                              className="px-3 py-1.5 rounded-lg border border-slate-200 text-slate-700 hover:bg-slate-100 font-semibold transition cursor-pointer"
                            >
                              {isAdmin ? 'Make User' : 'Make Admin'}
                            </button>

                            <button
                              type="button"
                              onClick={() => setResetTargetUser(u.username)}
                              className="px-3 py-1.5 rounded-lg border border-slate-200 text-slate-700 hover:bg-slate-100 font-semibold transition cursor-pointer"
                            >
                              Reset Password
                            </button>
                          </>
                        ) : (
                          <span className="text-xs text-slate-400 italic px-2">
                            Current Session
                          </span>
                        )}

                        {!isRootAdmin && !isSelf && (
                          <button
                            type="button"
                            onClick={() => setDeleteTargetUser(u.username)}
                            className="px-3 py-1.5 rounded-lg border border-red-200 text-red-600 hover:bg-red-50 font-semibold transition cursor-pointer"
                          >
                            Delete
                          </button>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        )}

        {/* Tab 2: Prediction Audit Logs */}
        {activeTab === 'audit' && (
          <div className="space-y-6 pb-12 max-w-5xl mx-auto">
            <div className="bg-white rounded-2xl border border-slate-200/90 shadow-xs p-6 sm:p-7">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-5 border-b border-slate-100">
                <div>
                  <h2 className="text-xl font-extrabold text-slate-900 tracking-tight">
                    Batch Prediction Audit Logs
                  </h2>
                  <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
                    Central audit trail of all batch calculations recorded across field user sessions
                  </p>
                </div>

                <div className="flex items-center gap-2 self-start sm:self-auto">
                  <button
                    type="button"
                    onClick={() => exportLogsToCsv(logs)}
                    className="inline-flex items-center gap-1.5 px-3.5 py-2 bg-emerald-700 hover:bg-emerald-800 text-white font-semibold rounded-xl text-xs transition shadow-xs cursor-pointer"
                  >
                    <Download className="w-4 h-4" />
                    <span>Export CSV</span>
                  </button>

                  {logs.length > 0 && (
                    <button
                      type="button"
                      onClick={() => setShowClearLogsConfirm(true)}
                      className="inline-flex items-center gap-1.5 px-3.5 py-2 border border-red-200 text-red-700 hover:bg-red-50 font-semibold rounded-xl text-xs transition cursor-pointer"
                    >
                      <Trash2 className="w-4 h-4" />
                      <span>Clear Logs</span>
                    </button>
                  )}
                </div>
              </div>

              {/* Table without MLR */}
              <div className="overflow-x-auto mt-4">
                <table className="w-full text-left text-xs">
                  <thead>
                    <tr className="bg-slate-50 border-y border-slate-200 text-slate-500 font-semibold uppercase tracking-wider">
                      <th className="py-2.5 px-3">Date & Time</th>
                      <th className="py-2.5 px-3">User</th>
                      <th className="py-2.5 px-3">Batch Weight</th>
                      <th className="py-2.5 px-3 font-mono">Est. Fruits</th>
                      <th className="py-2.5 px-3 font-mono">Simple Linear</th>
                      <th className="py-2.5 px-3 font-mono">Polynomial (d=2)</th>
                      <th className="py-2.5 px-3 font-mono text-emerald-700">Poly + ln(W) + Ridge</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {logs.length === 0 ? (
                      <tr>
                        <td colSpan={7} className="py-10 text-center text-slate-400">
                          No prediction logs recorded in system yet.
                        </td>
                      </tr>
                    ) : (
                      logs.map((log) => (
                        <tr key={log.id} className="hover:bg-slate-50/80 transition">
                          <td className="py-3 px-3 font-mono text-slate-500">{log.date}</td>
                          <td className="py-3 px-3 font-bold text-slate-800">
                            {log.user}
                          </td>
                          <td className="py-3 px-3 font-semibold text-slate-900">{log.weight}</td>
                          <td className="py-3 px-3 font-mono text-slate-700">
                            ~{log.count} fruits
                          </td>
                          <td className="py-3 px-3 font-mono text-slate-600">{log.slr}</td>
                          <td className="py-3 px-3 font-mono text-slate-600">{log.poly}</td>
                          <td className="py-3 px-3 font-mono font-bold text-emerald-700">
                            {log.cbPoly}
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}

        {/* Tab 3: Isolated Research Analytics Portal */}
        {activeTab === 'research' && (
          <ModelResultsTab />
        )}
      </main>

      {/* Modals */}
      <AddUserModal
        isOpen={isAddUserOpen}
        onClose={() => setIsAddUserOpen(false)}
        onAddUser={handleCreateUser}
      />

      <ResetPasswordModal
        isOpen={!!resetTargetUser}
        username={resetTargetUser || ''}
        onClose={() => setResetTargetUser(null)}
        onSuccess={handleResetPassword}
      />

      <ConfirmModal
        isOpen={!!deleteTargetUser}
        title="Delete User Account?"
        message={`Are you sure you want to permanently delete user "${deleteTargetUser}"? This action cannot be reversed.`}
        confirmLabel="Delete Account"
        onConfirm={handleDeleteUser}
        onCancel={() => setDeleteTargetUser(null)}
      />

      <ConfirmModal
        isOpen={showClearLogsConfirm}
        title="Clear All System Logs?"
        message="Are you sure you want to erase all prediction history audit logs across the entire system?"
        confirmLabel="Erase All Logs"
        onConfirm={() => {
          onClearLogs();
          setShowClearLogsConfirm(false);
          onShowToast('All audit logs cleared.');
        }}
        onCancel={() => setShowClearLogsConfirm(false)}
      />
    </div>
  );
};
