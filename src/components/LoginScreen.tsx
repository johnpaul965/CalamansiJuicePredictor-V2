import React, { useState } from 'react';
import { User, Lock, Eye, EyeOff, ShieldCheck, Sprout, AlertCircle } from 'lucide-react';
import { AppUser } from '../types';
import { getUsers, saveUsers } from '../services/storageService';

interface LoginScreenProps {
  onLoginSuccess: (user: AppUser) => void;
}

export const LoginScreen: React.FC<LoginScreenProps> = ({ onLoginSuccess }) => {
  const [isRegister, setIsRegister] = useState(false);
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    const u = username.trim().toLowerCase();
    const p = password.trim();

    if (!u) {
      setError('Please enter a username.');
      return;
    }
    if (!p) {
      setError('Please enter a password.');
      return;
    }

    const users = getUsers();

    if (isRegister) {
      if (p.length < 4) {
        setError('Password must be at least 4 characters long.');
        return;
      }
      if (p !== confirmPassword.trim()) {
        setError('Passwords do not match. Please verify.');
        return;
      }
      if (users.some((x) => x.username.toLowerCase() === u)) {
        setError('Username already registered. Please sign in or pick another.');
        return;
      }

      const newUser: AppUser = {
        id: `user-${Date.now()}`,
        username: u,
        password: p,
        role: 'user',
        status: 'Active',
        joined: new Date().toISOString().split('T')[0],
      };

      users.push(newUser);
      saveUsers(users);
      onLoginSuccess(newUser);
    } else {
      const existing = users.find(
        (x) => x.username.toLowerCase() === u && x.password === p
      );
      if (!existing) {
        setError('Incorrect username or password. Please verify and try again.');
        return;
      }
      if (existing.status === 'Suspended') {
        setError('This account has been suspended by an Administrator.');
        return;
      }
      onLoginSuccess(existing);
    }
  };

  const handleQuickFill = (u: string, p: string) => {
    setIsRegister(false);
    setUsername(u);
    setPassword(p);
    setError(null);
    const users = getUsers();
    const existing = users.find((x) => x.username.toLowerCase() === u && x.password === p);
    if (existing) {
      onLoginSuccess(existing);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <div className="bg-white rounded-2xl border border-slate-200/80 shadow-md p-7 sm:p-8">
          {/* Logo Badge */}
          <div className="w-14 h-14 bg-emerald-100 rounded-2xl flex items-center justify-center mx-auto mb-3 shadow-inner">
            <span className="text-3xl select-none leading-none">🍋</span>
          </div>

          <h1 className="text-xl sm:text-2xl font-extrabold text-center text-slate-900 tracking-tight">
            Calamansi Yield Predictor
          </h1>
          <p className="text-xs font-medium text-center text-emerald-800 mt-1">
            Leyte Normal University • Tacloban City Harvest Study
          </p>
          <p className="text-xs text-center text-slate-500 mt-0.5 mb-5">
            Predict pure juice extraction yield using trained regression algorithms
          </p>

          {/* Segmented Auth Control */}
          <div className="flex bg-slate-100 p-1 rounded-xl border border-slate-200 mb-5">
            <button
              type="button"
              onClick={() => {
                setIsRegister(false);
                setError(null);
              }}
              className={`flex-1 py-2 text-xs sm:text-sm font-semibold rounded-lg transition cursor-pointer ${
                !isRegister
                  ? 'bg-white text-emerald-800 shadow-xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              Sign In
            </button>
            <button
              type="button"
              onClick={() => {
                setIsRegister(true);
                setError(null);
              }}
              className={`flex-1 py-2 text-xs sm:text-sm font-semibold rounded-lg transition cursor-pointer ${
                isRegister
                  ? 'bg-white text-emerald-800 shadow-xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              Create Account
            </button>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                Username
              </label>
              <div className="relative flex items-center">
                <User className="absolute left-3 w-4 h-4 text-slate-400 pointer-events-none" />
                <input
                  type="text"
                  placeholder="Enter your username"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  autoComplete="username"
                  className="w-full pl-9 pr-3.5 py-2.5 bg-white border border-slate-300 rounded-xl text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-600 focus:border-transparent transition"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                Password
              </label>
              <div className="relative flex items-center">
                <Lock className="absolute left-3 w-4 h-4 text-slate-400 pointer-events-none" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  placeholder="Enter your password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  autoComplete={isRegister ? 'new-password' : 'current-password'}
                  className="w-full pl-9 pr-10 py-2.5 bg-white border border-slate-300 rounded-xl text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-600 focus:border-transparent transition"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 text-slate-400 hover:text-slate-600 cursor-pointer"
                  aria-label="Toggle password visibility"
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>

            {isRegister && (
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1.5">
                  Confirm Password
                </label>
                <div className="relative flex items-center">
                  <Lock className="absolute left-3 w-4 h-4 text-slate-400 pointer-events-none" />
                  <input
                    type={showPassword ? 'text' : 'password'}
                    placeholder="Re-enter password"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    autoComplete="new-password"
                    className="w-full pl-9 pr-3.5 py-2.5 bg-white border border-slate-300 rounded-xl text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-600 focus:border-transparent transition"
                    required
                  />
                </div>
              </div>
            )}

            {error && (
              <div className="flex items-start gap-2 p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-700">
                <AlertCircle className="w-4 h-4 shrink-0 text-red-500 mt-0.5" />
                <span>{error}</span>
              </div>
            )}

            <button
              type="submit"
              className="w-full py-2.5 px-4 bg-emerald-700 hover:bg-emerald-800 active:bg-emerald-900 text-white font-bold rounded-xl text-sm shadow-sm transition cursor-pointer"
            >
              {isRegister ? 'Create Account & Sign In' : 'Sign In to Predictor'}
            </button>
          </form>

          {/* DEMO ACCOUNTS DIVIDER */}
          <div className="relative my-6">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-slate-200" />
            </div>
            <div className="relative flex justify-center text-xs uppercase">
              <span className="bg-white px-2.5 font-semibold text-slate-400 text-[10px] tracking-wider">
                Demo Accounts
              </span>
            </div>
          </div>

          {/* DEMO ACCOUNTS BOX */}
          <div className="bg-slate-50 border border-slate-200 rounded-xl p-3 space-y-1.5 text-xs">
            <div className="flex items-center justify-between text-slate-700">
              <span className="flex items-center gap-1.5 text-slate-600 font-medium">
                <Sprout className="w-3.5 h-3.5 text-emerald-600" /> User:
              </span>
              <code className="bg-white px-2 py-0.5 rounded border border-slate-200 font-mono text-[11px] text-slate-800">
                farmer_juan / user123
              </code>
            </div>
            <div className="flex items-center justify-between text-slate-700">
              <span className="flex items-center gap-1.5 text-slate-600 font-medium">
                <ShieldCheck className="w-3.5 h-3.5 text-amber-600" /> Admin:
              </span>
              <code className="bg-white px-2 py-0.5 rounded border border-slate-200 font-mono text-[11px] text-slate-800">
                admin / admin123
              </code>
            </div>
          </div>

          {/* Quick Fill Buttons */}
          <div className="grid grid-cols-2 gap-2 mt-3">
            <button
              type="button"
              onClick={() => handleQuickFill('farmer_juan', 'user123')}
              className="flex items-center justify-center gap-1.5 py-2 px-3 bg-white hover:bg-slate-50 border border-slate-300 rounded-xl text-xs font-semibold text-slate-700 transition cursor-pointer"
            >
              <Sprout className="w-3.5 h-3.5 text-emerald-600" />
              <span>Quick User</span>
            </button>
            <button
              type="button"
              onClick={() => handleQuickFill('admin', 'admin123')}
              className="flex items-center justify-center gap-1.5 py-2 px-3 bg-white hover:bg-slate-50 border border-amber-300 rounded-xl text-xs font-semibold text-amber-900 transition cursor-pointer"
            >
              <ShieldCheck className="w-3.5 h-3.5 text-amber-600" />
              <span>Quick Admin</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
