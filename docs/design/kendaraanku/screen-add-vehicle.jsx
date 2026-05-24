// Screen — Tambah Kendaraan (form wizard, step 2/3)
function AddVehicleScreen() {
  return (
    <div className="kdr kdr-scroll">
      <div className="kdr-appbar">
        <button className="kdr-iconbtn"><IcBack size={20}/></button>
        <h2 className="kdr-h2" style={{ flex: 1 }}>Tambah Kendaraan</h2>
        <button style={{ background: 'none', border: 'none', color: 'var(--text-muted)', fontSize: 13, fontWeight: 600, fontFamily: 'inherit' }}>Lewati</button>
      </div>

      <div className="kdr-body">
        {/* Stepper */}
        <div style={{ padding: '0 20px 18px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <Step n={1} label="Jenis"   state="done"/>
            <StepLine done/>
            <Step n={2} label="Detail"  state="active"/>
            <StepLine/>
            <Step n={3} label="Foto"    state="pending"/>
          </div>
        </div>

        {/* Vehicle type preview */}
        <div style={{ padding: '0 20px 14px' }}>
          <div className="kdr-card" style={{
            display: 'flex', alignItems: 'center', gap: 12,
            background: 'var(--primary-softer)', borderColor: 'var(--primary-soft)',
          }}>
            <div style={{
              width: 48, height: 48, borderRadius: 12,
              background: 'var(--primary)', color: 'white',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}><IcCar size={26} sw={2}/></div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 11, color: 'var(--text-muted)', fontWeight: 600, letterSpacing: '0.02em' }}>JENIS KENDARAAN</div>
              <div style={{ fontSize: 15, fontWeight: 700, marginTop: 1 }}>Mobil Pribadi</div>
            </div>
            <button style={{ background: 'none', border: 'none', color: 'var(--primary)', fontSize: 12, fontWeight: 700, fontFamily: 'inherit' }}>Ubah</button>
          </div>
        </div>

        {/* Form */}
        <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 14 }}>
          <SectionLabel>Identitas Kendaraan</SectionLabel>
          <FormField label="Nama Panggilan" value="Brio Putih Andi" leading={<IcSpark size={18} sw={2}/>}/>
          <FormField label="Plat Nomor" value="B 1234 ABC" leading={<IcReceipt size={18} sw={2}/>}/>

          {/* Brand + Model side by side */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <FormField label="Merk" value="Honda" leading={<IcChevR size={16} sw={2}/>}/>
            <FormField label="Tipe / Model" value="Brio Satya"/>
          </div>

          {/* Year + color */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <FormField label="Tahun" value="2021"/>
            <FormField label="Warna" value="Putih Taffeta"/>
          </div>

          <SectionLabel style={{ marginTop: 8 }}>Spesifikasi</SectionLabel>

          {/* Fuel type chips */}
          <div>
            <label style={{ fontSize: 11.5, fontWeight: 600, color: 'var(--text-muted)', display: 'block', marginBottom: 8, letterSpacing: '0.02em' }}>Jenis Bahan Bakar</label>
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              <FuelChip label="Pertalite" active/>
              <FuelChip label="Pertamax"/>
              <FuelChip label="Pertamax Turbo"/>
              <FuelChip label="Solar"/>
              <FuelChip label="Listrik"/>
            </div>
          </div>

          <FormField label="Odometer Saat Ini" value="45.231 km" leading={<IcGauge size={18} sw={2}/>}/>
        </div>

        <div style={{ height: 110 }}/>
      </div>

      {/* Floating CTA */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0,
        background: 'linear-gradient(180deg, transparent 0%, var(--bg) 30%)',
        padding: '24px 20px 24px',
        display: 'flex', gap: 10,
      }}>
        <button className="kdr-btn ghost" style={{ flex: 1 }}>Kembali</button>
        <button className="kdr-btn primary" style={{ flex: 2 }}>Lanjut: Foto Kendaraan <IcChevR size={16} sw={2.4} stroke="white"/></button>
      </div>
    </div>
  );
}

function Step({ n, label, state }) {
  const isActive = state === 'active';
  const isDone   = state === 'done';
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
      <div style={{
        width: 28, height: 28, borderRadius: '50%',
        background: isDone ? 'var(--primary)' : isActive ? 'var(--primary)' : 'var(--surface)',
        color: isDone || isActive ? 'white' : 'var(--text-muted)',
        border: isActive || isDone ? 'none' : '1.5px solid var(--border)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 13, fontWeight: 700,
        boxShadow: isActive ? '0 0 0 4px var(--primary-soft)' : 'none',
      }}>{isDone ? <IcCheck size={14} stroke="white" sw={3}/> : n}</div>
      <div style={{
        fontSize: 11, fontWeight: 700,
        color: isActive || isDone ? 'var(--text)' : 'var(--text-soft)',
      }}>{label}</div>
    </div>
  );
}

function StepLine({ done }) {
  return (
    <div style={{
      flex: 1, height: 2, marginBottom: 18,
      background: done ? 'var(--primary)' : 'var(--border)',
      borderRadius: 1,
    }}/>
  );
}

function SectionLabel({ children, style }) {
  return (
    <div style={{
      fontSize: 11, fontWeight: 700, color: 'var(--text-muted)',
      letterSpacing: '0.04em', textTransform: 'uppercase',
      ...style,
    }}>{children}</div>
  );
}

function FuelChip({ label, active }) {
  return (
    <div style={{
      padding: '8px 14px', borderRadius: 100,
      background: active ? 'var(--primary)' : 'var(--surface)',
      color: active ? 'white' : 'var(--text)',
      border: active ? 'none' : '1.5px solid var(--border)',
      fontSize: 12.5, fontWeight: 600,
    }}>{label}</div>
  );
}

Object.assign(window, { AddVehicleScreen, Step, StepLine, SectionLabel, FuelChip });
