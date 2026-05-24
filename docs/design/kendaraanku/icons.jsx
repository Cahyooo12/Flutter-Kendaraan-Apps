// Icons.jsx — stroke-style icons for Kendaraanku
const Ic = ({ children, size = 22, stroke = 'currentColor', fill = 'none', sw = 1.8 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke={stroke}
       strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">{children}</svg>
);

const IcBell = (p) => <Ic {...p}><path d="M6 8a6 6 0 0112 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 003.4 0"/></Ic>;
const IcBack = (p) => <Ic {...p}><path d="M15 18l-6-6 6-6"/></Ic>;
const IcMore = (p) => <Ic {...p}><circle cx="5" cy="12" r="1.2" fill="currentColor"/><circle cx="12" cy="12" r="1.2" fill="currentColor"/><circle cx="19" cy="12" r="1.2" fill="currentColor"/></Ic>;
const IcEdit = (p) => <Ic {...p}><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 113 3L7 19l-4 1 1-4z"/></Ic>;
const IcFilter = (p) => <Ic {...p}><path d="M3 6h18M6 12h12M10 18h4"/></Ic>;
const IcPlus = (p) => <Ic {...p}><path d="M12 5v14M5 12h14"/></Ic>;
const IcChevR = (p) => <Ic {...p}><path d="M9 6l6 6-6 6"/></Ic>;
const IcSearch = (p) => <Ic {...p}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4-4"/></Ic>;
const IcHome = (p) => <Ic {...p}><path d="M3 11l9-8 9 8v10a2 2 0 01-2 2h-4v-7h-6v7H5a2 2 0 01-2-2z"/></Ic>;
const IcClock = (p) => <Ic {...p}><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></Ic>;
const IcDoc = (p) => <Ic {...p}><path d="M14 3H6a2 2 0 00-2 2v14a2 2 0 002 2h12a2 2 0 002-2V9z"/><path d="M14 3v6h6"/></Ic>;
const IcUser = (p) => <Ic {...p}><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 3.6-7 8-7s8 3 8 7"/></Ic>;
const IcCar = (p) => <Ic {...p}><path d="M5 17h14v-3l-2-5a2 2 0 00-1.9-1.4H8.9A2 2 0 007 9l-2 5z"/><circle cx="7.5" cy="17.5" r="1.5"/><circle cx="16.5" cy="17.5" r="1.5"/></Ic>;
const IcBike = (p) => <Ic {...p}><circle cx="5.5" cy="17.5" r="3.5"/><circle cx="18.5" cy="17.5" r="3.5"/><path d="M15 6h3l-2 5h-5l-2-3H6"/><path d="M11 11l-5 6.5"/></Ic>;
const IcFuel = (p) => <Ic {...p}><path d="M3 22V4a1 1 0 011-1h9a1 1 0 011 1v18"/><path d="M3 14h11"/><path d="M14 8h2a2 2 0 012 2v6a2 2 0 002 2v-9l-2-2"/></Ic>;
const IcWrench = (p) => <Ic {...p}><path d="M14.7 6.3a4 4 0 105.3 5.3L21 14l-7 7-2.4-1-1 1-4-4 1-1L7 14l7-7z"/></Ic>;
const IcShield = (p) => <Ic {...p}><path d="M12 2l8 3v6c0 5-3.5 9.5-8 11-4.5-1.5-8-6-8-11V5z"/></Ic>;
const IcReceipt = (p) => <Ic {...p}><path d="M5 3h14v18l-3-2-3 2-3-2-3 2-2-2z"/><path d="M9 8h6M9 12h6M9 16h4"/></Ic>;
const IcCalendar = (p) => <Ic {...p}><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 10h18"/></Ic>;
const IcSpark = (p) => <Ic {...p}><path d="M13 2L4 14h7l-1 8 9-12h-7z"/></Ic>;
const IcRupiah = (p) => <Ic {...p}><path d="M7 4h6a4 4 0 010 8H7zM7 12h5M7 4v16"/></Ic>;
const IcGauge = (p) => <Ic {...p}><path d="M12 14l4-4"/><path d="M3.5 14a9 9 0 1117 0"/></Ic>;
const IcStar = (p) => <Ic {...p}><path d="M12 3l2.7 6 6.3.6-4.8 4.2 1.5 6.2L12 17l-5.7 3 1.5-6.2L3 9.6 9.3 9z"/></Ic>;
const IcDownload = (p) => <Ic {...p}><path d="M12 4v12M6 10l6 6 6-6M4 20h16"/></Ic>;
const IcMapPin = (p) => <Ic {...p}><path d="M12 21s-7-7-7-12a7 7 0 0114 0c0 5-7 12-7 12z"/><circle cx="12" cy="9" r="2.5"/></Ic>;
const IcCheck = (p) => <Ic {...p}><path d="M4 12l5 5L20 6"/></Ic>;
const IcWarning = (p) => <Ic {...p}><path d="M12 3l10 18H2z"/><path d="M12 10v5M12 18v.5"/></Ic>;

// Vehicle illustrations — playful flat shapes (cars / motors from side)
const VCar = ({ size = 120, color = 'rgba(255,255,255,0.92)', shadow = 'rgba(0,0,0,0.15)' }) => (
  <svg width={size} height={size * 0.6} viewBox="0 0 200 120" fill="none">
    {/* shadow */}
    <ellipse cx="100" cy="106" rx="80" ry="6" fill={shadow}/>
    {/* body */}
    <path d="M20 80 Q22 60 40 56 L70 36 Q78 30 90 30 L130 30 Q142 30 150 38 L172 56 Q188 60 188 78 L188 90 Q188 96 182 96 L160 96 A14 14 0 1 0 132 96 L76 96 A14 14 0 1 0 48 96 L26 96 Q20 96 20 90 Z" fill={color}/>
    {/* windows */}
    <path d="M78 42 Q82 38 90 38 L122 38 Q130 38 136 44 L148 54 L80 54 Z" fill="rgba(0,0,0,0.18)"/>
    <path d="M105 38 L105 54" stroke="rgba(255,255,255,0.4)" strokeWidth="1.5"/>
    {/* headlight */}
    <rect x="172" y="64" width="14" height="6" rx="2" fill="rgba(255,220,140,0.9)"/>
    {/* wheels */}
    <circle cx="62" cy="96" r="14" fill="#1a1a2e"/>
    <circle cx="62" cy="96" r="6" fill="#4a4a6a"/>
    <circle cx="146" cy="96" r="14" fill="#1a1a2e"/>
    <circle cx="146" cy="96" r="6" fill="#4a4a6a"/>
  </svg>
);

const VBike = ({ size = 120, color = 'rgba(255,255,255,0.92)', shadow = 'rgba(0,0,0,0.15)' }) => (
  <svg width={size} height={size * 0.6} viewBox="0 0 200 120" fill="none">
    <ellipse cx="100" cy="106" rx="76" ry="6" fill={shadow}/>
    {/* body */}
    <path d="M50 80 L80 56 L130 56 L150 76 L150 88 L60 88 Z" fill={color}/>
    {/* seat */}
    <path d="M70 56 L100 50 L120 50 L120 60 L70 64 Z" fill="#1a1a2e"/>
    {/* handlebar */}
    <path d="M138 50 L150 40 L162 42" stroke={color} strokeWidth="6" strokeLinecap="round"/>
    {/* headlight */}
    <path d="M150 56 L168 60 L168 72 L150 76 Z" fill="rgba(255,220,140,0.9)"/>
    {/* wheels */}
    <circle cx="56" cy="96" r="16" fill="#1a1a2e"/>
    <circle cx="56" cy="96" r="6" fill="#4a4a6a"/>
    <circle cx="150" cy="96" r="16" fill="#1a1a2e"/>
    <circle cx="150" cy="96" r="6" fill="#4a4a6a"/>
  </svg>
);

Object.assign(window, {
  Ic, IcBell, IcBack, IcMore, IcEdit, IcFilter, IcPlus, IcChevR, IcSearch,
  IcHome, IcClock, IcDoc, IcUser, IcCar, IcBike, IcFuel, IcWrench, IcShield,
  IcReceipt, IcCalendar, IcSpark, IcRupiah, IcGauge, IcStar, IcDownload, IcMapPin, IcCheck, IcWarning,
  VCar, VBike,
});
