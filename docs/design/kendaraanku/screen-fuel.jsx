// Screen 4 — Catatan BBM
const FUEL_ENTRIES = [
  { date: '12 Mei 2026', station: 'Shell Antasari',     fuel: 'V-Power',      liters: 32.5, total: 525000, pricePerL: 16150, km: 45231, consumption: 13.8 },
  { date: '28 Apr 2026', station: 'Pertamina Pondok Indah', fuel: 'Pertalite', liters: 30.0, total: 300000, pricePerL: 10000, km: 44782, consumption: 13.2 },
  { date: '14 Apr 2026', station: 'Shell Antasari',     fuel: 'V-Power',      liters: 28.7, total: 463500, pricePerL: 16150, km: 44384, consumption: 14.1 },
  { date: '02 Apr 2026', station: 'Pertamina Lebak Bulus',  fuel: 'Pertalite', liters: 25.0, total: 250000, pricePerL: 10000, km: 43980, consumption: 12.9 },
];

const MONTH_SPEND = [
  { m: 'Des', v: 720 }, { m: 'Jan', v: 580 }, { m: 'Feb', v: 920 },
  { m: 'Mar', v: 760 }, { m: 'Apr', v: 1013 }, { m: 'Mei', v: 850, active: true },
];

function FuelScreen() {
  const maxV = Math.max(...MONTH_SPEND.map(x => x.v));
  return (
    <div className="kdr kdr-scroll" style={{ position: 'relative' }}>
      <AppBar
        title="Catatan BBM"
        trailing={<button className="kdr-iconbtn"><IcFilter size={20}/></button>}
      />
      <div className="kdr-body">
        {/* Summary card */}
        <div style={{ padding: '0 20px 14px' }}>
          <div className="kdr-card" style={{ padding: 18 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <div>
                <div style={{ fontSize: 11.5, color: 'var(--text-muted)', fontWeight: 600 }}>Total Mei 2026</div>
                <div className="kdr-num" style={{ fontSize: 26, fontWeight: 800, marginTop: 2, letterSpacing: '-0.02em' }}>{formatRp(850000)}</div>
              </div>
              <div style={{
                display: 'inline-flex', alignItems: 'center', gap: 4,
                background: 'var(--tint-mint)', color: 'var(--on-tint-mint)',
                padding: '4px 10px', borderRadius: 100,
                fontSize: 11, fontWeight: 700,
              }}>
                <IcSpark size={12} sw={2}/>-16% dari April
              </div>
            </div>
            <div style={{ display: 'flex', gap: 14, marginTop: 14 }}>
              <FuelKPI label="Total Liter" value="65,4 L"/>
              <div style={{ width: 1, background: 'var(--divider)' }}/>
              <FuelKPI label="Konsumsi Avg" value="13,5 km/L" highlight/>
              <div style={{ width: 1, background: 'var(--divider)' }}/>
              <FuelKPI label="Pengisian" value="2x"/>
            </div>
          </div>
        </div>

        {/* Bar chart */}
        <div style={{ padding: '0 20px 14px' }}>
          <div className="kdr-card" style={{ padding: 16 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
              <div>
                <div style={{ fontSize: 13, fontWeight: 700 }}>Pengeluaran 6 Bulan</div>
                <div style={{ fontSize: 11, color: 'var(--text-muted)', marginTop: 2 }}>dalam ribuan Rupiah</div>
              </div>
              <div className="kdr-chip tint" style={{ padding: '4px 10px', fontSize: 11 }}>2026</div>
            </div>
            <div style={{ display: 'flex', alignItems: 'flex-end', gap: 10, height: 120 }}>
              {MONTH_SPEND.map(m => (
                <div key={m.m} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
                  <div className="kdr-num" style={{
                    fontSize: 10, fontWeight: 700,
                    color: m.active ? 'var(--primary)' : 'var(--text-muted)',
                  }}>{m.v}</div>
                  <div style={{
                    width: '100%',
                    height: `${(m.v / maxV) * 86}px`,
                    background: m.active
                      ? 'var(--primary)'
                      : 'var(--primary-soft)',
                    borderRadius: 8,
                    minHeight: 8,
                  }}/>
                  <div style={{
                    fontSize: 10.5, fontWeight: 600,
                    color: m.active ? 'var(--primary)' : 'var(--text-muted)',
                  }}>{m.m}</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* List */}
        <SectionTitle title="Riwayat Pengisian" action="Lihat semua"/>
        <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 10 }}>
          {FUEL_ENTRIES.map((e, i) => <FuelCard key={i} e={e}/>)}
        </div>

        <div style={{ height: 120 }}/>
      </div>

      <button className="kdr-fab"><IcPlus size={20} stroke="white" sw={2.6}/>Catat BBM</button>
      <BottomNav active="history"/>
    </div>
  );
}

function FuelKPI({ label, value, highlight }) {
  return (
    <div style={{ flex: 1 }}>
      <div style={{ fontSize: 10.5, color: 'var(--text-muted)', fontWeight: 600, letterSpacing: '0.02em', textTransform: 'uppercase' }}>{label}</div>
      <div className="kdr-num" style={{
        fontSize: 14, fontWeight: 700, marginTop: 3,
        color: highlight ? 'var(--primary)' : 'var(--text)',
      }}>{value}</div>
    </div>
  );
}

function FuelCard({ e }) {
  return (
    <div className="kdr-card" style={{ padding: 14 }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
        <div className="tint-peach" style={{
          width: 42, height: 42, borderRadius: 12,
          display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
        }}><IcFuel size={20} sw={2}/></div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8 }}>
            <div style={{ minWidth: 0 }}>
              <div style={{ fontSize: 13.5, fontWeight: 700, letterSpacing: '-0.01em' }}>{e.station}</div>
              <div style={{ fontSize: 11.5, color: 'var(--text-muted)', marginTop: 2 }}>{e.fuel} · {e.date}</div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div className="kdr-num" style={{ fontSize: 14, fontWeight: 700, whiteSpace: 'nowrap' }}>{formatRp(e.total)}</div>
              <div className="kdr-num" style={{ fontSize: 10.5, color: 'var(--text-muted)', marginTop: 2 }}>{e.liters} L</div>
            </div>
          </div>
          <div style={{
            marginTop: 10, display: 'grid', gridTemplateColumns: '1fr 1fr 1fr',
            background: 'var(--surface-2)', borderRadius: 10, padding: '8px 10px',
          }}>
            <FuelMini label="Harga/L" value={`Rp${e.pricePerL.toLocaleString('id-ID')}`}/>
            <FuelMini label="Odo" value={formatKm(e.km)}/>
            <FuelMini label="Konsumsi" value={`${e.consumption} km/L`} accent/>
          </div>
        </div>
      </div>
    </div>
  );
}

function FuelMini({ label, value, accent }) {
  return (
    <div>
      <div style={{ fontSize: 9.5, color: 'var(--text-soft)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.04em' }}>{label}</div>
      <div className="kdr-num" style={{
        fontSize: 11.5, fontWeight: 700, marginTop: 2,
        color: accent ? 'var(--success)' : 'var(--text)',
      }}>{value}</div>
    </div>
  );
}

Object.assign(window, { FuelScreen, FuelKPI, FuelCard, FuelMini });
