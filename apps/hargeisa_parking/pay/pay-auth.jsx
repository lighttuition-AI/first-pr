/* global React, Button */
/* HPark Pay — auth: welcome, register (Somaliland ID), sign in, OTP */
const { useState: useStateA, useEffect: useEffectA } = React;
const AIcon = window.PayIcon;
const AField = window.PayField;

function Logo({ size = 56 }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 14 }}>
      <img src="assets/logo-mark.svg" width={size} height={size} alt="" />
      <div style={{ textAlign: 'center' }}>
        <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 22, color: 'var(--hp-text)', letterSpacing: '-0.02em' }}>Hargeisa Parking</div>
        <div style={{ fontFamily: 'var(--font-mono)', fontSize: 11, letterSpacing: '0.12em', color: 'var(--hp-text-muted)', textTransform: 'uppercase', marginTop: 3 }}>HPark Pay · Citizen</div>
      </div>
    </div>
  );
}

function Welcome({ onSignIn, onRegister }) {
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '0 28px 32px' }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 30 }}>
        <div style={{
          width: 96, height: 96, borderRadius: 28, background: 'var(--hp-gradient)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 18px 50px -16px rgba(124,108,248,0.7)',
        }}>
          <AIcon name="circle-parking" size={50} color="#fff" />
        </div>
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 30, color: '#fff', letterSpacing: '-0.02em', lineHeight: 1.1 }}>Park smart in<br />Hargeisa</div>
          <div style={{ fontSize: 15, color: 'var(--hp-text-2)', marginTop: 12, lineHeight: 1.5, maxWidth: 280 }}>Pay citations, find parking, and unlock deals across all 9 districts — in one app.</div>
        </div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        <Button block size="xl" onClick={onRegister}>Create account</Button>
        <Button block size="lg" variant="ghost" onClick={onSignIn}>I already have an account</Button>
      </div>
    </div>
  );
}

const STEPS = ['Identity', 'Verify', 'Vehicle'];

function Register({ onBack, onDone }) {
  const [step, setStep] = useStateA(0);
  const [name, setName] = useStateA('');
  const [dob, setDob] = useStateA('');
  const [id, setId] = useStateA('');
  const [phone, setPhone] = useStateA('');
  const [plate, setPlate] = useStateA('');
  const [otp, setOtp] = useStateA(['', '', '', '']);
  const otpRefs = [0, 1, 2, 3].map(() => React.useRef());

  const canIdentity = name.trim() && dob && id.length >= 6 && phone.length >= 7;
  const canVerify = otp.every((d) => d);

  const Header = (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '4px 0 18px' }}>
      <button onClick={step === 0 ? onBack : () => setStep((s) => s - 1)} style={{ width: 38, height: 38, borderRadius: 10, background: 'var(--hp-overlay)', border: '1px solid var(--hp-border)', color: 'var(--hp-text)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
        <AIcon name="arrow-left" size={18} />
      </button>
      <div style={{ flex: 1, display: 'flex', gap: 6 }}>
        {STEPS.map((_, i) => (
          <div key={i} style={{ flex: 1, height: 4, borderRadius: 3, background: i <= step ? 'var(--hp-purple)' : 'var(--hp-border-strong)', transition: 'background .2s' }} />
        ))}
      </div>
    </div>
  );

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '0 24px 26px', overflow: 'auto' }}>
      {Header}
      {step === 0 && (
        <>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 24, color: '#fff', marginBottom: 4 }}>Create your account</div>
          <div style={{ fontSize: 14, color: 'var(--hp-text-2)', marginBottom: 22 }}>We verify identity against your Somaliland ID.</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            <AField label="Full name" value={name} onChange={setName} placeholder="Amina Yusuf" icon="user" />
            <AField label="Date of birth" value={dob} onChange={setDob} placeholder="DD / MM / YYYY" icon="calendar" inputMode="numeric" />
            <AField label="Somaliland ID number" value={id} onChange={setId} placeholder="SL-0000-0000" icon="id-card" mono maxLength={14} />
            <AField label="Phone number" value={phone} onChange={setPhone} placeholder="+252 63 000 0000" icon="smartphone" mono inputMode="tel" />
          </div>
          <div style={{ flex: 1 }} />
          <Button block size="xl" disabled={!canIdentity} onClick={() => setStep(1)} style={{ marginTop: 24 }} iconRight={<AIcon name="arrow-right" size={18} />}>Continue</Button>
        </>
      )}
      {step === 1 && (
        <>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 24, color: '#fff', marginBottom: 4 }}>Verify your number</div>
          <div style={{ fontSize: 14, color: 'var(--hp-text-2)', marginBottom: 28 }}>We sent a 4-digit code to <span style={{ color: 'var(--hp-text)', fontFamily: 'var(--font-mono)' }}>{phone || '+252 63 000 0000'}</span></div>
          <div style={{ display: 'flex', gap: 12, justifyContent: 'center', marginBottom: 22 }}>
            {otp.map((d, i) => (
              <input key={i} ref={otpRefs[i]} value={d} inputMode="numeric" maxLength={1}
                onChange={(e) => {
                  const v = e.target.value.replace(/\D/g, '');
                  setOtp((o) => { const n = [...o]; n[i] = v; return n; });
                  if (v && i < 3) otpRefs[i + 1].current.focus();
                }}
                style={{
                  width: 60, height: 68, textAlign: 'center', borderRadius: 14,
                  background: 'var(--hp-overlay)', border: `1px solid ${d ? 'var(--hp-border-focus)' : 'var(--hp-border)'}`,
                  color: '#fff', fontFamily: 'var(--font-mono)', fontSize: 28, fontWeight: 700, outline: 'none',
                }} />
            ))}
          </div>
          <div style={{ textAlign: 'center', fontSize: 13, color: 'var(--hp-text-muted)' }}>Didn't get it? <span style={{ color: 'var(--hp-purple-300)', fontWeight: 600 }}>Resend in 0:24</span></div>
          <div style={{ flex: 1 }} />
          <Button block size="xl" disabled={!canVerify} onClick={() => setStep(2)} style={{ marginTop: 24 }}>Verify</Button>
        </>
      )}
      {step === 2 && (
        <>
          <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: 24, color: '#fff', marginBottom: 4 }}>Add your vehicle</div>
          <div style={{ fontSize: 14, color: 'var(--hp-text-2)', marginBottom: 22 }}>Link a plate to see its citations. You can add more later.</div>
          <div style={{ marginBottom: 14 }}>
            <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--hp-text-2)', display: 'block', marginBottom: 7 }}>Number plate</span>
            <input value={plate} onChange={(e) => setPlate(e.target.value.toUpperCase())} placeholder="HG-0000"
              style={{ width: '100%', height: 64, padding: '0 18px', background: 'var(--hp-overlay)', border: '1px solid var(--hp-border)', borderRadius: 'var(--radius-md)', color: '#fff', fontFamily: 'var(--font-mono)', fontSize: 24, fontWeight: 700, letterSpacing: '0.14em', textTransform: 'uppercase', outline: 'none', textAlign: 'center' }} />
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: 14, borderRadius: 'var(--radius-lg)', background: 'var(--hp-surface)', border: '1px solid var(--hp-border)' }}>
            <AIcon name="shield-check" size={18} color="var(--hp-success)" />
            <span style={{ fontSize: 13, color: 'var(--hp-text-2)' }}>Identity verified against Somaliland ID registry.</span>
          </div>
          <div style={{ flex: 1 }} />
          <Button block size="xl" onClick={() => onDone({ name: name || 'Amina Yusuf', plate: plate || 'HG-4821' })} style={{ marginTop: 24 }}>Enter HPark Pay</Button>
          <button onClick={() => onDone({ name: name || 'Amina Yusuf', plate: 'HG-4821' })} style={{ background: 'none', border: 'none', color: 'var(--hp-text-muted)', fontSize: 13, marginTop: 12, cursor: 'pointer' }}>Skip for now</button>
        </>
      )}
    </div>
  );
}

function SignIn({ onBack, onDone }) {
  const [id, setId] = useStateA('');
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '0 24px 28px' }}>
      <div style={{ display: 'flex', alignItems: 'center', padding: '4px 0 26px' }}>
        <button onClick={onBack} style={{ width: 38, height: 38, borderRadius: 10, background: 'var(--hp-overlay)', border: '1px solid var(--hp-border)', color: 'var(--hp-text)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <AIcon name="arrow-left" size={18} />
        </button>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, marginBottom: 30 }}>
        <Logo />
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
        <AField label="Somaliland ID or phone" value={id} onChange={setId} placeholder="SL-0000-0000" icon="id-card" mono />
      </div>
      <div style={{ flex: 1 }} />
      <Button block size="xl" onClick={() => onDone({ name: 'Amina Yusuf', plate: 'HG-4821' })}>Send login code</Button>
      <div style={{ textAlign: 'center', fontSize: 13, color: 'var(--hp-text-muted)', marginTop: 16 }}>Officer? <span style={{ color: 'var(--hp-purple-300)', fontWeight: 600 }}>Use HPark Enforce</span></div>
    </div>
  );
}

function AuthFlow({ onAuthed }) {
  const [view, setView] = useStateA('welcome');
  useEffectA(() => { if (window.lucide) window.lucide.createIcons(); });
  return (
    <>
      {window.HPStatusBar({ dark: true })}
      <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column' }}>
        {view === 'welcome' && <Welcome onSignIn={() => setView('signin')} onRegister={() => setView('register')} />}
        {view === 'register' && <Register onBack={() => setView('welcome')} onDone={onAuthed} />}
        {view === 'signin' && <SignIn onBack={() => setView('welcome')} onDone={onAuthed} />}
      </div>
      {window.HPHomeIndicator()}
    </>
  );
}

Object.assign(window, { PayAuthFlow: AuthFlow, PayLogo: Logo });
