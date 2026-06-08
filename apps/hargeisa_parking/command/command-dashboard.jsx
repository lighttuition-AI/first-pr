/* global React, KpiCard, Card, Badge */
/* HPark Command — Dashboard page */
const CDIcon = window.CmdIcon;
const CD_RECENT = window.CMD_RECENT;
const CdLiveMap = window.CmdLiveMap;

function ComplianceHero() {
  return (
    <div style={{ position: 'relative', overflow: 'hidden', borderRadius: 'var(--radius-xl)', border: '1px solid rgba(124,108,248,0.25)', background: 'linear-gradient(135deg, rgba(124,108,248,0.16), rgba(0,216,214,0.10))', padding: 24, display: 'flex', flexDirection: 'column', gap: 6, minHeight: 168 }}>
      <span className="hp-eyebrow">City compliance</span>
      <div style={{ display: 'flex', alignItems: 'flex-end', gap: 12 }}>
        <span style={{ fontFamily: 'var(--font-mono)', fontWeight: 700, fontSize: 64, lineHeight: 1, color: '#fff' }}>87%</span>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, color: 'var(--hp-success)', fontFamily: 'var(--font-mono)', fontWeight: 600, fontSize: 15, paddingBottom: 10, whiteSpace: 'nowrap' }}>
          <CDIcon name="trending-up" size={16} /> +4% this week
        </span>
      </div>
      <div style={{ marginTop: 8, height: 8, borderRadius: 999, background: 'rgba(255,255,255,0.08)', overflow: 'hidden' }}>
        <div style={{ width: '87%', height: '100%', background: 'var(--hp-gradient)' }} />
      </div>
      <span style={{ fontSize: 13, color: 'var(--hp-text-2)', marginTop: 4 }}>14 of 16 zones above the 80% compliance target.</span>
    </div>
  );
}

function RecentCitations() {
  return (
    <Card padding={0}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '16px 18px', borderBottom: '1px solid var(--hp-border)' }}>
        <h4 style={{ fontSize: 16 }}>Recent citations</h4>
        <span style={{ fontSize: 13, color: 'var(--hp-purple-300)', fontWeight: 600, cursor: 'pointer' }}>View all</span>
      </div>
      <div>
        {CD_RECENT.map(([id, plate, status, reason, zone, time], i) => (
          <div key={id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 18px', borderBottom: i < CD_RECENT.length - 1 ? '1px solid var(--hp-border)' : 'none' }}>
            <span className="hp-plate" style={{ fontSize: 13 }}>{plate}</span>
            <div style={{ minWidth: 0, flex: 1 }}>
              <div style={{ fontSize: 13.5, color: 'var(--hp-text)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{reason}</div>
              <div style={{ fontFamily: 'var(--font-mono)', fontSize: 11.5, color: 'var(--hp-text-muted)' }}>{zone} · {time}</div>
            </div>
            <Badge status={status} />
          </div>
        ))}
      </div>
    </Card>
  );
}

function Dashboard() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14 }}>
        <KpiCard label="Revenue today" value="4.28M" delta="+12%" icon={<CDIcon name="banknote" size={17} />} />
        <KpiCard label="Active violations" value="38" delta="-6%" deltaDir="down" accent="var(--hp-danger)" icon={<CDIcon name="triangle-alert" size={17} />} />
        <KpiCard label="Officers active" value="24" delta="+3" accent="var(--hp-map-officer)" icon={<CDIcon name="shield" size={17} />} />
        <KpiCard label="Occupancy rate" value="76%" delta="+8%" accent="var(--hp-teal)" icon={<CDIcon name="circle-parking" size={17} />} />
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1.55fr 1fr', gap: 18, alignItems: 'stretch' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
          <ComplianceHero />
          <CdLiveMap height={360} />
        </div>
        <RecentCitations />
      </div>
    </div>
  );
}

window.CmdDashboard = Dashboard;
