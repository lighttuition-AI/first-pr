/* global React */
const { useState } = React;

function StatusBar({ dark }) {
  const col = dark ? 'var(--hp-text)' : '#fff';
  return (
    <div style={{
      height: 44, flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 22px 0 26px', fontFamily: 'var(--font-mono)', fontSize: 14, fontWeight: 600, color: col,
    }}>
      <span>9:41</span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <i data-lucide="signal" style={{ width: 16, height: 16 }} />
        <i data-lucide="wifi" style={{ width: 16, height: 16 }} />
        <i data-lucide="battery-full" style={{ width: 20, height: 16 }} />
      </div>
    </div>
  );
}

/** PhoneFrame — 390×844 device shell on dark canvas. */
function PhoneFrame({ children, label }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 14 }}>
      <div style={{
        width: 390, height: 844, borderRadius: 46, padding: 5,
        background: 'linear-gradient(160deg, #26263a, #0d0d16)',
        boxShadow: '0 0 0 1px rgba(255,255,255,0.06), 0 40px 90px -30px rgba(0,0,0,0.8)',
        flexShrink: 0,
      }}>
        <div style={{
          position: 'relative', width: '100%', height: '100%', borderRadius: 41, overflow: 'hidden',
          background: 'var(--hp-bg)', display: 'flex', flexDirection: 'column',
        }}>
          {/* dynamic island */}
          <div style={{ position: 'absolute', top: 10, left: '50%', transform: 'translateX(-50%)', width: 116, height: 32, background: '#000', borderRadius: 20, zIndex: 20 }} />
          {children}
        </div>
      </div>
      {label && <span style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--hp-text-muted)' }}>{label}</span>}
    </div>
  );
}

function HomeIndicator() {
  return <div style={{ flexShrink: 0, height: 26, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
    <div style={{ width: 134, height: 5, borderRadius: 3, background: 'rgba(255,255,255,0.22)' }} />
  </div>;
}

Object.assign(window, { HPPhoneFrame: PhoneFrame, HPStatusBar: StatusBar, HPHomeIndicator: HomeIndicator });
