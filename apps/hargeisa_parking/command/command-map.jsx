/* global React, Badge */
/* HPark Command — live map (mission-control) with officer tracking */
const { useState: useStateCM, useEffect: useEffectCM } = React;
const CMIcon = window.CmdIcon;
const CM_OFFICERS = window.CMD_OFFICERS;

const CM_MARKERS = [
  { x: 18, y: 30, c: 'var(--hp-map-paid)' }, { x: 32, y: 62, c: 'var(--hp-map-paid)' },
  { x: 70, y: 24, c: 'var(--hp-map-paid)' }, { x: 55, y: 48, c: 'var(--hp-map-expiring)' },
  { x: 80, y: 66, c: 'var(--hp-map-expiring)' }, { x: 44, y: 78, c: 'var(--hp-map-violation)' },
  { x: 24, y: 50, c: 'var(--hp-map-violation)' }, { x: 86, y: 42, c: 'var(--hp-map-paid)' },
];
const CM_OFC = [
  { x: 62, y: 70, name: 'OFR-118' }, { x: 38, y: 38, name: 'OFR-204' },
  { x: 74, y: 52, name: 'OFR-233' }, { x: 28, y: 74, name: 'OFR-091' },
];
const CM_LEGEND = [['Paid', 'var(--hp-map-paid)'], ['Expiring', 'var(--hp-map-expiring)'], ['Violation', 'var(--hp-map-violation)'], ['Officer', 'var(--hp-map-officer)']];

function LiveMap({ height = 380, showRoute = true }) {
  return (
    <div style={{ position: 'relative', borderRadius: 'var(--radius-lg)', overflow: 'hidden', border: '1px solid var(--hp-border)', background: '#0C0C14', height, minHeight: height }}>
      <div style={{ position: 'absolute', inset: 0, backgroundImage:
        'linear-gradient(rgba(124,108,248,0.06) 1px, transparent 1px),linear-gradient(90deg, rgba(124,108,248,0.06) 1px, transparent 1px),linear-gradient(115deg, rgba(255,255,255,0.05) 2px, transparent 2px),linear-gradient(200deg, rgba(255,255,255,0.04) 2px, transparent 2px)',
        backgroundSize: '46px 46px, 46px 46px, 180px 180px, 240px 240px' }} />
      <div style={{ position: 'absolute', left: '-5%', top: '52%', width: '110%', height: 8, background: 'rgba(255,255,255,0.06)', transform: 'rotate(-7deg)' }} />
      <div style={{ position: 'absolute', left: '30%', top: '-5%', width: 7, height: '110%', background: 'rgba(255,255,255,0.05)' }} />
      {showRoute && (
        <svg style={{ position: 'absolute', inset: 0, width: '100%', height: '100%' }} preserveAspectRatio="none" viewBox="0 0 100 100">
          <polyline points="38,38 50,44 62,70 74,52" fill="none" stroke="var(--hp-map-route)" strokeWidth="0.5" strokeDasharray="2 1.4" opacity="0.8" />
        </svg>
      )}
      {CM_MARKERS.map((m, i) => (
        <div key={i} style={{ position: 'absolute', left: `${m.x}%`, top: `${m.y}%`, transform: 'translate(-50%,-50%)', width: 12, height: 12, borderRadius: '50%', background: m.c, boxShadow: `0 0 0 5px color-mix(in srgb, ${m.c} 20%, transparent)` }} />
      ))}
      {CM_OFC.map((m, i) => (
        <div key={'o' + i} style={{ position: 'absolute', left: `${m.x}%`, top: `${m.y}%`, transform: 'translate(-50%,-50%)', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3 }}>
          <div style={{ width: 18, height: 18, borderRadius: '50%', background: 'var(--hp-map-officer)', border: '2px solid #fff', boxShadow: '0 0 0 5px rgba(61,157,246,0.25)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <CMIcon name="shield" size={9} color="#fff" />
          </div>
          <span style={{ fontFamily: 'var(--font-mono)', fontSize: 9, color: '#fff', background: 'rgba(0,0,0,0.6)', padding: '1px 5px', borderRadius: 4, whiteSpace: 'nowrap' }}>{m.name}</span>
        </div>
      ))}
      <div style={{ position: 'absolute', left: 16, bottom: 16, display: 'flex', gap: 16, padding: '10px 14px', borderRadius: 'var(--radius-md)', background: 'rgba(10,10,15,0.72)', backdropFilter: 'var(--blur-bg)', border: '1px solid var(--hp-border)' }}>
        {CM_LEGEND.map(([label, c]) => (
          <span key={label} style={{ display: 'flex', alignItems: 'center', gap: 7, fontSize: 12, color: 'var(--hp-text-2)', fontWeight: 500 }}>
            <span style={{ width: 9, height: 9, borderRadius: '50%', background: c }} />{label}
          </span>
        ))}
      </div>
      <div style={{ position: 'absolute', right: 16, top: 16, display: 'flex', alignItems: 'center', gap: 7, padding: '7px 12px', borderRadius: 'var(--radius-pill)', background: 'rgba(10,10,15,0.72)', backdropFilter: 'var(--blur-bg)', border: '1px solid var(--hp-border)', fontSize: 12, fontWeight: 600, color: 'var(--hp-text)' }}>
        <span style={{ width: 8, height: 8, borderRadius: '50%', background: 'var(--hp-success)', boxShadow: '0 0 0 4px rgba(0,200,83,0.25)' }} />
        Live · 1,284 spaces
      </div>
    </div>
  );
}

window.CmdLiveMap = LiveMap;
