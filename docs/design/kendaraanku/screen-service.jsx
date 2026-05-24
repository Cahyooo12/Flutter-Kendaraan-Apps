// Screen 3 — Riwayat Servis
const SERVICE_HISTORY = [
  { month: 'Mei 2026', items: [
    { type: 'rutin', title: 'Ganti Oli Mesin', shop: 'AHASS Bintaro Sektor 7', date: '08 Mei 2026', km: 44480, cost: 285000, parts: ['Oli MPX2 0.8L', 'Filter Oli'] },
  ]},
  { month: 'April 2026', items: [
    { type: 'sparepart', title: 'Ganti Kampas Rem Depan', shop: 'Bengkel Resmi Honda Pondok Indah', date: '22 Apr 2026', km: 43210, cost: 620000, parts: ['Kampas rem depan', 'Brake cleaner'] },
    { type: 'rutin', title: 'Cuci & Tune-up Ringan', shop: 'Cucian Mobil Pak Hadi', date: '03 Apr 2026', km: 42890, cost: 75000 },
  ]},
  { month: 'Februari 2026', items: [
    { type: 'rutin', title: 'Servis Berkala 40.000 km', shop: 'AHASS Bintaro Sektor 7', date: '14 Feb 2026', km: 40120, cost: 850000, parts: ['Oli mesin', 'Filter udara', 'Busi', 'Tune-up engine'] },
  ]},
];

const TYPE_META = {
  rutin:      { tint: 'mint',     icon: <IcWrench size={20} sw={2}/>,  label: 'Servis Rutin' },
  reparasi:   { tint: 'rose',     icon: <IcWarning size={20} sw={2}/>, label: 'Reparasi' },
  sparepart:  { tint: 'peach',    icon: <IcSpark size={20} sw={2}/>,   label: 'Sparepart' },
};

function ServiceScreen() {
  return (
    <div className="kdr kdr-scroll" style={{ position: 'relative' }}>
      <AppBar
        title="Riwayat Servis"
        trailing={<button className="kdr-iconbtn"><IcFilter size={20}/></button>}
      />
      <div className="kdr-body">
        {/* Summary card */}
        <div style={{ padding: '0 20px 14px' }}>
          <div style={{
            background: 'var(--hero-bg)',
            color: 'white',
            borderRadius: 'var(--r-xl)',
            padding: '18px 20px',
            position: 'relative', overflow: 'hidden',
          }}>
            <div style={{
              position: 'absolute', right: -40, top: -40,
              width: 160, height: 160, borderRadius: '50%',
              background: 'rgba(255,255,255,0.15)',
            }}/>
            <div style={{ position: 'relative', zIndex: 2 }}>
              <div style={{ fontSize: 12, opacity: 0.9, fontWeight: 500 }}>Total Pengeluaran Servis 2026</div>
              <div className="kdr-num" style={{ fontSize: 28, fontWeight: 800, marginTop: 4, letterSpacing: '-0.02em' }}>{formatRp(1830000)}</div>
              <div style={{ display: 'flex', gap: 18, marginTop: 14, paddingTop: 14, borderTop: '1px solid rgba(255,255,255,0.22)' }}>
                <div>
                  <div style={{ fontSize: 11, opacity: 0.85 }}>Servis</div>
                  <div className="kdr-num" style={{ fontSize: 16, fontWeight: 700, marginTop: 2 }}>4 kali</div>
                </div>
                <div style={{ width: 1, background: 'rgba(255,255,255,0.22)' }}/>
                <div>
                  <div style={{ fontSize: 11, opacity: 0.85 }}>Rata-rata</div>
                  <div className="kdr-num" style={{ fontSize: 16, fontWeight: 700, marginTop: 2 }}>{formatRp(457500)}</div>
                </div>
                <div style={{ width: 1, background: 'rgba(255,255,255,0.22)' }}/>
                <div>
                  <div style={{ fontSize: 11, opacity: 0.85 }}>Hemat</div>
                  <div className="kdr-num" style={{ fontSize: 16, fontWeight: 700, marginTop: 2 }}>-18%</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Filter chips */}
        <div style={{ display: 'flex', gap: 8, padding: '0 20px 14px', overflowX: 'auto' }}>
          <div className="kdr-chip active">Semua · 4</div>
          <div className="kdr-chip">Rutin</div>
          <div className="kdr-chip">Reparasi</div>
          <div className="kdr-chip">Sparepart</div>
        </div>

        {/* Timeline list */}
        <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 18 }}>
          {SERVICE_HISTORY.map(group => (
            <div key={group.month}>
              <div style={{
                fontSize: 11, fontWeight: 700, color: 'var(--text-muted)',
                letterSpacing: '0.04em', textTransform: 'uppercase',
                marginBottom: 10,
              }}>{group.month}</div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                {group.items.map((s, i) => <ServiceCard key={i} s={s}/>)}
              </div>
            </div>
          ))}
        </div>

        <div style={{ height: 120 }}/>
      </div>

      <button className="kdr-fab"><IcPlus size={20} stroke="white" sw={2.6}/>Tambah Servis</button>
      <BottomNav active="history"/>
    </div>
  );
}

function ServiceCard({ s }) {
  const meta = TYPE_META[s.type];
  return (
    <div className="kdr-card" style={{ padding: 14 }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
        <div className={`tint-${meta.tint}`} style={{
          width: 42, height: 42, borderRadius: 12,
          display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
        }}>{meta.icon}</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8 }}>
            <div style={{ minWidth: 0 }}>
              <div style={{ fontSize: 14, fontWeight: 700, letterSpacing: '-0.01em' }}>{s.title}</div>
              <div style={{ fontSize: 11.5, color: 'var(--text-muted)', marginTop: 2 }}>{s.shop}</div>
            </div>
            <div className="kdr-num" style={{ fontSize: 14, fontWeight: 700, whiteSpace: 'nowrap' }}>{formatRp(s.cost)}</div>
          </div>
          <div style={{ display: 'flex', gap: 6, marginTop: 10, flexWrap: 'wrap' }}>
            <span style={{
              display: 'inline-flex', alignItems: 'center', gap: 4,
              background: 'var(--surface-2)', padding: '3px 8px',
              borderRadius: 6, fontSize: 10.5, color: 'var(--text-muted)', fontWeight: 600,
            }}>
              <IcCalendar size={11} sw={2}/>{s.date}
            </span>
            <span style={{
              display: 'inline-flex', alignItems: 'center', gap: 4,
              background: 'var(--surface-2)', padding: '3px 8px',
              borderRadius: 6, fontSize: 10.5, color: 'var(--text-muted)', fontWeight: 600,
            }}>
              <IcGauge size={11} sw={2}/>{formatKm(s.km)}
            </span>
          </div>
          {s.parts && (
            <div style={{
              marginTop: 10, padding: '8px 10px',
              background: 'var(--surface-2)', borderRadius: 10,
              fontSize: 11.5, color: 'var(--text-muted)',
            }}>
              <span style={{ fontWeight: 600, color: 'var(--text)' }}>Item: </span>
              {s.parts.join(' · ')}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { ServiceScreen, ServiceCard });
