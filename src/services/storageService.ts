import { AppUser, PredictionLog } from '../types';
import { getSupabase, isSupabaseConfigured } from './supabaseClient';

export { isSupabaseConfigured };

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
    count: 394,
    slr: '2050.25 ml',
    primary: '2072.15 ml',
    slrMl: 2050.25,
    primaryMl: 2072.15,
  },
  {
    id: 'log-102',
    date: '2026-10-23 09:15',
    user: 'tacloban_vendor',
    weightG: 10000,
    weight: '10.00 kg (10000g)',
    count: 788,
    slr: '4100.50 ml',
    primary: '4144.30 ml',
    slrMl: 4100.50,
    primaryMl: 4144.30,
  },
  {
    id: 'log-103',
    date: '2026-10-22 16:40',
    user: 'farmer_juan',
    weightG: 1000,
    weight: '1.00 kg (1000g)',
    count: 79,
    slr: '410.05 ml',
    primary: '414.43 ml',
    slrMl: 410.05,
    primaryMl: 414.43,
  },
];

// --- Local Storage Getters & Setters ---

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
  try {
    localStorage.setItem(USERS_STORAGE_KEY, JSON.stringify(users));
  } catch {
    // Ignore storage quota errors
  }

  // Background sync to Supabase if configured
  const supabase = getSupabase();
  if (supabase) {
    void (async () => {
      try {
        const { error } = await supabase.from('calamansi_users').upsert(
          users.map((u) => ({
            id: u.id,
            username: u.username,
            password: u.password || '',
            role: u.role,
            status: u.status,
            joined: u.joined,
          }))
        );
        if (error) console.warn('[Supabase] Error syncing users:', error.message);
      } catch (err: unknown) {
        console.warn('[Supabase] Network error syncing users:', err);
      }
    })();
  }
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
  try {
    localStorage.setItem(LOGS_STORAGE_KEY, JSON.stringify(logs));
  } catch {
    // Ignore storage quota errors
  }
}

export function addLog(log: PredictionLog): void {
  const logs = getLogs();
  logs.unshift(log);
  if (logs.length > 200) logs.pop();
  saveLogs(logs);

  // Background sync to Supabase
  const supabase = getSupabase();
  if (supabase) {
    void (async () => {
      try {
        const { error } = await supabase.from('calamansi_harvest_logs').upsert({
          id: log.id,
          date: log.date,
          username: log.user,
          weight_g: log.weightG,
          weight_label: log.weight,
          count: log.count,
          slr_ml: log.slrMl ?? null,
          primary_ml: log.primaryMl ?? null,
          poly_ml: log.polyMl ?? null,
          rbf_ml: log.rbfMl ?? null,
        });
        if (error) console.warn('[Supabase] Error inserting harvest log:', error.message);
      } catch (err: unknown) {
        console.warn('[Supabase] Network error inserting log:', err);
      }
    })();
  }
}

export function clearLogs(): void {
  saveLogs([]);

  const supabase = getSupabase();
  if (supabase) {
    void (async () => {
      try {
        const { error } = await supabase
          .from('calamansi_harvest_logs')
          .delete()
          .neq('id', '___all___');
        if (error) console.warn('[Supabase] Error clearing logs:', error.message);
      } catch (err: unknown) {
        console.warn('[Supabase] Network error clearing logs:', err);
      }
    })();
  }
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

// --- Cloud Sync Helper on App Load ---

export async function syncFromSupabase(): Promise<{
  synced: boolean;
  users?: AppUser[];
  logs?: PredictionLog[];
  error?: string;
}> {
  const supabase = getSupabase();
  if (!supabase) {
    return { synced: false, error: 'Supabase credentials not configured' };
  }

  try {
    // 1. Fetch Users from Supabase
    const { data: remoteUsers, error: userErr } = await supabase
      .from('calamansi_users')
      .select('*')
      .order('created_at', { ascending: true });

    let updatedUsers: AppUser[] | undefined;
    if (!userErr && remoteUsers && remoteUsers.length > 0) {
      updatedUsers = remoteUsers.map((r: any) => ({
        id: r.id,
        username: r.username,
        password: r.password,
        role: r.role,
        status: r.status,
        joined: r.joined,
      }));
      // Save to localStorage cache
      localStorage.setItem(USERS_STORAGE_KEY, JSON.stringify(updatedUsers));
    } else if (!userErr && remoteUsers && remoteUsers.length === 0) {
      // First time connecting: seed initial users into Supabase so accounts are in cloud
      const initialUsers = getUsers();
      await supabase.from('calamansi_users').upsert(
        initialUsers.map((u) => ({
          id: u.id,
          username: u.username,
          password: u.password || '',
          role: u.role,
          status: u.status,
          joined: u.joined,
        }))
      );
    }

    // 2. Fetch Logs from Supabase
    const { data: remoteLogs, error: logErr } = await supabase
      .from('calamansi_harvest_logs')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(200);

    let updatedLogs: PredictionLog[] | undefined;
    if (!logErr && remoteLogs && remoteLogs.length > 0) {
      updatedLogs = remoteLogs.map((r: any) => ({
        id: r.id,
        date: r.date,
        user: r.username,
        weightG: Number(r.weight_g),
        weight: r.weight_label || `${r.weight_g}g`,
        count: r.count,
        slr: `${Number(r.slr_ml || 0).toFixed(2)} ml`,
        primary: `${Number(r.primary_ml || 0).toFixed(2)} ml`,
        slrMl: Number(r.slr_ml || 0),
        primaryMl: Number(r.primary_ml || 0),
        polyMl: r.poly_ml ? Number(r.poly_ml) : undefined,
        rbfMl: r.rbf_ml ? Number(r.rbf_ml) : undefined,
      }));
      localStorage.setItem(LOGS_STORAGE_KEY, JSON.stringify(updatedLogs));
    } else if (!logErr && remoteLogs && remoteLogs.length === 0) {
      // First time connecting: seed initial demo logs into Supabase
      const initialLogs = getLogs();
      await supabase.from('calamansi_harvest_logs').upsert(
        initialLogs.map((l) => ({
          id: l.id,
          date: l.date,
          username: l.user,
          weight_g: l.weightG,
          weight_label: l.weight,
          count: l.count,
          slr_ml: l.slrMl ?? null,
          primary_ml: l.primaryMl ?? null,
          poly_ml: l.polyMl ?? null,
          rbf_ml: l.rbfMl ?? null,
        }))
      );
    }

    return {
      synced: true,
      users: updatedUsers,
      logs: updatedLogs,
    };
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.warn('[Supabase] Sync failed:', msg);
    return { synced: false, error: msg };
  }
}

// --- CSV Export with Formula Injection Protection ---

export function exportLogsToCsv(logs: PredictionLog[]): void {
  const headers = [
    'Log ID',
    'Date & Time',
    'User',
    'Batch Weight',
    'Est. Calamansi Count',
    'Simple Linear (mL)',
    'Polynomial Degree 2 (mL)',
    'RBF SVR (mL)',
    'Poly+ Ridge (mL)',
  ];

  // Sanitize cell values against spreadsheet formula execution
  const sanitizeCell = (val: unknown): string => {
    let str = String(val ?? '');
    if (/^[=+\-@\t\r]/.test(str)) {
      str = `'${str}`; // Prepend apostrophe to neutralize spreadsheet formula
    }
    return `"${str.replace(/"/g, '""')}"`;
  };

  const rows = logs.map((l) => [
    l.id,
    l.date,
    l.user,
    l.weight,
    l.count,
    l.slr,
    l.poly ?? l.polyMl ?? '',
    l.rbf ?? l.rbfMl ?? '',
    l.primary ?? l.cbPoly ?? '',
  ]);

  const csv = [headers.map(sanitizeCell).join(','), ...rows.map((r) => r.map(sanitizeCell).join(','))].join('\n');
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `calamansi_harvest_predictions_${Date.now()}.csv`;
  a.click();
  URL.revokeObjectURL(url);
}
