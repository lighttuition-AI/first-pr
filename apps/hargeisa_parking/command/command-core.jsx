/* global React */
/* HPark Command — shared: icon, data, sidebar, topbar, primitives */
const { useState: useStateCC, useEffect: useEffectCC, useRef: useRefCC } = React;

const CIcon = ({ name, size = 20, color, style }) => (
  <i data-lucide={name} style={{ width: size, height: size, color, display: 'inline-flex', flexShrink: 0, ...style }} />
);

const cMoney = (n) => 'SLSH ' + n.toLocaleString('en-US');

/* ---- Data ---------------------------------------------------------------- */
const C_NAV = [
  ['Dashboard', 'layout-dashboard'],
  ['Live map', 'map'],
  ['Officers', 'shield'],
  ['Zones', 'layers'],
  ['Vehicles', 'car'],
  ['Appeals', 'gavel'],
  ['Reports', 'bar-chart-3'],
];

const C_OFFICERS = [
  { id: 'OFR-118', name: 'Hodan Ali',       district: 'Mohamed Mooge',   status: 'patrol',  today: 14, revenue: 1480000, perf: 96 },
  { id: 'OFR-204', name: 'Yusuf Jama',      district: 'Ahmed Dhagah',    status: 'patrol',  today: 11, revenue: 1120000, perf: 91 },
  { id: 'OFR-091', name: 'Sagal Omar',      district: '26 June',         status: 'patrol',  today: 9,  revenue: 880000,  perf: 88 },
  { id: 'OFR-156', name: 'Abdi Warsame',    district: 'Gacan Libaax',    status: 'break',   today: 7,  revenue: 640000,  perf: 79 },
  { id: 'OFR-233', name: 'Naima Farah',     district: 'Ibrahim Koodbuur', status: 'patrol', today: 12, revenue: 1260000, perf: 93 },
  { id: 'OFR-177', name: 'Khadar Ismail',   district: '31 May',          status: 'offline', today: 4,  revenue: 320000,  perf: 64 },
  { id: 'OFR-142', name: 'Ayan Mohamed',    district: 'Maxamuud Haybe',  status: 'patrol',  today: 8,  revenue: 760000,  perf: 84 },
  { id: 'OFR-209', name: 'Liban Aden',      district: 'Macalin Haroon',  status: 'break',   today: 6,  revenue: 540000,  perf: 76 },
];

const C_ZONES = [
  { zone: 'Z1', name: '26 June',          compliance: 91, revenue: 5200000, occupancy: 82, officers: 3 },
  { zone: 'Z2', name: 'Mohamed Mooge',    compliance: 87, revenue: 6800000, occupancy: 94, officers: 4 },
  { zone: 'Z3', name: '31 May',           compliance: 73, revenue: 2100000, occupancy: 61, officers: 2 },
  { zone: 'Z4', name: 'Ahmed Dhagah',     compliance: 89, revenue: 4400000, occupancy: 88, officers: 3 },
  { zone: 'Z5', name: 'Gacan Libaax',     compliance: 95, revenue: 3100000, occupancy: 54, officers: 2 },
  { zone: 'Z6', name: 'Ibrahim Koodbuur', compliance: 84, revenue: 3900000, occupancy: 77, officers: 3 },
  { zone: 'Z7', name: 'Maxamuud Haybe',   compliance: 92, revenue: 2700000, occupancy: 49, officers: 2 },
  { zone: 'Z8', name: 'Mohamoud Haibe',   compliance: 81, revenue: 2200000, occupancy: 66, officers: 2 },
  { zone: 'Z9', name: 'Macalin Haroon',   compliance: 78, revenue: 1900000, occupancy: 71, officers: 2 },
];

const C_RECENT = [
  ['CIT-2026-04823', 'HG-4821', 'overdue', 'No valid permit', 'Mohamed Mooge', '2m'],
  ['CIT-2026-04822', 'SL-09122', 'active', 'Expired meter', 'Ahmed Dhagah', '6m'],
  ['CIT-2026-04821', 'HG-2210', 'review', 'Disabled bay', '26 June', '14m'],
  ['CIT-2026-04820', 'HG-7741', 'active', 'Double parking', 'Gacan Libaax', '22m'],
  ['CIT-2026-04819', 'SL-04412', 'paid', 'Loading zone', 'Ibrahim Koodbuur', '31m'],
];

const C_APPEALS = [
  { id: 'CIT-2026-02871', plate: 'SL-09122', reason: 'Loading zone',   fine: 100000, by: 'Amina Yusuf', when: '1h ago', video: true },
  { id: 'CIT-2026-02844', plate: 'HG-3320',  reason: 'Expired meter',  fine: 80000,  by: 'Omar Said',   when: '3h ago', video: true },
  { id: 'CIT-2026-02790', plate: 'HG-1180',  reason: 'No valid permit', fine: 150000, by: 'Hani Abdi',  when: '5h ago', video: false },
];

/* ---- Sidebar ------------------------------------------------------------- */
function Sidebar({ active, onNav }) {
  return (
    <aside style={{ width: 'var(--sidebar-w)', flexShrink: 0, height: '100%', background: 'var(--hp-bg)', borderRight: '1px solid var(--hp-border)', display: 'flex', flexDirection: 'column', padding: '20px 14px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 11, padding: '4px 8px 22px' }}>
        <img src="assets/logo-mark.svg" width="32" height="32" alt="" />
        <div style={{ lineHeight: 1.15 }}>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 15, color: 'var(--hp-text)', whiteSpace: 'nowrap' }}>Hargeisa Parking</div>
          <div style={{ fontFamily: 'var(--font-mono)', fontSize: 10.5, letterSpacing: '0.08em', color: 'var(--hp-text-muted)', textTransform: 'uppercase' }}>Command</div>
        </div>
      </div>
      <nav style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        {C_NAV.map(([label, icon]) => {
          const on = active === label;
          return (
            <button key={label} onClick={() => onNav(label)} style={{
              display: 'flex', alignItems: 'center', gap: 11, width: '100%', padding: '10px 12px', borderRadius: 'var(--radius-md)',
              border: '1px solid transparent', cursor: 'pointer', textAlign: 'left',
              background: on ? 'var(--hp-purple-tint)' : 'transparent', borderColor: on ? 'rgba(124,108,248,0.35)' : 'transparent',
              color: on ? '#fff' : 'var(--hp-text-2)', fontFamily: 'var(--font-body)', fontSize: 14, fontWeight: on ? 600 : 500, transition: 'background .12s, color .12s',
            }}
            onMouseEnter={(e) => { if (!on) { e.currentTarget.style.background = 'var(--hp-overlay)'; e.currentTarget.style.color = 'var(--hp-text)'; } }}
            onMouseLeave={(e) => { if (!on) { e.currentTarget.style.background = 'transparent'; e.currentTarget.style.color = 'var(--hp-text-2)'; } }}>
              <CIcon name={icon} size={18} color={on ? 'var(--hp-purple-300)' : 'currentColor'} />
              {label}
            </button>
          );
        })}
      </nav>
      <div style={{ marginTop: 'auto', display: 'flex', alignItems: 'center', gap: 10, padding: '12px 8px', borderTop: '1px solid var(--hp-border)' }}>
        <div style={{ width: 34, height: 34, borderRadius: '50%', background: 'var(--hp-gradient)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 700, fontSize: 13 }}>NW</div>
        <div style={{ lineHeight: 1.25, minWidth: 0 }}>
          <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--hp-text)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>Naima Warsame</div>
          <div style={{ fontSize: 11, color: 'var(--hp-text-muted)' }}>Operations lead</div>
        </div>
      </div>
    </aside>
  );
}

/* ---- Topbar -------------------------------------------------------------- */
function Topbar({ title, sub }) {
  return (
    <div style={{ height: 'var(--topbar-h)', flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 28px', borderBottom: '1px solid var(--hp-border)', background: 'rgba(10,10,15,0.7)', backdropFilter: 'var(--blur-bg)', position: 'sticky', top: 0, zIndex: 10 }}>
      <div>
        <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 20, color: '#fff', whiteSpace: 'nowrap' }}>{title}</div>
        {sub && <div style={{ fontSize: 12.5, color: 'var(--hp-text-muted)', whiteSpace: 'nowrap' }}>{sub}</div>}
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, height: 40, padding: '0 14px', borderRadius: 'var(--radius-md)', background: 'var(--hp-overlay)', border: '1px solid var(--hp-border)', color: 'var(--hp-text-muted)', fontSize: 13.5, minWidth: 220 }}>
          <CIcon name="search" size={16} /> Search plate, citation, officer…
        </div>
        <button style={{ width: 40, height: 40, borderRadius: 'var(--radius-md)', background: 'var(--hp-overlay)', border: '1px solid var(--hp-border)', color: 'var(--hp-text-2)', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', position: 'relative' }}>
          <CIcon name="bell" size={18} />
          <span style={{ position: 'absolute', top: 9, right: 10, width: 7, height: 7, borderRadius: '50%', background: 'var(--hp-danger)', border: '2px solid var(--hp-bg)' }} />
        </button>
        <div style={{ display: 'flex', alignItems: 'center', gap: 7, height: 40, padding: '0 12px', borderRadius: 'var(--radius-pill)', background: 'var(--hp-success-tint)', border: '1px solid rgba(0,200,83,0.3)' }}>
          <span style={{ width: 8, height: 8, borderRadius: '50%', background: 'var(--hp-success)', boxShadow: '0 0 0 3px rgba(0,200,83,0.2)' }} />
          <span style={{ fontSize: 12.5, fontWeight: 600, color: 'var(--hp-text)' }}>Live</span>
        </div>
      </div>
    </div>
  );
}

/* ---- Small primitives ---------------------------------------------------- */
function Section({ title, action, children, style }) {
  return (
    <div style={style}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 14 }}>
        <h3 style={{ fontSize: 17 }}>{title}</h3>
        {action}
      </div>
      {children}
    </div>
  );
}

function complianceColor(v) { return v >= 90 ? 'var(--hp-success)' : v >= 80 ? 'var(--hp-teal)' : v >= 70 ? 'var(--hp-warning)' : 'var(--hp-danger)'; }
const STATUS_META = { patrol: ['On patrol', 'var(--hp-map-officer)'], break: ['On break', 'var(--hp-warning)'], offline: ['Offline', 'var(--hp-text-muted)'] };

Object.assign(window, {
  CmdIcon: CIcon, cmdMoney: cMoney, CMD_NAV: C_NAV, CMD_OFFICERS: C_OFFICERS, CMD_ZONES: C_ZONES,
  CMD_RECENT: C_RECENT, CMD_APPEALS: C_APPEALS, CmdSidebar: Sidebar, CmdTopbar: Topbar, CmdSection: Section,
  cmdComplianceColor: complianceColor, CMD_STATUS_META: STATUS_META,
});
