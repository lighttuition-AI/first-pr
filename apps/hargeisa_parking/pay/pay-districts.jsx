/* global React, Button, Badge, Card */
/* HPark Pay — Districts interactive map, shop deals, coupon, video appeal */
const { useState: useStateD, useEffect: useEffectD, useRef: useRefD } = React;
const DIcon = window.PayIcon;
const D_DISTRICTS = window.PAY_DISTRICTS;
const dDealsFor = window.payDealsFor;
const dMoney = window.payMoney;
const dLoadColor = window.payLoadColor;

/* Renders a real scannable QR code (uses the qrcode-generator lib loaded in the page) */
function QRBox({ text, size = 132 }) {
  const ref = useRefD(null);
  useEffectD(() => {
    let stop = false;
    (function go() {
      if (stop || !ref.current) return;
      if (typeof window.qrcode === 'undefined') return setTimeout(go, 50);
      const qr = window.qrcode(0, 'M');
      qr.addData(text);
      qr.make();
      ref.current.innerHTML = qr.createImgTag(4, 0);
      const img = ref.current.querySelector('img');
      if (img) { img.style.width = size + 'px'; img.style.height = size + 'px'; img.style.display = 'block'; img.style.imageRendering = 'pixelated'; img.style.borderRadius = '4px'; }
    })();
    return () => { stop = true; };
  }, [text, size]);
  return <div ref={ref} style={{ width: size, height: size }} />;
}

/* ---- Map geometry -------------------------------------------------------- */
const GP = [
[[10, 14], [112, 8], [210, 16], [310, 10]],
[[6, 118], [122, 132], [225, 116], [314, 126]],
[[12, 250], [105, 238], [214, 252], [308, 240]],
[[8, 352], [110, 360], [218, 350], [312, 358]]];

const CELLS = [
[0, 0], [0, 1], [0, 2],
[1, 0], [1, 1], [1, 2],
[2, 0], [2, 1], [2, 2]];

function cellCorners(r, c) {return [GP[r][c], GP[r][c + 1], GP[r + 1][c + 1], GP[r + 1][c]];}
function polyPath(pts) {return 'M' + pts.map((p) => p.join(',')).join(' L') + ' Z';}
function centroid(pts) {
  const x = pts.reduce((s, p) => s + p[0], 0) / pts.length;
  const y = pts.reduce((s, p) => s + p[1], 0) / pts.length;
  return [x, y];
}

function HargeisaMap({ selected, onSelect }) {
  return (
    <svg viewBox="0 0 320 368" style={{ width: '100%', display: 'block', borderRadius: 'var(--radius-lg)', background: '#0C0C14', border: '1px solid var(--hp-border)' }}>
      <defs>
        <filter id="distGlow" x="-30%" y="-30%" width="160%" height="160%">
          <feGaussianBlur stdDeviation="4" result="b" /><feMerge><feMergeNode in="b" /><feMergeNode in="SourceGraphic" /></feMerge>
        </filter>
      </defs>
      {/* subtle street grid */}
      <g opacity="0.5">
        {[60, 120, 180, 240, 300].map((x) => <line key={'v' + x} x1={x} y1="0" x2={x} y2="368" stroke="rgba(124,108,248,0.06)" strokeWidth="1" />)}
        {[70, 140, 210, 280].map((y) => <line key={'h' + y} x1="0" y1={y} x2="320" y2={y} stroke="rgba(124,108,248,0.06)" strokeWidth="1" />)}
      </g>
      {/* district regions */}
      {CELLS.map(([r, c], i) => {
        const pts = cellCorners(r, c);
        const d = D_DISTRICTS[i];
        const on = selected === d.id;
        const [cx, cy] = centroid(pts);
        return (
          <g key={d.id} onClick={() => onSelect(d.id)} style={{ cursor: 'pointer' }}>
            <path d={polyPath(pts)} fill={on ? 'rgba(124,108,248,0.22)' : 'rgba(20,20,32,0.85)'}
            stroke={on ? 'var(--hp-purple)' : 'rgba(255,255,255,0.10)'} strokeWidth={on ? 2 : 1.2}
            filter={on ? 'url(#distGlow)' : undefined} />
            <text x={cx} y={cy - 4} textAnchor="middle" fontFamily="var(--font-body)" fontSize="10" fontWeight="600" fill={on ? '#fff' : 'var(--hp-text-2)'}>{d.name}</text>
            <g transform={`translate(${cx}, ${cy + 12})`}>
              <circle r="9" fill={on ? 'var(--hp-teal)' : 'rgba(0,216,214,0.18)'} stroke="var(--hp-teal)" strokeWidth="1" />
              <text textAnchor="middle" y="3.3" fontFamily="var(--font-mono)" fontSize="9" fontWeight="700" fill={on ? '#04201f' : 'var(--hp-teal)'}>{d.deals}</text>
            </g>
          </g>);

      })}
      {/* main avenue */}
      <path d="M0,128 C90,150 230,108 320,130" fill="none" stroke="rgba(255,255,255,0.10)" strokeWidth="5" />
      {/* you-are-here */}
      <g transform="translate(168,180)">
        <circle r="6" fill="var(--hp-purple)" stroke="#fff" strokeWidth="2" />
        <circle r="12" fill="none" stroke="var(--hp-purple)" strokeWidth="1" opacity="0.5" />
      </g>
    </svg>);

}

function DistrictsTab({ onOpen }) {
  const [sel, setSel] = useStateD(null);
  useEffectD(() => {if (window.lucide) window.lucide.createIcons();});
  return (
    <div style={{ flex: 1, overflow: 'auto', padding: '4px 20px 24px' }}>
      <div style={{ padding: '8px 0 6px' }}>
        <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 22, color: 'var(--hp-text)' }}>Districts & deals</div>
        <div style={{ fontSize: 13.5, color: 'var(--hp-text-2)', marginTop: 2 }}>Tap a district to see parking and local offers.</div>
      </div>
      <div style={{ position: 'relative', margin: '14px 0 16px' }}>
        <HargeisaMap selected={sel} onSelect={setSel} />
        <div style={{ position: 'absolute', right: 12, top: 12, display: 'flex', alignItems: 'center', gap: 7, padding: '6px 11px', borderRadius: 'var(--radius-pill)', background: 'rgba(10,10,15,0.72)', backdropFilter: 'var(--blur-bg)', border: '1px solid var(--hp-border)', fontSize: 11.5, fontWeight: 600, color: 'var(--hp-text)' }}>
          <span style={{ width: 7, height: 7, borderRadius: '50%', background: 'var(--hp-teal)' }} /> deals
        </div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {D_DISTRICTS.map((d) =>
        <button key={d.id} onClick={() => onOpen(d)} onMouseEnter={() => setSel(d.id)}
        style={{ display: 'flex', alignItems: 'center', gap: 13, padding: 14, borderRadius: 'var(--radius-lg)', cursor: 'pointer', textAlign: 'left',
          background: sel === d.id ? 'var(--hp-purple-tint)' : 'var(--hp-surface)', border: `1px solid ${sel === d.id ? 'var(--hp-border-focus)' : 'var(--hp-border)'}`, color: 'var(--hp-text)' }}>
            <div style={{ width: 40, height: 40, borderRadius: 11, background: 'var(--hp-overlay)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <DIcon name="map-pin" size={18} color="var(--hp-purple-300)" />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 15, fontWeight: 600 }}>{d.name}</div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 3, fontSize: 12, color: 'var(--hp-text-muted)' }}>
                <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}><span style={{ width: 7, height: 7, borderRadius: '50%', background: dLoadColor(d.load) }} />{d.spaces} free</span>
                <span style={{ fontFamily: 'var(--font-mono)' }}>· {d.deals} deals</span>
              </div>
            </div>
            <DIcon name="chevron-right" size={18} color="var(--hp-text-muted)" />
          </button>
        )}
      </div>
    </div>);

}

/* District detail — parking summary + shop deals */
function DistrictDetail({ district, onBack, onCoupon }) {
  const deals = dDealsFor(district.id);
  const featured = deals.find((d) => d.tag === 'Featured') || deals[0];
  const rest = deals.filter((d) => d !== featured);
  useEffectD(() => {if (window.lucide) window.lucide.createIcons();});
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minHeight: 0 }}>
      <div style={{ padding: '6px 20px 12px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={onBack} style={{ width: 38, height: 38, borderRadius: 10, background: 'var(--hp-overlay)', border: '1px solid var(--hp-border)', color: 'var(--hp-text)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <DIcon name="arrow-left" size={18} />
        </button>
        <div>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 20, color: 'var(--hp-text)' }}>{district.name}</div>
          <div style={{ fontSize: 12.5, color: 'var(--hp-text-muted)' }}>{district.deals} active deals</div>
        </div>
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '0 20px 20px' }}>
        {/* parking summary */}
        <div style={{ display: 'flex', gap: 10, marginBottom: 16 }}>
          {[['Free spaces', district.spaces, 'circle-parking', dLoadColor(district.load)], ['Status', district.load === 'busy' ? 'Busy' : 'Open', 'activity', dLoadColor(district.load)]].map(([k, v, ic, c]) =>
          <div key={k} style={{ flex: 1, padding: 14, borderRadius: 'var(--radius-lg)', background: 'var(--hp-surface)', border: '1px solid var(--hp-border)' }}>
              <DIcon name={ic} size={17} color={c} />
              <div style={{ fontFamily: 'var(--font-mono)', fontSize: 22, fontWeight: 700, color: '#fff', marginTop: 8 }}>{v}</div>
              <div style={{ fontSize: 12, color: 'var(--hp-text-muted)' }}>{k}</div>
            </div>
          )}
        </div>

        {/* featured deal */}
        <window.PaySectionLabel>Featured offer</window.PaySectionLabel>
        <button onClick={() => onCoupon(featured)} style={{ width: '100%', textAlign: 'left', cursor: 'pointer', border: '1px solid rgba(124,108,248,0.3)', borderRadius: 'var(--radius-xl)', overflow: 'hidden', background: 'linear-gradient(135deg, rgba(124,108,248,0.2), rgba(0,216,214,0.12))', padding: 18, marginBottom: 18, color: 'var(--hp-text)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
            <div style={{ width: 52, height: 52, borderRadius: 14, background: 'var(--hp-gradient)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <DIcon name={featured.icon} size={24} color="#fff" />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span style={{ fontSize: 16, fontWeight: 700, color: '#fff' }}>{featured.shop}</span>
                <span style={{ fontSize: 11, fontWeight: 700, color: '#04201f', background: 'var(--hp-teal)', padding: '2px 8px', borderRadius: 999 }}>{featured.off}</span>
              </div>
              <div style={{ fontSize: 13, color: 'var(--hp-text-2)', marginTop: 4 }}>{featured.desc}</div>
            </div>
          </div>
        </button>

        {/* more deals */}
        <window.PaySectionLabel>More deals nearby</window.PaySectionLabel>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {rest.map((d) =>
          <button key={d.shop} onClick={() => onCoupon(d)} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: 14, borderRadius: 'var(--radius-lg)', cursor: 'pointer', textAlign: 'left', background: 'var(--hp-surface)', border: '1px solid var(--hp-border)', color: 'var(--hp-text)' }}>
              <div style={{ width: 42, height: 42, borderRadius: 11, background: 'var(--hp-overlay)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                <DIcon name={d.icon} size={19} color="var(--hp-teal)" />
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14.5, fontWeight: 600 }}>{d.shop}</div>
                <div style={{ fontSize: 12.5, color: 'var(--hp-text-muted)' }}>{d.cat} · {d.desc}</div>
              </div>
              <span style={{ fontSize: 12.5, fontWeight: 700, color: 'var(--hp-teal)', whiteSpace: 'nowrap' }}>{d.off}</span>
            </button>
          )}
        </div>
      </div>
    </div>);

}

function CouponModal({ deal, onClose }) {
  const code = 'HP-' + deal.shop.replace(/[^A-Z]/gi, '').slice(0, 4).toUpperCase() + '-26';
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 40, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 26 }}>
      <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(3px)' }} />
      <div style={{ position: 'relative', width: '100%', background: 'var(--hp-elevated)', borderRadius: 'var(--radius-2xl)', border: '1px solid var(--hp-border)', overflow: 'hidden' }}>
        <div style={{ padding: '26px 24px 20px', textAlign: 'center', background: 'linear-gradient(135deg, rgba(124,108,248,0.22), rgba(0,216,214,0.14))' }}>
          <div style={{ width: 60, height: 60, borderRadius: 16, background: 'var(--hp-gradient)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 14px' }}>
            <DIcon name={deal.icon} size={28} color="#fff" />
          </div>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 22, color: '#fff' }}>{deal.off} at {deal.shop}</div>
          <div style={{ fontSize: 13.5, color: 'var(--hp-text-2)', marginTop: 4 }}>{deal.desc}</div>
        </div>
        <div style={{ padding: 22 }}>
          <div style={{ fontSize: 12, color: 'var(--hp-text-muted)', textAlign: 'center', marginBottom: 12 }}>Scan at the till to redeem</div>
          <div data-comment-anchor="3d8ff85b22-div-193-11" style={{ display: 'flex', justifyContent: 'center', marginBottom: 14 }}>
            <div style={{ background: '#fff', padding: 12, borderRadius: 14, boxShadow: '0 10px 26px -10px rgba(0,0,0,0.55)' }}>
              <QRBox text={'HPARK-DEAL:' + code + ':' + deal.shop} size={132} />
            </div>
          </div>
          <div style={{ textAlign: 'center', fontFamily: 'var(--font-mono)', fontSize: 18, fontWeight: 700, letterSpacing: '0.12em', color: '#fff', marginBottom: 18 }}>{code}</div>
          <Button block size="lg" onClick={onClose}>Done</Button>
        </div>
      </div>
    </div>);

}

/* ---- Video appeal flow --------------------------------------------------- */
function AppealFlow({ cite, onClose, onSubmitted }) {
  const [step, setStep] = useStateD('intro'); // intro | record | review | done
  const [secs, setSecs] = useStateD(0);
  const [recording, setRecording] = useStateD(false);
  useEffectD(() => {if (window.lucide) window.lucide.createIcons();});
  useEffectD(() => {
    if (!recording) return;
    const t = setInterval(() => setSecs((s) => s + 1), 1000);
    return () => clearInterval(t);
  }, [recording]);
  const mmss = (s) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;

  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 50, background: 'var(--hp-bg)', display: 'flex', flexDirection: 'column' }}>
      {window.HPStatusBar({ dark: true })}
      <div style={{ padding: '6px 20px 12px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={onClose} style={{ width: 38, height: 38, borderRadius: 10, background: 'var(--hp-overlay)', border: '1px solid var(--hp-border)', color: 'var(--hp-text)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <DIcon name="x" size={18} />
        </button>
        <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 18, color: 'var(--hp-text)' }}>Challenge citation</div>
      </div>

      {step === 'intro' &&
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '4px 24px 26px', overflow: 'auto' }}>
          <Card padding={16} style={{ marginBottom: 18 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
              <window.PayPlate>{cite.plate}</window.PayPlate><Badge status={cite.status} />
            </div>
            <div style={{ fontSize: 15, fontWeight: 600, color: '#fff' }}>{cite.reason}</div>
            <div style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--hp-text-muted)', marginTop: 2 }}>{cite.id} · {dMoney(cite.fine)}</div>
          </Card>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 20, color: '#fff', marginBottom: 6 }}>Record your explanation</div>
          <div style={{ fontSize: 14, color: 'var(--hp-text-2)', lineHeight: 1.55, marginBottom: 18 }}>Record a short video (max 60s) explaining why you're challenging this citation. An adjudicator will review it and decide your case.</div>
          {[['video', 'Speak clearly and show any evidence'], ['clock', 'Keep it under 60 seconds'], ['shield', 'Your video is private to the review team']].map(([ic, t]) =>
        <div key={t} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '11px 0', borderBottom: '1px solid var(--hp-border)' }}>
              <DIcon name={ic} size={18} color="var(--hp-purple-300)" />
              <span style={{ fontSize: 13.5, color: 'var(--hp-text-2)' }}>{t}</span>
            </div>
        )}
          <div style={{ flex: 1 }} />
          <Button block size="xl" onClick={() => setStep('record')} icon={<DIcon name="video" size={19} />} style={{ marginTop: 22 }}>Start recording</Button>
        </div>
      }

      {step === 'record' &&
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '4px 16px 24px' }}>
          {/* viewfinder */}
          <div style={{ flex: 1, borderRadius: 'var(--radius-xl)', position: 'relative', overflow: 'hidden', background: 'radial-gradient(120% 90% at 50% 20%, #23233a, #0c0c14)', border: '1px solid var(--hp-border)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', opacity: 0.18 }}>
              <DIcon name="user" size={120} color="#fff" />
            </div>
            {recording &&
          <div style={{ position: 'absolute', top: 14, left: 14, display: 'flex', alignItems: 'center', gap: 7, padding: '5px 11px', borderRadius: 999, background: 'rgba(0,0,0,0.55)', fontFamily: 'var(--font-mono)', fontSize: 13, fontWeight: 600, color: '#fff' }}>
                <span style={{ width: 9, height: 9, borderRadius: '50%', background: 'var(--hp-danger)', animation: 'pulse 1s infinite' }} /> {mmss(secs)}
              </div>
          }
            <div style={{ position: 'absolute', bottom: 14, left: 14, display: 'flex', alignItems: 'center', gap: 7, padding: '5px 11px', borderRadius: 999, background: 'rgba(0,0,0,0.55)', fontSize: 12, color: 'var(--hp-text-2)' }}>
              <DIcon name="map-pin" size={13} color="var(--hp-teal)" /> {cite.zone}
            </div>
          </div>
          {/* record control */}
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, padding: '20px 0 4px' }}>
            <button onClick={() => {if (recording) {setRecording(false);setStep('review');} else {setSecs(0);setRecording(true);}}}
          style={{ width: 74, height: 74, borderRadius: '50%', border: '4px solid rgba(255,255,255,0.85)', background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <div style={{ width: recording ? 26 : 58, height: recording ? 26 : 58, borderRadius: recording ? 7 : '50%', background: 'var(--hp-danger)', transition: 'all .2s' }} />
            </button>
            <span style={{ fontSize: 12.5, color: 'var(--hp-text-muted)' }}>{recording ? 'Tap to stop' : 'Tap to record'}</span>
          </div>
        </div>
      }

      {step === 'review' &&
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '4px 24px 24px', overflow: 'auto' }}>
          <div style={{ position: 'relative', aspectRatio: '4/3', borderRadius: 'var(--radius-xl)', overflow: 'hidden', background: 'radial-gradient(120% 90% at 50% 20%, #23233a, #0c0c14)', border: '1px solid var(--hp-border)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 16 }}>
            <div style={{ width: 56, height: 56, borderRadius: '50%', background: 'rgba(255,255,255,0.16)', display: 'flex', alignItems: 'center', justifyContent: 'center', backdropFilter: 'blur(4px)' }}>
              <DIcon name="play" size={24} color="#fff" />
            </div>
            <div style={{ position: 'absolute', bottom: 12, right: 14, fontFamily: 'var(--font-mono)', fontSize: 12.5, color: '#fff', background: 'rgba(0,0,0,0.5)', padding: '3px 8px', borderRadius: 6 }}>{mmss(secs || 18)}</div>
          </div>
          <Card padding={16} style={{ marginBottom: 'auto' }}>
            <div style={{ fontSize: 14, fontWeight: 600, color: '#fff', marginBottom: 6 }}>Add a note (optional)</div>
            <textarea placeholder="Briefly summarise your appeal…" style={{ width: '100%', minHeight: 72, resize: 'none', border: 'none', outline: 'none', background: 'transparent', color: 'var(--hp-text)', fontFamily: 'var(--font-body)', fontSize: 14 }} />
          </Card>
          <div style={{ display: 'flex', gap: 10, marginTop: 18 }}>
            <Button size="lg" variant="secondary" onClick={() => setStep('record')} icon={<DIcon name="rotate-ccw" size={17} />} style={{ flex: 1 }}>Re-record</Button>
            <Button size="lg" onClick={() => setStep('done')} style={{ flex: 1.4 }}>Submit appeal</Button>
          </div>
        </div>
      }

      {step === 'done' &&
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 30, textAlign: 'center' }}>
          <div style={{ width: 92, height: 92, borderRadius: '50%', background: 'rgba(0,216,214,0.14)', border: '1px solid rgba(0,216,214,0.4)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 0 0 8px rgba(0,216,214,0.05)' }}>
            <DIcon name="gavel" size={40} color="var(--hp-teal)" />
          </div>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 24, color: '#fff', marginTop: 22 }}>Appeal submitted</div>
          <div style={{ fontSize: 14, color: 'var(--hp-text-2)', marginTop: 6, maxWidth: 260 }}>Case {cite.id} is now under review. You'll hear back within 5 working days.</div>
          <div style={{ width: '100%', marginTop: 30 }}><Button block size="lg" onClick={onSubmitted}>Back to citations</Button></div>
        </div>
      }
    </div>);

}

Object.assign(window, { PayDistrictsTab: DistrictsTab, PayDistrictDetail: DistrictDetail, PayCouponModal: CouponModal, PayAppealFlow: AppealFlow });