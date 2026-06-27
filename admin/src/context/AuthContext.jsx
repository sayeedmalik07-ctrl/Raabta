import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import {
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signOut,
} from 'firebase/auth';
import { auth, ADMIN_EMAIL } from '../firebase';
import { setAdminToken } from '../lib/api';

const AuthContext = createContext(null);

const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true';

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(!USE_MOCK);
  const [error, setError] = useState('');

  useEffect(() => {
    if (USE_MOCK) return undefined;

    const unsub = onAuthStateChanged(auth, async (firebaseUser) => {
      if (firebaseUser?.email === ADMIN_EMAIL) {
        const token = await firebaseUser.getIdToken();
        setAdminToken(token);
        setUser(firebaseUser);
      } else if (firebaseUser) {
        await signOut(auth);
        setUser(null);
        setAdminToken(null);
        setError('Only admin@raabta.app can access this dashboard');
      } else {
        setUser(null);
        setAdminToken(null);
      }
      setLoading(false);
    });
    return unsub;
  }, []);

  const login = async (email, password) => {
    setError('');
    if (email !== ADMIN_EMAIL) {
      setError('Only admin@raabta.app is authorized');
      return;
    }
    if (USE_MOCK) {
      setAdminToken('mock-dev-token');
      setUser({ email: ADMIN_EMAIL, mock: true });
      return;
    }
    try {
      await signInWithEmailAndPassword(auth, email, password);
    } catch (err) {
      setError(err.message || 'Login failed');
    }
  };

  const logout = () => {
    if (USE_MOCK) {
      setUser(null);
      setAdminToken(null);
      return;
    }
    signOut(auth);
  };

  const value = useMemo(
    () => ({ user, loading, error, login, logout, isAdmin: !!user }),
    [user, loading, error],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
