import { NavLink } from 'react-router-dom';

const links = [
  { to: '/', label: 'Overview', icon: '📊', end: true },
  { to: '/moderation', label: 'Moderation', icon: '🛡️' },
  { to: '/users', label: 'Users', icon: '👥' },
  { to: '/exchange-rates', label: 'Exchange Rates', icon: '💱' },
  { to: '/content', label: 'Content', icon: '📝' },
  { to: '/ai-monitor', label: 'AI Monitor', icon: '🤖' },
];

export default function Sidebar() {
  return (
    <aside className="w-64 border-r border-border bg-surface hidden md:flex flex-col">
      <div className="p-6 border-b border-border">
        <div className="flex items-center gap-2">
          <span className="text-2xl">🌙</span>
          <div>
            <div className="font-bold text-text-primary">Raabta</div>
            <div className="text-xs text-primary">Admin Panel</div>
          </div>
        </div>
      </div>
      <nav className="flex-1 p-4 space-y-1">
        {links.map((link) => (
          <NavLink
            key={link.to}
            to={link.to}
            end={link.end}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition ${
                isActive
                  ? 'bg-primary/10 text-primary border border-primary/30 shadow-glow'
                  : 'text-text-secondary hover:text-text-primary hover:bg-surface-elevated'
              }`
            }
          >
            <span>{link.icon}</span>
            {link.label}
          </NavLink>
        ))}
      </nav>
      <div className="p-4 border-t border-border text-xs text-text-muted">
        v1.0 · raabta-27c6a
      </div>
    </aside>
  );
}
