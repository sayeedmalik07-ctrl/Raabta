import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  flexRender,
  getCoreRowModel,
  getFilteredRowModel,
  getSortedRowModel,
  useReactTable,
} from '@tanstack/react-table';
import { api } from '../lib/api';

function scamScoreColor(score) {
  if (score >= 70) return 'text-error bg-error/10 border-error/30';
  if (score >= 40) return 'text-warning bg-warning/10 border-warning/30';
  return 'text-success bg-success/10 border-success/30';
}

export default function Moderation() {
  const [listings, setListings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [minScore, setMinScore] = useState(0);
  const [maxScore, setMaxScore] = useState(100);
  const [selected, setSelected] = useState({});
  const [busy, setBusy] = useState(null);

  const load = useCallback(() => {
    setLoading(true);
    api
      .getModerationQueue(minScore, maxScore)
      .then((data) => setListings(data.listings || []))
      .finally(() => setLoading(false));
  }, [minScore, maxScore]);

  useEffect(() => {
    load();
  }, [load]);

  const act = async (id, action) => {
    setBusy(id);
    await api.moderateListing(id, action);
    setListings((prev) => prev.filter((l) => l.id !== id));
    setBusy(null);
  };

  const bulkApprove = async () => {
    const ids = Object.keys(selected).filter((k) => selected[k]);
    if (!ids.length) return;
    setBusy('bulk');
    await api.bulkApprove(ids);
    setListings((prev) => prev.filter((l) => !ids.includes(l.id)));
    setSelected({});
    setBusy(null);
  };

  const columns = useMemo(
    () => [
      {
        id: 'select',
        header: ({ table }) => (
          <input
            type="checkbox"
            checked={table.getIsAllRowsSelected()}
            onChange={table.getToggleAllRowsSelectedHandler()}
            className="accent-primary"
          />
        ),
        cell: ({ row }) => (
          <input
            type="checkbox"
            checked={!!selected[row.original.id]}
            onChange={() =>
              setSelected((s) => ({ ...s, [row.original.id]: !s[row.original.id] }))
            }
            className="accent-primary"
          />
        ),
      },
      {
        accessorKey: 'photoUrl',
        header: 'Photo',
        cell: ({ getValue, row }) => (
          <img
            src={getValue() || `https://picsum.photos/seed/${row.original.id}/48/48`}
            alt=""
            className="w-12 h-12 rounded-lg object-cover border border-border"
          />
        ),
      },
      {
        accessorKey: 'title',
        header: 'Title',
        cell: ({ getValue, row }) => (
          <div>
            <div className="font-medium text-text-primary">{getValue()}</div>
            <div className="text-xs text-text-secondary">
              {row.original.area} · {row.original.pricePerMonth} QR/mo
            </div>
          </div>
        ),
      },
      {
        accessorKey: 'scamScore',
        header: 'Scam Score',
        cell: ({ getValue }) => {
          const score = getValue();
          return (
            <span className={`px-2 py-1 rounded-md text-xs font-bold border ${scamScoreColor(score)}`}>
              {score}
            </span>
          );
        },
      },
      {
        accessorKey: 'reportCount',
        header: 'Reports',
        cell: ({ getValue }) => (
          <span className={getValue() > 0 ? 'text-error font-semibold' : 'text-text-secondary'}>
            {getValue()}
          </span>
        ),
      },
      {
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => (
          <div className="flex gap-1">
            <button
              type="button"
              disabled={busy === row.original.id}
              onClick={() => act(row.original.id, 'approve')}
              className="px-2 py-1 text-xs rounded bg-success/20 text-success border border-success/30 hover:bg-success/30"
              title="Approve"
            >
              ✓
            </button>
            <button
              type="button"
              disabled={busy === row.original.id}
              onClick={() => act(row.original.id, 'reject')}
              className="px-2 py-1 text-xs rounded bg-error/20 text-error border border-error/30 hover:bg-error/30"
              title="Reject"
            >
              ✗
            </button>
            <button
              type="button"
              disabled={busy === row.original.id}
              onClick={() => act(row.original.id, 'flag')}
              className="px-2 py-1 text-xs rounded bg-warning/20 text-warning border border-warning/30 hover:bg-warning/30"
              title="Flag"
            >
              ⚠️
            </button>
          </div>
        ),
      },
    ],
    [busy, selected],
  );

  const table = useReactTable({
    data: listings,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
  });

  const selectedCount = Object.values(selected).filter(Boolean).length;

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-text-primary">Listing Moderation Queue</h2>
          <p className="text-text-secondary text-sm mt-1">{listings.length} pending listings</p>
        </div>
        <button
          type="button"
          onClick={bulkApprove}
          disabled={!selectedCount || busy === 'bulk'}
          className="px-4 py-2 rounded-lg bg-success/20 text-success border border-success/30 text-sm font-medium disabled:opacity-40"
        >
          Bulk Approve ({selectedCount})
        </button>
      </div>

      <div className="flex flex-wrap gap-4 items-end bg-surface border border-border rounded-xl p-4">
        <div>
          <label className="text-xs text-text-secondary block mb-1">Min scam score</label>
          <input
            type="number"
            min={0}
            max={100}
            value={minScore}
            onChange={(e) => setMinScore(Number(e.target.value))}
            className="w-24 bg-surface-elevated border border-border rounded-lg px-3 py-2 text-sm"
          />
        </div>
        <div>
          <label className="text-xs text-text-secondary block mb-1">Max scam score</label>
          <input
            type="number"
            min={0}
            max={100}
            value={maxScore}
            onChange={(e) => setMaxScore(Number(e.target.value))}
            className="w-24 bg-surface-elevated border border-border rounded-lg px-3 py-2 text-sm"
          />
        </div>
        <button
          type="button"
          onClick={load}
          className="px-4 py-2 rounded-lg bg-primary/20 text-primary border border-primary/30 text-sm"
        >
          Apply filter
        </button>
      </div>

      <div className="bg-surface border border-border rounded-xl overflow-hidden">
        {loading ? (
          <div className="p-8 text-center text-text-secondary">Loading queue...</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                {table.getHeaderGroups().map((hg) => (
                  <tr key={hg.id} className="border-b border-border bg-surface-elevated">
                    {hg.headers.map((header) => (
                      <th
                        key={header.id}
                        className="text-left px-4 py-3 text-text-secondary font-medium"
                      >
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
                      <td key={cell.id} className="px-4 py-3">
                        {flexRender(cell.column.columnDef.cell, cell.getContext())}
                      </td>
                    ))}
                  </tr>
                ))}
                {!listings.length && (
                  <tr>
                    <td colSpan={columns.length} className="px-4 py-8 text-center text-text-secondary">
                      No pending listings in this score range
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
