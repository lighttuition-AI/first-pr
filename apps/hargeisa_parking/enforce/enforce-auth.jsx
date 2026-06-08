/* global React, Button */
/* HPark Enforce — officer auth: badge login + district assignment */
const { useState: useStateEA, useEffect: useEffectEA } = React;
const EAIcon = window.EnfIcon;
const EA_DISTRICTS = window.ENF_DISTRICTS;

function OfficerField({ label, value, onChange, placeholder, icon, type = 'text', mono }) {
  const [focus, setFocus] = useStateEA(false);
  return (
    <label style={{ display: 'flex', flexDirection: 'column', gap: 7 }}>
      <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--hp-text-2)' }}>{label}</span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, height: 52, padding: '0 14px', background: 'var(--hp-overlay)', borderRadius: 'var(--radius-md)', border: `1px solid ${focus ? 'var(--hp-border-focus)' : 'var(--hp-border)'}`, boxShadow: focus ? 'var(--ring-focus)' : 'none' }}>
        {icon && <EAIcon name={icon} size={18} color="var(--hp-text-muted)" />}
        <input value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder} type={type}
          onFocus={() => setFocus(true)} onBlur={() => setFocus(false)}
          style={{ flex: 1, width: '100%', border: 'none', outline: 'none', background: 'transparent', color: 'var(--hp-text)', fontFamily: mono ? 'var(--font-mono)' : 'var(--font-body)', fontSize: 15, fontWeight: 500, letterSpacing: mono ? '0.06em' : 'normal' }} />
      </div>
    </label>
  );
}

function OfficerLogin({ onNext }) {
  const [badge, setBadge] = useStateEA('OFR-118');
  const [pin, setPin] = useStateEA('');
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '0 26px 30px' }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', gap: 28 }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16 }}>
          <div style={{ position: 'relative', width: 88, height: 88, borderRadius: 24, background: 'var(--hp-gradient)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 18px 50px -16px rgba(124,108,248,0.7)' }}>
            <EAIcon name="shield" size={44} color="#fff" />
          </div>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 24, color: '#fff', letterSpacing: '-0.02em', whiteSpace: 'nowrap', lineHeight: 1.1 }}>HPark Enforce</div>
            <div style={{ fontFamily: 'var(--font-mono)', fontSize: 11.5, letterSpacing: '0.1em', color: 'var(--hp-text-muted)', textTransform: 'uppercase', marginTop: 6 }}>Officer terminal</div>
          </div>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          <OfficerField label="Officer badge ID" value={badge} onChange={setBadge} placeholder="OFR-000" icon="id-card" mono />
          <OfficerField label="PIN" value={pin} onChange={(v) => setPin(v.replace(/\D/g, '').slice(0, 6))} placeholder="••••" icon="lock" type="password" mono />
        </div>
      </div>
      <Button block size="xl" onClick={onNext} icon={<EAIcon name="log-in" size={19} />}>Sign in to patrol</Button>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7, marginTop: 16, fontSize: 12.5, color: 'var(--hp-text-muted)' }}>
        <EAIcon name="lock" size={13} /> Encrypted · works offline on patrol
      </div>
    </div>
  );
}

function DistrictAssignment({ onDone }) {
  const [sel, setSel] = useStateEA('Mohamed Mooge');
  const [shift, setShift] = useStateEA('Morning · 06:00–14:00');
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '4px 22px 26px', overflow: 'auto' }}>
      <div style={{ padding: '6px 0 6px' }}>
        <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 24, color: '#fff' }}>Confirm assignment</div>
        <div style={{ fontSize: 14, color: 'var(--hp-text-2)', marginTop: 4 }}>Select the district you're patrolling today. The back office monitors coverage live.</div>
      </div>

      <div className="hp-eyebrow" style={{ margin: '20px 0 10px' }}>District</div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 9 }}>
        {EA_DISTRICTS.map((d, i) => {
          const on = sel === d;
          return (
            <button key={d} onClick={() => setSel(d)} style={{
              display: 'flex', alignItems: 'center', gap: 9, padding: '12px 12px', borderRadius: 'var(--radius-md)', cursor: 'pointer', textAlign: 'left',
              background: on ? 'var(--hp-purple-tint)' : 'var(--hp-surface)', border: `1px solid ${on ? 'var(--hp-border-focus)' : 'var(--hp-border)'}`,
              boxShadow: on ? 'var(--glow-purple-sm)' : 'none', color: on ? '#fff' : 'var(--hp-text-2)',
            }}>
              <span style={{ fontFamily: 'var(--font-mono)', fontSize: 11, color: on ? 'var(--hp-purple-300)' : 'var(--hp-text-muted)' }}>Z{i + 1}</span>
              <span style={{ fontSize: 13, fontWeight: 600, lineHeight: 1.15 }}>{d}</span>
            </button>
          );
        })}
      </div>

      <div className="hp-eyebrow" style={{ margin: '22px 0 10px' }}>Shift</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
        {['Morning · 06:00–14:00', 'Afternoon · 14:00–22:00', 'Night · 22:00–06:00'].map((s) => {
          const on = shift === s;
          return (
            <button key={s} onClick={() => setShift(s)} style={{ display: 'flex', alignItems: 'center', gap: 11, padding: 14, borderRadius: 'var(--radius-md)', cursor: 'pointer', textAlign: 'left', background: 'var(--hp-surface)', border: `1px solid ${on ? 'var(--hp-border-focus)' : 'var(--hp-border)'}`, color: 'var(--hp-text)' }}>
              <div style={{ width: 20, height: 20, borderRadius: '50%', border: `2px solid ${on ? 'var(--hp-purple)' : 'var(--hp-border-strong)'}`, background: on ? 'var(--hp-purple)' : 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{on && <EAIcon name="check" size={12} color="#fff" />}</div>
              <span style={{ fontSize: 14, fontWeight: 500 }}>{s}</span>
            </button>
          );
        })}
      </div>

      <div style={{ flex: 1, minHeight: 16 }} />
      <Button block size="xl" onClick={() => onDone({ district: sel, shift })} style={{ marginTop: 20 }} icon={<EAIcon name="navigation" size={18} />}>Start shift</Button>
    </div>
  );
}

function EnforceAuth({ onAuthed }) {
  const [stage, setStage] = useStateEA('login');
  useEffectEA(() => { if (window.lucide) window.lucide.createIcons(); });
  return (
    <>
      {window.HPStatusBar({ dark: true })}
      <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column' }}>
        {stage === 'login' && <OfficerLogin onNext={() => setStage('assign')} />}
        {stage === 'assign' && <DistrictAssignment onDone={(a) => onAuthed({ id: 'OFR-118', name: 'Hodan Ali', ...a })} />}
      </div>
      {window.HPHomeIndicator()}
    </>
  );
}

window.EnforceAuth = EnforceAuth;
