import { Outlet } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import Sidebar from './Sidebar';

export default function Layout() {
  const { user, logout } = useAuth();

  return (
    <div className="min-h-screen flex bg-background">
      <Sidebar />
      <div className="flex-1 flex flex-col min-w-0">
        <header className="h-16 border-b border-border flex items-center justify-between px-6 bg-surface/80 backdrop-blur sticky top-0 z-10">
          <div>
            <h1 className="text-lg font-semibold text-text-primary">Raabta Admin</h1>
            <p className="text-xs text-text-secondary">Qatar expat platform control center</p>
          </div>
          <div className="flex items-center gap-4">
            <span className="text-sm text-text-secondary hidden sm:block">{user?.email}</span>
            <button
              type="button"
              onClick={logout}
              className="px-3 py-1.5 text-sm rounded-lg border border-border hover:border-primary/50 hover:text-primary transition"
            >
              Sign out
            </button>
          </div>
        </header>
        <main className="flex-1 p-6 overflow-auto">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
