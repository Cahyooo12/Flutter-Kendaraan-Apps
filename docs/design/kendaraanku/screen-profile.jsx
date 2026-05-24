// Screen — Profil & Pengaturan
function ProfileScreen() {
  return (
    <div className="kdr kdr-scroll">
      <div className="kdr-body" style={{ padding: 0 }}>
        {/* Header */}
        <div style={{
          background: 'var(--hero-bg-vertical)',
          padding: '12px 20px 60px',
          position: 'relative', overflow: 'hidden',
          borderBottomLeftRadius: 28, borderBottomRightRadius: 28,
        }}>
          <div style={{ position: 'absolute', right: -60, top: -40, width: 220, height: 220, borderRadius: '50%', background: 'rgba(255,255,255,0.10)' }}/>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, color: 'white', position: 'relative', zIndex: 2 }}>
            <button className="kdr-iconbtn" style={{ background: 'rgba(255,255,255,0.2)', border: 'none', color: 'white' }}><IcBack size={20}/></button>
            <div style={{ flex: 1, textAlign: 'center', fontSize: 13, fontWeight: 600, opacity: 0.9 }}>Profil Saya</div>
            <button className="kdr-iconbtn" style={{ background: 'rgba(255,255,255,0.2)', border: 'none', color: 'white' }}><IcEdit size={18}/></button>
          </div>
        </div>

        {/* Profile card */}
        <div style={{ padding: '0 20px', marginTop: -42, position: 'relative', zIndex: 2 }}>
          <div className="kdr-card" style={{ padding: 18 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
              <div style={{
                width: 64, height: 64, borderRadius: 20,
                background: 'var(--primary-soft)', color: 'var(--primary-strong)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 22, fontWeight: 800,
                border: '3px solid var(--surface)',
                boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
              }}>AP</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 17, fontWeight: 800, letterSpacing: '-0.01em' }}>Andi Pratama</div>
                <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>andi.pratama@email.com</div>
                <div style={{ display: 'inline-flex', alignItems: 'center', gap: 4, marginTop: 6, padding: '2px 8px', background: 'var(--tint-amber)', color: 'var(--on-tint-amber)', borderRadius: 100, fontSize: 10, fontWeight: 700 }}>
                  <IcStar size={10} sw={2.4}/>Member Plus
                </div>
              </div>
            </div>

            <div style={{ display: 'flex', gap: 12, marginTop: 16, paddingTop: 16, borderTop: '1px solid var(--divider)' }}>
              <ProfileStat value="2" label="Kendaraan"/>
              <div style={{ width: 1, background: 'var(--divider)' }}/>
              <ProfileStat value="14" label="Servis"/>
              <div style={{ width: 1, background: 'var(--divider)' }}/>
              <ProfileStat value="6" label="Dokumen"/>
            </div>
          </div>
        </div>

        {/* Menu group: Akun */}
        <SettingsGroup title="Akun">
          <SettingsRow icon={<IcUser size={18} sw={2}/>}  tint="blue"     title="Informasi Pribadi" sub="Nama, email, nomor HP"/>
          <SettingsRow icon={<IcShield size={18} sw={2}/>} tint="mint"    title="Keamanan & Sandi" sub="Ubah sandi, biometrik"/>
          <SettingsRow icon={<IcCar size={18} sw={2}/>}    tint="peach"   title="Kelola Kendaraan" sub="2 kendaraan terdaftar"/>
        </SettingsGroup>

        {/* Menu group: Preferensi */}
        <SettingsGroup title="Preferensi">
          <SettingsRow icon={<IcBell size={18} sw={2}/>}     tint="rose"     title="Notifikasi" sub="Pengingat servis, pajak"  right={<Switch on/>}/>
          <SettingsRow icon={<IcSpark size={18} sw={2}/>}    tint="lavender" title="Tema & Tampilan" sub="Soft Blue · Mode Terang"/>
          <SettingsRow icon={<IcMapPin size={18} sw={2}/>}   tint="amber"    title="Bahasa" sub="Bahasa Indonesia"/>
        </SettingsGroup>

        {/* Menu group: Lainnya */}
        <SettingsGroup title="Lainnya">
          <SettingsRow icon={<IcDoc size={18} sw={2}/>}   tint="blue"  title="Bantuan & FAQ" sub="Panduan penggunaan aplikasi"/>
          <SettingsRow icon={<IcStar size={18} sw={2}/>}  tint="amber" title="Beri Rating" sub="Bantu kami berkembang"/>
          <SettingsRow icon={<IcDownload size={18} sw={2}/>} tint="mint" title="Ekspor Data" sub="Unduh riwayat (PDF/Excel)"/>
        </SettingsGroup>

        {/* Logout */}
        <div style={{ padding: '8px 20px 16px' }}>
          <button style={{
            width: '100%', background: 'var(--surface)',
            border: '1.5px solid var(--border)',
            borderRadius: 16, padding: 14,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            fontFamily: 'inherit', fontSize: 14, fontWeight: 700, color: 'var(--danger)',
          }}>
            Keluar dari Akun
          </button>
        </div>

        <div style={{ textAlign: 'center', fontSize: 11, color: 'var(--text-soft)', padding: '0 0 14px' }}>
          Kendaraanku v2.4.1 · Build 240518
        </div>
      </div>
      <BottomNav active="profile"/>
    </div>
  );
}

function ProfileStat({ value, label }) {
  return (
    <div style={{ flex: 1, textAlign: 'center' }}>
      <div className="kdr-num" style={{ fontSize: 18, fontWeight: 800, letterSpacing: '-0.02em' }}>{value}</div>
      <div style={{ fontSize: 11, color: 'var(--text-muted)', fontWeight: 500, marginTop: 2 }}>{label}</div>
    </div>
  );
}

function SettingsGroup({ title, children }) {
  return (
    <div style={{ padding: '18px 20px 0' }}>
      <div style={{
        fontSize: 11, fontWeight: 700, color: 'var(--text-muted)',
        letterSpacing: '0.04em', textTransform: 'uppercase',
        marginBottom: 10,
      }}>{title}</div>
      <div className="kdr-card" style={{ padding: 0 }}>
        {React.Children.map(children, (c, i) => (
          <React.Fragment>
            {i > 0 && <div className="kdr-divider" style={{ marginLeft: 60 }}/>}
            {c}
          </React.Fragment>
        ))}
      </div>
    </div>
  );
}

function SettingsRow({ icon, tint, title, sub, right }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: 14 }}>
      <div className={`tint-${tint}`} style={{
        width: 36, height: 36, borderRadius: 10,
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}>{icon}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 13.5, fontWeight: 600 }}>{title}</div>
        {sub && <div style={{ fontSize: 11.5, color: 'var(--text-muted)', marginTop: 1 }}>{sub}</div>}
      </div>
      {right || <IcChevR size={16} sw={2} stroke="var(--text-soft)"/>}
    </div>
  );
}

function Switch({ on }) {
  return (
    <div style={{
      width: 40, height: 24, borderRadius: 100,
      background: on ? 'var(--primary)' : 'var(--border)',
      position: 'relative', flexShrink: 0,
    }}>
      <div style={{
        position: 'absolute', top: 2, left: on ? 18 : 2,
        width: 20, height: 20, borderRadius: '50%',
        background: 'white',
        boxShadow: '0 2px 4px rgba(0,0,0,0.2)',
        transition: 'left 0.2s',
      }}/>
    </div>
  );
}

Object.assign(window, { ProfileScreen, ProfileStat, SettingsGroup, SettingsRow, Switch });
