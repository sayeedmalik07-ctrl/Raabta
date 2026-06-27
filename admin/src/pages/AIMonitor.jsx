import { useEffect, useState } from 'react';
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import StatCard from '../components/StatCard';
import { api } from '../lib/api';

export default function AIMonitor() {
  const [conversations, setConversations] = useState([]);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [flagReason, setFlagReason] = useState('');
  const [flagging, setFlagging] = useState(null);

  const load = () => {
    setLoading(true);
    api
      .getAiMonitor()
      .then((data) => {
        setConversations(data.conversations || []);
        setStats(data.stats);
      })
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    load();
  }, []);

  const flag = async (id, flagged) => {
    setFlagging(id);
    await api.flagConversation(id, flagged, flagReason);
    load();
    setFlagging(null);
    setFlagReason('');
  };

  if (loading) {
    return <div className="text-text-secondary animate-pulse">Loading AI monitor...</div>;
  }

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-text-primary">AI Monitor</h2>
        <p className="text-text-secondary text-sm mt-1">
          Review anonymized conversations, costs, and common questions
        </p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatCard
          label="API Cost Today"
          value={`$${stats?.totalCostToday?.toFixed(2) ?? '0.00'}`}
          icon="💸"
          accent="warning"
        />
        <StatCard
          label="API Cost This Month"
          value={`$${stats?.totalCostMonth?.toFixed(2) ?? '0.00'}`}
          icon="📊"
        />
        <StatCard
          label="Conversations (recent)"
          value={conversations.length}
          icon="💬"
        />
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="font-semibold text-text-primary mb-4">Daily AI API Spend (USD)</h3>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={stats?.dailyCost || []}>
              <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
              <XAxis dataKey="day" stroke="#8A9BB0" fontSize={12} />
              <YAxis stroke="#8A9BB0" fontSize={12} />
              <Tooltip
                contentStyle={{ background: '#0D1520', border: '1px solid rgba(255,255,255,0.1)' }}
              />
              <Bar dataKey="cost" fill="#A78BFA" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="font-semibold text-text-primary mb-4">Most Common Questions</h3>
          <div className="space-y-2">
            {(stats?.commonQuestions || []).map((q, i) => (
              <div
                key={q.question}
                className="flex items-center justify-between py-2 border-b border-border/50 last:border-0"
              >
                <div className="flex items-center gap-2">
                  <span className="text-xs text-text-muted w-5">{i + 1}.</span>
                  <span className="text-sm text-text-primary">{q.question}</span>
                </div>
                <span className="text-xs text-primary font-semibold">{q.count}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="bg-surface border border-border rounded-xl overflow-hidden">
        <div className="px-5 py-4 border-b border-border">
          <h3 className="font-semibold text-text-primary">Recent AI Conversations (anonymized)</h3>
        </div>
        <div className="divide-y divide-border">
          {conversations.map((c) => (
            <div key={c.id} className="p-4 hover:bg-surface-elevated/50">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-medium text-text-primary">{c.topic}</span>
                    {c.flagged && (
                      <span className="text-xs px-2 py-0.5 rounded bg-error/20 text-error border border-error/30">
                        Flagged
                      </span>
                    )}
                  </div>
                  <p className="text-sm text-text-secondary mt-1 italic">"{c.preview}"</p>
                  <div className="flex gap-4 mt-2 text-xs text-text-muted">
                    <span>{c.messages} messages</span>
                    <span>${c.costUsd?.toFixed(3)} cost</span>
                    <span>{new Date(c.createdAt).toLocaleString()}</span>
                  </div>
                  {c.flagReason && (
                    <p className="text-xs text-error mt-1">Flag: {c.flagReason}</p>
                  )}
                </div>
                <div className="flex flex-col gap-2 shrink-0">
                  {!c.flagged ? (
                    <>
                      <input
                        placeholder="Flag reason..."
                        value={flagging === c.id ? flagReason : ''}
                        onFocus={() => setFlagging(c.id)}
                        onChange={(e) => setFlagReason(e.target.value)}
                        className="w-40 bg-surface-elevated border border-border rounded px-2 py-1 text-xs"
                      />
                      <button
                        type="button"
                        onClick={() => flag(c.id, true)}
                        className="text-xs px-2 py-1 rounded bg-error/20 text-error border border-error/30"
                      >
                        Flag answer
                      </button>
                    </>
                  ) : (
                    <button
                      type="button"
                      onClick={() => flag(c.id, false)}
                      className="text-xs px-2 py-1 rounded border border-border text-text-secondary"
                    >
                      Clear flag
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
