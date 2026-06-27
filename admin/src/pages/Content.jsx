import { useEffect, useState } from 'react';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';
import { api } from '../lib/api';

const TABS = [
  { id: 'visa-guides', label: 'Visa Guides', icon: '📋' },
  { id: 'doctors', label: 'Doctors', icon: '🏥' },
  { id: 'businesses', label: 'Businesses', icon: '🏪' },
  { id: 'announcements', label: 'Announcements', icon: '📢' },
];

export default function Content() {
  const [tab, setTab] = useState('visa-guides');
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({});
  const [saving, setSaving] = useState(false);

  const load = () => {
    setLoading(true);
    api
      .getContent(tab)
      .then((data) => setItems(data.items || []))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    load();
  }, [tab]);

  const openNew = () => {
    setEditing('new');
    if (tab === 'visa-guides') {
      setForm({ title: '', summary: '', content: '' });
    } else if (tab === 'doctors') {
      setForm({ name: '', specialty: '', hospital: '', area: '', rating: 4.5, languages: ['English'] });
    } else if (tab === 'businesses') {
      setForm({ name: '', category: '', location: '', phone: '', rating: 4.5 });
    } else {
      setForm({ title: '', body: '', route: '/news' });
    }
  };

  const openEdit = (item) => {
    setEditing(item.id);
    setForm({ ...item });
  };

  const save = async () => {
    setSaving(true);
    await api.saveContent(tab, form);
    setEditing(null);
    load();
    setSaving(false);
  };

  const remove = async (id) => {
    if (!confirm('Delete this item?')) return;
    await api.deleteContent(tab, id);
    load();
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-text-primary">Content Manager</h2>
        <p className="text-text-secondary text-sm mt-1">
          Edit visa guides, doctors, businesses, and system announcements
        </p>
      </div>

      <div className="flex flex-wrap gap-2">
        {TABS.map((t) => (
          <button
            key={t.id}
            type="button"
            onClick={() => setTab(t.id)}
            className={`px-4 py-2 rounded-lg text-sm font-medium border transition ${
              tab === t.id
                ? 'bg-primary/10 text-primary border-primary/30'
                : 'border-border text-text-secondary hover:text-text-primary'
            }`}
          >
            {t.icon} {t.label}
          </button>
        ))}
        <button
          type="button"
          onClick={openNew}
          className="ml-auto px-4 py-2 rounded-lg bg-primary text-background text-sm font-medium"
        >
          + Add new
        </button>
      </div>

      {editing && (
        <div className="bg-surface border border-border rounded-xl p-5 space-y-4">
          <h3 className="font-semibold text-text-primary">
            {editing === 'new' ? 'Create' : 'Edit'} {TABS.find((t) => t.id === tab)?.label}
          </h3>

          {tab === 'visa-guides' && (
            <>
              <input
                placeholder="Title"
                value={form.title || ''}
                onChange={(e) => setForm({ ...form, title: e.target.value })}
                className="w-full bg-surface-elevated border border-border rounded-lg px-3 py-2"
              />
              <input
                placeholder="Summary"
                value={form.summary || ''}
                onChange={(e) => setForm({ ...form, summary: e.target.value })}
                className="w-full bg-surface-elevated border border-border rounded-lg px-3 py-2"
              />
              <ReactQuill
                theme="snow"
                value={form.content || ''}
                onChange={(content) => setForm({ ...form, content })}
              />
            </>
          )}

          {tab === 'doctors' && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {['name', 'specialty', 'hospital', 'area'].map((field) => (
                <input
                  key={field}
                  placeholder={field}
                  value={form[field] || ''}
                  onChange={(e) => setForm({ ...form, [field]: e.target.value })}
                  className="bg-surface-elevated border border-border rounded-lg px-3 py-2 capitalize"
                />
              ))}
              <input
                type="number"
                step="0.1"
                placeholder="Rating"
                value={form.rating || ''}
                onChange={(e) => setForm({ ...form, rating: Number(e.target.value) })}
                className="bg-surface-elevated border border-border rounded-lg px-3 py-2"
              />
            </div>
          )}

          {tab === 'businesses' && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {['name', 'category', 'location', 'phone'].map((field) => (
                <input
                  key={field}
                  placeholder={field}
                  value={form[field] || ''}
                  onChange={(e) => setForm({ ...form, [field]: e.target.value })}
                  className="bg-surface-elevated border border-border rounded-lg px-3 py-2 capitalize"
                />
              ))}
            </div>
          )}

          {tab === 'announcements' && (
            <>
              <input
                placeholder="Title"
                value={form.title || ''}
                onChange={(e) => setForm({ ...form, title: e.target.value })}
                className="w-full bg-surface-elevated border border-border rounded-lg px-3 py-2"
              />
              <textarea
                placeholder="Body"
                rows={3}
                value={form.body || ''}
                onChange={(e) => setForm({ ...form, body: e.target.value })}
                className="w-full bg-surface-elevated border border-border rounded-lg px-3 py-2"
              />
              <input
                placeholder="Deep link route (e.g. /news)"
                value={form.route || ''}
                onChange={(e) => setForm({ ...form, route: e.target.value })}
                className="w-full bg-surface-elevated border border-border rounded-lg px-3 py-2"
              />
            </>
          )}

          <div className="flex gap-2">
            <button
              type="button"
              onClick={save}
              disabled={saving}
              className="px-4 py-2 rounded-lg bg-primary text-background text-sm font-medium"
            >
              {saving ? 'Saving...' : 'Save'}
            </button>
            <button
              type="button"
              onClick={() => setEditing(null)}
              className="px-4 py-2 rounded-lg border border-border text-text-secondary text-sm"
            >
              Cancel
            </button>
          </div>
        </div>
      )}

      <div className="bg-surface border border-border rounded-xl divide-y divide-border">
        {loading ? (
          <div className="p-8 text-center text-text-secondary">Loading...</div>
        ) : items.length === 0 ? (
          <div className="p-8 text-center text-text-secondary">No items yet</div>
        ) : (
          items.map((item) => (
            <div
              key={item.id}
              className="p-4 flex items-center justify-between gap-4 hover:bg-surface-elevated/50"
            >
              <div>
                <div className="font-medium text-text-primary">
                  {item.title || item.name}
                </div>
                <div className="text-xs text-text-secondary mt-0.5">
                  {item.summary || item.specialty || item.category || item.body?.slice(0, 60)}
                </div>
              </div>
              <div className="flex gap-2 shrink-0">
                <button
                  type="button"
                  onClick={() => openEdit(item)}
                  className="text-xs text-primary hover:underline"
                >
                  Edit
                </button>
                <button
                  type="button"
                  onClick={() => remove(item.id)}
                  className="text-xs text-error hover:underline"
                >
                  Delete
                </button>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
