// Shared UI bits + common data

const VEHICLES = [
  {
    id: 'brio',
    type: 'Mobil',
    name: 'Honda Brio Satya',
    plate: 'B 1234 ABC',
    year: 2021,
    color: 'Putih Taffeta',
    odo: 45231,
    odoMonth: 1240,
    fuelType: 'Bensin (Pertalite)',
    engine: '1.2L i-VTEC',
    transmission: 'Manual 5-speed',
    illustration: 'car',
  },
  {
    id: 'vario',
    type: 'Motor',
    name: 'Honda Vario 160',
    plate: 'B 4567 XYZ',
    year: 2023,
    color: 'Hitam Doff',
    odo: 8420,
    odoMonth: 320,
    fuelType: 'Bensin (Pertamax)',
    engine: '160cc PGM-FI',
    transmission: 'Otomatis (CVT)',
    illustration: 'bike',
  },
];

const formatRp = (n) => 'Rp ' + n.toLocaleString('id-ID');
const formatKm = (n) => n.toLocaleString('id-ID') + ' km';

// Header used on home
function HomeHeader({ name = 'Andi' }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 20px 8px' }}>
      <div style={{
        width: 44, height: 44, borderRadius: 14,
        background: 'var(--primary-soft)', color: 'var(--primary-strong)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontWeight: 700, fontSize: 16,
      }}>{name[0]}P</div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 12, color: 'var(--text-muted)', fontWeight: 500 }}>Selamat pagi,</div>
        <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.01em' }}>Andi Pratama</div>
      </div>
      <button className="kdr-iconbtn" style={{ position: 'relative' }}>
        <IcBell size={20}/>
        <span style={{
          position: 'absolute', top: 8, right: 9,
          width: 8, height: 8, borderRadius: '50%',
          background: 'var(--danger)', border: '2px solid var(--surface)',
        }}/>
      </button>
    </div>
  );
}

// Stat card with tint
function StatCard({ tint, icon, value, label, sub }) {
  return (
    <div style={{
      flex: 1, background: 'var(--surface)', borderRadius: 'var(--r-lg)',
      padding: '14px 12px', border: '1px solid var(--border)',
      boxShadow: 'var(--shadow-sm)',
    }}>
      <div className={`tint-${tint}`} style={{
        width: 34, height: 34, borderRadius: 10,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        marginBottom: 10,
      }}>
        {icon}
      </div>
      <div className="kdr-num" style={{ fontSize: 14.5, fontWeight: 700, letterSpacing: '-0.02em', whiteSpace: 'nowrap' }}>{value}</div>
      <div style={{ fontSize: 11, color: 'var(--text-muted)', fontWeight: 500, marginTop: 2 }}>{label}</div>
      {sub && <div style={{ fontSize: 10, color: 'var(--success)', fontWeight: 600, marginTop: 3 }}>{sub}</div>}
    </div>
  );
}

// Section title row
function SectionTitle({ title, action = 'Lihat semua', onAction }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 20px', marginBottom: 10 }}>
      <h3 className="kdr-h3">{title}</h3>
      {action && (
        <button style={{ background: 'none', border: 'none', color: 'var(--primary)', fontSize: 12, fontWeight: 600, fontFamily: 'inherit' }}>
          {action}
        </button>
      )}
    </div>
  );
}

// Bottom nav — 4 tab evenly spaced
function BottomNav({ active = 'home' }) {
  const items = [
    { id: 'home',    icon: <IcHome size={22}/>,  label: 'Beranda' },
    { id: 'history', icon: <IcClock size={22}/>, label: 'Riwayat' },
    { id: 'docs',    icon: <IcDoc size={22}/>,   label: 'Dokumen' },
    { id: 'profile', icon: <IcUser size={22}/>,  label: 'Profil' },
  ];
  return (
    <div className="kdr-nav">
      {items.map(it => (
        <button key={it.id} className={`kdr-nav-item ${active === it.id ? 'active' : ''}`}>
          <div className="nav-icon">{it.icon}</div>
          <span>{it.label}</span>
        </button>
      ))}
    </div>
  );
}

// App bar with back, title, optional trailing
function AppBar({ title, trailing }) {
  return (
    <div className="kdr-appbar">
      <button className="kdr-iconbtn"><IcBack size={20}/></button>
      <h2 className="kdr-h2" style={{ flex: 1 }}>{title}</h2>
      {trailing}
    </div>
  );
}

Object.assign(window, {
  VEHICLES, formatRp, formatKm,
  HomeHeader, StatCard, SectionTitle, BottomNav, AppBar,
});
