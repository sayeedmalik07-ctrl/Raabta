export default function StatCard({ label, value, sub, icon, accent = 'primary' }) {
  const accentMap = {
    primary: 'text-primary border-primary/30 bg-primary/5',
    success: 'text-success border-success/30 bg-success/5',
    warning: 'text-warning border-warning/30 bg-warning/5',
    error: 'text-error border-error/30 bg-error/5',
    gold: 'text-gold border-gold/30 bg-gold/5',
  };

  return (
    <div className={`rounded-xl border p-5 ${accentMap[accent]}`}>
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm text-text-secondary">{label}</p>
          <p className="text-3xl font-bold mt-1 text-text-primary">{value}</p>
          {sub && <p className="text-xs text-text-secondary mt-1">{sub}</p>}
        </div>
        {icon && <span className="text-2xl opacity-80">{icon}</span>}
      </div>
    </div>
  );
}
