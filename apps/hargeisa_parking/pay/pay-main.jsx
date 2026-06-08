/* global React, Button, Badge, Card */
/* HPark Pay — main tabs: Home, Citations, Pay, Profile */
const { useState: useStateM, useEffect: useEffectM } = React;
const MIcon = window.PayIcon;
const mMoney = window.payMoney;
const M_CITES = window.PAY_CITES;
const MPlate = window.PayPlate;

function balanceDue() {
  return M_CITES.filter((c) => c.status === 'overdue' || c.status === 'active').reduce((s, c) => s + c.fine, 0);
}

function HomeTab({ user, onPay, onGoCitations, onGoDistricts }) {
  const due = balanceDue();
  const count = M_CITES.filter((c) => c.status === 'overdue' || c.status === 'active').length;
  return (
    <div style={{ flex: 1, overflow: 'auto', padding: '4px 20px 24px' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '4px 0 18px' }}>
        <div>
          <div style={{ fontSize: 13, color: 'var(--hp-text-muted)' }}>Good morning</div>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 22, color: 'var(--hp-text)' }}>{user.name.split(' ')[0]}</div>
        </div>
        <div style={{ width: 44, height: 44, borderRadius: '50%', background: 'var(--hp-purple-tint)', border: '1px solid var(--hp-border)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--hp-purple-300)', fontWeight: 700 }}>
          {user.name.split(' ').map((n) => n[0]).slice(0, 2).join('')}
        </div>
      </div>

      {/* Outstanding balance hero — the citizen's primary view */}
      <div style={{ borderRadius: 'var(--radius-2xl)', overflow: 'hidden', position: 'relative', border: '1px solid rgba(255,82,82,0.28)', background: 'linear-gradient(150deg, rgba(255,82,82,0.16), rgba(124,108,248,0.10))', padding: 22, marginBottom: 16 }}>
        <span className="hp-eyebrow" style={{ color: 'var(--hp-text-2)' }}>Outstanding balance</span>
        <div style={{ display: 'flex', alignItems: 'flex-end', gap: 10, marginTop: 8 }}>
          <span style={{ fontFamily: 'var(--font-mono)', fontWeight: 700, fontSize: 40, lineHeight: 1, color: '#fff', letterSpacing: '-0.01em' }}>{mMoney(due)}</span>
        </div>
        <div style={{ fontSize: 13, color: 'var(--hp-text-2)', marginTop: 8 }}>{count} unpaid citation{count !== 1 ? 's' : ''} · pay before 14 Jun to avoid escalation</div>
        <Button block size="lg" variant="danger" style={{ marginTop: 16 }} onClick={onPay} icon={<MIcon name="credit-card" size={18} />}>Pay now</Button>
      </div>

      {/* Active session card */}
      <div style={{ borderRadius: 'var(--radius-xl)', border: '1px solid rgba(0,216,214,0.25)', background: 'var(--hp-surface)', padding: 18, marginBottom: 18 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
          <span className="hp-eyebrow">Active parking</span>
          <Badge status="paid" />
        </div>
        <div style={{ display: 'flex', alignItems: 'flex-end', gap: 8 }}>
          <span style={{ fontFamily: 'var(--font-mono)', fontWeight: 700, fontSize: 34, lineHeight: 1, color: '#fff' }}>0:42</span>
          <span style={{ fontSize: 13, color: 'var(--hp-text-2)', paddingBottom: 5 }}>remaining</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 10, fontSize: 13, color: 'var(--hp-text-2)' }}>
          <MIcon name="map-pin" size={15} color="var(--hp-teal)" /> Zone 4 · Pepsi Roundabout · Bay 12
        </div>
      </div>

      <window.PaySectionLabel>Quick actions</window.PaySectionLabel>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
        {[
          ['Pay citation', 'receipt', 'var(--hp-danger)', onPay],
          ['Districts & deals', 'map', 'var(--hp-teal)', onGoDistricts],
          ['My citations', 'file-text', 'var(--hp-purple-300)', onGoCitations],
          ['Find parking', 'circle-parking', 'var(--hp-warning)', onGoDistricts],
        ].map(([t, ic, c, fn]) => (
          <button key={t} onClick={fn} style={{ display: 'flex', flexDirection: 'column', gap: 12, padding: 16, borderRadius: 'var(--radius-lg)', background: 'var(--hp-surface)', border: '1px solid var(--hp-border)', cursor: 'pointer', textAlign: 'left', color: 'var(--hp-text)' }}>
            <div style={{ width: 38, height: 38, borderRadius: 11, background: 'var(--hp-overlay)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><MIcon name={ic} size={19} color={c} /></div>
            <span style={{ fontSize: 14, fontWeight: 600 }}>{t}</span>
          </button>
        ))}
      </div>
    </div>
  );
}

function CitationsTab({ onOpen }) {
  const [filter, setFilter] = useStateM('all');
  const filters = [['all', 'All'], ['overdue', 'Unpaid'], ['paid', 'Paid'], ['review', 'Appeals']];
  const list = M_CITES.filter((c) => filter === 'all' ? true : filter === 'overdue' ? (c.status === 'overdue' || c.status === 'active') : c.status === filter);
  return (
    <div style={{ flex: 1, overflow: 'auto', padding: '4px 20px 24px' }}>
      <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 22, color: 'var(--hp-text)', padding: '8px 0 14px' }}>Citations</div>
      <div style={{ display: 'flex', gap: 8, marginBottom: 16, overflowX: 'auto', paddingBottom: 2 }}>
        {filters.map(([k, l]) => (
          <button key={k} onClick={() => setFilter(k)} style={{
            flexShrink: 0, padding: '7px 14px', borderRadius: 'var(--radius-pill)', cursor: 'pointer', fontSize: 13, fontWeight: 600,
            background: filter === k ? 'var(--hp-purple-tint)' : 'var(--hp-surface)',
            border: `1px solid ${filter === k ? 'var(--hp-border-focus)' : 'var(--hp-border)'}`,
            color: filter === k ? '#fff' : 'var(--hp-text-2)',
          }}>{l}</button>
        ))}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {list.map((c) => (
          <Card key={c.id} hover padding={16} onClick={() => onOpen(c)} style={{ cursor: 'pointer' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
              <MPlate>{c.plate}</MPlate>
              <Badge status={c.status} />
            </div>
            <div style={{ fontSize: 15, fontWeight: 600, color: 'var(--hp-text)' }}>{c.reason}</div>
            <div style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--hp-text-muted)', marginTop: 2 }}>{c.id} · {c.date}</div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 14 }}>
              <span style={{ fontFamily: 'var(--font-mono)', fontWeight: 700, fontSize: 18, color: 'var(--hp-text)' }}>{mMoney(c.fine)}</span>
              {c.status === 'paid'
                ? <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontSize: 13, color: 'var(--hp-success)', fontWeight: 600 }}><MIcon name="check" size={15} /> Settled</span>
                : c.status === 'review'
                ? <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontSize: 13, color: 'var(--hp-teal)', fontWeight: 600 }}><MIcon name="clock" size={15} /> In review</span>
                : <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontSize: 13, color: 'var(--hp-purple-300)', fontWeight: 600 }}>Details <MIcon name="chevron-right" size={15} /></span>}
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}

/* Citation detail — shows ticket template + actions (pay / appeal) */
function CitationDetail({ cite, onBack, onPay, onAppeal }) {
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minHeight: 0 }}>
      <div style={{ padding: '6px 20px 14px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={onBack} style={{ width: 38, height: 38, borderRadius: 10, background: 'var(--hp-overlay)', border: '1px solid var(--hp-border)', color: 'var(--hp-text)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <MIcon name="arrow-left" size={18} />
        </button>
        <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 20, color: 'var(--hp-text)' }}>Citation</div>
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '0 20px 20px' }}>
        {/* ticket template */}
        <div style={{ borderRadius: 'var(--radius-xl)', border: '1px solid var(--hp-border)', overflow: 'hidden', marginBottom: 16 }}>
          <div style={{ padding: '16px 18px', background: 'var(--hp-elevated)', borderBottom: '1px dashed var(--hp-border-strong)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <img src="assets/logo-mark.svg" width="26" height="26" alt="" />
              <div>
                <div style={{ fontSize: 13, fontWeight: 700, color: '#fff' }}>Parking citation</div>
                <div style={{ fontFamily: 'var(--font-mono)', fontSize: 11, color: 'var(--hp-text-muted)' }}>{cite.id}</div>
              </div>
            </div>
            <Badge status={cite.status} />
          </div>
          <div style={{ padding: 18, background: 'var(--hp-surface)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16 }}>
              <div>
                <div className="hp-eyebrow">Offense</div>
                <div style={{ fontSize: 19, fontWeight: 700, color: '#fff', marginTop: 4 }}>{cite.reason}</div>
              </div>
              <MPlate size={15}>{cite.plate}</MPlate>
            </div>
            {[['Location', cite.zone], ['Date issued', cite.date], ['Issuing officer', cite.officer], ['Fine outstanding', mMoney(cite.fine)]].map(([k, v], i, a) => (
              <div key={k} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 0', borderBottom: i < a.length - 1 ? '1px solid var(--hp-border)' : 'none' }}>
                <span style={{ fontSize: 13.5, color: 'var(--hp-text-2)' }}>{k}</span>
                <span style={{ fontSize: 14, fontWeight: 600, color: '#fff', fontFamily: k === 'Issuing officer' || k === 'Fine outstanding' ? 'var(--font-mono)' : 'var(--font-body)' }}>{v}</span>
              </div>
            ))}
          </div>
        </div>
        {(cite.status === 'overdue' || cite.status === 'active') && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <Button block size="xl" onClick={() => onPay(cite)} icon={<MIcon name="credit-card" size={19} />}>Pay {mMoney(cite.fine)}</Button>
            <Button block size="lg" variant="secondary" onClick={() => onAppeal(cite)} icon={<MIcon name="gavel" size={18} />}>Challenge this citation</Button>
          </div>
        )}
        {cite.status === 'review' && (
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: 16, borderRadius: 'var(--radius-lg)', background: 'var(--hp-teal-tint)', border: '1px solid rgba(0,216,214,0.3)' }}>
            <MIcon name="clock" size={20} color="var(--hp-teal)" />
            <div style={{ fontSize: 13.5, color: 'var(--hp-text)' }}>Your appeal is under review. We'll notify you within 5 working days.</div>
          </div>
        )}
        {cite.status === 'paid' && (
          <Button block size="lg" variant="secondary" icon={<MIcon name="download" size={18} />}>Download receipt</Button>
        )}
      </div>
    </div>
  );
}

/* Payment bottom sheet with ZAAD / eDahab choice */
function PaySheet({ cite, onClose, onPaid }) {
  const [method, setMethod] = useStateM('zaad');
  const amount = cite ? cite.fine : balanceDue();
  const methods = [
    { id: 'zaad', name: 'ZAAD', sub: 'Telesom · •••• 4471', icon: 'smartphone', color: 'var(--hp-teal)' },
    { id: 'edahab', name: 'eDahab', sub: 'Dahabshiil · •••• 8820', icon: 'wallet', color: 'var(--hp-purple-300)' },
  ];
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 30, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
      <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.6)', backdropFilter: 'blur(2px)' }} />
      <div style={{ position: 'relative', background: 'var(--hp-elevated)', borderTopLeftRadius: 24, borderTopRightRadius: 24, border: '1px solid var(--hp-border)', borderBottom: 'none', padding: '12px 20px 28px' }}>
        <div style={{ width: 40, height: 4, borderRadius: 3, background: 'var(--hp-border-strong)', margin: '0 auto 18px' }} />
        <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 22, color: 'var(--hp-text)', marginBottom: 4 }}>Pay citation{cite ? '' : 's'}</div>
        <div style={{ fontSize: 14, color: 'var(--hp-text-2)', marginBottom: 18 }}>{cite ? `${cite.id} · ${cite.reason}` : 'Settle full outstanding balance'}</div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '14px 16px', borderRadius: 'var(--radius-lg)', background: 'var(--hp-surface)', border: '1px solid var(--hp-border)', marginBottom: 18 }}>
          <span style={{ fontSize: 14, color: 'var(--hp-text-2)' }}>Amount due</span>
          <span style={{ fontFamily: 'var(--font-mono)', fontWeight: 700, fontSize: 22, color: '#fff' }}>{mMoney(amount)}</span>
        </div>
        <window.PaySectionLabel>Pay with</window.PaySectionLabel>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginBottom: 20 }}>
          {methods.map((m) => {
            const on = method === m.id;
            return (
              <button key={m.id} onClick={() => setMethod(m.id)} style={{
                display: 'flex', alignItems: 'center', gap: 13, padding: 14, borderRadius: 'var(--radius-lg)', cursor: 'pointer', textAlign: 'left',
                background: 'var(--hp-surface)', border: `1px solid ${on ? 'var(--hp-border-focus)' : 'var(--hp-border)'}`, boxShadow: on ? 'var(--glow-purple-sm)' : 'none', color: 'var(--hp-text)',
              }}>
                <div style={{ width: 40, height: 40, borderRadius: 11, background: 'var(--hp-overlay)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><MIcon name={m.icon} size={20} color={m.color} /></div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 15, fontWeight: 600 }}>{m.name}</div>
                  <div style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--hp-text-muted)' }}>{m.sub}</div>
                </div>
                <div style={{ width: 22, height: 22, borderRadius: '50%', border: `2px solid ${on ? 'var(--hp-purple)' : 'var(--hp-border-strong)'}`, background: on ? 'var(--hp-purple)' : 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  {on && <MIcon name="check" size={13} color="#fff" />}
                </div>
              </button>
            );
          })}
        </div>
        <Button block size="xl" onClick={onPaid}>Pay {mMoney(amount)}</Button>
      </div>
    </div>
  );
}

function PaidToast() {
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 40, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', background: 'rgba(10,10,15,0.94)', backdropFilter: 'blur(4px)', padding: 30, textAlign: 'center' }}>
      <div style={{ width: 92, height: 92, borderRadius: '50%', background: 'rgba(0,200,83,0.14)', border: '1px solid rgba(0,200,83,0.4)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 0 0 8px rgba(0,200,83,0.06)' }}>
        <MIcon name="check" size={44} color="var(--hp-success)" />
      </div>
      <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 24, color: 'var(--hp-text)', marginTop: 22 }}>Payment complete</div>
      <div style={{ fontSize: 14, color: 'var(--hp-text-2)', marginTop: 6 }}>Citation settled · receipt sent by SMS</div>
    </div>
  );
}

function ProfileTab({ user, onSignOut }) {
  const rows = [
    ['id-card', 'Somaliland ID', 'SL-4471-2208'],
    ['car', 'My vehicles', user.plate + ' · +1'],
    ['smartphone', 'Phone', '+252 63 442 0098'],
    ['bell', 'Notifications', 'On'],
    ['globe', 'Language', 'English'],
  ];
  return (
    <div style={{ flex: 1, overflow: 'auto', padding: '4px 20px 24px' }}>
      <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 22, color: 'var(--hp-text)', padding: '8px 0 18px' }}>Profile</div>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12, marginBottom: 22 }}>
        <div style={{ width: 80, height: 80, borderRadius: '50%', background: 'var(--hp-gradient)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontSize: 30, fontWeight: 700, fontFamily: 'var(--font-heading)' }}>
          {user.name.split(' ').map((n) => n[0]).slice(0, 2).join('')}
        </div>
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 20, color: '#fff' }}>{user.name}</div>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontSize: 12.5, color: 'var(--hp-success)', marginTop: 4 }}><MIcon name="shield-check" size={14} /> Verified resident</div>
        </div>
      </div>
      <Card padding={0} style={{ marginBottom: 16 }}>
        {rows.map(([ic, k, v], i) => (
          <div key={k} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '14px 16px', borderBottom: i < rows.length - 1 ? '1px solid var(--hp-border)' : 'none' }}>
            <MIcon name={ic} size={18} color="var(--hp-text-muted)" />
            <span style={{ fontSize: 14, color: 'var(--hp-text-2)', flex: 1 }}>{k}</span>
            <span style={{ fontSize: 13.5, fontWeight: 600, color: '#fff' }}>{v}</span>
          </div>
        ))}
      </Card>
      <Button block size="lg" variant="ghost" onClick={onSignOut} icon={<MIcon name="log-out" size={18} />}>Sign out</Button>
    </div>
  );
}

Object.assign(window, { PayHomeTab: HomeTab, PayCitationsTab: CitationsTab, PayCitationDetail: CitationDetail, PayPaySheet: PaySheet, PayPaidToast: PaidToast, PayProfileTab: ProfileTab, payBalanceDue: balanceDue });
