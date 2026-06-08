/* global React, Button, Badge, Card */
/* HPark Enforce — patrol home, activity, profile */
const { useState: useStateEH } = React;
const EHIcon = window.EnfIcon;
const EH_ISSUED = window.ENF_ISSUED;
const ehMoney = window.enfMoney;
const EHPlate = window.EnfPlate;

function PatrolHome({ officer, offline, onScan, onGoActivity }) {
  return (
    <div style={{ flex: 1, overflow: 'auto', padding: '4px 20px 24px' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '4px 0 16px' }}>
        <div>
          <div style={{ fontSize: 13, color: 'var(--hp-text-muted)' }}>On patrol</div>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 22, color: 'var(--hp-text)' }}>{officer.name}</div>
        </div>
        <Badge status="patrol" size="lg" />
      </div>

      {/* assignment card */}
      <div style={{ borderRadius: 'var(--radius-xl)', overflow: 'hidden', border: '1px solid rgba(124,108,248,0.28)', background: 'linear-gradient(150deg, rgba(124,108,248,0.18), rgba(0,216,214,0.08))', padding: 18, marginBottom: 16 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <span className="hp-eyebrow" style={{ color: 'var(--hp-text-2)' }}>Today's district</span>
          <span style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--hp-purple-300)' }}>{officer.id}</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 10 }}>
          <EHIcon name="map-pin" size={22} color="var(--hp-teal)" />
          <span style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 24, color: '#fff' }}>{officer.district}</span>
        </div>
        <div style={{ fontSize: 13, color: 'var(--hp-text-2)', marginTop: 6 }}>{officer.shift}</div>
      </div>

      {/* shift stats */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10, marginBottom: 18 }}>
        {[['Issued', '8', 'file-text'], ['Scanned', '34', 'scan-line'], ['Revenue', '1.1M', 'banknote']].map(([k, v, ic]) => (
          <div key={k} style={{ padding: 14, borderRadius: 'var(--radius-lg)', background: 'var(--hp-surface)', border: '1px solid var(--hp-border)' }}>
            <EHIcon name={ic} size={16} color="var(--hp-purple-300)" />
            <div style={{ fontFamily: 'var(--font-mono)', fontSize: 22, fontWeight: 700, color: '#fff', marginTop: 8 }}>{v}</div>
            <div style={{ fontSize: 11.5, color: 'var(--hp-text-muted)' }}>{k}</div>
          </div>
        ))}
      </div>

      <Button block size="xl" onClick={onScan} icon={<EHIcon name="scan-line" size={20} />}>Scan a vehicle</Button>

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', margin: '22px 0 10px' }}>
        <div className="hp-eyebrow">Recent activity</div>
        <span onClick={onGoActivity} style={{ fontSize: 13, color: 'var(--hp-purple-300)', fontWeight: 600, cursor: 'pointer' }}>View all</span>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        {EH_ISSUED.slice(0, 3).map((c) => (
          <div key={c.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: 13, borderRadius: 'var(--radius-lg)', background: 'var(--hp-surface)', border: '1px solid var(--hp-border)' }}>
            <EHPlate>{c.plate}</EHPlate>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 13.5, fontWeight: 600, color: '#fff', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{c.reason}</div>
              <div style={{ fontSize: 11.5, color: 'var(--hp-text-muted)' }}>{c.time}</div>
            </div>
            <span style={{ fontFamily: 'var(--font-mono)', fontSize: 12.5, color: 'var(--hp-text-2)' }}>{ehMoney(c.fine).replace('SLSH ', '')}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

function ActivityTab({ offline, queued }) {
  const list = [...(queued ? [{ id: 'CIT-2026-04823', plate: 'HG-4821', reason: 'No valid permit', fine: 150000, time: 'just now', synced: false }] : []), ...EH_ISSUED];
  return (
    <div style={{ flex: 1, overflow: 'auto', padding: '4px 20px 24px' }}>
      <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 22, color: 'var(--hp-text)', padding: '8px 0 14px' }}>My activity</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {list.map((c) => (
          <Card key={c.id} padding={15}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
              <EHPlate>{c.plate}</EHPlate>
              {c.synced ? <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, fontSize: 12, color: 'var(--hp-success)', fontWeight: 600 }}><EHIcon name="cloud-check" size={14} /> Synced</span>
                : <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, fontSize: 12, color: 'var(--hp-warning)', fontWeight: 600 }}><EHIcon name="cloud-off" size={14} /> Queued</span>}
            </div>
            <div style={{ fontSize: 15, fontWeight: 600, color: '#fff' }}>{c.reason}</div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 8 }}>
              <span style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--hp-text-muted)' }}>{c.id} · {c.time}</span>
              <span style={{ fontFamily: 'var(--font-mono)', fontWeight: 700, fontSize: 15, color: '#fff' }}>{ehMoney(c.fine)}</span>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}

function OfficerProfile({ officer, onSignOut }) {
  const rows = [['id-card', 'Badge ID', officer.id], ['map-pin', 'District', officer.district], ['clock', 'Shift', officer.shift], ['award', 'Rank', 'Senior officer']];
  return (
    <div style={{ flex: 1, overflow: 'auto', padding: '4px 20px 24px' }}>
      <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 22, color: 'var(--hp-text)', padding: '8px 0 18px' }}>Profile</div>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12, marginBottom: 22 }}>
        <div style={{ width: 80, height: 80, borderRadius: '50%', background: 'var(--hp-gradient)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontSize: 28, fontWeight: 700, fontFamily: 'var(--font-heading)' }}>HA</div>
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 20, color: '#fff' }}>{officer.name}</div>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontSize: 12.5, color: 'var(--hp-map-officer)', marginTop: 4 }}><EHIcon name="shield" size={14} /> Enforcement officer</div>
        </div>
      </div>
      <Card padding={0} style={{ marginBottom: 16 }}>
        {rows.map(([ic, k, v], i) => (
          <div key={k} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '14px 16px', borderBottom: i < rows.length - 1 ? '1px solid var(--hp-border)' : 'none' }}>
            <EHIcon name={ic} size={18} color="var(--hp-text-muted)" />
            <span style={{ fontSize: 14, color: 'var(--hp-text-2)', flex: 1 }}>{k}</span>
            <span style={{ fontSize: 13.5, fontWeight: 600, color: '#fff', fontFamily: k === 'Badge ID' ? 'var(--font-mono)' : 'var(--font-body)' }}>{v}</span>
          </div>
        ))}
      </Card>
      <Button block size="lg" variant="ghost" onClick={onSignOut} icon={<EHIcon name="log-out" size={18} />}>End shift & sign out</Button>
    </div>
  );
}

Object.assign(window, { EnfPatrolHome: PatrolHome, EnfActivityTab: ActivityTab, EnfOfficerProfile: OfficerProfile });
