// Screen — Notifikasi
const NOTIFICATIONS = [
  { date: 'Hari ini', items: [
    { id: 1, tint: 'rose',     icon: <IcWrench size={18} sw={2}/>, urgent: true,
      title: 'Servis 50.000 km segera!', body: 'Honda Brio Satya · sisa 760 km. Booking servis untuk menghindari biaya tambahan.', time: '08:32', unread: true },
    { id: 2, tint: 'amber',    icon: <IcShield size={18} sw={2}/>,
      title: 'Pajak STNK 23 hari lagi', body: 'B 1234 ABC · Rp 2.150.000. Bayar online lebih cepat lewat aplikasi.', time: '07:00', unread: true },
  ]},
  { date: 'Kemarin', items: [
    { id: 3, tint: 'mint',  icon: <IcCheck size={18} sw={2}/>,
      title: 'Catatan BBM berhasil disimpan', body: 'Shell Antasari · 32,5 L · Rp 525.000. Konsumsi BBM 13,8 km/L.', time: '14:18' },
    { id: 4, tint: 'lavender', icon: <IcSpark size={18} sw={2}/>,
      title: 'Tips: Ganti oli setiap 5.000 km', body: 'Perawatan rutin mesin agar performa tetap optimal.', time: '10:02' },
  ]},
  { date: 'Senin, 12 Mei 2026', items: [
    { id: 5, tint: 'peach', icon: <IcFuel size={18} sw={2}/>,
      title: 'Konsumsi BBM bulan ini hemat 12%', body: 'Lanjutkan pola berkendara hemat untuk capaian lebih baik.', time: '20:45' },
    { id: 6, tint: 'blue',  icon: <IcReceipt size={18} sw={2}/>,
      title: 'Servis tercatat — AHASS Bintaro', body: 'Ganti oli & filter · Rp 285.000 telah ditambahkan ke riwayat.', time: '11:30' },
  ]},
];

function NotificationsScreen() {
  return (
    <div className="kdr kdr-scroll">
      <div className="kdr-appbar" style={{ padding: '14px 20px 8px' }}>
        <button className="kdr-iconbtn"><IcBack size={20}/></button>
        <div style={{ flex: 1 }}>
          <h1 className="kdr-h1">Notifikasi</h1>
          <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 1 }}>2 belum dibaca</div>
        </div>
        <button className="kdr-iconbtn"><IcCheck size={20}/></button>
      </div>

      <div className="kdr-body">
        {/* Filter chips */}
        <div style={{ display: 'flex', gap: 8, padding: '4px 20px 16px', overflowX: 'auto' }}>
          <div className="kdr-chip active">Semua · 6</div>
          <div className="kdr-chip">Pengingat <span style={{ marginLeft: 4, background: 'var(--danger)', color: 'white', padding: '0 5px', borderRadius: 100, fontSize: 10 }}>2</span></div>
          <div className="kdr-chip">Aktivitas</div>
          <div className="kdr-chip">Tips</div>
        </div>

        {NOTIFICATIONS.map(group => (
          <div key={group.date} style={{ marginBottom: 16 }}>
            <div style={{
              fontSize: 11, fontWeight: 700, color: 'var(--text-muted)',
              letterSpacing: '0.04em', textTransform: 'uppercase',
              padding: '0 20px', marginBottom: 8,
            }}>{group.date}</div>
            <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 8 }}>
              {group.items.map(n => <NotifCard key={n.id} n={n}/>)}
            </div>
          </div>
        ))}

        <div style={{ height: 20 }}/>
      </div>
    </div>
  );
}

function NotifCard({ n }) {
  return (
    <div className="kdr-card" style={{
      padding: 14,
      borderColor: n.unread ? 'var(--primary-soft)' : 'var(--border)',
      background: n.unread ? 'var(--primary-softer)' : 'var(--surface)',
      position: 'relative',
    }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
        <div className={`tint-${n.tint}`} style={{
          width: 38, height: 38, borderRadius: 11,
          display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
        }}>{n.icon}</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8 }}>
            <div style={{ fontSize: 13.5, fontWeight: 700, letterSpacing: '-0.01em', display: 'flex', alignItems: 'center', gap: 6 }}>
              {n.title}
              {n.urgent && <span style={{ background: 'var(--danger)', color: 'white', padding: '1px 6px', borderRadius: 6, fontSize: 9, fontWeight: 800, letterSpacing: '0.04em' }}>URGEN</span>}
            </div>
            <div style={{ fontSize: 10.5, color: 'var(--text-soft)', whiteSpace: 'nowrap', fontWeight: 600 }}>{n.time}</div>
          </div>
          <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 4, lineHeight: 1.45 }}>{n.body}</div>
          {n.urgent && (
            <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
              <button className="kdr-btn primary" style={{ padding: '7px 14px', fontSize: 12 }}>Booking Sekarang</button>
              <button className="kdr-btn ghost" style={{ padding: '7px 14px', fontSize: 12 }}>Nanti</button>
            </div>
          )}
        </div>
      </div>
      {n.unread && (
        <span style={{
          position: 'absolute', top: 14, right: 14,
          width: 8, height: 8, borderRadius: '50%',
          background: 'var(--primary)',
        }}/>
      )}
    </div>
  );
}

Object.assign(window, { NotificationsScreen, NotifCard });
