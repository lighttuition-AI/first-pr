/* global React, Card, Badge, Button */
/* HPark Command — Vehicles + data upload/dedupe, Appeals review, Reports */
const { useState: useStatePB, useEffect: useEffectPB } = React;
const PBIcon = window.CmdIcon;
const pbMoney = window.cmdMoney;
const PB_APPEALS = window.CMD_APPEALS;
const PB_ZONES = window.CMD_ZONES;

/* ---- Vehicles registry + upload/dedupe ----------------------------------- */
const REGISTRY = [
  ['HG-4821', 'Amina Yusuf', 'Toyota Vitz', 'SL-4471-2208', 'Active'],
  ['SL-09122', 'Omar Said', 'Nissan March', 'SL-1180-3340', 'Active'],
  ['HG-2210', 'Hani Abdi', 'Toyota Probox', 'SL-7782-1190', 'Active'],
  ['HG-7741', 'Said Farah', 'Toyota Hilux', 'SL-2231-8890', 'Flagged'],
  ['SL-04412', 'Layla Nur', 'Suzuki Alto', 'SL-9921-4420', 'Active'],
];

function UploadPanel() {
  const [stage, setStage] = useStatePB('idle'); // idle | analyzing | preview | done
  useEffectPB(() => { if (stage === 'analyzing') { const t = setTimeout(() => setStage('preview'), 1600); return () => clearTimeout(t); } }, [stage]);
  const result = { total: 4212, neu: 318, updated: 47, unchanged: 3841, conflicts: 6 };
  return (
    <Card padding={0}>
      <div style={{ padding: '16px 20px', borderBottom: '1px solid var(--hp-border)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div><h4 style={{ fontSize: 16 }}>Import vehicle data</h4><div style={{ fontSize: 12.5, color: 'var(--hp-text-muted)', marginTop: 2 }}>Excel · CSV · Google Sheets — deduped against the live registry</div></div>
        <div style={{ display: 'flex', gap: 7 }}>
          {['sheet', 'file-spreadsheet', 'database'].map((ic) => <span key={ic} style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--hp-overlay)', border: '1px solid var(--hp-border)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><PBIcon name={ic} size={16} color="var(--hp-text-2)" /></span>)}
        </div>
      </div>
      <div style={{ padding: 20 }}>
        {(stage === 'idle' || stage === 'analyzing') && (
          <div style={{ border: '1.5px dashed var(--hp-border-strong)', borderRadius: 'var(--radius-lg)', padding: '34px 20px', textAlign: 'center', background: 'var(--hp-surface)' }}>
            {stage === 'analyzing' ? (
              <>
                <PBIcon name="loader" size={30} color="var(--hp-purple-300)" style={{ animation: 'spin 1s linear infinite' }} />
                <div style={{ fontSize: 14.5, fontWeight: 600, color: '#fff', marginTop: 14 }}>Analyzing 4,212 rows…</div>
                <div style={{ fontSize: 12.5, color: 'var(--hp-text-muted)', marginTop: 4 }}>Matching plates & owner records against the database</div>
              </>
            ) : (
              <>
                <div style={{ width: 52, height: 52, borderRadius: 14, background: 'var(--hp-purple-tint)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 14px' }}><PBIcon name="upload-cloud" size={26} color="var(--hp-purple-300)" /></div>
                <div style={{ fontSize: 15, fontWeight: 600, color: '#fff' }}>Drop a spreadsheet here</div>
                <div style={{ fontSize: 13, color: 'var(--hp-text-2)', margin: '4px 0 16px' }}>or connect a Google Sheet by URL</div>
                <div style={{ display: 'flex', gap: 10, justifyContent: 'center' }}>
                  <Button size="md" onClick={() => setStage('analyzing')} icon={<PBIcon name="file-up" size={16} />}>Choose file</Button>
                  <Button size="md" variant="secondary" onClick={() => setStage('analyzing')} icon={<PBIcon name="link" size={16} />}>Link Sheet</Button>
                </div>
              </>
            )}
          </div>
        )}
        {(stage === 'preview' || stage === 'done') && (
          <>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px', borderRadius: 'var(--radius-md)', background: 'var(--hp-overlay)', border: '1px solid var(--hp-border)', marginBottom: 16 }}>
              <PBIcon name="file-spreadsheet" size={18} color="var(--hp-success)" />
              <span style={{ fontSize: 13.5, fontWeight: 600, color: '#fff' }}>hargeisa_vehicles_jun2026.xlsx</span>
              <span style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--hp-text-muted)', marginLeft: 'auto' }}>{result.total.toLocaleString()} rows</span>
            </div>
            <div className="hp-eyebrow" style={{ marginBottom: 10 }}>Dedupe preview</div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 10, marginBottom: 16 }}>
              {[['New', result.neu, 'var(--hp-success)', 'plus-circle'], ['Updated', result.updated, 'var(--hp-teal)', 'refresh-cw'], ['Unchanged', result.unchanged, 'var(--hp-text-2)', 'minus-circle'], ['Conflicts', result.conflicts, 'var(--hp-warning)', 'alert-triangle']].map(([k, v, c, ic]) => (
                <div key={k} style={{ padding: 14, borderRadius: 'var(--radius-md)', background: 'var(--hp-surface)', border: '1px solid var(--hp-border)' }}>
                  <PBIcon name={ic} size={15} color={c} />
                  <div style={{ fontFamily: 'var(--font-mono)', fontSize: 22, fontWeight: 700, color: '#fff', marginTop: 8 }}>{typeof v === 'number' ? v.toLocaleString() : v}</div>
                  <div style={{ fontSize: 11.5, color: 'var(--hp-text-muted)' }}>{k}</div>
                </div>
              ))}
            </div>
            <div style={{ padding: '11px 14px', borderRadius: 'var(--radius-md)', background: 'var(--hp-teal-tint)', border: '1px solid rgba(0,216,214,0.25)', fontSize: 12.5, color: 'var(--hp-text)', marginBottom: 16, display: 'flex', gap: 9, alignItems: 'center' }}>
              <PBIcon name="info" size={15} color="var(--hp-teal)" /> 47 records show an owner change — only the differing fields will be updated.
            </div>
            {stage === 'done' ? (
              <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '13px 16px', borderRadius: 'var(--radius-md)', background: 'var(--hp-success-tint)', border: '1px solid rgba(0,200,83,0.3)' }}>
                <PBIcon name="check-circle" size={18} color="var(--hp-success)" />
                <span style={{ fontSize: 13.5, fontWeight: 600, color: '#fff' }}>Imported · 365 records added or updated, 6 conflicts queued for review</span>
              </div>
            ) : (
              <div style={{ display: 'flex', gap: 10 }}>
                <Button size="lg" onClick={() => setStage('done')} icon={<PBIcon name="database" size={17} />}>Import 365 changes</Button>
                <Button size="lg" variant="secondary" onClick={() => setStage('idle')}>Cancel</Button>
              </div>
            )}
          </>
        )}
      </div>
    </Card>
  );
}

function VehiclesPage() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 14 }}>
        {[['Registered vehicles', '48,210', 'car', 'var(--hp-purple-300)'], ['Active permits', '12,884', 'badge-check', 'var(--hp-success)'], ['Flagged plates', '326', 'flag', 'var(--hp-danger)']].map(([k, v, ic, c]) => (
          <Card key={k} padding={18}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}><span className="hp-eyebrow">{k}</span><span style={{ width: 30, height: 30, borderRadius: 8, background: 'rgba(124,108,248,0.12)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><PBIcon name={ic} size={16} color={c} /></span></div>
            <div style={{ fontFamily: 'var(--font-mono)', fontSize: 28, fontWeight: 700, color: '#fff', marginTop: 14 }}>{v}</div>
          </Card>
        ))}
      </div>
      <UploadPanel />
      <Card padding={0}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '16px 20px', borderBottom: '1px solid var(--hp-border)' }}>
          <h4 style={{ fontSize: 16 }}>Vehicle registry</h4>
          <span style={{ fontSize: 13, color: 'var(--hp-purple-300)', fontWeight: 600, cursor: 'pointer' }}>Export</span>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1.4fr 1.2fr 1.4fr 1fr', gap: 12, padding: '11px 20px', borderBottom: '1px solid var(--hp-border)', fontSize: 11.5, fontWeight: 600, letterSpacing: '0.04em', textTransform: 'uppercase', color: 'var(--hp-text-muted)' }}>
          <span>Plate</span><span>Owner</span><span>Vehicle</span><span>ID number</span><span>Status</span>
        </div>
        {REGISTRY.map(([plate, owner, model, id, status]) => (
          <div key={plate} style={{ display: 'grid', gridTemplateColumns: '1fr 1.4fr 1.2fr 1.4fr 1fr', gap: 12, padding: '13px 20px', borderBottom: '1px solid var(--hp-border)', alignItems: 'center' }}>
            <span className="hp-plate" style={{ fontSize: 12.5, justifySelf: 'start' }}>{plate}</span>
            <span style={{ fontSize: 13.5, color: '#fff' }}>{owner}</span>
            <span style={{ fontSize: 13, color: 'var(--hp-text-2)' }}>{model}</span>
            <span style={{ fontFamily: 'var(--font-mono)', fontSize: 12.5, color: 'var(--hp-text-2)' }}>{id}</span>
            <span style={{ justifySelf: 'start' }}>{status === 'Flagged' ? <Badge status="overdue" glyph="▲">Flagged</Badge> : <Badge status="active" glyph="●">Active</Badge>}</span>
          </div>
        ))}
      </Card>
    </div>
  );
}

/* ---- Appeals review ------------------------------------------------------ */
function AppealsPage() {
  const [list, setList] = useStatePB(PB_APPEALS);
  const [open, setOpen] = useStatePB(null);
  const decide = (id) => { setList((l) => l.filter((a) => a.id !== id)); setOpen(null); };
  return (
    <div style={{ display: 'grid', gridTemplateColumns: open ? '1fr 380px' : '1fr', gap: 18, transition: 'all .2s' }}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <span style={{ fontFamily: 'var(--font-mono)', fontSize: 13, color: 'var(--hp-text-2)' }}>{list.length} awaiting review</span>
        </div>
        {list.map((a) => (
          <Card key={a.id} hover padding={16} onClick={() => setOpen(a)} style={{ cursor: 'pointer', borderColor: open && open.id === a.id ? 'var(--hp-border-focus)' : undefined }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
              <div style={{ position: 'relative', width: 80, height: 56, borderRadius: 10, overflow: 'hidden', background: 'radial-gradient(120% 90% at 50% 20%, #23233a, #0c0c14)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                <PBIcon name={a.video ? 'play' : 'file-text'} size={20} color="#fff" />
                {a.video && <span style={{ position: 'absolute', bottom: 4, right: 4, fontFamily: 'var(--font-mono)', fontSize: 8.5, color: '#fff', background: 'rgba(0,0,0,0.6)', padding: '1px 4px', borderRadius: 3 }}>0:18</span>}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 4 }}>
                  <span className="hp-plate" style={{ fontSize: 12.5 }}>{a.plate}</span>
                  <Badge status="review" />
                </div>
                <div style={{ fontSize: 14.5, fontWeight: 600, color: '#fff' }}>{a.reason}</div>
                <div style={{ fontSize: 12.5, color: 'var(--hp-text-muted)' }}>{a.by} · {a.when} · {pbMoney(a.fine)}</div>
              </div>
              <PBIcon name="chevron-right" size={18} color="var(--hp-text-muted)" />
            </div>
          </Card>
        ))}
        {list.length === 0 && (
          <Card padding={40} style={{ textAlign: 'center' }}>
            <PBIcon name="check-circle" size={30} color="var(--hp-success)" />
            <div style={{ fontSize: 15, fontWeight: 600, color: '#fff', marginTop: 12 }}>All appeals reviewed</div>
            <div style={{ fontSize: 13, color: 'var(--hp-text-muted)', marginTop: 4 }}>Nothing in the queue. Nice work.</div>
          </Card>
        )}
      </div>
      {open && (
        <Card padding={0} style={{ alignSelf: 'start', position: 'sticky', top: 18 }}>
          <div style={{ position: 'relative', aspectRatio: '16/10', background: 'radial-gradient(120% 90% at 50% 20%, #23233a, #0c0c14)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <div style={{ width: 52, height: 52, borderRadius: '50%', background: 'rgba(255,255,255,0.16)', backdropFilter: 'blur(4px)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><PBIcon name="play" size={22} color="#fff" /></div>
            <span style={{ position: 'absolute', top: 12, left: 12, fontSize: 11.5, fontWeight: 600, color: '#fff', background: 'rgba(0,0,0,0.55)', padding: '3px 9px', borderRadius: 999 }}>Driver video appeal</span>
          </div>
          <div style={{ padding: 18 }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}><span className="hp-plate" style={{ fontSize: 13 }}>{open.plate}</span><span style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--hp-text-muted)' }}>{open.id}</span></div>
            <div style={{ fontSize: 16, fontWeight: 700, color: '#fff' }}>{open.reason}</div>
            <div style={{ fontSize: 13, color: 'var(--hp-text-2)', margin: '8px 0 16px', lineHeight: 1.5 }}>"{open.by === 'Amina Yusuf' ? 'The loading bay sign was covered by a parked truck — I had no way to see the restriction.' : 'I paid via ZAAD but the meter did not register my session in time.'}"</div>
            <div style={{ display: 'flex', justifyContent: 'space-between', padding: '11px 0', borderTop: '1px solid var(--hp-border)', borderBottom: '1px solid var(--hp-border)', marginBottom: 16 }}>
              <span style={{ fontSize: 13, color: 'var(--hp-text-2)' }}>Fine in dispute</span>
              <span style={{ fontFamily: 'var(--font-mono)', fontWeight: 700, fontSize: 15, color: '#fff' }}>{pbMoney(open.fine)}</span>
            </div>
            <div style={{ display: 'flex', gap: 10 }}>
              <Button size="lg" variant="danger" onClick={() => decide(open.id)} icon={<PBIcon name="x" size={17} />} style={{ flex: 1 }}>Uphold</Button>
              <Button size="lg" onClick={() => decide(open.id)} icon={<PBIcon name="check" size={17} />} style={{ flex: 1 }}>Dismiss</Button>
            </div>
          </div>
        </Card>
      )}
    </div>
  );
}

/* ---- Reports ------------------------------------------------------------- */
const TREND = [42, 51, 47, 63, 58, 71, 68, 82, 76, 91, 88, 97];
function ReportsPage() {
  const maxRev = Math.max(...PB_ZONES.map((z) => z.revenue));
  const zad = 62, edahab = 38;
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
      <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: 18 }}>
        {/* citations trend */}
        <Card padding={20}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 18 }}>
            <div><h4 style={{ fontSize: 16 }}>Citations issued</h4><div style={{ fontSize: 12.5, color: 'var(--hp-text-muted)' }}>Last 12 weeks</div></div>
            <span style={{ fontFamily: 'var(--font-mono)', fontSize: 13, color: 'var(--hp-success)' }}>▲ +18%</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'flex-end', gap: 8, height: 150 }}>
            {TREND.map((v, i) => (
              <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', height: '100%' }}>
                <div style={{ height: (v / 100 * 100) + '%', borderRadius: '5px 5px 0 0', background: i === TREND.length - 1 ? 'var(--hp-gradient)' : 'var(--hp-purple-tint)', border: i === TREND.length - 1 ? 'none' : '1px solid rgba(124,108,248,0.3)' }} />
              </div>
            ))}
          </div>
        </Card>
        {/* payment split */}
        <Card padding={20}>
          <h4 style={{ fontSize: 16, marginBottom: 18 }}>Payment methods</h4>
          <div style={{ display: 'flex', alignItems: 'center', gap: 20 }}>
            <div style={{ width: 120, height: 120, borderRadius: '50%', background: `conic-gradient(var(--hp-teal) 0% ${zad}%, var(--hp-purple) ${zad}% 100%)`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <div style={{ width: 78, height: 78, borderRadius: '50%', background: 'var(--hp-surface)', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
                <span style={{ fontFamily: 'var(--font-mono)', fontSize: 18, fontWeight: 700, color: '#fff' }}>4.2M</span>
                <span style={{ fontSize: 10, color: 'var(--hp-text-muted)' }}>today</span>
              </div>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
              {[['ZAAD', 'Telesom', zad, 'var(--hp-teal)'], ['eDahab', 'Dahabshiil', edahab, 'var(--hp-purple)']].map(([n, s, p, c]) => (
                <div key={n} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <span style={{ width: 12, height: 12, borderRadius: 4, background: c }} />
                  <div><div style={{ fontSize: 14, fontWeight: 600, color: '#fff' }}>{n} <span style={{ fontFamily: 'var(--font-mono)', color: 'var(--hp-text-2)', fontWeight: 400 }}>{p}%</span></div><div style={{ fontSize: 11.5, color: 'var(--hp-text-muted)' }}>{s}</div></div>
                </div>
              ))}
            </div>
          </div>
        </Card>
      </div>
      {/* revenue by zone */}
      <Card padding={20}>
        <h4 style={{ fontSize: 16, marginBottom: 18 }}>Revenue by district (this month)</h4>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {[...PB_ZONES].sort((a, b) => b.revenue - a.revenue).map((z) => (
            <div key={z.zone} style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
              <span style={{ width: 130, fontSize: 13, color: 'var(--hp-text-2)', flexShrink: 0 }}>{z.name}</span>
              <div style={{ flex: 1, height: 12, borderRadius: 999, background: 'var(--hp-overlay)', overflow: 'hidden' }}><div style={{ width: (z.revenue / maxRev * 100) + '%', height: '100%', background: 'var(--hp-gradient)', borderRadius: 999 }} /></div>
              <span style={{ width: 56, textAlign: 'right', fontFamily: 'var(--font-mono)', fontSize: 13, color: '#fff', flexShrink: 0 }}>{(z.revenue / 1000000).toFixed(1)}M</span>
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}

Object.assign(window, { CmdVehiclesPage: VehiclesPage, CmdAppealsPage: AppealsPage, CmdReportsPage: ReportsPage });
