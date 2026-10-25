import React, { useState, useEffect } from 'react';
import { AppUser, PredictionLog } from './types';
import {
  getUsers,
  saveUsers,
  getLogs,
  clearLogs,
  getSavedSession,
  setSavedSession,
} from './services/storageService';
import { LoginScreen } from './components/LoginScreen';
import { UserScaffold } from './components/UserScaffold';
import { AdminScaffold } from './components/AdminScaffold';
import { ToastNotification } from './components/Modals';

export const App: React.FC = () => {
  const [currentUser, setCurrentUser] = useState<AppUser | null>(() => getSavedSession());
  const [users, setUsers] = useState<AppUser[]>(() => getUsers());
  const [logs, setLogs] = useState<PredictionLog[]>(() => getLogs());
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Sync users in state and localStorage
  const handleUpdateUsers = (newUsers: AppUser[]) => {
    setUsers(newUsers);
    saveUsers(newUsers);

    // If current user was updated or deleted
    if (currentUser) {
      const refreshedCurrent = newUsers.find((u) => u.username === currentUser.username);
      if (!refreshedCurrent || refreshedCurrent.status === 'Suspended') {
        handleSignOut();
      } else {
        setCurrentUser(refreshedCurrent);
        setSavedSession(refreshedCurrent);
      }
    }
  };

  const handleRefreshLogs = () => {
    setLogs(getLogs());
  };

  const handleClearLogs = () => {
    clearLogs();
    setLogs([]);
  };

  const handleLoginSuccess = (user: AppUser) => {
    setCurrentUser(user);
    setSavedSession(user);
    setToastMessage(`Welcome back, ${user.username}!`);
  };

  const handleSignOut = () => {
    setCurrentUser(null);
    setSavedSession(null);
    setToastMessage('Signed out successfully.');
  };

  const showToast = (msg: string) => {
    setToastMessage(msg);
  };

  useEffect(() => {
    if (toastMessage) {
      const timer = setTimeout(() => setToastMessage(null), 3500);
      return () => clearTimeout(timer);
    }
  }, [toastMessage]);

  return (
    <>
      {!currentUser ? (
        <LoginScreen onLoginSuccess={handleLoginSuccess} />
      ) : currentUser.role === 'admin' ? (
        <AdminScaffold
          currentUser={currentUser}
          users={users}
          logs={logs}
          onUpdateUsers={handleUpdateUsers}
          onClearLogs={handleClearLogs}
          onRefreshLogs={handleRefreshLogs}
          onSignOut={handleSignOut}
          onShowToast={showToast}
        />
      ) : (
        <UserScaffold
          currentUser={currentUser}
          logs={logs}
          onRefreshLogs={handleRefreshLogs}
          onClearLogs={handleClearLogs}
          onSignOut={handleSignOut}
        />
      )}

      <ToastNotification
        message={toastMessage}
        onClose={() => setToastMessage(null)}
      />
    </>
  );
};

export default App;
