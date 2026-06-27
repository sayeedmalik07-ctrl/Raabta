import { useState } from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function Login() {
  const { user, login, error, loading } = useAuth();
  const [email, setEmail] = useState('admin@raabta.app');
  const [password, setPassword] = useState('');
  const [submitting, setSubmitting] = useState(false);

  if (!loading && user) return <Navigate to="/" replace />;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    await login(email, password);
    setSubmitting(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background p-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <span className="text-5xl">🌙</span>
          <h1 className="text-2xl font-bold mt-4 text-text-primary">Raabta Admin</h1>
          <p className="text-text-secondary mt-2">Sign in with your admin account</p>
        </div>

        <form
          onSubmit={handleSubmit}
          className="bg-surface border border-border rounded-2xl p-6 shadow-glow space-y-4"
        >
          <div>
            <label className="block text-sm text-text-secondary mb-1.5">Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full bg-surface-elevated border border-border rounded-lg px-3 py-2.5 text-text-primary focus:outline-none focus:border-primary"
              required
            />
          </div>
          <div>
            <label className="block text-sm text-text-secondary mb-1.5">Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full bg-surface-elevated border border-border rounded-lg px-3 py-2.5 text-text-primary focus:outline-none focus:border-primary"
              required
            />
          </div>

          {error && (
            <div className="text-error text-sm bg-error/10 border border-error/30 rounded-lg px-3 py-2">
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={submitting}
            className="w-full bg-primary text-background font-semibold py-2.5 rounded-lg hover:bg-primary-dark transition disabled:opacity-50"
          >
            {submitting ? 'Signing in...' : 'Sign in'}
          </button>

          <p className="text-xs text-text-muted text-center">
            Only admin@raabta.app is authorized
            {import.meta.env.VITE_USE_MOCK === 'true' && (
              <span className="block mt-1 text-primary">Dev mode — any password works</span>
            )}
          </p>
        </form>
      </div>
    </div>
  );
}
