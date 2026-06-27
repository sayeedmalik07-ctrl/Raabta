import { useEffect, useState } from 'react';
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Legend,
  Line,
  LineChart,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import StatCard from '../components/StatCard';
import { api } from '../lib/api';

const PIE_COLORS = ['#22D3EE', '#6366F1', '#A78BFA', '#34D399', '#FBBF24', '#F87171', '#FFB800'];

export default function Dashboard() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.getStats().then(setStats).finally(() => setLoading(false));
  }, []);

  if (loading) {
    return <div className="text-text-secondary animate-pulse">Loading dashboard...</div>;
  }

  if (!stats) return null;

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-text-primary">Overview Dashboard</h2>
        <p className="text-text-secondary text-sm mt-1">Platform metrics at a glance</p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
        <StatCard label="Total Users" value={stats.totalUsers.toLocaleString()} icon="👥" />
        <StatCard
          label="New This Week"
          value={stats.newThisWeek.toLocaleString()}
          sub="+12% vs last week"
          icon="📈"
          accent="success"
        />
        <StatCard
          label="Premium Subscribers"
          value={stats.premiumSubscribers.toLocaleString()}
          icon="⭐"
          accent="gold"
        />
        <StatCard
          label="Active Listings"
          value={stats.activeListings.toLocaleString()}
          icon="🏠"
        />
        <StatCard
          label="Pending Moderation"
          value={stats.pendingModeration}
          icon="🛡️"
          accent="warning"
        />
        <StatCard
          label="AI Messages Today"
          value={stats.aiMessagesToday.toLocaleString()}
          icon="🤖"
          accent="primary"
        />
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="font-semibold text-text-primary mb-4">Monthly Revenue (QR)</h3>
          <ResponsiveContainer width="100%" height={260}>
            <BarChart data={stats.revenueMonthly}>
              <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
              <XAxis dataKey="month" stroke="#8A9BB0" fontSize={12} />
              <YAxis stroke="#8A9BB0" fontSize={12} />
              <Tooltip
                contentStyle={{ background: '#0D1520', border: '1px solid rgba(255,255,255,0.1)' }}
              />
              <Bar dataKey="revenue" fill="#22D3EE" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="font-semibold text-text-primary mb-4">AI Chat Usage (messages/day)</h3>
          <ResponsiveContainer width="100%" height={260}>
            <LineChart data={stats.aiUsageDaily}>
              <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
              <XAxis dataKey="day" stroke="#8A9BB0" fontSize={12} />
              <YAxis stroke="#8A9BB0" fontSize={12} />
              <Tooltip
                contentStyle={{ background: '#0D1520', border: '1px solid rgba(255,255,255,0.1)' }}
              />
              <Line type="monotone" dataKey="messages" stroke="#6366F1" strokeWidth={2} dot={{ fill: '#6366F1' }} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="bg-surface border border-border rounded-xl p-5 max-w-lg">
        <h3 className="font-semibold text-text-primary mb-4">Users by Nationality</h3>
        <ResponsiveContainer width="100%" height={280}>
          <PieChart>
            <Pie
              data={stats.nationalityBreakdown}
              dataKey="value"
              nameKey="name"
              cx="50%"
              cy="50%"
              outerRadius={90}
              label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
            >
              {stats.nationalityBreakdown.map((_, i) => (
                <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
              ))}
            </Pie>
            <Tooltip
              contentStyle={{ background: '#0D1520', border: '1px solid rgba(255,255,255,0.1)' }}
            />
            <Legend />
          </PieChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
