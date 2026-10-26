import { AppUser, PredictionLog } from '../types';

const USERS_STORAGE_KEY = 'calamansi_app_users';
const LOGS_STORAGE_KEY = 'calamansi_prediction_logs';
const SESSION_STORAGE_KEY = 'calamansi_active_user';

export const INITIAL_USERS: AppUser[] = [
  {
    id: 'user-1',
    username: 'admin',
    password: 'admin123',
    role: 'admin',
    status: 'Active',
    joined: '2026-09-01',
  },
  {
    id: 'user-2',
    username: 'farmer_juan',
    password: 'user123',
    role: 'user',
    status: 'Active',
    joined: '2026-09-02',
  },
  {
    id: 'user-3',
    username: 'tacloban_vendor',
    password: 'user123',
    role: 'user',
    status: 'Active',
    joined: '2026-09-03',
  },
];

export const INITIAL_LOGS: PredictionLog[] = [
  {
    id: 'log-101',
    date: '2026-10-24 14:32',
    user: 'farmer_juan',
    weightG: 5000,
    weight: '5.00 kg (5000g)',
    count: 395,
    slr: '2050.25 ml',
    poly: '2063.40 ml',
    cbPoly: '2072.15 ml',
    slrMl: 2050.25,
    polyMl: 2063.40,
    cbPolyMl: 2072.15,
  },
  {
    id: 'log-102',
    date: '2026-10-23 09:15',
    user: 'tacloban_vendor',
    weightG: 10000,
    weight: '10.00 kg (10000g)',
    count: 791,
    slr: '4100.50 ml',
    poly: '4126.80 ml',
    cbPoly: '4144.30 ml',
    slrMl: 4100.50,
    polyMl: 4126.80,
    cbPolyMl: 4144.30,
  },
  {
    id: 'log-103',
    date: '2026-10-22 16:40',
    user: 'farmer_juan',
    weightG: 1000,
    weight: '1.00 kg (1000g)',
    count: 79,
    slr: '410.05 ml',
    poly: '412.68 ml',
    cbPoly: '414.43 ml',
    slrMl: 410.05,
    polyMl: 412.68,
    cbPolyMl: 414.43,
  },
];

export function getUsers(): AppUser[] {
  try {
    const raw = localStorage.getItem(USERS_STORAGE_KEY);
    if (!raw) {
      saveUsers(INITIAL_USERS);
      return [...INITIAL_USERS];
    }
    return JSON.parse(raw);
  } catch {
    return [...INITIAL_USERS];
  }
}

export function saveUsers(users: AppUser[]): void {
  localStorage.setItem(USERS_STORAGE_KEY, JSON.stringify(users));
}

export function getLogs(): PredictionLog[] {
  try {
    const raw = localStorage.getItem(LOGS_STORAGE_KEY);
    if (!raw) {
      saveLogs(INITIAL_LOGS);
      return [...INITIAL_LOGS];
    }
    return JSON.parse(raw);
  } catch {
    return [...INITIAL_LOGS];
  }
}

export function saveLogs(logs: PredictionLog[]): void {
  localStorage.setItem(LOGS_STORAGE_KEY, JSON.stringify(logs));
}

export function addLog(log: PredictionLog): void {
  const logs = getLogs();
  logs.unshift(log);
  if (logs.length > 100) logs.pop();
  saveLogs(logs);
}

export function clearLogs(): void {
  saveLogs([]);
}

export function getSavedSession(): AppUser | null {
  try {
    const raw = sessionStorage.getItem(SESSION_STORAGE_KEY);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

export function setSavedSession(user: AppUser | null): void {
  if (user) {
    sessionStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(user));
  } else {
    sessionStorage.removeItem(SESSION_STORAGE_KEY);
  }
}

export function exportLogsToCsv(logs: PredictionLog[]): void {
  const headers = [
    'Log ID',
    'Date & Time',
    'User',
    'Batch Weight',
    'Est. Fruit Count',
    'Simple Linear SLR (ml)',
    'Polynomial d=2 (ml)',
    'Poly d=2 + ln(W) + Ridge (ml)',
  ];

  const rows = logs.map((l) => [
    l.id,
    l.date,
    l.user,
    l.weight,
    l.count,
    l.slr,
    l.poly,
    l.cbPoly,
  ]);

  const csv = [headers.join(','), ...rows.map((r) => r.map((c) => `"${c}"`).join(','))].join('\n');
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `calamansi_harvest_predictions_${Date.now()}.csv`;
  a.click();
  URL.revokeObjectURL(url);
}
