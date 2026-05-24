// Screen 2 — Detail Kendaraan
function DetailScreen() {
  const v = VEHICLES[0];
  return (
    <div className="kdr kdr-scroll" style={{ background: 'var(--bg)' }}>
      <div className="kdr-body" style={{ padding: 0 }}>
        {/* Hero header — vertical gradient so top edge matches status bar */}
        <div style={{
          background: 'var(--hero-bg-vertical)',
          padding: '12px 20px 28px',
          borderBottomLeftRadius: 28, borderBottomRightRadius: 28,
          position: 'relative', overflow: 'hidden',
        }}>
          <div style={{
            position: 'absolute', right: -60, top: -40,
            width: 220, height: 220, borderRadius: '50%',
            background: 'rgba(255,255,255,0.12)',
          }}/>
          <div style={{
            position: 'absolute', left: -40, bottom: -40,
            width: 140, height: 140, borderRadius: '50%',
            background: 'rgba(255,255,255,0.10)',
          }}/>

          <div style={{ display: 'flex', alignItems: 'center', gap: 8, position: 'relative', zIndex: 2 }}>
            <button className="kdr-iconbtn" style={{ background: 'rgba(255,255,255,0.2)', border: 'none', color: 'white' }}>
              <IcBack size={20}/>
            </button>
            <div style={{ flex: 1, textAlign: 'center', color: 'white', fontSize: 13, fontWeight: 600, opacity: 0.9 }}>Detail Kendaraan</div>
            <button className="kdr-iconbtn" style={{ background: 'rgba(255,255,255,0.2)', border: 'none', color: 'white' }}>
              <IcEdit size={18}/>
            </button>
          </div>

          {/* Vehicle illustration */}
          <div style={{ display: 'flex', justifyContent: 'center', margin: '12px 0 6px', position: 'relative', zIndex: 2 }}>
            <VCar size={210}/>
          </div>

          <div style={{ textAlign: 'center', color: 'white', position: 'relative', zIndex: 2 }}>
            <div style={{
              display: 'inline-block',
              background: 'white', color: 'var(--text)',
              padding: '6px 14px', borderRadius: 8,
              fontSize: 18, fontWeight: 800, letterSpacing: '0.05em',
              fontFamily: 'monospace',
              boxShadow: '0 4px 12px rgba(0,0,0,0.12)',
            }}>{v.plate}</div>
            <h1 style={{ fontSize: 22, fontWeight: 800, marginTop: 14, letterSpacing: '-0.01em' }}>{v.name}</h1>
            <div style={{ fontSize: 13, opacity: 0.9, marginTop: 4 }}>{v.color} · {v.year}</div>
          </div>
        </div>

        {/* Stats grid */}
        <div style={{ padding: '16px 20px 8px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <MiniStat icon={<IcGauge size={16} sw={2}/>} tint="blue"     label="Odometer"      value={formatKm(v.odo)}/>
          <MiniStat icon={<IcFuel size={16} sw={2}/>}  tint="peach"    label="Tipe BBM"      value="Pertalite"/>
          <MiniStat icon={<IcWrench size={16} sw={2}/>} tint="mint"    label="Servis Terakhir" value="08 Mei 2026"/>
          <MiniStat icon={<IcShield size={16} sw={2}/>} tint="amber"   label="Pajak Berikut" value="09 Jun 2026"/>
        </div>

        {/* Tabs */}
        <div style={{ padding: '8px 20px 0' }}>
          <div style={{
            display: 'flex', background: 'var(--surface)', borderRadius: 14,
            padding: 4, border: '1px solid var(--border)',
          }}>
            <Tab label="Spesifikasi" active/>
            <Tab label="Servis"/>
            <Tab label="Dokumen"/>
          </div>
        </div>

        {/* Spesifikasi */}
        <div style={{ padding: '14px 20px 0' }}>
          <div className="kdr-card" style={{ padding: 0 }}>
            <SpecRow label="Merk & Tipe"   value={`Honda ${v.name.split(' ').slice(1).join(' ')}`}/>
            <div className="kdr-divider"/>
            <SpecRow label="Tahun Produksi" value={String(v.year)}/>
            <div className="kdr-divider"/>
            <SpecRow label="Warna"          value={v.color}/>
            <div className="kdr-divider"/>
            <SpecRow label="Mesin"          value={v.engine}/>
            <div className="kdr-divider"/>
            <SpecRow label="Transmisi"      value={v.transmission}/>
            <div className="kdr-divider"/>
            <SpecRow label="No. Rangka"     value="MHRGM6850MJ•••231"  mono/>
            <div className="kdr-divider"/>
            <SpecRow label="No. Mesin"      value="L12B3•••48721"     mono/>
          </div>
        </div>

        {/* Action buttons */}
        <div style={{ padding: '16px 20px 4px', display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
          <ActionBtn tint="mint"  icon={<IcWrench size={20} sw={2}/>} label="Servis"/>
          <ActionBtn tint="peach" icon={<IcFuel size={20} sw={2}/>}   label="BBM"/>
          <ActionBtn tint="amber" icon={<IcReceipt size={20} sw={2}/>} label="Pajak"/>
        </div>

        <div style={{ height: 20 }}/>
      </div>
      <BottomNav active="home"/>
    </div>
  );
}

function MiniStat({ icon, tint, label, value }) {
  return (
    <div className="kdr-card" style={{ padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10 }}>
      <div className={`tint-${tint}`} style={{
        width: 34, height: 34, borderRadius: 10,
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}>{icon}</div>
      <div style={{ minWidth: 0 }}>
        <div style={{ fontSize: 10.5, color: 'var(--text-muted)', fontWeight: 600, letterSpacing: '0.02em', textTransform: 'uppercase' }}>{label}</div>
        <div className="kdr-num" style={{ fontSize: 13, fontWeight: 700, marginTop: 1 }}>{value}</div>
      </div>
    </div>
  );
}

function Tab({ label, active }) {
  return (
    <div style={{
      flex: 1, textAlign: 'center',
      padding: '10px 8px',
      borderRadius: 10,
      fontSize: 13, fontWeight: 600,
      background: active ? 'var(--primary)' : 'transparent',
      color: active ? 'white' : 'var(--text-muted)',
      boxShadow: active ? '0 4px 10px rgba(61,107,245,0.25)' : 'none',
    }}>{label}</div>
  );
}

function SpecRow({ label, value, mono }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 16px' }}>
      <div style={{ fontSize: 12, color: 'var(--text-muted)', fontWeight: 500 }}>{label}</div>
      <div style={{
        fontSize: 13, fontWeight: 600,
        fontFamily: mono ? 'ui-monospace, Menlo, monospace' : 'inherit',
      }}>{value}</div>
    </div>
  );
}

function ActionBtn({ tint, icon, label }) {
  return (
    <button className={`tint-${tint}`} style={{
      border: 'none', padding: '14px 8px', borderRadius: 14,
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
      fontFamily: 'inherit', fontSize: 12, fontWeight: 600,
    }}>
      {icon}
      <span>{label}</span>
    </button>
  );
}

Object.assign(window, { DetailScreen, MiniStat, Tab, SpecRow, ActionBtn });
