// app.jsx — Main app: design canvas with 5 screens + Tweaks panel for theme

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "theme": "blue",
  "showFrame": true
}/*EDITMODE-END*/;

const THEMES = [
  { id: 'blue',     label: 'Soft Blue',     swatch: ['#3D6BF5', '#E8EEFE', '#F2F5FF'] },
  { id: 'mint',     label: 'Soft Mint',     swatch: ['#1F8F66', '#DEF2E8', '#EEFBF4'] },
  { id: 'peach',    label: 'Soft Peach',    swatch: ['#E36B33', '#FCE3D2', '#FFF3EA'] },
  { id: 'lavender', label: 'Soft Lavender', swatch: ['#6B49C8', '#E5DDF7', '#F2EEFB'] },
];

function ThemeSwatchPicker({ value, onChange }) {
  return (
    <div>
      <div style={{
        fontSize: 11, fontWeight: 600, color: '#9CA0A8',
        textTransform: 'uppercase', letterSpacing: '0.04em',
        marginBottom: 10,
      }}>Palette</div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
        {THEMES.map(th => {
          const active = th.id === value;
          return (
            <button
              key={th.id}
              onClick={() => onChange(th.id)}
              style={{
                background: '#fff', cursor: 'pointer',
                border: active ? `2px solid ${th.swatch[0]}` : '1px solid #E5E9F2',
                borderRadius: 12, padding: '10px 10px',
                display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 8,
                fontFamily: 'inherit', textAlign: 'left',
                boxShadow: active ? '0 4px 12px rgba(0,0,0,0.06)' : 'none',
              }}
            >
              <div style={{ display: 'flex', gap: 4 }}>
                <div style={{ width: 22, height: 22, borderRadius: 6, background: th.swatch[0] }}/>
                <div style={{ width: 14, height: 22, borderRadius: 6, background: th.swatch[1] }}/>
                <div style={{ width: 10, height: 22, borderRadius: 6, background: th.swatch[2], border: '1px solid #E5E9F2' }}/>
              </div>
              <div style={{ fontSize: 12, fontWeight: 600, color: '#0F1B33' }}>{th.label}</div>
            </button>
          );
        })}
      </div>
    </div>
  );
}

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);

  React.useEffect(() => {
    const root = document.documentElement;
    if (t.theme === 'blue') root.removeAttribute('data-theme');
    else root.setAttribute('data-theme', t.theme);
  }, [t.theme]);

  const auth = [
    { id: 'splash',    label: '00 · Splash',      el: <SplashScreen/>,
      statusBarBg: 'var(--hero-top)', statusBarDark: true,
      gestureNavBg: 'transparent',    gestureNavDark: true },
    { id: 'onboard',   label: '01 · Onboarding',  el: <OnboardingScreen/>,
      statusBarBg: 'var(--bg)',    statusBarDark: false,
      gestureNavBg: 'var(--bg)',   gestureNavDark: false },
    { id: 'login',     label: '02 · Login',       el: <LoginScreen/>,
      statusBarBg: 'var(--bg)',    statusBarDark: false,
      gestureNavBg: 'var(--bg)',   gestureNavDark: false },
    { id: 'register',  label: '03 · Register',    el: <RegisterScreen/>,
      statusBarBg: 'var(--bg)',    statusBarDark: false,
      gestureNavBg: 'var(--bg)',   gestureNavDark: false },
  ];

  const main = [
    { id: 'home',    label: '01 · Beranda',          el: <HomeScreen/>,
      statusBarBg: 'var(--bg)',    statusBarDark: false,
      gestureNavBg: 'var(--surface)', gestureNavDark: false },
    { id: 'detail',  label: '02 · Detail Kendaraan', el: <DetailScreen/>,
      statusBarBg: 'var(--hero-top)', statusBarDark: true,
      gestureNavBg: 'var(--surface)', gestureNavDark: false },
    { id: 'service', label: '03 · Riwayat Servis',   el: <ServiceScreen/>,
      statusBarBg: 'var(--bg)',    statusBarDark: false,
      gestureNavBg: 'var(--surface)', gestureNavDark: false },
    { id: 'fuel',    label: '04 · Catatan BBM',      el: <FuelScreen/>,
      statusBarBg: 'var(--bg)',    statusBarDark: false,
      gestureNavBg: 'var(--surface)', gestureNavDark: false },
    { id: 'docs',    label: '05 · Dokumen',          el: <DocsScreen/>,
      statusBarBg: 'var(--bg)',    statusBarDark: false,
      gestureNavBg: 'var(--surface)', gestureNavDark: false },
  ];

  const extras = [
    { id: 'profile', label: '01 · Profil & Pengaturan', el: <ProfileScreen/>,
      statusBarBg: 'var(--hero-top)', statusBarDark: true,
      gestureNavBg: 'var(--surface)', gestureNavDark: false },
    { id: 'notif',   label: '02 · Notifikasi',     el: <NotificationsScreen/>,
      statusBarBg: 'var(--bg)',    statusBarDark: false,
      gestureNavBg: 'var(--bg)',   gestureNavDark: false },
    { id: 'addvh',   label: '03 · Tambah Kendaraan', el: <AddVehicleScreen/>,
      statusBarBg: 'var(--bg)',    statusBarDark: false,
      gestureNavBg: 'var(--bg)',   gestureNavDark: false },
  ];

  const FRAME_W = 412, FRAME_H = 892;
  const ART_W = t.showFrame ? FRAME_W + 16 : FRAME_W;
  const ART_H = t.showFrame ? FRAME_H + 16 : FRAME_H;

  const renderArtboard = (s) => (
    <DCArtboard key={s.id} id={s.id} label={s.label} width={ART_W} height={ART_H}>
      <div data-screen-label={s.label} style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {t.showFrame ? (
          <AndroidDevice
            width={FRAME_W} height={FRAME_H}
            bg="var(--bg)"
            statusBarBg={s.statusBarBg}
            statusBarDark={s.statusBarDark}
            gestureNavBg={s.gestureNavBg}
            gestureNavDark={s.gestureNavDark}
          >
            {s.el}
          </AndroidDevice>
        ) : (
          <div style={{
            width: FRAME_W, height: FRAME_H,
            borderRadius: 18, overflow: 'hidden',
            border: '1px solid var(--border)',
            background: 'var(--surface)',
            boxShadow: '0 14px 32px rgba(15,27,51,0.10), 0 4px 10px rgba(15,27,51,0.05)',
          }}>{s.el}</div>
        )}
      </div>
    </DCArtboard>
  );

  return (
    <React.Fragment>
      <DesignCanvas>
        <DCSection id="main" title="Layar Utama" subtitle="5 layar inti aplikasi setelah login">
          {main.map(renderArtboard)}
        </DCSection>
        <DCSection id="auth" title="Onboarding & Autentikasi" subtitle="Splash → Onboarding → Login / Register → OTP">
          {auth.map(renderArtboard)}
        </DCSection>
        <DCSection id="extras" title="Profil, Notifikasi & Form" subtitle="Halaman pendukung yang melengkapi alur utama">
          {extras.map(renderArtboard)}
        </DCSection>
      </DesignCanvas>

      <TweaksPanel title="Tweaks">
        <TweakSection label="Tema Warna">
          <ThemeSwatchPicker value={t.theme} onChange={(v) => setTweak('theme', v)}/>
        </TweakSection>
        <TweakSection label="Tampilan">
          <TweakToggle label="Device Frame Android" value={t.showFrame} onChange={(v) => setTweak('showFrame', v)}/>
        </TweakSection>
      </TweaksPanel>
    </React.Fragment>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
