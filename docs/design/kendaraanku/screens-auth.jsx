// Auth screens: Splash, Onboarding, Login, Register, OTP

// ─── Splash ────────────────────────────────────────────────
function SplashScreen() {
  return (
    <div className="kdr kdr-scroll" style={{
      background: 'var(--hero-bg-vertical)',
      color: 'white',
      alignItems: 'center', justifyContent: 'center',
    }}>
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center', gap: 24,
        position: 'relative',
      }}>
        <div style={{
          position: 'absolute', right: -80, top: 80,
          width: 240, height: 240, borderRadius: '50%',
          background: 'rgba(255,255,255,0.10)',
        }}/>
        <div style={{
          position: 'absolute', left: -60, bottom: 120,
          width: 180, height: 180, borderRadius: '50%',
          background: 'rgba(255,255,255,0.08)',
        }}/>

        <div style={{
          width: 96, height: 96, borderRadius: 28,
          background: 'rgba(255,255,255,0.20)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          backdropFilter: 'blur(10px)',
          position: 'relative', zIndex: 2,
        }}>
          <IcCar size={50} sw={2} stroke="white"/>
        </div>
        <div style={{ textAlign: 'center', zIndex: 2, position: 'relative' }}>
          <h1 style={{ fontSize: 32, fontWeight: 800, letterSpacing: '-0.02em' }}>Kendaraanku</h1>
          <div style={{ fontSize: 13, opacity: 0.85, marginTop: 8, fontWeight: 500 }}>Semua tentang kendaraan, dalam genggaman</div>
        </div>
      </div>
      <div style={{ padding: '0 0 60px', display: 'flex', justifyContent: 'center', zIndex: 2 }}>
        <div style={{
          width: 40, height: 40, borderRadius: '50%',
          border: '3px solid rgba(255,255,255,0.25)',
          borderTopColor: 'white',
          animation: 'kdr-spin 1s linear infinite',
        }}/>
      </div>
      <style>{`@keyframes kdr-spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );
}

// ─── Onboarding ───────────────────────────────────────────
function OnboardingScreen() {
  return (
    <div className="kdr kdr-scroll" style={{ background: 'var(--bg)' }}>
      <div style={{ padding: '14px 20px 0', display: 'flex', justifyContent: 'flex-end' }}>
        <button style={{
          background: 'transparent', border: 'none',
          fontSize: 13, fontWeight: 600, color: 'var(--text-muted)',
          fontFamily: 'inherit',
        }}>Lewati</button>
      </div>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 24px' }}>
        {/* Big illustration card */}
        <div style={{
          width: '100%', maxWidth: 320, height: 280,
          background: 'var(--hero-bg-vertical)',
          borderRadius: 32,
          position: 'relative', overflow: 'hidden',
          display: 'flex', alignItems: 'flex-end', justifyContent: 'center',
          padding: '0 0 30px',
        }}>
          <div style={{
            position: 'absolute', right: -50, top: -50,
            width: 200, height: 200, borderRadius: '50%',
            background: 'rgba(255,255,255,0.15)',
          }}/>
          <div style={{
            position: 'absolute', left: -40, bottom: -40,
            width: 140, height: 140, borderRadius: '50%',
            background: 'rgba(255,255,255,0.10)',
          }}/>
          {/* floating chips */}
          <div style={{ position: 'absolute', top: 30, left: 24, background: 'rgba(255,255,255,0.95)', padding: '8px 12px', borderRadius: 12, display: 'flex', alignItems: 'center', gap: 6, boxShadow: '0 8px 20px rgba(0,0,0,0.10)' }}>
            <div style={{ width: 22, height: 22, borderRadius: 7, background: 'var(--tint-mint)', color: 'var(--on-tint-mint)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><IcWrench size={12} sw={2.4}/></div>
            <div>
              <div style={{ fontSize: 9, color: 'var(--text-muted)', fontWeight: 600 }}>SERVIS</div>
              <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--text)' }}>7 hari lagi</div>
            </div>
          </div>
          <div style={{ position: 'absolute', top: 90, right: 16, background: 'rgba(255,255,255,0.95)', padding: '8px 12px', borderRadius: 12, display: 'flex', alignItems: 'center', gap: 6, boxShadow: '0 8px 20px rgba(0,0,0,0.10)' }}>
            <div style={{ width: 22, height: 22, borderRadius: 7, background: 'var(--tint-amber)', color: 'var(--on-tint-amber)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><IcShield size={12} sw={2.4}/></div>
            <div>
              <div style={{ fontSize: 9, color: 'var(--text-muted)', fontWeight: 600 }}>PAJAK</div>
              <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--text)' }}>23 hari lagi</div>
            </div>
          </div>
          <VCar size={210}/>
        </div>

        <h1 style={{ fontSize: 24, fontWeight: 800, marginTop: 36, textAlign: 'center', letterSpacing: '-0.02em' }}>Lupa servis & pajak?<br/>Tenang, kami ingatkan.</h1>
        <p style={{ fontSize: 14, color: 'var(--text-muted)', marginTop: 12, textAlign: 'center', maxWidth: 280, lineHeight: 1.5 }}>
          Catat servis, BBM, dan dokumen dalam satu aplikasi. Dapatkan notifikasi otomatis sebelum jatuh tempo.
        </p>
      </div>

      {/* Dots */}
      <div style={{ display: 'flex', justifyContent: 'center', gap: 6, marginBottom: 20 }}>
        <span style={{ width: 24, height: 6, borderRadius: 3, background: 'var(--primary)' }}/>
        <span style={{ width: 6, height: 6, borderRadius: 3, background: 'var(--border)' }}/>
        <span style={{ width: 6, height: 6, borderRadius: 3, background: 'var(--border)' }}/>
      </div>

      <div style={{ padding: '0 20px 32px', display: 'flex', gap: 10 }}>
        <button className="kdr-btn ghost" style={{ flex: 1 }}>Kembali</button>
        <button className="kdr-btn primary" style={{ flex: 2 }}>Lanjut <IcChevR size={16} sw={2.4} stroke="white"/></button>
      </div>
    </div>
  );
}

// ─── Login ────────────────────────────────────────────────
function LoginScreen() {
  return (
    <div className="kdr kdr-scroll" style={{ background: 'var(--bg)' }}>
      <div className="kdr-body" style={{ padding: '8px 24px 0' }}>
        <button className="kdr-iconbtn" style={{ marginTop: 4 }}><IcBack size={20}/></button>

        <div style={{ marginTop: 28 }}>
          <div style={{
            width: 56, height: 56, borderRadius: 18,
            background: 'var(--primary-soft)', color: 'var(--primary)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}><IcCar size={28} sw={2}/></div>
          <h1 style={{ fontSize: 26, fontWeight: 800, marginTop: 20, letterSpacing: '-0.02em' }}>Halo, selamat datang kembali</h1>
          <p style={{ fontSize: 13, color: 'var(--text-muted)', marginTop: 8 }}>Masuk untuk melanjutkan mengelola kendaraan Anda.</p>
        </div>

        <div style={{ marginTop: 28, display: 'flex', flexDirection: 'column', gap: 14 }}>
          <FormField label="Email atau Nomor HP" value="andi.pratama@email.com" leading={<IcUser size={18} sw={2}/>}/>
          <FormField label="Kata Sandi" value="••••••••••" type="password" leading={<IcShield size={18} sw={2}/>} trailing="Lihat"/>
        </div>

        <button className="kdr-btn primary" style={{ marginTop: 24, width: '100%' }}>Masuk</button>

        <div style={{ textAlign: 'center', fontSize: 13, color: 'var(--text-muted)', marginTop: 24, paddingBottom: 20 }}>
          Belum punya akun? <span style={{ color: 'var(--primary)', fontWeight: 700 }}>Daftar sekarang</span>
        </div>
      </div>
    </div>
  );
}

// ─── Register ─────────────────────────────────────────────
function RegisterScreen() {
  return (
    <div className="kdr kdr-scroll" style={{ background: 'var(--bg)' }}>
      <div className="kdr-body" style={{ padding: '8px 24px 0' }}>
        <button className="kdr-iconbtn" style={{ marginTop: 4 }}><IcBack size={20}/></button>

        <div style={{ marginTop: 20 }}>
          <h1 style={{ fontSize: 26, fontWeight: 800, letterSpacing: '-0.02em' }}>Buat Akun Baru</h1>
          <p style={{ fontSize: 13, color: 'var(--text-muted)', marginTop: 6 }}>Hanya butuh 1 menit untuk mulai mencatat kendaraan Anda.</p>
        </div>

        <div style={{ marginTop: 24, display: 'flex', flexDirection: 'column', gap: 12 }}>
          <FormField label="Nama Lengkap" value="Andi Pratama" leading={<IcUser size={18} sw={2}/>}/>
          <FormField label="Email" value="andi.pratama@email.com" leading={<IcEmail/>}/>
          <FormField label="Kata Sandi" value="••••••••" type="password" leading={<IcShield size={18} sw={2}/>} trailing="Lihat"/>
          <FormField label="Konfirmasi Sandi" value="••••••••" type="password" leading={<IcShield size={18} sw={2}/>} trailing="Lihat"/>

          {/* password strength */}
          <div>
            <div style={{ display: 'flex', gap: 4 }}>
              <div style={{ flex: 1, height: 4, borderRadius: 2, background: 'var(--success)' }}/>
              <div style={{ flex: 1, height: 4, borderRadius: 2, background: 'var(--success)' }}/>
              <div style={{ flex: 1, height: 4, borderRadius: 2, background: 'var(--success)' }}/>
              <div style={{ flex: 1, height: 4, borderRadius: 2, background: 'var(--border)' }}/>
            </div>
            <div style={{ fontSize: 11, color: 'var(--success)', fontWeight: 700, marginTop: 6 }}>Kekuatan sandi: Kuat</div>
          </div>

          {/* Offline warning */}
          <div style={{
            display: 'flex', gap: 10, alignItems: 'flex-start',
            background: 'var(--tint-amber)', borderRadius: 12,
            padding: '12px 14px', marginTop: 4,
          }}>
            <div style={{
              width: 22, height: 22, borderRadius: 7, flexShrink: 0,
              background: 'rgba(255,255,255,0.6)', color: 'var(--on-tint-amber)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}><IcWarning size={13} sw={2.4}/></div>
            <div style={{ fontSize: 11.5, color: 'var(--on-tint-amber)', lineHeight: 1.5, fontWeight: 500 }}>
              <span style={{ fontWeight: 700 }}>Aplikasi ini bekerja offline.</span> Sandi tidak dapat dipulihkan jika lupa. Pastikan kamu mengingatnya baik-baik.
            </div>
          </div>
        </div>

        <label style={{ display: 'flex', alignItems: 'flex-start', gap: 10, fontSize: 12, color: 'var(--text-muted)', marginTop: 18, lineHeight: 1.5 }}>
          <span style={{
            width: 18, height: 18, borderRadius: 5, flexShrink: 0, marginTop: 1,
            background: 'var(--primary)',
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          }}><IcCheck size={12} stroke="white" sw={3}/></span>
          Saya menyetujui <span style={{ color: 'var(--primary)', fontWeight: 700 }}>Syarat & Ketentuan</span> dan <span style={{ color: 'var(--primary)', fontWeight: 700 }}>Kebijakan Privasi</span> Kendaraanku.
        </label>

        <button className="kdr-btn primary" style={{ marginTop: 22, width: '100%' }}>Daftar Sekarang</button>

        <div style={{ textAlign: 'center', fontSize: 13, color: 'var(--text-muted)', marginTop: 18, paddingBottom: 20 }}>
          Sudah punya akun? <span style={{ color: 'var(--primary)', fontWeight: 700 }}>Masuk</span>
        </div>
      </div>
    </div>
  );
}

// ─── OTP ──────────────────────────────────────────────────
function OtpScreen() {
  const digits = ['4', '8', '2', '6', '', ''];
  return (
    <div className="kdr kdr-scroll" style={{ background: 'var(--bg)' }}>
      <div className="kdr-body" style={{ padding: '8px 24px 0' }}>
        <button className="kdr-iconbtn" style={{ marginTop: 4 }}><IcBack size={20}/></button>

        <div style={{ marginTop: 32, textAlign: 'center' }}>
          <div style={{
            width: 72, height: 72, borderRadius: 22,
            background: 'var(--primary-soft)', color: 'var(--primary)',
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          }}><IcPhone size={32}/></div>
          <h1 style={{ fontSize: 24, fontWeight: 800, marginTop: 22, letterSpacing: '-0.02em' }}>Verifikasi Nomor HP</h1>
          <p style={{ fontSize: 13, color: 'var(--text-muted)', marginTop: 8, lineHeight: 1.5 }}>
            Kami mengirim kode 6-digit ke<br/>
            <span style={{ color: 'var(--text)', fontWeight: 700 }}>+62 812 •••• 7890</span>{' '}
            <span style={{ color: 'var(--primary)', fontWeight: 700 }}>Ubah</span>
          </p>
        </div>

        <div style={{ display: 'flex', gap: 10, justifyContent: 'center', marginTop: 32 }}>
          {digits.map((d, i) => (
            <div key={i} style={{
              width: 48, height: 56, borderRadius: 14,
              border: d ? '2px solid var(--primary)' : '1.5px solid var(--border)',
              background: 'var(--surface)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 24, fontWeight: 800, color: 'var(--text)',
              fontFamily: 'inherit',
              position: 'relative',
            }}>
              {d}
              {i === 4 && (
                <span style={{
                  position: 'absolute', width: 2, height: 26,
                  background: 'var(--primary)',
                  animation: 'kdr-blink 1s steps(2) infinite',
                }}/>
              )}
            </div>
          ))}
        </div>
        <style>{`@keyframes kdr-blink { to { opacity: 0; } }`}</style>

        <div style={{ textAlign: 'center', marginTop: 24, fontSize: 12, color: 'var(--text-muted)' }}>
          Belum dapat kode? <span style={{ color: 'var(--text-soft)' }}>Kirim ulang dalam</span> <span style={{ color: 'var(--primary)', fontWeight: 700 }}>00:42</span>
        </div>

        <button className="kdr-btn primary" style={{ marginTop: 32, width: '100%' }}>Verifikasi</button>
      </div>

      <FakeKeypad/>
    </div>
  );
}

// ─── Form field ───────────────────────────────────────────
function FormField({ label, value, type = 'text', leading, trailing }) {
  return (
    <div>
      <label style={{ fontSize: 11.5, fontWeight: 600, color: 'var(--text-muted)', display: 'block', marginBottom: 6, letterSpacing: '0.02em' }}>{label}</label>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10,
        background: 'var(--surface)', borderRadius: 14,
        border: '1.5px solid var(--border)',
        padding: '12px 14px',
      }}>
        {leading && <div style={{ color: 'var(--text-muted)' }}>{leading}</div>}
        <div style={{ flex: 1, fontSize: 14, fontWeight: 500, color: 'var(--text)' }}>{value}</div>
        {trailing && <span style={{ fontSize: 12, color: 'var(--primary)', fontWeight: 700 }}>{trailing}</span>}
      </div>
    </div>
  );
}

function SocialBtn({ label, icon }) {
  return (
    <button style={{
      background: 'var(--surface)', border: '1.5px solid var(--border)',
      borderRadius: 14, padding: '12px',
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      fontFamily: 'inherit', fontSize: 14, fontWeight: 600, color: 'var(--text)',
    }}>
      {icon}<span>{label}</span>
    </button>
  );
}

function GoogleG() {
  return (
    <svg width="18" height="18" viewBox="0 0 18 18">
      <path d="M17.64 9.2a10 10 0 0 0-.16-1.84H9v3.48h4.84a4.14 4.14 0 0 1-1.8 2.72v2.26h2.92a8.78 8.78 0 0 0 2.68-6.62z" fill="#4285F4"/>
      <path d="M9 18a8.6 8.6 0 0 0 5.96-2.18l-2.92-2.26a5.4 5.4 0 0 1-8.04-2.84H.96v2.32A9 9 0 0 0 9 18z" fill="#34A853"/>
      <path d="M3.96 10.72a5.4 5.4 0 0 1 0-3.44V4.96H.96a9 9 0 0 0 0 8.08l3-2.32z" fill="#FBBC05"/>
      <path d="M9 3.58a4.9 4.9 0 0 1 3.44 1.34l2.58-2.58A8.66 8.66 0 0 0 9 0 9 9 0 0 0 .96 4.96l3 2.32A5.4 5.4 0 0 1 9 3.58z" fill="#EA4335"/>
    </svg>
  );
}
function AppleG() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="#000">
      <path d="M16.7 12.7c0-2.5 2-3.6 2.1-3.7-1.1-1.6-2.9-1.9-3.5-1.9-1.5-.2-3 .9-3.7.9-.8 0-1.9-.9-3.2-.9-1.7 0-3.2 1-4 2.5-1.7 3-.4 7.3 1.2 9.7.8 1.2 1.8 2.5 3 2.4 1.2-.1 1.7-.8 3.2-.8 1.5 0 1.9.8 3.2.8 1.3 0 2.2-1.2 3-2.3.9-1.3 1.3-2.6 1.4-2.7-.1-.1-2.7-1-2.7-4zM14.4 5.6c.7-.9 1.2-2.1 1-3.4-1.1 0-2.3.7-3 1.5-.6.8-1.2 2.1-1 3.3 1.1 0 2.3-.6 3-1.4z"/>
    </svg>
  );
}
const IcEmail = (p) => <Ic {...p}><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></Ic>;
const IcPhone = (p) => <Ic {...p}><path d="M5 4h4l2 5-2.5 1.5a11 11 0 005 5L15 13l5 2v4a2 2 0 01-2 2A16 16 0 013 6a2 2 0 012-2z"/></Ic>;

function FakeKeypad() {
  const keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
  return (
    <div style={{ background: '#E4E7ED', padding: '10px 6px 22px' }}>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8 }}>
        {keys.map((k, i) => (
          <div key={i} style={{
            height: 44, borderRadius: 8,
            background: k && k !== '⌫' ? 'white' : (k === '⌫' ? 'transparent' : 'transparent'),
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 22, fontWeight: 500,
            boxShadow: k && k !== '⌫' ? '0 1px 0 rgba(0,0,0,0.18)' : 'none',
          }}>{k}</div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, {
  SplashScreen, OnboardingScreen, LoginScreen, RegisterScreen, OtpScreen,
  FormField, SocialBtn, FakeKeypad, IcEmail, IcPhone,
});
