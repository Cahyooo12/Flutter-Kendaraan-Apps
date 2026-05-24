// Screen 5 — Dokumen
const DOCS = [
  { id: 'stnk1', kind: 'STNK',  owner: 'Honda Brio Satya', sub: 'B 1234 ABC',  expiry: '09 Jun 2026', days: 23, status: 'warn',  icon: <IcReceipt size={22} sw={2}/>, tint: 'amber' },
  { id: 'stnk2', kind: 'STNK',  owner: 'Honda Vario 160',  sub: 'B 4567 XYZ',  expiry: '14 Mar 2027', days: 301, status: 'ok',  icon: <IcReceipt size={22} sw={2}/>, tint: 'mint' },
  { id: 'bpkb1', kind: 'BPKB',  owner: 'Honda Brio Satya', sub: 'No. M•••8423', expiry: 'Tidak berlaku', days: null, status: 'ok', icon: <IcShield size={22} sw={2}/>, tint: 'blue' },
  { id: 'sim',   kind: 'SIM A', owner: 'Andi Pratama',     sub: '317•••42201',  expiry: '22 Aug 2027', days: 462, status: 'ok',  icon: <IcUser size={22} sw={2}/>, tint: 'lavender' },
  { id: 'asur',  kind: 'Asuransi All Risk', owner: 'Honda Brio Satya', sub: 'Astra Buana · ABC-771', expiry: '01 Aug 2026', days: 76, status: 'ok', icon: <IcShield size={22} sw={2}/>, tint: 'mint' },
  { id: 'pajak', kind: 'PKB Tahunan', owner: 'Honda Vario 160',  sub: 'B 4567 XYZ', expiry: '05 Sep 2026', days: 111, status: 'ok',  icon: <IcReceipt size={22} sw={2}/>, tint: 'peach' },
];

function DocsScreen() {
  return (
    <div className="kdr kdr-scroll" style={{ position: 'relative' }}>
      <div className="kdr-appbar" style={{ padding: '14px 20px 8px' }}>
        <div style={{ flex: 1 }}>
          <h1 className="kdr-h1">Dokumen</h1>
          <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>6 dokumen aktif · 1 perlu diperbarui</div>
        </div>
        <button className="kdr-iconbtn"><IcSearch size={20}/></button>
      </div>

      <div className="kdr-body">
        {/* Urgent banner */}
        <div style={{ padding: '0 20px 14px' }}>
          <div style={{
            background: 'var(--tint-rose)',
            borderRadius: 'var(--r-lg)',
            padding: '14px 16px',
            display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <div style={{
              width: 40, height: 40, borderRadius: 12,
              background: 'rgba(255,255,255,0.55)',
              color: 'var(--on-tint-rose)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
            }}>
              <IcWarning size={20} sw={2}/>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--on-tint-rose)' }}>1 dokumen akan kadaluarsa</div>
              <div style={{ fontSize: 11.5, color: 'var(--on-tint-rose)', opacity: 0.85, marginTop: 1 }}>Pajak Tahunan Brio Satya dalam 23 hari</div>
            </div>
            <button style={{
              background: 'white', color: 'var(--on-tint-rose)',
              border: 'none', padding: '7px 12px', borderRadius: 100,
              fontSize: 11.5, fontWeight: 700, fontFamily: 'inherit',
            }}>Bayar</button>
          </div>
        </div>

        {/* Quick categories */}
        <div style={{ display: 'flex', gap: 8, padding: '0 20px 14px', overflowX: 'auto' }}>
          <div className="kdr-chip active">Semua · 6</div>
          <div className="kdr-chip">STNK</div>
          <div className="kdr-chip">BPKB</div>
          <div className="kdr-chip">SIM</div>
          <div className="kdr-chip">Asuransi</div>
        </div>

        {/* Document grid */}
        <div style={{
          padding: '0 20px',
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          gap: 10,
        }}>
          {DOCS.map(d => <DocCard key={d.id} d={d}/>)}
        </div>

        <div style={{ height: 120 }}/>
      </div>

      <button className="kdr-fab"><IcPlus size={20} stroke="white" sw={2.6}/>Tambah Dokumen</button>
      <BottomNav active="docs"/>
    </div>
  );
}

function DocCard({ d }) {
  const statusLabel = d.days === null ? 'Permanen'
    : d.days <= 30 ? `${d.days} hari lagi`
    : d.days <= 90 ? 'Akan habis'
    : 'Aktif';
  const statusClass = d.days === null ? 'ok'
    : d.days <= 30 ? 'due'
    : d.days <= 90 ? 'warn'
    : 'ok';

  return (
    <div className="kdr-card" style={{ padding: 14, display: 'flex', flexDirection: 'column', gap: 10 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <div className={`tint-${d.tint}`} style={{
          width: 44, height: 44, borderRadius: 12,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>{d.icon}</div>
        <div className={`kdr-status ${statusClass}`}><span className="dot"/>{statusLabel}</div>
      </div>
      <div style={{ minHeight: 56 }}>
        <div style={{ fontSize: 14, fontWeight: 700, letterSpacing: '-0.01em' }}>{d.kind}</div>
        <div style={{ fontSize: 11.5, color: 'var(--text-muted)', marginTop: 2 }}>{d.owner}</div>
        <div style={{ fontSize: 11, color: 'var(--text-soft)', marginTop: 1, fontFamily: d.sub.includes('•') ? 'ui-monospace, Menlo, monospace' : 'inherit' }}>{d.sub}</div>
      </div>
      <div style={{
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        paddingTop: 10, borderTop: '1px solid var(--divider)',
      }}>
        <div>
          <div style={{ fontSize: 9.5, color: 'var(--text-soft)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.04em' }}>Berlaku s/d</div>
          <div className="kdr-num" style={{ fontSize: 11.5, fontWeight: 700, marginTop: 2 }}>{d.expiry}</div>
        </div>
        <button style={{
          background: 'var(--primary-soft)', color: 'var(--primary-strong)',
          border: 'none', width: 30, height: 30, borderRadius: 10,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <IcChevR size={16} sw={2.2}/>
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { DocsScreen, DocCard });
