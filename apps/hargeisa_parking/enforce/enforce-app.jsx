/* global React */
/* HPark Enforce — app shell: offline toggle, sync banner, nav, citation flow */
const { useState: useStateEApp, useEffect: useEffectEApp } = React;
const EAppIcon = window.EnfIcon;

const ENF_TABS = [
  ['patrol', 'shield', 'Patrol'],
  ['scan', 'scan-line', 'Issue'],
  ['activity', 'list', 'Activity'],
  ['profile', 'user', 'Profile'],
];

function EnfBottomNav({ active, onTab }) {
  return (
    <div style={{ flexShrink: 0, display: 'flex', alignItems: 'stretch', padding: '8px 8px 4px', borderTop: '1px solid var(--hp-border)', background: 'rgba(10,10,15,0.85)', backdropFilter: 'var(--blur-bg)' }}>
      {ENF_TABS.map(([key, icon, label]) => {
        const on = active === key;
        const center = key === 'scan';
        return (
          <button key={key} onClick={() => onTab(key)} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, padding: '6px 0', background: 'none', border: 'none', cursor: 'pointer', color: on ? 'var(--hp-purple-300)' : 'var(--hp-text-muted)' }}>
            {center ? (
              <div style={{ width: 44, height: 44, borderRadius: 14, marginTop: -12, marginBottom: -4, background: 'var(--hp-gradient)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: 'var(--glow-purple-sm)' }}>
                <EAppIcon name={icon} size={22} color="#fff" />
              </div>
            ) : (
              <EAppIcon name={icon} size={22} />
            )}
            <span style={{ fontSize: 10.5, fontWeight: on ? 600 : 500 }}>{label}</span>
          </button>
        );
      })}
    </div>
  );
}

/* connectivity pill in the top-right of the status area */
function OfflineBanner({ offline, syncing, onToggle }) {
  return (
    <div style={{ padding: '0 20px 8px' }}>
      <button onClick={onToggle} style={{
        width: '100%', display: 'flex', alignItems: 'center', gap: 10, padding: '9px 13px', borderRadius: 'var(--radius-md)', cursor: 'pointer', textAlign: 'left',
        background: offline ? 'var(--hp-warning-tint)' : syncing ? 'var(--hp-purple-tint)' : 'var(--hp-success-tint)',
        border: `1px solid ${offline ? 'rgba(255,179,0,0.3)' : syncing ? 'var(--hp-border-focus)' : 'rgba(0,200,83,0.3)'}`, color: 'var(--hp-text)',
      }}>
        <EAppIcon name={offline ? 'cloud-off' : syncing ? 'refresh-cw' : 'cloud-check'} size={17} color={offline ? 'var(--hp-warning)' : syncing ? 'var(--hp-purple-300)' : 'var(--hp-success)'} style={syncing ? { animation: 'spin 1s linear infinite' } : undefined} />
        <span style={{ fontSize: 12.5, fontWeight: 600, flex: 1 }}>
          {offline ? 'Offline — citations queue locally' : syncing ? 'Syncing queued citations…' : 'Online — all data synced'}
        </span>
        <span style={{ fontSize: 11, color: 'var(--hp-text-muted)', fontFamily: 'var(--font-mono)' }}>{offline ? 'tap: go online' : 'tap: go offline'}</span>
      </button>
    </div>
  );
}

function EnforceApp() {
  const [officer, setOfficer] = useStateEApp(null);
  const [tab, setTab] = useStateEApp('patrol');
  const [flow, setFlow] = useStateEApp(null); // null | found | violation | evidence | review | issued
  const [violation, setViolation] = useStateEApp(null);
  const [offline, setOffline] = useStateEApp(false);
  const [syncing, setSyncing] = useStateEApp(false);
  const [queued, setQueued] = useStateEApp(false);
  useEffectEApp(() => { if (window.lucide) window.lucide.createIcons(); });

  function toggleConn() {
    if (offline) {
      // going back online → sync
      setOffline(false);
      if (queued) { setSyncing(true); setTimeout(() => { setSyncing(false); setQueued(false); }, 1800); }
    } else { setOffline(true); }
  }

  if (!officer) return <window.EnforceAuth onAuthed={setOfficer} />;

  // citation flow (modal-ish full screen over scan)
  let flowBody = null;
  if (flow === 'found') flowBody = <window.EnfFoundScreen offline={offline} onBack={() => setFlow(null)} onIssue={() => setFlow('violation')} />;
  else if (flow === 'violation') flowBody = <window.EnfViolationScreen onBack={() => setFlow('found')} onNext={() => setFlow('evidence')} selected={violation} setSelected={setViolation} />;
  else if (flow === 'evidence') flowBody = <window.EnfEvidenceScreen offline={offline} onBack={() => setFlow('violation')} onNext={() => setFlow('review')} />;
  else if (flow === 'review') flowBody = <window.EnfReviewScreen offline={offline} violation={violation} onBack={() => setFlow('evidence')} onIssue={() => { if (offline) setQueued(true); setFlow('issued'); }} />;
  else if (flow === 'issued') flowBody = <window.EnfIssuedScreen offline={offline} onDone={() => { setFlow(null); setViolation(null); setTab('activity'); }} />;

  let body;
  if (flowBody) body = flowBody;
  else if (tab === 'patrol') body = <window.EnfPatrolHome officer={officer} offline={offline} onScan={() => setTab('scan')} onGoActivity={() => setTab('activity')} />;
  else if (tab === 'scan') body = <window.EnfSearchScreen offline={offline} onFound={() => setFlow('found')} />;
  else if (tab === 'activity') body = <window.EnfActivityTab offline={offline} queued={queued} />;
  else if (tab === 'profile') body = <window.EnfOfficerProfile officer={officer} onSignOut={() => { setOfficer(null); setTab('patrol'); }} />;

  return (
    <>
      {window.HPStatusBar({ dark: true })}
      {!flowBody && <OfflineBanner offline={offline} syncing={syncing} onToggle={toggleConn} />}
      <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column', position: 'relative' }}>
        {body}
      </div>
      {!flowBody && <EnfBottomNav active={tab} onTab={(t) => { setFlow(null); setTab(t); }} />}
      {window.HPHomeIndicator()}
    </>
  );
}

window.EnforceApp = EnforceApp;
