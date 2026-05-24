// Screen 1 — Home / Dashboard
function HomeScreen() {
  const v = VEHICLES[0];
  return (
    <div className="kdr kdr-scroll">
      <div className="kdr-body">
        <HomeHeader/>

        {/* Vehicle selector chips */}
        <div style={{ display: 'flex', gap: 8, padding: '6px 20px 14px', overflowX: 'auto' }}>
          <div className="kdr-chip active">
            <IcCar size={14} sw={2}/>
            <span>Brio Satya</span>
          </div>
          <div className="kdr-chip">
            <IcBike size={14} sw={2}/>
            <span>Vario 160</span>
          </div>
          <div className="kdr-chip" style={{ color: 'var(--primary)', borderStyle: 'dashed' }}>
            <IcPlus size={14} sw={2}/>
            <span>Tambah</span>
          </div>
        </div>

        {/* Hero vehicle card */}
        <div style={{ padding: '0 20px' }}>
          <div className="kdr-hero">
            <div style={{ position: 'relative', zIndex: 2, display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
              <div>
                <div style={{
                  display: 'inline-flex', alignItems: 'center', gap: 6,
                  background: 'rgba(255,255,255,0.22)', padding: '4px 10px',
                  borderRadius: 100, fontSize: 11, fontWeight: 700, letterSpacing: '0.04em',
                }}>
                  <span style={{ width: 5, height: 5, borderRadius: '50%', background: '#7CFFB0' }}/>
                  AKTIF
                </div>
                <div style={{ fontSize: 11, marginTop: 14, opacity: 0.85, fontWeight: 500 }}>Plat Nomor</div>
                <div style={{ fontSize: 22, fontWeight: 800, letterSpacing: '0.03em', marginTop: 2 }}>{v.plate}</div>
                <div style={{ fontSize: 13, marginTop: 8, opacity: 0.95, fontWeight: 500 }}>{v.name} · {v.year}</div>
              </div>
            </div>
            <div style={{ marginTop: 4, position: 'relative', zIndex: 2, display: 'flex', justifyContent: 'flex-end' }}>
              <VCar size={150}/>
            </div>
            <div style={{
              position: 'relative', zIndex: 2,
              marginTop: 8, paddingTop: 12,
              borderTop: '1px solid rgba(255,255,255,0.22)',
              display: 'flex', justifyContent: 'space-between', alignItems: 'center',
            }}>
              <div>
                <div style={{ fontSize: 11, opacity: 0.85, fontWeight: 500 }}>Odometer</div>
                <div className="kdr-num" style={{ fontSize: 18, fontWeight: 700, marginTop: 2 }}>{formatKm(v.odo)}</div>
              </div>
              <button style={{
                background: 'rgba(255,255,255,0.22)', color: 'white',
                border: 'none', padding: '8px 14px',
                borderRadius: 100, fontSize: 12, fontWeight: 600,
                fontFamily: 'inherit', display: 'flex', alignItems: 'center', gap: 6,
              }}>
                Detail <IcChevR size={14} sw={2.4}/>
              </button>
            </div>
          </div>
        </div>

        {/* Quick stats */}
        <div style={{ display: 'flex', gap: 10, padding: '16px 20px 6px' }}>
          <StatCard tint="blue"  icon={<IcGauge size={18} sw={2}/>} value="1.240 km" label="Bulan ini" sub="+12% dr bulan lalu"/>
          <StatCard tint="peach" icon={<IcFuel size={18} sw={2}/>}  value={formatRp(850000)} label="BBM Mei" sub="13,5 km/L"/>
          <StatCard tint="mint"  icon={<IcRupiah size={18} sw={2}/>} value={formatRp(1250000)} label="Pengeluaran"/>
        </div>

        {/* Pengingat */}
        <div style={{ marginTop: 16 }}>
          <SectionTitle title="Pengingat" action="Lihat semua"/>
          <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 10 }}>
            <ReminderCard
              tint="rose"
              icon={<IcWrench size={20} sw={2}/>}
              title="Servis Rutin 50.000 km"
              sub="Honda Brio Satya · Sisa 760 km"
              right={<div style={{ textAlign: 'right' }}>
                <div className="kdr-status due"><span className="dot"/>7 hari lagi</div>
                <div style={{ fontSize: 11, color: 'var(--text-muted)', marginTop: 6 }}>24 Mei 2026</div>
              </div>}
            />
            <ReminderCard
              tint="amber"
              icon={<IcShield size={20} sw={2}/>}
              title="Pajak Tahunan STNK"
              sub="B 1234 ABC · Rp 2.150.000"
              right={<div style={{ textAlign: 'right' }}>
                <div className="kdr-status warn"><span className="dot"/>23 hari lagi</div>
                <div style={{ fontSize: 11, color: 'var(--text-muted)', marginTop: 6 }}>09 Jun 2026</div>
              </div>}
            />
          </div>
        </div>

        {/* Aktivitas terakhir */}
        <div style={{ marginTop: 20 }}>
          <SectionTitle title="Aktivitas Terakhir" action="Lihat semua"/>
          <div style={{ padding: '0 20px' }}>
            <div className="kdr-card" style={{ padding: 0 }}>
              <ActivityRow tint="peach" icon={<IcFuel size={18} sw={2}/>} title="Isi BBM Pertalite" sub="Shell Antasari · 12 Mei" amount={`-${formatRp(150000)}`} amountColor="var(--text)"/>
              <div className="kdr-divider"/>
              <ActivityRow tint="mint"  icon={<IcWrench size={18} sw={2}/>} title="Ganti Oli Mesin" sub="AHASS Bintaro · 08 Mei" amount={`-${formatRp(285000)}`} amountColor="var(--text)"/>
              <div className="kdr-divider"/>
              <ActivityRow tint="lavender" icon={<IcReceipt size={18} sw={2}/>} title="Tol Jakarta–Bogor" sub="e-Toll · 05 Mei" amount={`-${formatRp(38000)}`} amountColor="var(--text)"/>
            </div>
          </div>
        </div>

        <div style={{ height: 16 }}/>
      </div>
      <BottomNav active="home"/>
    </div>
  );
}

function ReminderCard({ tint, icon, title, sub, right }) {
  return (
    <div className="kdr-card" style={{ display: 'flex', alignItems: 'center', gap: 12, padding: 14 }}>
      <div className={`tint-${tint}`} style={{
        width: 42, height: 42, borderRadius: 12,
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}>{icon}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14, fontWeight: 600, letterSpacing: '-0.01em' }}>{title}</div>
        <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>{sub}</div>
      </div>
      {right}
    </div>
  );
}

function ActivityRow({ tint, icon, title, sub, amount, amountColor }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: 14 }}>
      <div className={`tint-${tint}`} style={{
        width: 36, height: 36, borderRadius: 10,
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}>{icon}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 13, fontWeight: 600 }}>{title}</div>
        <div style={{ fontSize: 11, color: 'var(--text-muted)', marginTop: 1 }}>{sub}</div>
      </div>
      <div className="kdr-num" style={{ fontSize: 13, fontWeight: 700, color: amountColor }}>{amount}</div>
    </div>
  );
}

Object.assign(window, { HomeScreen, ReminderCard, ActivityRow });
