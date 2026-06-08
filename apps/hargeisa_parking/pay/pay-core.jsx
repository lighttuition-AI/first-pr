/* global React */
/* HPark Pay — shared helpers, data & small primitives */
const { useState, useEffect, useRef } = React;

const Icon = ({ name, size = 20, color, style }) => (
  <i data-lucide={name} style={{ width: size, height: size, color, display: 'inline-flex', flexShrink: 0, ...style }} />
);

/* ---- Data ---------------------------------------------------------------- */

const CITES = [
  { id: 'CIT-2026-04821', plate: 'HG-4821', status: 'overdue', reason: 'No valid permit', fine: 150000, zone: 'Pepsi Roundabout · Zone 4', date: '4 Jun 2026', officer: 'OFR-118' },
  { id: 'CIT-2026-04655', plate: 'HG-4821', status: 'active',  reason: 'Expired meter',   fine: 80000,  zone: 'Mohamed Mooge · Zone 2', date: '1 Jun 2026', officer: 'OFR-204' },
  { id: 'CIT-2026-03194', plate: 'HG-4821', status: 'paid',    reason: 'Double parking',  fine: 120000, zone: '26 June · Zone 1',      date: '18 May 2026', officer: 'OFR-091' },
  { id: 'CIT-2026-02871', plate: 'SL-09122', status: 'review', reason: 'Loading zone',    fine: 100000, zone: 'Ahmed Dhagah · Zone 5', date: '9 May 2026',  officer: 'OFR-118' },
];

const money = (n) => 'SLSH ' + n.toLocaleString('en-US');

/* 9 Hargeisa districts (as provided) with deal counts + parking load */
const DISTRICTS = [
  { id: 'ahmed-dhagah',   name: 'Ahmed Dhagah',   deals: 12, load: 'busy', spaces: 38 },
  { id: '26-june',        name: '26 June',        deals: 9,  load: 'open', spaces: 124 },
  { id: '31-may',         name: '31 May',         deals: 6,  load: 'busy', spaces: 21 },
  { id: 'mohamed-mooge',  name: 'Mohamed Mooge',  deals: 18, load: 'busy', spaces: 12 },
  { id: 'maxamuud-haybe', name: 'Maxamuud Haybe', deals: 7,  load: 'open', spaces: 96 },
  { id: 'gacan-libaax',   name: 'Gacan Libaax',   deals: 5,  load: 'open', spaces: 142 },
  { id: 'ibrahim-koodbuur', name: 'Ibrahim Koodbuur', deals: 11, load: 'busy', spaces: 44 },
  { id: 'mohamoud-haibe', name: 'Mohamoud Haibe', deals: 4,  load: 'open', spaces: 110 },
  { id: 'macalin-haroon', name: 'Macalin Haroon', deals: 8,  load: 'busy', spaces: 33 },
];

/* deals keyed by district id */
const DEALS = {
  'mohamed-mooge': [
    { shop: 'Liido Shoes',        cat: 'Footwear',   off: '50% off',     desc: 'Half price on all sneakers this week', tag: 'Featured', icon: 'footprints' },
    { shop: 'Xamar Burger House',  cat: 'Food',       off: 'Free drink',  desc: 'Free soda with any meal over SLSH 40k', icon: 'utensils' },
    { shop: 'Geel Electronics',    cat: 'Electronics', off: '20% off',    desc: 'Phone accessories & chargers', icon: 'smartphone' },
    { shop: 'Nasiib Pharmacy',     cat: 'Health',     off: '15% off',     desc: 'On vitamins and supplements', icon: 'pill' },
  ],
  'ahmed-dhagah': [
    { shop: 'Star Coffee',         cat: 'Café',       off: 'Buy 1 get 1', desc: 'On all hot drinks before 10am', tag: 'Featured', icon: 'coffee' },
    { shop: 'Hodan Fabrics',       cat: 'Clothing',   off: '30% off',     desc: 'Dirac and guntiino selection', icon: 'shirt' },
    { shop: 'City Barber',         cat: 'Grooming',   off: 'SLSH 10k cut', desc: 'Walk-in haircut special', icon: 'scissors' },
  ],
  '26-june': [
    { shop: 'Maandeeq Bakery',     cat: 'Bakery',     off: '2 for 1',     desc: 'Fresh malawax every morning', tag: 'Featured', icon: 'croissant' },
    { shop: 'Toyo Auto Parts',     cat: 'Auto',       off: '25% off',     desc: 'Tyres & engine oil', icon: 'wrench' },
  ],
  '_default': [
    { shop: 'Local Market Co-op',  cat: 'Grocery',    off: '10% off',     desc: 'Weekly produce basket', tag: 'Featured', icon: 'shopping-basket' },
    { shop: 'Bursa Phone Shop',    cat: 'Electronics', off: 'SLSH 5k off', desc: 'Screen protectors fitted free', icon: 'smartphone' },
    { shop: 'Qamar Restaurant',    cat: 'Food',       off: '15% off',     desc: 'Lunch combos 12–3pm', icon: 'utensils' },
  ],
};
const dealsFor = (id) => DEALS[id] || DEALS._default;

/* ---- Small primitives ---------------------------------------------------- */

function Plate({ children, size = 14, style }) {
  return <span className="hp-plate" style={{ fontSize: size, ...style }}>{children}</span>;
}

function SectionLabel({ children, style }) {
  return <div className="hp-eyebrow" style={{ margin: '6px 0 10px', ...style }}>{children}</div>;
}

/* field with floating label for forms */
function Field({ label, value, onChange, placeholder, icon, type = 'text', mono, maxLength, inputMode }) {
  const [focus, setFocus] = useState(false);
  return (
    <label style={{ display: 'flex', flexDirection: 'column', gap: 7 }}>
      <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--hp-text-2)' }}>{label}</span>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10, height: 52, padding: '0 14px',
        background: 'var(--hp-overlay)', borderRadius: 'var(--radius-md)',
        border: `1px solid ${focus ? 'var(--hp-border-focus)' : 'var(--hp-border)'}`,
        boxShadow: focus ? 'var(--ring-focus)' : 'none', transition: 'border-color .18s, box-shadow .18s',
      }}>
        {icon && <Icon name={icon} size={18} color="var(--hp-text-muted)" />}
        <input
          value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder}
          type={type} maxLength={maxLength} inputMode={inputMode}
          onFocus={() => setFocus(true)} onBlur={() => setFocus(false)}
          style={{
            flex: 1, width: '100%', border: 'none', outline: 'none', background: 'transparent',
            color: 'var(--hp-text)', fontFamily: mono ? 'var(--font-mono)' : 'var(--font-body)',
            fontSize: 15, fontWeight: 500, letterSpacing: mono ? '0.04em' : 'normal',
          }}
        />
      </div>
    </label>
  );
}

/* a status dot used in lists */
function loadColor(load) { return load === 'busy' ? 'var(--hp-warning)' : 'var(--hp-success)'; }

Object.assign(window, {
  PayIcon: Icon, PAY_CITES: CITES, PAY_DISTRICTS: DISTRICTS, payDealsFor: dealsFor,
  payMoney: money, PayPlate: Plate, PaySectionLabel: SectionLabel, PayField: Field, payLoadColor: loadColor,
});
