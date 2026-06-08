/* global React, Button, Badge, Card, Input */
/* HPark Enforce — citation flow: search/scan/LPR → found → violation → evidence → review → issued */
const { useState: useStateEF, useEffect: useEffectEF, useRef: useRefEF } = React;
const EFIcon = window.EnfIcon;
const EF_VIOLATIONS = window.ENF_VIOLATIONS;
const EF_VEHICLE = window.ENF_VEHICLE;
const efMoney = window.enfMoney;
const EFShell = window.EnfScreenShell;
const EFPlate = window.EnfPlate;

/* Step 0 — search: scan / LPR / manual */
function SearchScreen({ offline, onFound }) {
  const [lpr, setLpr] = useStateEF(false);
  const [plate, setPlate] = useStateEF('HG-4821');
  useEffectEF(() => { if (lpr) { const t = setTimeout(() => { setLpr(false); onFound(); }, 1700); return () => clearTimeout(t); } }, [lpr]);
  return (
    <EFShell title="Vehicle lookup" sub={offline ? 'Offline · using cached vehicle data' : 'Real-time permit & payment check'}>
      {/* scan / LPR target */}
      <div style={{ position: 'relative', width: '100%', aspectRatio: '16/10', borderRadius: 'var(--radius-xl)', overflow: 'hidden', border: '1px solid rgba(124,108,248,0.3)', background: 'linear-gradient(160deg, rgba(124,108,248,0.16), rgba(0,216,214,0.08))', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 12 }}>
        {lpr ? (
          <>
            <div style={{ position: 'absolute', inset: 0, background: 'repeating-linear-gradient(180deg, rgba(0,216,214,0.04) 0 2px, transparent 2px 5px)' }} />
            <div style={{ position: 'absolute', left: '8%', right: '8%', height: 2, background: 'var(--hp-teal)', boxShadow: '0 0 12px var(--hp-teal)', animation: 'scanline 1.6s ease-in-out infinite' }} />
            <div style={{ width: 150, height: 60, border: '2px solid var(--hp-teal)', borderRadius: 8, display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: 'var(--font-mono)', fontWeight: 700, fontSize: 24, letterSpacing: '0.12em', color: '#fff', zIndex: 1 }}>{plate}</div>
            <span style={{ fontSize: 13, color: 'var(--hp-teal)', zIndex: 1 }}>Reading plate…</span>
          </>
        ) : (
          <>
            <div style={{ width: 64, height: 64, borderRadius: 18, background: 'var(--hp-gradient)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><EFIcon name="scan-line" size={30} color="#fff" /></div>
            <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 18, color: '#fff' }}>Scan number plate</div>
            <div style={{ fontSize: 13, color: 'var(--hp-text-2)' }}>LPR auto-detects the plate</div>
          </>
        )}
      </div>
      <Button block size="lg" variant="secondary" onClick={() => setLpr(true)} disabled={lpr} icon={<EFIcon name="camera" size={18} />} style={{ marginTop: 12 }}>{lpr ? 'Scanning…' : 'Start LPR scan'}</Button>

      <div style={{ display: 'flex', alignItems: 'center', gap: 12, margin: '18px 0' }}>
        <div style={{ flex: 1, height: 1, background: 'var(--hp-border)' }} />
        <span style={{ fontSize: 12, color: 'var(--hp-text-muted)' }}>or enter manually</span>
        <div style={{ flex: 1, height: 1, background: 'var(--hp-border)' }} />
      </div>
      <Input plate size="xl" value={plate} onChange={(e) => setPlate(e.target.value)} containerStyle={{ marginBottom: 14 }} />
      <Button block size="lg" onClick={onFound} icon={<EFIcon name="search" size={18} />}>Look up vehicle</Button>

      <div style={{ marginTop: 22 }}>
        <div className="hp-eyebrow" style={{ marginBottom: 10 }}>Recent</div>
        {[['HG-2210', '2 min ago'], ['SL-09122', '14 min ago']].map(([p, t]) => (
          <div key={p} onClick={onFound} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '11px 0', borderBottom: '1px solid var(--hp-border)', cursor: 'pointer' }}>
            <EFPlate>{p}</EFPlate>
            <span style={{ fontSize: 13, color: 'var(--hp-text-muted)', marginLeft: 'auto' }}>{t}</span>
            <EFIcon name="chevron-right" size={16} color="var(--hp-text-muted)" />
          </div>
        ))}
      </div>
    </EFShell>
  );
}

function InfoRow({ icon, label, children, danger }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 0', borderBottom: '1px solid var(--hp-border)' }}>
      <EFIcon name={icon} size={18} color="var(--hp-text-muted)" />
      <span style={{ fontSize: 14, color: 'var(--hp-text-2)' }}>{label}</span>
      <span style={{ marginLeft: 'auto', fontSize: 14, fontWeight: 600, color: danger ? 'var(--hp-danger)' : 'var(--hp-text)', textAlign: 'right' }}>{children}</span>
    </div>
  );
}

function FoundScreen({ offline, onBack, onIssue }) {
  const v = EF_VEHICLE;
  return (
    <EFShell title="Vehicle found" sub={offline ? 'Cached 6 min ago' : 'Live record'} onBack={onBack}>
      <Card glow padding={18} style={{ marginBottom: 16 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 6 }}>
          <EFPlate size={22}>{v.plate}</EFPlate>
          <Badge status="overdue" />
        </div>
        <div style={{ fontSize: 13, color: 'var(--hp-text-muted)', marginBottom: 6 }}>{v.model}</div>
        <InfoRow icon="user" label="Owner">{v.owner}</InfoRow>
        <InfoRow icon="circle-parking" label="Parking status" danger>{v.parking}</InfoRow>
        <InfoRow icon="badge-check" label="Permit" danger>{v.permit}</InfoRow>
        <InfoRow icon="file-text" label="Outstanding">{v.outstanding} citation</InfoRow>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 0 2px' }}>
          <EFIcon name="map-pin" size={18} color="var(--hp-text-muted)" />
          <span style={{ fontSize: 14, color: 'var(--hp-text-2)' }}>Last seen</span>
          <span style={{ marginLeft: 'auto', fontSize: 13, fontWeight: 600, color: 'var(--hp-text)' }}>{v.lastSeen}</span>
        </div>
      </Card>
      <Button block size="xl" variant="danger" onClick={onIssue} icon={<EFIcon name="file-plus" size={19} />}>Issue citation</Button>
    </EFShell>
  );
}

function ViolationScreen({ onBack, onNext, selected, setSelected }) {
  return (
    <EFShell title="Select violation" sub="Step 1 of 3" onBack={onBack}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {EF_VIOLATIONS.map(([name, icon, fine], i) => {
          const on = selected === i;
          return (
            <button key={name} onClick={() => setSelected(i)} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: 15, textAlign: 'left', cursor: 'pointer', borderRadius: 'var(--radius-lg)', background: 'var(--hp-surface)', border: `1px solid ${on ? 'var(--hp-border-focus)' : 'var(--hp-border)'}`, boxShadow: on ? 'var(--glow-purple-sm)' : 'none', color: 'var(--hp-text)' }}>
              <div style={{ width: 40, height: 40, borderRadius: 11, flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', background: on ? 'var(--hp-purple-tint)' : 'var(--hp-overlay)', color: on ? 'var(--hp-purple-300)' : 'var(--hp-text-2)' }}>
                <EFIcon name={icon} size={19} />
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, fontWeight: 600 }}>{name}</div>
                <div style={{ fontFamily: 'var(--font-mono)', fontSize: 12.5, color: 'var(--hp-text-muted)' }}>{efMoney(fine)}</div>
              </div>
              <div style={{ width: 22, height: 22, borderRadius: '50%', border: `2px solid ${on ? 'var(--hp-purple)' : 'var(--hp-border-strong)'}`, background: on ? 'var(--hp-purple)' : 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{on && <EFIcon name="check" size={13} color="#fff" />}</div>
            </button>
          );
        })}
      </div>
      <div style={{ marginTop: 16 }}>
        <Button block size="lg" disabled={selected == null} onClick={onNext} iconRight={<EFIcon name="arrow-right" size={18} />}>Continue</Button>
      </div>
    </EFShell>
  );
}

/* evidence: photos + a short video + GPS lock */
function EvidenceScreen({ offline, onBack, onNext }) {
  const [shots, setShots] = useStateEF(2);
  const [hasVideo, setHasVideo] = useStateEF(false);
  const [recording, setRecording] = useStateEF(false);
  useEffectEF(() => { if (!recording) return; const t = setTimeout(() => { setRecording(false); setHasVideo(true); }, 1800); return () => clearTimeout(t); }, [recording]);
  return (
    <EFShell title="Capture evidence" sub="Step 2 of 3" onBack={onBack}>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 12 }}>
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} style={{ position: 'relative', aspectRatio: '1', borderRadius: 'var(--radius-lg)', display: 'flex', alignItems: 'center', justifyContent: 'center', border: i < shots ? '1px solid var(--hp-border)' : '1px dashed var(--hp-border-strong)', background: i < shots ? 'linear-gradient(160deg, #1a1a28, #101019)' : 'var(--hp-surface)', color: 'var(--hp-text-muted)' }}>
            {i < shots ? <EFIcon name="image" size={22} color="var(--hp-text-2)" /> : <EFIcon name="plus" size={22} />}
            {i < shots && <span style={{ position: 'absolute', bottom: 6, left: 6, fontFamily: 'var(--font-mono)', fontSize: 8.5, color: 'var(--hp-text-2)', background: 'rgba(0,0,0,0.5)', padding: '1px 4px', borderRadius: 3 }}>09:41 · GPS</span>}
          </div>
        ))}
      </div>
      <div style={{ display: 'flex', gap: 10, marginBottom: 14 }}>
        <Button size="md" variant="secondary" onClick={() => setShots((s) => Math.min(4, s + 1))} icon={<EFIcon name="camera" size={17} />} style={{ flex: 1 }}>Photo ({shots}/4)</Button>
        <Button size="md" variant={hasVideo ? 'secondary' : 'secondary'} onClick={() => setRecording(true)} disabled={recording || hasVideo} icon={<EFIcon name={hasVideo ? 'check' : 'video'} size={17} />} style={{ flex: 1 }}>{recording ? 'Rec…' : hasVideo ? 'Video ✓' : 'Video'}</Button>
      </div>
      {recording && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 9, padding: '10px 14px', borderRadius: 'var(--radius-md)', background: 'var(--hp-danger-tint)', border: '1px solid rgba(255,82,82,0.3)', marginBottom: 14 }}>
          <span style={{ width: 9, height: 9, borderRadius: '50%', background: 'var(--hp-danger)', animation: 'pulse 1s infinite' }} />
          <span style={{ fontSize: 13, color: '#fff', fontWeight: 600 }}>Recording video evidence…</span>
        </div>
      )}
      <Card padding={14} style={{ display: 'flex', alignItems: 'center', gap: 11, marginBottom: 16 }}>
        <EFIcon name="map-pin" size={18} color="var(--hp-teal)" />
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 14, fontWeight: 600, color: 'var(--hp-text)' }}>Pepsi Roundabout, Zone 4</div>
          <div style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--hp-text-muted)' }}>9.5621° N, 44.0650° E · ±4m</div>
        </div>
        <Badge status="patrol" glyph="">GPS lock</Badge>
      </Card>
      {offline && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: 13, borderRadius: 'var(--radius-md)', background: 'var(--hp-warning-tint)', border: '1px solid rgba(255,179,0,0.3)', marginBottom: 16 }}>
          <EFIcon name="cloud-off" size={18} color="var(--hp-warning)" />
          <span style={{ fontSize: 12.5, color: 'var(--hp-text)' }}>Offline — evidence saved locally, will sync when back online.</span>
        </div>
      )}
      <Button block size="lg" onClick={onNext} iconRight={<EFIcon name="arrow-right" size={18} />}>Review citation</Button>
    </EFShell>
  );
}

function ReviewScreen({ offline, violation, onBack, onIssue }) {
  const [name, icon, fine] = EF_VIOLATIONS[violation ?? 0];
  const v = EF_VEHICLE;
  return (
    <EFShell title="Review & issue" sub="Step 3 of 3" onBack={onBack}>
      <div style={{ borderRadius: 'var(--radius-xl)', border: '1px solid var(--hp-border)', overflow: 'hidden', marginBottom: 16 }}>
        <div style={{ padding: '15px 18px', background: 'var(--hp-elevated)', borderBottom: '1px dashed var(--hp-border-strong)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <img src="assets/logo-mark.svg" width="24" height="24" alt="" />
            <div style={{ fontSize: 13, fontWeight: 700, color: '#fff' }}>Citation preview</div>
          </div>
          <EFPlate>{v.plate}</EFPlate>
        </div>
        <div style={{ padding: 18, background: 'var(--hp-surface)' }}>
          <div className="hp-eyebrow">Violation</div>
          <div style={{ fontSize: 19, fontWeight: 700, color: '#fff', margin: '4px 0 4px' }}>{name}</div>
          {[['Fine', efMoney(fine)], ['Owner', v.owner], ['Location', 'Pepsi Roundabout · Zone 4'], ['Evidence', '2 photos · 1 video'], ['Officer', 'OFR-118']].map(([k, val], i, a) => (
            <div key={k} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '11px 0', borderBottom: i < a.length - 1 ? '1px solid var(--hp-border)' : 'none' }}>
              <span style={{ fontSize: 13.5, color: 'var(--hp-text-2)' }}>{k}</span>
              <span style={{ fontSize: 14, fontWeight: 600, color: '#fff', fontFamily: k === 'Fine' || k === 'Officer' ? 'var(--font-mono)' : 'var(--font-body)' }}>{val}</span>
            </div>
          ))}
        </div>
      </div>
      <Button block size="xl" variant="danger" onClick={onIssue} icon={<EFIcon name="check" size={19} />}>{offline ? 'Issue & queue for sync' : 'Issue citation'}</Button>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7, marginTop: 14, fontSize: 12.5, color: 'var(--hp-text-muted)' }}>
        <EFIcon name="smartphone" size={13} /> Driver notified by SMS on issue
      </div>
    </EFShell>
  );
}

function IssuedScreen({ offline, onDone }) {
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 28, textAlign: 'center' }}>
      <div style={{ width: 92, height: 92, borderRadius: '50%', background: 'rgba(0,200,83,0.14)', border: '1px solid rgba(0,200,83,0.4)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 22, boxShadow: '0 0 0 8px rgba(0,200,83,0.06)' }}>
        <EFIcon name="check" size={44} color="var(--hp-success)" />
      </div>
      <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 26, color: 'var(--hp-text)' }}>Citation issued</div>
      <div style={{ fontSize: 14, color: 'var(--hp-text-2)', marginTop: 6, marginBottom: 4 }}>Completed in 24 seconds</div>
      <EFPlate style={{ marginTop: 8 }}>CIT-2026-04823</EFPlate>
      <div style={{ display: 'inline-flex', alignItems: 'center', gap: 7, fontSize: 13, color: offline ? 'var(--hp-warning)' : 'var(--hp-text-muted)', marginTop: 16 }}>
        <EFIcon name={offline ? 'cloud-off' : 'cloud-check'} size={15} />
        {offline ? 'Queued — will sync when back online' : 'SMS sent · synced to Command'}
      </div>
      <div style={{ width: '100%', marginTop: 30 }}><Button block size="lg" onClick={onDone}>Done</Button></div>
    </div>
  );
}

Object.assign(window, { EnfSearchScreen: SearchScreen, EnfFoundScreen: FoundScreen, EnfViolationScreen: ViolationScreen, EnfEvidenceScreen: EvidenceScreen, EnfReviewScreen: ReviewScreen, EnfIssuedScreen: IssuedScreen });
