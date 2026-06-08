/* global React */
/* HPark Enforce — shared helpers & data */
const { useState: useStateEC, useEffect: useEffectEC, useRef: useRefEC } = React;

const EIcon = ({ name, size = 20, color, style }) => (
  <i data-lucide={name} style={{ width: size, height: size, color, display: 'inline-flex', flexShrink: 0, ...style }} />
);

const E_DISTRICTS = ['Ahmed Dhagah', '26 June', '31 May', 'Mohamed Mooge', 'Maxamuud Haybe', 'Gacan Libaax', 'Ibrahim Koodbuur', 'Mohamoud Haibe', 'Macalin Haroon'];

const E_VIOLATIONS = [
  ['No valid permit', 'parking-meter', 150000],
  ['Expired meter', 'timer-off', 80000],
  ['Disabled bay misuse', 'accessibility', 300000],
  ['Double parking', 'cars', 120000],
  ['Loading zone', 'truck', 100000],
  ['Blocking hydrant', 'flame', 200000],
];

/* a found vehicle record (cached/live) */
const E_VEHICLE = {
  plate: 'HG-4821', owner: 'Amina Yusuf', model: 'Toyota Vitz · White', id: 'SL-4471-2208',
  parking: 'Unpaid', permit: 'None', outstanding: 1, lastSeen: 'Pepsi Roundabout · 4m',
};

/* officer's recent issued citations */
const E_ISSUED = [
  { id: 'CIT-2026-04822', plate: 'HG-4821', reason: 'No valid permit', fine: 150000, time: '2m ago', synced: true },
  { id: 'CIT-2026-04815', plate: 'SL-09122', reason: 'Double parking', fine: 120000, time: '38m ago', synced: true },
  { id: 'CIT-2026-04808', plate: 'HG-2210', reason: 'Expired meter', fine: 80000, time: '1h ago', synced: true },
  { id: 'CIT-2026-04790', plate: 'HG-7741', reason: 'Loading zone', fine: 100000, time: '2h ago', synced: true },
];

const eMoney = (n) => 'SLSH ' + n.toLocaleString('en-US');

function EPlate({ children, size = 14, style }) { return <span className="hp-plate" style={{ fontSize: size, ...style }}>{children}</span>; }

function EScreenShell({ title, sub, children, onBack, action }) {
  return (
    <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column' }}>
      <div style={{ padding: '6px 20px 14px', display: 'flex', alignItems: 'center', gap: 12 }}>
        {onBack && (
          <button onClick={onBack} style={{ width: 38, height: 38, borderRadius: 10, background: 'var(--hp-overlay)', border: '1px solid var(--hp-border)', color: 'var(--hp-text)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', flexShrink: 0 }}>
            <EIcon name="arrow-left" size={18} />
          </button>
        )}
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 22, color: 'var(--hp-text)' }}>{title}</div>
          {sub && <div style={{ fontSize: 13, color: 'var(--hp-text-muted)' }}>{sub}</div>}
        </div>
        {action}
      </div>
      <div style={{ flex: 1, minHeight: 0, overflow: 'auto', padding: '0 20px 16px' }}>{children}</div>
    </div>
  );
}

Object.assign(window, {
  EnfIcon: EIcon, ENF_DISTRICTS: E_DISTRICTS, ENF_VIOLATIONS: E_VIOLATIONS,
  ENF_VEHICLE: E_VEHICLE, ENF_ISSUED: E_ISSUED, enfMoney: eMoney, EnfPlate: EPlate, EnfScreenShell: EScreenShell,
});
