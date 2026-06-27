import { Navigate, Route, Routes } from 'react-router-dom';
import { useAuth } from './context/AuthContext';
import Layout from './components/Layout';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Moderation from './pages/Moderation';
import Users from './pages/Users';
import ExchangeRates from './pages/ExchangeRates';
import Content from './pages/Content';
import AIMonitor from './pages/AIMonitor';

function ProtectedRoute({ children }) {
  const { user, loading } = useAuth();
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <div className="text-primary animate-pulse text-lg">Loading Raabta Admin...</div>
      </div>
    );
  }
  if (!user) return <Navigate to="/login" replace />;
  return children;
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route
        path="/*"
        element={
          <ProtectedRoute>
            <Layout />
          </ProtectedRoute>
        }
      >
        <Route index element={<Dashboard />} />
        <Route path="moderation" element={<Moderation />} />
        <Route path="users" element={<Users />} />
        <Route path="exchange-rates" element={<ExchangeRates />} />
        <Route path="content" element={<Content />} />
        <Route path="ai-monitor" element={<AIMonitor />} />
      </Route>
    </Routes>
  );
}
