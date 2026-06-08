/* global React, Card, Badge, Button */
/* HPark Command — Officers, Zones, Live map pages */
const { useState: useStatePA } = React;
const PAIcon = window.CmdIcon;
const PA_OFFICERS = window.CMD_OFFICERS;
const PA_ZONES = window.CMD_ZONES;
const paMoney = window.cmdMoney;
const paComplianceColor = window.cmdComplianceColor;
const PA_STATUS = window.CMD_STATUS_META;
const PaLiveMap = window.CmdLiveMap;

/* ---- Officers ------------------------------------------------------------ */
function OfficersPage() {
  const ranked = [...PA_OFFICERS].sort((a, b) => b.perf - a.perf);
  const top = ranked[0];
  const active = PA_OFFICERS.filter((o) => o.status === 'patrol').length;
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
      <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 1fr 1fr', gap: 14 }}>
        {/* top performer */}
        <div style={{ borderRadius: 'var(--radius-xl)', border: '1px solid rgba(124,108,248,0.28)', background: 'linear-gradient(135deg, rgba(124,108,248,0.18), rgba(0,216,214,0.08))', padding: 20 }}>
          <span className="hp-eyebrow">Top performer today</span>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginTop: 14 }}>
            <div style={{ width: 52, height: 52, borderRadius: '50%', background: 'var(--hp-gradient)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 700, fontSize: 18, fontFamily: 'var(--font-heading)' }}>{top.name.split(' ').map((n) => n[0]).join('')}</div>
            <div>
              <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 19, color: '#fff' }}>{top.name}</div>
              <div style={{ fontFamily: 'var(--font-mono)', fontSize: 12.5, color: 'var(--hp-purple-300)' }}>{top.id} · {top.district}</div>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 22, marginTop: 16 }}>
            <div><div style={{ fontFamily: 'var(--font-mono)', fontSize: 22, fontWeight: 700, color: '#fff' }}>{top.today}</div><div style={{ fontSize: 11.5, color: 'var(--hp-text-muted)' }}>Citations</div></div>
            <div><div style={{ fontFamily: 'var(--font-mono)', fontSize: 22, fontWeight: 700, color: 'var(--hp-success)' }}>{top.perf}%</div><div style={{ fontSize: 11.5, color: 'var(--hp-text-muted)' }}>Performance</div></div>
          </div>
        </div>
        {[['Officers on duty', active + ' / ' + PA_OFFICERS.length, 'shield', 'var(--hp-map-officer)'], ['Citations today', '71', 'file-text', 'var(--hp-purple-300)']].map(([k, v, ic, c]) => (
          <Card key={k} padding={20}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}><span className="hp-eyebrow">{k}</span><span style={{ width: 30, height: 30, borderRadius: 8, background: 'rgba(124,108,248,0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><PAIcon name={ic} size={16} color={c} /></span></div>
            <div style={{ fontFamily: 'var(--font-mono)', fontSize: 32, fontWeight: 700, color: '#fff', marginTop: 16 }}>{v}</div>
          </Card>
        ))}
      </div>

      <Card padding={0}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '16px 20px', borderBottom: '1px solid var(--hp-border)' }}>
          <h4 style={{ fontSize: 16 }}>All officers</h4>
          <Button size="sm" variant="secondary" icon={<PAIcon name="user-plus" size={15} />}>Assign officer</Button>
        </div>
        {/* table header */}
        <div style={{ display: 'grid', gridTemplateColumns: '2fr 1.4fr 1.2fr 0.8fr 1fr 1.4fr', gap: 12, padding: '11px 20px', borderBottom: '1px solid var(--hp-border)', fontSize: 11.5, fontWeight: 600, letterSpacing: '0.04em', textTransform: 'uppercase', color: 'var(--hp-text-muted)' }}>
          <span>Officer</span><span>District</span><span>Status</span><span>Today</span><span>Revenue</span><span>Performance</span>
        </div>
        {ranked.map((o) => {
          const [label, color] = PA_STATUS[o.status];
          return (
            <div key={o.id} style={{ display: 'grid', gridTemplateColumns: '2fr 1.4fr 1.2fr 0.8fr 1fr 1.4fr', gap: 12, padding: '13px 20px', borderBottom: '1px solid var(--hp-border)', alignItems: 'center' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 11 }}>
                <div style={{ width: 34, height: 34, borderRadius: '50%', background: 'var(--hp-overlay)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--hp-purple-300)', fontWeight: 700, fontSize: 12.5 }}>{o.name.split(' ').map((n) => n[0]).join('')}</div>
                <div style={{ minWidth: 0 }}><div style={{ fontSize: 13.5, fontWeight: 600, color: '#fff' }}>{o.name}</div><div style={{ fontFamily: 'var(--font-mono)', fontSize: 11.5, color: 'var(--hp-text-muted)' }}>{o.id}</div></div>
              </div>
              <span style={{ fontSize: 13, color: 'var(--hp-text-2)' }}>{o.district}</span>
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 7, fontSize: 12.5, color }}><span style={{ width: 7, height: 7, borderRadius: '50%', background: color }} />{label}</span>
              <span style={{ fontFamily: 'var(--font-mono)', fontSize: 14, color: '#fff' }}>{o.today}</span>
              <span style={{ fontFamily: 'var(--font-mono)', fontSize: 13, color: 'var(--hp-text-2)' }}>{(o.revenue / 1000000).toFixed(2)}M</span>
              <div style={{ display: 'flex', alignItems: 'center', gap: 9 }}>
                <div style={{ flex: 1, height: 6, borderRadius: 999, background: 'var(--hp-overlay)', overflow: 'hidden' }}><div style={{ width: o.perf + '%', height: '100%', background: paComplianceColor(o.perf) }} /></div>
                <span style={{ fontFamily: 'var(--font-mono)', fontSize: 12.5, color: paComplianceColor(o.perf), width: 34, textAlign: 'right' }}>{o.perf}%</span>
              </div>
            </div>
          );
        })}
      </Card>
    </div>
  );
}

/* ---- Zones --------------------------------------------------------------- */
function ZonesPage() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 14 }}>
        {PA_ZONES.map((z) => (
          <Card key={z.zone} hover padding={18}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 14 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <span style={{ fontFamily: 'var(--font-mono)', fontSize: 12, fontWeight: 700, color: 'var(--hp-purple-300)', background: 'var(--hp-purple-tint)', padding: '3px 8px', borderRadius: 6 }}>{z.zone}</span>
                <span style={{ fontSize: 15, fontWeight: 600, color: '#fff' }}>{z.name}</span>
              </div>
              <span style={{ fontSize: 12.5, color: 'var(--hp-text-muted)', display: 'inline-flex', alignItems: 'center', gap: 5 }}><PAIcon name="shield" size={13} />{z.officers}</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: 10 }}>
              <div>
                <div style={{ fontSize: 11.5, color: 'var(--hp-text-muted)' }}>Compliance</div>
                <div style={{ fontFamily: 'var(--font-mono)', fontSize: 26, fontWeight: 700, color: paComplianceColor(z.compliance) }}>{z.compliance}%</div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: 11.5, color: 'var(--hp-text-muted)' }}>Revenue (mo)</div>
                <div style={{ fontFamily: 'var(--font-mono)', fontSize: 15, fontWeight: 600, color: '#fff' }}>{(z.revenue / 1000000).toFixed(1)}M</div>
              </div>
            </div>
            <div style={{ height: 6, borderRadius: 999, background: 'var(--hp-overlay)', overflow: 'hidden' }}>
              <div style={{ width: z.compliance + '%', height: '100%', background: paComplianceColor(z.compliance) }} />
            </div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 12, fontSize: 12, color: 'var(--hp-text-2)' }}>
              <span>Occupancy {z.occupancy}%</span>
              <span style={{ color: 'var(--hp-purple-300)', fontWeight: 600, cursor: 'pointer' }}>Manage →</span>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}

/* ---- Live map page ------------------------------------------------------- */
function LiveMapPage() {
  const onPatrol = PA_OFFICERS.filter((o) => o.status === 'patrol');
  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 320px', gap: 18, height: '100%' }}>
      <PaLiveMap height={620} />
      <Card padding={0} style={{ display: 'flex', flexDirection: 'column' }}>
        <div style={{ padding: '16px 18px', borderBottom: '1px solid var(--hp-border)' }}>
          <h4 style={{ fontSize: 16 }}>Officers on patrol</h4>
          <div style={{ fontSize: 12.5, color: 'var(--hp-text-muted)', marginTop: 2 }}>{onPatrol.length} live · GPS tracked</div>
        </div>
        <div style={{ flex: 1, overflow: 'auto' }}>
          {onPatrol.map((o) => (
            <div key={o.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 18px', borderBottom: '1px solid var(--hp-border)' }}>
              <div style={{ width: 36, height: 36, borderRadius: '50%', background: 'var(--hp-blue-tint)', border: '1px solid rgba(61,157,246,0.3)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--hp-map-officer)', fontWeight: 700, fontSize: 12.5 }}>{o.name.split(' ').map((n) => n[0]).join('')}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13.5, fontWeight: 600, color: '#fff' }}>{o.name}</div>
                <div style={{ fontSize: 11.5, color: 'var(--hp-text-muted)' }}>{o.district}</div>
              </div>
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, fontSize: 11.5, color: 'var(--hp-map-officer)', fontWeight: 600 }}><span style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--hp-map-officer)' }} />Live</span>
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}

Object.assign(window, { CmdOfficersPage: OfficersPage, CmdZonesPage: ZonesPage, CmdLiveMapPage: LiveMapPage });
