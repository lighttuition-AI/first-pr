/* global React */
/* HPark Pay — app shell, bottom nav, routing */
const { useState: useStateApp, useEffect: useEffectApp } = React;
const NIcon = window.PayIcon;

const PAY_TABS = [
  ['home', 'layout-dashboard', 'Home'],
  ['citations', 'file-text', 'Citations'],
  ['districts', 'map', 'Districts'],
  ['appeals', 'gavel', 'Appeals'],
  ['profile', 'user', 'Profile'],
];

function BottomNav({ active, onTab }) {
  return (
    <div style={{ flexShrink: 0, display: 'flex', alignItems: 'stretch', padding: '8px 8px 4px', borderTop: '1px solid var(--hp-border)', background: 'rgba(10,10,15,0.85)', backdropFilter: 'var(--blur-bg)' }}>
      {PAY_TABS.map(([key, icon, label]) => {
        const on = active === key;
        const center = key === 'districts';
        return (
          <button key={key} onClick={() => onTab(key)} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, padding: '6px 0', background: 'none', border: 'none', cursor: 'pointer', color: on ? 'var(--hp-purple-300)' : 'var(--hp-text-muted)' }}>
            {center ? (
              <div style={{ width: 40, height: 40, borderRadius: 13, marginTop: -10, marginBottom: -2, background: on ? 'var(--hp-gradient)' : 'var(--hp-elevated)', border: on ? 'none' : '1px solid var(--hp-border-strong)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: on ? 'var(--glow-purple-sm)' : 'none' }}>
                <NIcon name={icon} size={20} color={on ? '#fff' : 'var(--hp-text-2)'} />
              </div>
            ) : (
              <NIcon name={icon} size={22} />
            )}
            <span style={{ fontSize: 10.5, fontWeight: on ? 600 : 500 }}>{label}</span>
          </button>
        );
      })}
    </div>
  );
}

/* Appeals tab — lists citations that can be / are being appealed */
function AppealsTab({ onAppeal, onView }) {
  const cites = window.PAY_CITES;
  const appealable = cites.filter((c) => c.status === 'overdue' || c.status === 'active');
  const inReview = cites.filter((c) => c.status === 'review');
  const Plate = window.PayPlate;
  return (
    <div style={{ flex: 1, overflow: 'auto', padding: '4px 20px 24px' }}>
      <div style={{ padding: '8px 0 6px' }}>
        <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 22, color: 'var(--hp-text)' }}>Appeals</div>
        <div style={{ fontSize: 13.5, color: 'var(--hp-text-2)', marginTop: 2 }}>Challenge a citation with a short video.</div>
      </div>
      {inReview.length > 0 && <window.PaySectionLabel style={{ marginTop: 16 }}>In review</window.PaySectionLabel>}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginBottom: 18 }}>
        {inReview.map((c) => (
          <div key={c.id} onClick={() => onView(c)} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: 15, borderRadius: 'var(--radius-lg)', background: 'var(--hp-teal-tint)', border: '1px solid rgba(0,216,214,0.3)', cursor: 'pointer' }}>
            <NIcon name="clock" size={20} color="var(--hp-teal)" />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 14.5, fontWeight: 600, color: '#fff' }}>{c.reason}</div>
              <div style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--hp-text-muted)' }}>{c.id}</div>
            </div>
            <span style={{ fontSize: 12.5, fontWeight: 600, color: 'var(--hp-teal)' }}>5 days left</span>
          </div>
        ))}
      </div>
      <window.PaySectionLabel>Eligible to challenge</window.PaySectionLabel>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {appealable.map((c) => (
          <div key={c.id} style={{ padding: 16, borderRadius: 'var(--radius-lg)', background: 'var(--hp-surface)', border: '1px solid var(--hp-border)' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
              <Plate>{c.plate}</Plate>
              <span style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--hp-text-muted)' }}>{c.id}</span>
            </div>
            <div style={{ fontSize: 15, fontWeight: 600, color: '#fff' }}>{c.reason}</div>
            <div style={{ fontSize: 12.5, color: 'var(--hp-text-muted)', marginTop: 2 }}>{c.zone} · {c.date}</div>
            <Button block size="md" variant="secondary" onClick={() => onAppeal(c)} icon={<NIcon name="video" size={16} />} style={{ marginTop: 14 }}>Record video appeal</Button>
          </div>
        ))}
      </div>
    </div>
  );
}

function PayApp() {
  const [user, setUser] = useStateApp(null);
  const [tab, setTab] = useStateApp('home');
  const [detail, setDetail] = useStateApp(null);      // citation detail
  const [district, setDistrict] = useStateApp(null);  // district detail
  const [coupon, setCoupon] = useStateApp(null);
  const [sheet, setSheet] = useStateApp(null);        // pay sheet (cite or 'all')
  const [toast, setToast] = useStateApp(false);
  const [appeal, setAppeal] = useStateApp(null);
  useEffectApp(() => { if (window.lucide) window.lucide.createIcons(); });
  useEffectApp(() => { if (toast) { const t = setTimeout(() => setToast(false), 2200); return () => clearTimeout(t); } }, [toast]);

  if (!user) return <window.PayAuthFlow onAuthed={setUser} />;

  const openPay = (cite) => setSheet(cite || 'all');

  let body;
  if (district) body = <window.PayDistrictDetail district={district} onBack={() => setDistrict(null)} onCoupon={setCoupon} />;
  else if (detail) body = <window.PayCitationDetail cite={detail} onBack={() => setDetail(null)} onPay={openPay} onAppeal={(c) => { setDetail(null); setAppeal(c); }} />;
  else if (tab === 'home') body = <window.PayHomeTab user={user} onPay={() => openPay(null)} onGoCitations={() => setTab('citations')} onGoDistricts={() => setTab('districts')} />;
  else if (tab === 'citations') body = <window.PayCitationsTab onOpen={setDetail} />;
  else if (tab === 'districts') body = <window.PayDistrictsTab onOpen={setDistrict} />;
  else if (tab === 'appeals') body = <AppealsTab onAppeal={setAppeal} onView={setDetail} />;
  else if (tab === 'profile') body = <window.PayProfileTab user={user} onSignOut={() => { setUser(null); setTab('home'); }} />;

  return (
    <>
      {window.HPStatusBar({ dark: true })}
      <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column', position: 'relative' }}>
        {body}
        {sheet && <window.PayPaySheet cite={sheet === 'all' ? null : sheet} onClose={() => setSheet(null)} onPaid={() => { setSheet(null); setToast(true); }} />}
        {toast && <window.PayPaidToast />}
        {coupon && <window.PayCouponModal deal={coupon} onClose={() => setCoupon(null)} />}
      </div>
      <BottomNav active={tab} onTab={(t) => { setDetail(null); setDistrict(null); setTab(t); }} />
      {window.HPHomeIndicator()}
      {appeal && <window.PayAppealFlow cite={appeal} onClose={() => setAppeal(null)} onSubmitted={() => { setAppeal(null); setTab('appeals'); }} />}
    </>
  );
}

window.PayApp = PayApp;
