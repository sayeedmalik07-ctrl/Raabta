import { useEffect, useMemo, useState } from 'react';
import {
  flexRender,
  getCoreRowModel,
  useReactTable,
} from '@tanstack/react-table';
import { api } from '../lib/api';

export default function Users() {
  const [users, setUsers] = useState([]);
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState(null);
  const [banReason, setBanReason] = useState('');
  const [busy, setBusy] = useState(false);

  const load = (q = query) => {
    setLoading(true);
    api
      .searchUsers(q)
      .then((data) => setUsers(data.users || []))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    load('');
  }, []);

  const doAction = async (action) => {
    if (!selected) return;
    setBusy(true);
    await api.updateUser(selected.id, action, banReason);
    load();
    setSelected(null);
    setBanReason('');
    setBusy(false);
  };

  const columns = useMemo(
    () => [
      { accessorKey: 'name', header: 'Name' },
      { accessorKey: 'phone', header: 'Phone' },
      { accessorKey: 'nationality', header: 'Nationality' },
      {
        accessorKey: 'subscription',
        header: 'Subscription',
        cell: ({ getValue }) => (
          <span
            className={
              getValue() === 'premium'
                ? 'text-gold font-semibold'
                : 'text-text-secondary'
            }
          >
            {getValue()}
          </span>
        ),
      },
      {
        accessorKey: 'status',
        header: 'Status',
        cell: ({ getValue }) => {
          const v = getValue();
          const colors = {
            active: 'text-success',
            suspended: 'text-warning',
            banned: 'text-error',
          };
          return <span className={colors[v] || 'text-text-secondary'}>{v}</span>;
        },
      },
      { accessorKey: 'listingsPosted', header: 'Listings' },
      { accessorKey: 'joinedAt', header: 'Joined' },
      {
        id: 'view',
        header: '',
        cell: ({ row }) => (
          <button
            type="button"
            onClick={() => setSelected(row.original)}
            className="text-primary text-xs hover:underline"
          >
            Manage
          </button>
        ),
      },
    ],
    [],
  );

  const table = useReactTable({
    data: users,
    columns,
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-text-primary">User Management</h2>
        <p className="text-text-secondary text-sm mt-1">Search and manage platform users</p>
      </div>

      <div className="flex gap-3">
        <input
          type="search"
          placeholder="Search by name, phone, nationality..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && load()}
          className="flex-1 bg-surface border border-border rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:border-primary"
        />
        <button
          type="button"
          onClick={() => load()}
          className="px-4 py-2.5 rounded-lg bg-primary text-background font-medium text-sm"
        >
          Search
        </button>
      </div>

      <div className="bg-surface border border-border rounded-xl overflow-hidden">
        {loading ? (
          <div className="p-8 text-center text-text-secondary">Loading users...</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                {table.getHeaderGroups().map((hg) => (
                  <tr key={hg.id} className="border-b border-border bg-surface-elevated">
                    {hg.headers.map((header) => (
                      <th key={header.id} className="text-left px-4 py-3 text-text-secondary font-medium">
                        {flexRender(header.column.columnDef.header, header.getContext())}
                      </th>
                    ))}
                  </tr>
                ))}
              </thead>
              <tbody>
                {table.getRowModel().rows.map((row) => (
                  <tr key={row.id} className="border-b border-border/50 hover:bg-surface-elevated/50">
                    {row.getVisibleCells().map((cell) => (
                      <td key={cell.id} className="px-4 py-3 text-text-primary">
                        {flexRender(cell.column.columnDef.cell, cell.getContext())}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {selected && (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
          <div className="bg-surface border border-border rounded-2xl p-6 w-full max-w-md space-y-4">
            <h3 className="text-lg font-bold text-text-primary">{selected.name}</h3>
            <div className="grid grid-cols-2 gap-2 text-sm">
              <div className="text-text-secondary">Phone</div>
              <div>{selected.phone}</div>
              <div className="text-text-secondary">Nationality</div>
              <div>{selected.nationality}</div>
              <div className="text-text-secondary">Subscription</div>
              <div className={selected.subscription === 'premium' ? 'text-gold' : ''}>
                {selected.subscription}
              </div>
              <div className="text-text-secondary">Listings posted</div>
              <div>{selected.listingsPosted}</div>
              <div className="text-text-secondary">Status</div>
              <div>{selected.status}</div>
              {selected.banReason && (
                <>
                  <div className="text-text-secondary">Ban reason</div>
                  <div className="text-error">{selected.banReason}</div>
                </>
              )}
            </div>

            <div>
              <label className="text-xs text-text-secondary">Ban/suspend reason</label>
              <input
                value={banReason}
                onChange={(e) => setBanReason(e.target.value)}
                placeholder="Reason for action..."
                className="w-full mt-1 bg-surface-elevated border border-border rounded-lg px-3 py-2 text-sm"
              />
            </div>

            <div className="flex flex-wrap gap-2">
              <button
                type="button"
                disabled={busy}
                onClick={() => doAction('grant-premium')}
                className="px-3 py-1.5 text-xs rounded-lg bg-gold/20 text-gold border border-gold/30"
              >
                Grant Premium
              </button>
              <button
                type="button"
                disabled={busy}
                onClick={() => doAction('revoke-premium')}
                className="px-3 py-1.5 text-xs rounded-lg border border-border text-text-secondary"
              >
                Revoke Premium
              </button>
              <button
                type="button"
                disabled={busy}
                onClick={() => doAction('suspend')}
                className="px-3 py-1.5 text-xs rounded-lg bg-warning/20 text-warning border border-warning/30"
              >
                Suspend
              </button>
              <button
                type="button"
                disabled={busy}
                onClick={() => doAction('ban')}
                className="px-3 py-1.5 text-xs rounded-lg bg-error/20 text-error border border-error/30"
              >
                Ban
              </button>
              {selected.status !== 'active' && (
                <button
                  type="button"
                  disabled={busy}
                  onClick={() => doAction('unban')}
                  className="px-3 py-1.5 text-xs rounded-lg bg-success/20 text-success border border-success/30"
                >
                  Unban
                </button>
              )}
            </div>

            <button
              type="button"
              onClick={() => setSelected(null)}
              className="w-full py-2 text-sm text-text-secondary border border-border rounded-lg"
            >
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
