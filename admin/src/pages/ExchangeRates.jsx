import { useEffect, useState } from 'react';
import { api } from '../lib/api';

export default function ExchangeRates() {
  const [rates, setRates] = useState([]);
  const [edits, setEdits] = useState({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(null);
  const [notifying, setNotifying] = useState(false);

  const load = () => {
    setLoading(true);
    api
      .getExchangeRates()
      .then((data) => {
        setRates(data.rates || []);
        const initial = {};
        (data.rates || []).forEach((r) => {
          initial[r.id] = r.rate;
        });
        setEdits(initial);
      })
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    load();
  }, []);

  const save = async (id) => {
    setSaving(id);
    await api.updateRate(id, Number(edits[id]));
    load();
    setSaving(null);
  };

  const notifyUsers = async () => {
    setNotifying(true);
    await api.notifyRateChange('INR', 5);
    setNotifying(false);
    alert('Rate change notification queued for users with rate alerts');
  };

  const formatTime = (iso) => {
    if (!iso) return '—';
    return new Date(iso).toLocaleString('en-QA', {
      dateStyle: 'medium',
      timeStyle: 'short',
    });
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-text-primary">Exchange Rate Manager</h2>
          <p className="text-text-secondary text-sm mt-1">
            Edit rates for all exchange houses and currency pairs
          </p>
        </div>
        <button
          type="button"
          onClick={notifyUsers}
          disabled={notifying}
          className="px-4 py-2 rounded-lg bg-warning/20 text-warning border border-warning/30 text-sm font-medium"
        >
          {notifying ? 'Sending...' : '🔔 Notify users of big rate change'}
        </button>
      </div>

      <div className="bg-surface border border-border rounded-xl overflow-hidden">
        {loading ? (
          <div className="p-8 text-center text-text-secondary">Loading rates...</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border bg-surface-elevated">
                  <th className="text-left px-4 py-3 text-text-secondary font-medium">Exchange House</th>
                  <th className="text-left px-4 py-3 text-text-secondary font-medium">From</th>
                  <th className="text-left px-4 py-3 text-text-secondary font-medium">To</th>
                  <th className="text-left px-4 py-3 text-text-secondary font-medium">Rate</th>
                  <th className="text-left px-4 py-3 text-text-secondary font-medium">Last Updated</th>
                  <th className="text-left px-4 py-3 text-text-secondary font-medium">Action</th>
                </tr>
              </thead>
              <tbody>
                {rates.map((r) => (
                  <tr key={r.id} className="border-b border-border/50 hover:bg-surface-elevated/50">
                    <td className="px-4 py-3 font-medium text-text-primary">{r.house}</td>
                    <td className="px-4 py-3 text-text-secondary">{r.from}</td>
                    <td className="px-4 py-3 text-text-secondary">{r.to}</td>
                    <td className="px-4 py-3">
                      <input
                        type="number"
                        step="0.01"
                        value={edits[r.id] ?? r.rate}
                        onChange={(e) =>
                          setEdits((prev) => ({ ...prev, [r.id]: e.target.value }))
                        }
                        className="w-28 bg-surface-elevated border border-border rounded-lg px-3 py-1.5 text-primary font-semibold"
                      />
                    </td>
                    <td className="px-4 py-3 text-text-secondary text-xs">
                      {formatTime(r.updatedAt)}
                    </td>
                    <td className="px-4 py-3">
                      <button
                        type="button"
                        disabled={saving === r.id}
                        onClick={() => save(r.id)}
                        className="px-3 py-1.5 text-xs rounded-lg bg-primary/20 text-primary border border-primary/30"
                      >
                        {saving === r.id ? 'Saving...' : 'Save'}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
