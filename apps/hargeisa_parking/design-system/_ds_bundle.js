/* @ds-bundle: {"format":3,"namespace":"HargeisaParkingDesignSystem_0eb67a","components":[{"name":"Button","sourcePath":"components/buttons/Button.jsx"},{"name":"Avatar","sourcePath":"components/data/Avatar.jsx"},{"name":"Badge","sourcePath":"components/data/Badge.jsx"},{"name":"KpiCard","sourcePath":"components/data/KpiCard.jsx"},{"name":"Input","sourcePath":"components/forms/Input.jsx"},{"name":"Switch","sourcePath":"components/forms/Switch.jsx"},{"name":"Card","sourcePath":"components/surfaces/Card.jsx"}],"sourceHashes":{"components/buttons/Button.jsx":"b65e4b36446f","components/data/Avatar.jsx":"58563a737572","components/data/Badge.jsx":"7f2f4acf5b56","components/data/KpiCard.jsx":"b61a41c7cf2a","components/forms/Input.jsx":"768a3f145614","components/forms/Switch.jsx":"a2281a1eebdd","components/surfaces/Card.jsx":"4ce4fcf16ab2","ui_kits/hpark-command/Dashboard.jsx":"973fee3422f0","ui_kits/hpark-command/LiveMap.jsx":"c6b247467e71","ui_kits/hpark-command/Sidebar.jsx":"80b40ca078e9","ui_kits/hpark-enforce/EnforceApp.jsx":"b72dce87138b","ui_kits/hpark-enforce/phone-frame.jsx":"d48ad69e4760","ui_kits/hpark-pay/PayApp.jsx":"5ca285750640","ui_kits/hpark-pay/phone-frame.jsx":"d48ad69e4760","vendor/ds-bundle.js":"b52f53341751"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.HargeisaParkingDesignSystem_0eb67a = window.HargeisaParkingDesignSystem_0eb67a || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/buttons/Button.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * Button — primary action control for Hargeisa Parking.
 * Variants: primary (purple, gradient-on-hover), secondary (dark+border),
 * danger, ghost. One primary action per screen.
 */
function Button({
  variant = 'primary',
  size = 'md',
  icon = null,
  iconRight = null,
  block = false,
  disabled = false,
  type = 'button',
  children,
  style = {},
  ...rest
}) {
  const sizes = {
    sm: {
      height: 36,
      padding: '0 14px',
      font: 14,
      radius: 8,
      gap: 7
    },
    md: {
      height: 44,
      padding: '0 18px',
      font: 15,
      radius: 8,
      gap: 8
    },
    lg: {
      height: 52,
      padding: '0 22px',
      font: 16,
      radius: 10,
      gap: 9
    },
    xl: {
      height: 60,
      padding: '0 28px',
      font: 17,
      radius: 12,
      gap: 10
    }
  };
  const s = sizes[size] || sizes.md;
  const base = {
    display: block ? 'flex' : 'inline-flex',
    width: block ? '100%' : 'auto',
    alignItems: 'center',
    justifyContent: 'center',
    gap: s.gap,
    height: s.height,
    padding: s.padding,
    fontFamily: 'var(--font-body)',
    fontSize: s.font,
    fontWeight: 600,
    lineHeight: 1,
    letterSpacing: '-0.01em',
    border: '1px solid transparent',
    borderRadius: s.radius,
    cursor: disabled ? 'not-allowed' : 'pointer',
    opacity: disabled ? 0.45 : 1,
    transition: 'transform var(--dur-fast) var(--ease-out), box-shadow var(--dur-base) var(--ease-out), background var(--dur-base) var(--ease-out), border-color var(--dur-base) var(--ease-out)',
    whiteSpace: 'nowrap',
    userSelect: 'none'
  };
  const variants = {
    primary: {
      background: 'var(--hp-purple)',
      color: '#fff',
      borderColor: 'var(--hp-purple)'
    },
    secondary: {
      background: 'var(--hp-elevated)',
      color: 'var(--hp-text)',
      borderColor: 'var(--hp-border-strong)'
    },
    danger: {
      background: 'var(--hp-danger)',
      color: '#fff',
      borderColor: 'var(--hp-danger)'
    },
    ghost: {
      background: 'transparent',
      color: 'var(--hp-text-2)',
      borderColor: 'transparent'
    }
  };
  const hoverEnter = e => {
    if (disabled) return;
    const el = e.currentTarget;
    el.style.transform = 'translateY(-1px)';
    if (variant === 'primary') {
      el.style.background = 'var(--hp-gradient)';
      el.style.boxShadow = 'var(--glow-purple-sm)';
    } else if (variant === 'secondary') {
      el.style.borderColor = 'var(--hp-border-focus)';
      el.style.boxShadow = '0 0 0 1px rgba(124,108,248,0.30)';
    } else if (variant === 'danger') {
      el.style.boxShadow = 'var(--glow-danger)';
    } else if (variant === 'ghost') {
      el.style.background = 'var(--hp-overlay)';
      el.style.color = 'var(--hp-text)';
    }
  };
  const hoverLeave = e => {
    if (disabled) return;
    const el = e.currentTarget;
    el.style.transform = 'none';
    el.style.boxShadow = 'none';
    el.style.background = variants[variant].background;
    el.style.borderColor = variants[variant].borderColor;
    if (variant === 'ghost') el.style.color = variants.ghost.color;
  };
  const press = e => {
    if (!disabled) e.currentTarget.style.transform = 'translateY(0) scale(0.98)';
  };
  const release = e => {
    if (!disabled) e.currentTarget.style.transform = 'translateY(-1px)';
  };
  return /*#__PURE__*/React.createElement("button", _extends({
    type: type,
    disabled: disabled,
    style: {
      ...base,
      ...variants[variant],
      ...style
    },
    onMouseEnter: hoverEnter,
    onMouseLeave: hoverLeave,
    onMouseDown: press,
    onMouseUp: release
  }, rest), icon && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      flexShrink: 0
    }
  }, icon), children, iconRight && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      flexShrink: 0
    }
  }, iconRight));
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/buttons/Button.jsx", error: String((e && e.message) || e) }); }

// components/data/Avatar.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * Avatar — circular identity token. Image, or initials on a tinted fill.
 * Optional status dot (e.g. officer on patrol).
 */
function Avatar({
  name = '',
  src = null,
  size = 40,
  status = null,
  // 'patrol' | 'success' | 'danger' | null
  style = {},
  ...rest
}) {
  const initials = name.split(' ').filter(Boolean).slice(0, 2).map(p => p[0]).join('').toUpperCase();
  const statusColor = {
    patrol: 'var(--hp-map-officer)',
    success: 'var(--hp-success)',
    danger: 'var(--hp-danger)'
  }[status];
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      position: 'relative',
      display: 'inline-flex',
      flexShrink: 0,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      width: size,
      height: size,
      borderRadius: '50%',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      overflow: 'hidden',
      background: src ? 'var(--hp-overlay)' : 'rgba(124,108,248,0.18)',
      border: '1px solid var(--hp-border)',
      color: 'var(--hp-purple-300)',
      fontFamily: 'var(--font-body)',
      fontWeight: 700,
      fontSize: size * 0.38,
      letterSpacing: '0.01em'
    }
  }, src ? /*#__PURE__*/React.createElement("img", {
    src: src,
    alt: name,
    style: {
      width: '100%',
      height: '100%',
      objectFit: 'cover'
    }
  }) : initials), statusColor && /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      right: -1,
      bottom: -1,
      width: size * 0.28,
      height: size * 0.28,
      minWidth: 9,
      minHeight: 9,
      borderRadius: '50%',
      background: statusColor,
      border: '2px solid var(--hp-bg)'
    }
  }));
}
Object.assign(__ds_scope, { Avatar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/Avatar.jsx", error: String((e && e.message) || e) }); }

// components/data/Badge.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * Badge — small status pill. Tinted fill + colored dot/glyph.
 * Presets map to Hargeisa Parking's operational statuses.
 */
const PRESETS = {
  paid: {
    color: 'var(--hp-success)',
    tint: 'var(--hp-success-tint)',
    glyph: '✓',
    label: 'Paid'
  },
  active: {
    color: 'var(--hp-purple)',
    tint: 'var(--hp-purple-tint)',
    glyph: '●',
    label: 'Active'
  },
  review: {
    color: 'var(--hp-teal)',
    tint: 'var(--hp-teal-tint)',
    glyph: '◌',
    label: 'Appeal Review'
  },
  overdue: {
    color: 'var(--hp-danger)',
    tint: 'var(--hp-danger-tint)',
    glyph: '▲',
    label: 'Overdue'
  },
  patrol: {
    color: 'var(--hp-map-officer)',
    tint: 'var(--hp-blue-tint)',
    glyph: '●',
    label: 'On Patrol'
  },
  expiring: {
    color: 'var(--hp-warning)',
    tint: 'var(--hp-warning-tint)',
    glyph: '◷',
    label: 'Expiring'
  },
  neutral: {
    color: 'var(--hp-text-2)',
    tint: 'rgba(255,255,255,0.06)',
    glyph: '',
    label: ''
  }
};
function Badge({
  status = 'neutral',
  color,
  glyph,
  size = 'md',
  children,
  style = {},
  ...rest
}) {
  const p = PRESETS[status] || PRESETS.neutral;
  const c = color || p.color;
  const tint = (PRESETS[status] || PRESETS.neutral).tint;
  const g = glyph !== undefined ? glyph : p.glyph;
  const sizes = {
    sm: {
      font: 11,
      pad: '3px 8px',
      gap: 5
    },
    md: {
      font: 12,
      pad: '4px 10px',
      gap: 6
    },
    lg: {
      font: 13,
      pad: '6px 12px',
      gap: 7
    }
  };
  const s = sizes[size] || sizes.md;
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: s.gap,
      padding: s.pad,
      fontFamily: 'var(--font-body)',
      fontSize: s.font,
      fontWeight: 600,
      lineHeight: 1,
      letterSpacing: '0.01em',
      color: c,
      background: tint,
      border: `1px solid ${c}33`,
      borderRadius: 'var(--radius-pill)',
      whiteSpace: 'nowrap',
      ...style
    }
  }, rest), g && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: '0.92em',
      lineHeight: 1
    }
  }, g), children || p.label);
}
Object.assign(__ds_scope, { Badge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/Badge.jsx", error: String((e && e.message) || e) }); }

// components/data/KpiCard.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * KpiCard — dashboard metric tile. Big mono value, label, delta chip.
 * Value uses JetBrains Mono with tabular figures.
 */
function KpiCard({
  label,
  value,
  delta = null,
  deltaDir = 'up',
  icon = null,
  accent = 'var(--hp-purple)',
  style = {},
  ...rest
}) {
  const up = deltaDir === 'up';
  const deltaColor = up ? 'var(--hp-success)' : 'var(--hp-danger)';
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      background: 'var(--hp-surface)',
      border: '1px solid var(--hp-border)',
      borderRadius: 'var(--radius-lg)',
      padding: 20,
      display: 'flex',
      flexDirection: 'column',
      gap: 14,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      fontWeight: 600,
      letterSpacing: '0.04em',
      textTransform: 'uppercase',
      color: 'var(--hp-text-muted)'
    }
  }, label), icon && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: 30,
      height: 30,
      borderRadius: 8,
      background: 'rgba(124,108,248,0.12)',
      color: accent
    }
  }, icon)), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      gap: 10,
      flexWrap: 'wrap'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-mono)',
      fontSize: 32,
      fontWeight: 700,
      lineHeight: 1,
      color: 'var(--hp-text)',
      fontFeatureSettings: "'tnum' 1"
    }
  }, value), delta != null && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 3,
      fontFamily: 'var(--font-mono)',
      fontSize: 13,
      fontWeight: 600,
      color: deltaColor,
      paddingBottom: 3
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 11
    }
  }, up ? '▲' : '▼'), delta)));
}
Object.assign(__ds_scope, { KpiCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/KpiCard.jsx", error: String((e && e.message) || e) }); }

// components/forms/Input.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * Input — text field on dark surface. Optional leading icon, label, hint,
 * and a `plate` mode for vehicle-plate entry (mono, uppercase, wide tracking).
 */
function Input({
  label,
  hint,
  error,
  icon = null,
  plate = false,
  size = 'md',
  style = {},
  containerStyle = {},
  ...rest
}) {
  const [focus, setFocus] = React.useState(false);
  const sizes = {
    md: 44,
    lg: 52,
    xl: 60
  };
  const h = sizes[size] || 44;
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 7,
      ...containerStyle
    }
  }, label && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      fontWeight: 600,
      color: 'var(--hp-text-2)',
      letterSpacing: '-0.005em'
    }
  }, label), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      height: h,
      padding: plate ? '0 16px' : '0 14px',
      background: 'var(--hp-overlay)',
      border: `1px solid ${error ? 'var(--hp-danger)' : focus ? 'var(--hp-border-focus)' : 'var(--hp-border)'}`,
      borderRadius: plate ? 'var(--radius-md)' : 'var(--radius-sm)',
      boxShadow: focus && !error ? 'var(--ring-focus)' : 'none',
      transition: 'border-color var(--dur-base) var(--ease-out), box-shadow var(--dur-base) var(--ease-out)'
    }
  }, icon && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      color: 'var(--hp-text-muted)',
      flexShrink: 0
    }
  }, icon), /*#__PURE__*/React.createElement("input", _extends({
    onFocus: e => {
      setFocus(true);
      rest.onFocus && rest.onFocus(e);
    },
    onBlur: e => {
      setFocus(false);
      rest.onBlur && rest.onBlur(e);
    },
    style: {
      flex: 1,
      width: '100%',
      border: 'none',
      outline: 'none',
      background: 'transparent',
      color: 'var(--hp-text)',
      fontFamily: plate ? 'var(--font-mono)' : 'var(--font-body)',
      fontSize: plate ? 22 : 15,
      fontWeight: plate ? 700 : 500,
      letterSpacing: plate ? '0.14em' : 'normal',
      textTransform: plate ? 'uppercase' : 'none',
      ...style
    }
  }, rest))), (hint || error) && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: error ? 'var(--hp-danger)' : 'var(--hp-text-muted)'
    }
  }, error || hint));
}
Object.assign(__ds_scope, { Input });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Input.jsx", error: String((e && e.message) || e) }); }

// components/forms/Switch.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * Switch — toggle control. Purple when on. 44px-friendly hit area.
 */
function Switch({
  checked = false,
  onChange,
  disabled = false,
  label,
  style = {},
  ...rest
}) {
  const toggle = () => {
    if (!disabled && onChange) onChange(!checked);
  };
  const track = {
    width: 44,
    height: 26,
    borderRadius: 999,
    flexShrink: 0,
    background: checked ? 'var(--hp-purple)' : 'var(--hp-overlay)',
    border: `1px solid ${checked ? 'var(--hp-purple)' : 'var(--hp-border-strong)'}`,
    boxShadow: checked ? 'var(--glow-purple-sm)' : 'none',
    position: 'relative',
    cursor: disabled ? 'not-allowed' : 'pointer',
    transition: 'background var(--dur-base) var(--ease-out), box-shadow var(--dur-base) var(--ease-out)',
    opacity: disabled ? 0.5 : 1
  };
  const knob = {
    position: 'absolute',
    top: 2,
    left: checked ? 20 : 2,
    width: 20,
    height: 20,
    borderRadius: '50%',
    background: '#fff',
    transition: 'left var(--dur-base) var(--ease-out)'
  };
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 10,
      cursor: disabled ? 'not-allowed' : 'pointer',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", _extends({
    role: "switch",
    "aria-checked": checked,
    onClick: toggle,
    style: track
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: knob
  })), label && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      color: 'var(--hp-text)',
      fontWeight: 500
    }
  }, label));
}
Object.assign(__ds_scope, { Switch });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Switch.jsx", error: String((e && e.message) || e) }); }

// components/surfaces/Card.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * Card — primary surface. Soft border, 12px radius, no drop shadow.
 * Optional purple glow on hover (interactive cards).
 */
function Card({
  hover = false,
  glow = false,
  padding = 20,
  as = 'div',
  children,
  style = {},
  ...rest
}) {
  const Tag = as;
  const [h, setH] = React.useState(false);
  return /*#__PURE__*/React.createElement(Tag, _extends({
    onMouseEnter: () => hover && setH(true),
    onMouseLeave: () => hover && setH(false),
    style: {
      background: 'var(--hp-surface)',
      border: '1px solid var(--hp-border)',
      borderRadius: 'var(--radius-lg)',
      padding,
      transition: 'border-color var(--dur-base) var(--ease-out), box-shadow var(--dur-base) var(--ease-out), transform var(--dur-base) var(--ease-out)',
      ...(glow || h ? {
        borderColor: 'var(--hp-border-focus)',
        boxShadow: '0 0 0 1px rgba(124,108,248,0.25), 0 10px 40px -16px rgba(124,108,248,0.45)',
        transform: hover ? 'translateY(-2px)' : 'none'
      } : {}),
      ...style
    }
  }, rest), children);
}
Object.assign(__ds_scope, { Card });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/surfaces/Card.jsx", error: String((e && e.message) || e) }); }

// ui_kits/hpark-command/Dashboard.jsx
try { (() => {
/* global React, KpiCard, Card, Badge */
const LiveMap = window.HPCLiveMap;
const Icon = window.HPCIcon;
function ComplianceHero() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      overflow: 'hidden',
      borderRadius: 'var(--radius-xl)',
      border: '1px solid rgba(124,108,248,0.25)',
      background: 'linear-gradient(135deg, rgba(124,108,248,0.16), rgba(0,216,214,0.10))',
      padding: 24,
      display: 'flex',
      flexDirection: 'column',
      gap: 6,
      minHeight: 168
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "hp-eyebrow"
  }, "City compliance"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-mono)',
      fontWeight: 700,
      fontSize: 64,
      lineHeight: 1,
      color: '#fff'
    }
  }, "87%"), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 4,
      color: 'var(--hp-success)',
      fontFamily: 'var(--font-mono)',
      fontWeight: 600,
      fontSize: 15,
      paddingBottom: 10
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "trending-up",
    size: 16
  }), " +4% this week")), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 8,
      height: 8,
      borderRadius: 999,
      background: 'rgba(255,255,255,0.08)',
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: '87%',
      height: '100%',
      background: 'var(--hp-gradient)'
    }
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: 'var(--hp-text-2)',
      marginTop: 4
    }
  }, "14 of 16 zones above the 80% compliance target."));
}
const RECENT = [['CIT-2026-04821', 'HG-4821', 'overdue', 'No valid permit'], ['CIT-2026-04820', 'SL-09122', 'active', 'Expired meter'], ['CIT-2026-04819', 'HG-2210', 'review', 'Disabled bay'], ['CIT-2026-04818', 'HG-7741', 'active', 'Double parking']];
function RecentCitations() {
  return /*#__PURE__*/React.createElement(Card, {
    padding: 0
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '16px 18px',
      borderBottom: '1px solid var(--hp-border)'
    }
  }, /*#__PURE__*/React.createElement("h4", {
    style: {
      fontSize: 16
    }
  }, "Recent citations"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: 'var(--hp-purple-300)',
      fontWeight: 600,
      cursor: 'pointer'
    }
  }, "View all")), /*#__PURE__*/React.createElement("div", null, RECENT.map(([id, plate, status, reason], i) => /*#__PURE__*/React.createElement("div", {
    key: id,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '13px 18px',
      borderBottom: i < RECENT.length - 1 ? '1px solid var(--hp-border)' : 'none'
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "hp-plate",
    style: {
      fontSize: 13
    }
  }, plate), /*#__PURE__*/React.createElement("div", {
    style: {
      minWidth: 0,
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-mono)',
      fontSize: 12.5,
      color: 'var(--hp-text-2)'
    }
  }, id), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: 'var(--hp-text)',
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis'
    }
  }, reason)), /*#__PURE__*/React.createElement(Badge, {
    status: status
  })))));
}
function Dashboard() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 18
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: 'repeat(4, 1fr)',
      gap: 14
    }
  }, /*#__PURE__*/React.createElement(KpiCard, {
    label: "Revenue today",
    value: "4.28M",
    delta: "+12%",
    icon: /*#__PURE__*/React.createElement(Icon, {
      name: "banknote",
      size: 17
    })
  }), /*#__PURE__*/React.createElement(KpiCard, {
    label: "Active violations",
    value: "38",
    delta: "-6%",
    deltaDir: "down",
    accent: "var(--hp-danger)",
    icon: /*#__PURE__*/React.createElement(Icon, {
      name: "triangle-alert",
      size: 17
    })
  }), /*#__PURE__*/React.createElement(KpiCard, {
    label: "Officers active",
    value: "24",
    delta: "+3",
    accent: "var(--hp-map-officer)",
    icon: /*#__PURE__*/React.createElement(Icon, {
      name: "shield",
      size: 17
    })
  }), /*#__PURE__*/React.createElement(KpiCard, {
    label: "Occupancy rate",
    value: "76%",
    delta: "+8%",
    accent: "var(--hp-teal)",
    icon: /*#__PURE__*/React.createElement(Icon, {
      name: "circle-parking",
      size: 17
    })
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1.55fr 1fr',
      gap: 18,
      alignItems: 'stretch'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 18
    }
  }, /*#__PURE__*/React.createElement(ComplianceHero, null), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 360
    }
  }, /*#__PURE__*/React.createElement(LiveMap, null))), /*#__PURE__*/React.createElement(RecentCitations, null)));
}
window.HPCDashboard = Dashboard;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/hpark-command/Dashboard.jsx", error: String((e && e.message) || e) }); }

// ui_kits/hpark-command/LiveMap.jsx
try { (() => {
/* global React */

const MARKERS = [{
  x: 18,
  y: 30,
  c: 'var(--hp-map-paid)'
}, {
  x: 32,
  y: 62,
  c: 'var(--hp-map-paid)'
}, {
  x: 70,
  y: 24,
  c: 'var(--hp-map-paid)'
}, {
  x: 55,
  y: 48,
  c: 'var(--hp-map-expiring)'
}, {
  x: 80,
  y: 66,
  c: 'var(--hp-map-expiring)'
}, {
  x: 44,
  y: 78,
  c: 'var(--hp-map-violation)'
}, {
  x: 24,
  y: 50,
  c: 'var(--hp-map-violation)'
}, {
  x: 62,
  y: 70,
  c: 'var(--hp-map-officer)',
  officer: true
}, {
  x: 38,
  y: 38,
  c: 'var(--hp-map-officer)',
  officer: true
}];
const LEGEND = [['Paid', 'var(--hp-map-paid)'], ['Expiring', 'var(--hp-map-expiring)'], ['Violation', 'var(--hp-map-violation)'], ['Officer', 'var(--hp-map-officer)']];
function LiveMap() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      borderRadius: 'var(--radius-lg)',
      overflow: 'hidden',
      border: '1px solid var(--hp-border)',
      background: '#0C0C14',
      minHeight: 380,
      height: '100%'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      backgroundImage: 'linear-gradient(rgba(124,108,248,0.06) 1px, transparent 1px),' + 'linear-gradient(90deg, rgba(124,108,248,0.06) 1px, transparent 1px),' + 'linear-gradient(115deg, rgba(255,255,255,0.05) 2px, transparent 2px),' + 'linear-gradient(200deg, rgba(255,255,255,0.04) 2px, transparent 2px)',
      backgroundSize: '46px 46px, 46px 46px, 180px 180px, 240px 240px'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: '-5%',
      top: '52%',
      width: '110%',
      height: 8,
      background: 'rgba(255,255,255,0.06)',
      transform: 'rotate(-7deg)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: '30%',
      top: '-5%',
      width: 7,
      height: '110%',
      background: 'rgba(255,255,255,0.05)'
    }
  }), /*#__PURE__*/React.createElement("svg", {
    style: {
      position: 'absolute',
      inset: 0,
      width: '100%',
      height: '100%'
    },
    preserveAspectRatio: "none",
    viewBox: "0 0 100 100"
  }, /*#__PURE__*/React.createElement("polyline", {
    points: "38,38 50,44 62,70 80,66",
    fill: "none",
    stroke: "var(--hp-map-route)",
    strokeWidth: "0.6",
    strokeDasharray: "2 1.4",
    opacity: "0.8"
  })), MARKERS.map((m, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    style: {
      position: 'absolute',
      left: `${m.x}%`,
      top: `${m.y}%`,
      transform: 'translate(-50%,-50%)',
      width: m.officer ? 16 : 12,
      height: m.officer ? 16 : 12,
      borderRadius: '50%',
      background: m.c,
      border: m.officer ? '2px solid #fff' : 'none',
      boxShadow: `0 0 0 5px color-mix(in srgb, ${m.c} 20%, transparent)`
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: 16,
      bottom: 16,
      display: 'flex',
      gap: 16,
      padding: '10px 14px',
      borderRadius: 'var(--radius-md)',
      background: 'rgba(10,10,15,0.72)',
      backdropFilter: 'var(--blur-bg)',
      border: '1px solid var(--hp-border)'
    }
  }, LEGEND.map(([label, c]) => /*#__PURE__*/React.createElement("span", {
    key: label,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 7,
      fontSize: 12,
      color: 'var(--hp-text-2)',
      fontWeight: 500
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 9,
      height: 9,
      borderRadius: '50%',
      background: c
    }
  }), label))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      right: 16,
      top: 16,
      display: 'flex',
      alignItems: 'center',
      gap: 7,
      padding: '7px 12px',
      borderRadius: 'var(--radius-pill)',
      background: 'rgba(10,10,15,0.72)',
      backdropFilter: 'var(--blur-bg)',
      border: '1px solid var(--hp-border)',
      fontSize: 12,
      fontWeight: 600,
      color: 'var(--hp-text)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 8,
      height: 8,
      borderRadius: '50%',
      background: 'var(--hp-success)',
      boxShadow: '0 0 0 4px rgba(0,200,83,0.25)'
    }
  }), "Live \xB7 1,284 spaces"));
}
window.HPCLiveMap = LiveMap;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/hpark-command/LiveMap.jsx", error: String((e && e.message) || e) }); }

// ui_kits/hpark-command/Sidebar.jsx
try { (() => {
/* global React */
const {
  useState
} = React;
const NAV = [{
  icon: 'layout-dashboard',
  label: 'Dashboard'
}, {
  icon: 'map',
  label: 'Live Map'
}, {
  icon: 'file-text',
  label: 'Citations'
}, {
  icon: 'car',
  label: 'Vehicles'
}, {
  icon: 'shield',
  label: 'Officers'
}, {
  icon: 'credit-card',
  label: 'Payments'
}, {
  icon: 'gavel',
  label: 'Appeals'
}, {
  icon: 'bar-chart-3',
  label: 'Reports'
}, {
  icon: 'settings',
  label: 'Settings'
}];
function Icon({
  name,
  size = 20,
  color,
  style
}) {
  return /*#__PURE__*/React.createElement("i", {
    "data-lucide": name,
    style: {
      width: size,
      height: size,
      color,
      display: 'inline-flex',
      ...style
    }
  });
}
function Sidebar({
  active,
  onNav
}) {
  return /*#__PURE__*/React.createElement("aside", {
    style: {
      width: 'var(--sidebar-w)',
      flexShrink: 0,
      height: '100%',
      background: 'var(--hp-bg)',
      borderRight: '1px solid var(--hp-border)',
      display: 'flex',
      flexDirection: 'column',
      padding: '20px 14px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 11,
      padding: '4px 8px 22px'
    }
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/logo-mark.svg",
    width: "32",
    height: "32",
    alt: ""
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      lineHeight: 1.15
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-heading)',
      fontWeight: 700,
      fontSize: 15,
      color: 'var(--hp-text)'
    }
  }, "Hargeisa Parking"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-mono)',
      fontSize: 10.5,
      letterSpacing: '0.08em',
      color: 'var(--hp-text-muted)',
      textTransform: 'uppercase'
    }
  }, "Command"))), /*#__PURE__*/React.createElement("nav", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 2
    }
  }, NAV.map(n => {
    const on = active === n.label;
    return /*#__PURE__*/React.createElement("button", {
      key: n.label,
      onClick: () => onNav(n.label),
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: 11,
        width: '100%',
        padding: '10px 12px',
        borderRadius: 'var(--radius-md)',
        border: '1px solid transparent',
        cursor: 'pointer',
        textAlign: 'left',
        background: on ? 'var(--hp-purple-tint)' : 'transparent',
        borderColor: on ? 'rgba(124,108,248,0.35)' : 'transparent',
        color: on ? '#fff' : 'var(--hp-text-2)',
        fontFamily: 'var(--font-body)',
        fontSize: 14,
        fontWeight: on ? 600 : 500,
        transition: 'background var(--dur-fast) var(--ease-out), color var(--dur-fast) var(--ease-out)'
      },
      onMouseEnter: e => {
        if (!on) {
          e.currentTarget.style.background = 'var(--hp-overlay)';
          e.currentTarget.style.color = 'var(--hp-text)';
        }
      },
      onMouseLeave: e => {
        if (!on) {
          e.currentTarget.style.background = 'transparent';
          e.currentTarget.style.color = 'var(--hp-text-2)';
        }
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: n.icon,
      size: 18,
      color: on ? 'var(--hp-purple-300)' : 'currentColor'
    }), n.label);
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'auto',
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      padding: '10px 8px',
      borderTop: '1px solid var(--hp-border)'
    }
  }, /*#__PURE__*/React.createElement(Avatar, {
    name: "Naima Warsame",
    size: 34,
    status: "success"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      lineHeight: 1.25,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      fontWeight: 600,
      color: 'var(--hp-text)',
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis'
    }
  }, "Naima Warsame"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 11,
      color: 'var(--hp-text-muted)'
    }
  }, "Operations lead"))));
}
window.HPCSidebar = Sidebar;
window.HPCIcon = Icon;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/hpark-command/Sidebar.jsx", error: String((e && e.message) || e) }); }

// ui_kits/hpark-enforce/EnforceApp.jsx
try { (() => {
/* global React, Button, Badge, Card, Input */
const {
  useState,
  useEffect
} = React;
const Icon = ({
  name,
  size = 20,
  color,
  style
}) => /*#__PURE__*/React.createElement("i", {
  "data-lucide": name,
  style: {
    width: size,
    height: size,
    color,
    display: 'inline-flex',
    ...style
  }
});
const VIOLATIONS = [['No valid permit', 'parking-meter', 'SLSH 150,000'], ['Expired meter', 'timer-off', 'SLSH 80,000'], ['Disabled bay misuse', 'accessibility', 'SLSH 300,000'], ['Double parking', 'cars', 'SLSH 120,000'], ['Loading zone', 'truck', 'SLSH 100,000']];
function ScreenShell({
  title,
  sub,
  children,
  onBack
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '6px 20px 14px',
      display: 'flex',
      alignItems: 'center',
      gap: 12
    }
  }, onBack && /*#__PURE__*/React.createElement("button", {
    onClick: onBack,
    style: {
      width: 38,
      height: 38,
      borderRadius: 10,
      background: 'var(--hp-overlay)',
      border: '1px solid var(--hp-border)',
      color: 'var(--hp-text)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      cursor: 'pointer',
      flexShrink: 0
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-left",
    size: 18
  })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-heading)',
      fontWeight: 700,
      fontSize: 22,
      color: 'var(--hp-text)'
    }
  }, title), sub && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: 'var(--hp-text-muted)'
    }
  }, sub))), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      overflow: 'auto',
      padding: '0 20px 16px'
    }
  }, children));
}
function SearchScreen({
  onFound
}) {
  return /*#__PURE__*/React.createElement(ScreenShell, {
    title: "Vehicle search",
    sub: "Fastest possible lookup"
  }, /*#__PURE__*/React.createElement("button", {
    onClick: onFound,
    style: {
      width: '100%',
      aspectRatio: '16/10',
      borderRadius: 'var(--radius-xl)',
      cursor: 'pointer',
      border: '1px solid rgba(124,108,248,0.3)',
      background: 'linear-gradient(160deg, rgba(124,108,248,0.16), rgba(0,216,214,0.08))',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 12,
      color: 'var(--hp-text)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 64,
      height: 64,
      borderRadius: 18,
      background: 'var(--hp-gradient)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "scan-line",
    size: 30,
    color: "#fff"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-heading)',
      fontWeight: 700,
      fontSize: 18
    }
  }, "Scan plate"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: 'var(--hp-text-2)'
    }
  }, "Point camera at the number plate")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      margin: '18px 0'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      height: 1,
      background: 'var(--hp-border)'
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: 'var(--hp-text-muted)'
    }
  }, "or enter manually"), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      height: 1,
      background: 'var(--hp-border)'
    }
  })), /*#__PURE__*/React.createElement(Input, {
    plate: true,
    size: "xl",
    placeholder: "HG-0000",
    defaultValue: "HG-4821",
    containerStyle: {
      marginBottom: 14
    }
  }), /*#__PURE__*/React.createElement(Button, {
    block: true,
    size: "lg",
    onClick: onFound,
    icon: /*#__PURE__*/React.createElement(Icon, {
      name: "search",
      size: 18
    })
  }, "Look up vehicle"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 22
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "hp-eyebrow",
    style: {
      marginBottom: 10
    }
  }, "Recent"), [['HG-2210', '2 min ago'], ['SL-09122', '14 min ago']].map(([p, t]) => /*#__PURE__*/React.createElement("div", {
    key: p,
    onClick: onFound,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '11px 0',
      borderBottom: '1px solid var(--hp-border)',
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "hp-plate",
    style: {
      fontSize: 14
    }
  }, p), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: 'var(--hp-text-muted)',
      marginLeft: 'auto'
    }
  }, t), /*#__PURE__*/React.createElement(Icon, {
    name: "chevron-right",
    size: 16,
    color: "var(--hp-text-muted)"
  })))));
}
function InfoRow({
  icon,
  label,
  children
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '13px 0',
      borderBottom: '1px solid var(--hp-border)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: icon,
    size: 18,
    color: "var(--hp-text-muted)"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      color: 'var(--hp-text-2)'
    }
  }, label), /*#__PURE__*/React.createElement("span", {
    style: {
      marginLeft: 'auto',
      fontSize: 14,
      fontWeight: 600,
      color: 'var(--hp-text)',
      textAlign: 'right'
    }
  }, children));
}
function FoundScreen({
  onBack,
  onIssue
}) {
  return /*#__PURE__*/React.createElement(ScreenShell, {
    title: "Vehicle found",
    onBack: onBack
  }, /*#__PURE__*/React.createElement(Card, {
    glow: true,
    padding: 18,
    style: {
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginBottom: 14
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "hp-plate",
    style: {
      fontSize: 22
    }
  }, "HG-4821"), /*#__PURE__*/React.createElement(Badge, {
    status: "overdue"
  })), /*#__PURE__*/React.createElement(InfoRow, {
    icon: "user",
    label: "Owner"
  }, "Amina Yusuf"), /*#__PURE__*/React.createElement(InfoRow, {
    icon: "circle-parking",
    label: "Parking status"
  }, "Unpaid"), /*#__PURE__*/React.createElement(InfoRow, {
    icon: "file-text",
    label: "Outstanding"
  }, "1 citation"), /*#__PURE__*/React.createElement(InfoRow, {
    icon: "badge-check",
    label: "Permit"
  }, "None"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '13px 0 2px'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "map-pin",
    size: 18,
    color: "var(--hp-text-muted)"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      color: 'var(--hp-text-2)'
    }
  }, "Last seen"), /*#__PURE__*/React.createElement("span", {
    style: {
      marginLeft: 'auto',
      fontSize: 13,
      fontWeight: 600,
      color: 'var(--hp-text)'
    }
  }, "Pepsi Roundabout \xB7 4m"))), /*#__PURE__*/React.createElement(Button, {
    block: true,
    size: "xl",
    variant: "danger",
    onClick: onIssue,
    icon: /*#__PURE__*/React.createElement(Icon, {
      name: "file-plus",
      size: 19
    })
  }, "Issue citation"));
}
function ViolationScreen({
  onBack,
  onNext,
  selected,
  setSelected
}) {
  return /*#__PURE__*/React.createElement(ScreenShell, {
    title: "Select violation",
    sub: "Step 1 of 3",
    onBack: onBack
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 10
    }
  }, VIOLATIONS.map(([name, icon, fine], i) => {
    const on = selected === i;
    return /*#__PURE__*/React.createElement("button", {
      key: name,
      onClick: () => setSelected(i),
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: 13,
        padding: 15,
        textAlign: 'left',
        cursor: 'pointer',
        borderRadius: 'var(--radius-lg)',
        background: 'var(--hp-surface)',
        border: `1px solid ${on ? 'var(--hp-border-focus)' : 'var(--hp-border)'}`,
        boxShadow: on ? 'var(--glow-purple-sm)' : 'none',
        color: 'var(--hp-text)'
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        width: 40,
        height: 40,
        borderRadius: 11,
        flexShrink: 0,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: on ? 'var(--hp-purple-tint)' : 'var(--hp-overlay)',
        color: on ? 'var(--hp-purple-300)' : 'var(--hp-text-2)'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: icon,
      size: 19
    })), /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 15,
        fontWeight: 600
      }
    }, name), /*#__PURE__*/React.createElement("div", {
      style: {
        fontFamily: 'var(--font-mono)',
        fontSize: 12.5,
        color: 'var(--hp-text-muted)'
      }
    }, fine)), /*#__PURE__*/React.createElement("div", {
      style: {
        width: 22,
        height: 22,
        borderRadius: '50%',
        border: `2px solid ${on ? 'var(--hp-purple)' : 'var(--hp-border-strong)'}`,
        background: on ? 'var(--hp-purple)' : 'transparent',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
      }
    }, on && /*#__PURE__*/React.createElement(Icon, {
      name: "check",
      size: 13,
      color: "#fff"
    })));
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 16
    }
  }, /*#__PURE__*/React.createElement(Button, {
    block: true,
    size: "lg",
    disabled: selected == null,
    onClick: onNext,
    iconRight: /*#__PURE__*/React.createElement(Icon, {
      name: "arrow-right",
      size: 18
    })
  }, "Continue")));
}
function PhotoScreen({
  onBack,
  onNext
}) {
  const [shots, setShots] = useState(1);
  return /*#__PURE__*/React.createElement(ScreenShell, {
    title: "Capture evidence",
    sub: "Step 2 of 3",
    onBack: onBack
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 10,
      marginBottom: 16
    }
  }, Array.from({
    length: 4
  }).map((_, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    style: {
      aspectRatio: '1',
      borderRadius: 'var(--radius-lg)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      border: i < shots ? '1px solid var(--hp-border)' : '1px dashed var(--hp-border-strong)',
      background: i < shots ? 'linear-gradient(160deg, #1a1a28, #101019)' : 'var(--hp-surface)',
      color: 'var(--hp-text-muted)'
    }
  }, i < shots ? /*#__PURE__*/React.createElement(Icon, {
    name: "image",
    size: 22,
    color: "var(--hp-text-2)"
  }) : /*#__PURE__*/React.createElement(Icon, {
    name: "plus",
    size: 22
  })))), /*#__PURE__*/React.createElement(Button, {
    block: true,
    variant: "secondary",
    size: "lg",
    onClick: () => setShots(s => Math.min(4, s + 1)),
    icon: /*#__PURE__*/React.createElement(Icon, {
      name: "camera",
      size: 18
    }),
    style: {
      marginBottom: 12
    }
  }, "Add photo (", shots, "/4)"), /*#__PURE__*/React.createElement(Card, {
    padding: 14,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 11,
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "map-pin",
    size: 18,
    color: "var(--hp-teal)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 14,
      fontWeight: 600,
      color: 'var(--hp-text)'
    }
  }, "Pepsi Roundabout, Zone 4"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-mono)',
      fontSize: 12,
      color: 'var(--hp-text-muted)'
    }
  }, "9.5621\xB0 N, 44.0650\xB0 E")), /*#__PURE__*/React.createElement(Badge, {
    status: "patrol",
    glyph: ""
  }, "GPS lock")), /*#__PURE__*/React.createElement(Button, {
    block: true,
    size: "lg",
    onClick: onNext,
    iconRight: /*#__PURE__*/React.createElement(Icon, {
      name: "arrow-right",
      size: 18
    })
  }, "Review citation"));
}
function IssuedScreen({
  onDone
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 28,
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 92,
      height: 92,
      borderRadius: '50%',
      background: 'rgba(0,200,83,0.14)',
      border: '1px solid rgba(0,200,83,0.4)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      marginBottom: 22,
      boxShadow: '0 0 0 8px rgba(0,200,83,0.06)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "check",
    size: 44,
    color: "var(--hp-success)"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-heading)',
      fontWeight: 700,
      fontSize: 26,
      color: 'var(--hp-text)'
    }
  }, "Citation issued"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 14,
      color: 'var(--hp-text-2)',
      marginTop: 6,
      marginBottom: 4
    }
  }, "Completed in 24 seconds"), /*#__PURE__*/React.createElement("span", {
    className: "hp-plate",
    style: {
      fontSize: 14,
      marginTop: 8
    }
  }, "CIT-2026-04822"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: 'var(--hp-text-muted)',
      marginTop: 14
    }
  }, "SMS sent to owner \xB7 synced to Command"), /*#__PURE__*/React.createElement("div", {
    style: {
      width: '100%',
      marginTop: 30
    }
  }, /*#__PURE__*/React.createElement(Button, {
    block: true,
    size: "lg",
    onClick: onDone
  }, "Done")));
}
function EnforceApp() {
  const [step, setStep] = useState('search');
  const [violation, setViolation] = useState(null);
  useEffect(() => {
    if (window.lucide) window.lucide.createIcons();
  });
  return /*#__PURE__*/React.createElement(React.Fragment, null, window.HPStatusBar({
    dark: true
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      display: 'flex',
      flexDirection: 'column',
      paddingTop: 4
    }
  }, step === 'search' && /*#__PURE__*/React.createElement(SearchScreen, {
    onFound: () => setStep('found')
  }), step === 'found' && /*#__PURE__*/React.createElement(FoundScreen, {
    onBack: () => setStep('search'),
    onIssue: () => setStep('violation')
  }), step === 'violation' && /*#__PURE__*/React.createElement(ViolationScreen, {
    onBack: () => setStep('found'),
    onNext: () => setStep('photo'),
    selected: violation,
    setSelected: setViolation
  }), step === 'photo' && /*#__PURE__*/React.createElement(PhotoScreen, {
    onBack: () => setStep('violation'),
    onNext: () => setStep('issued')
  }), step === 'issued' && /*#__PURE__*/React.createElement(IssuedScreen, {
    onDone: () => {
      setStep('search');
      setViolation(null);
    }
  })), window.HPHomeIndicator());
}
window.EnforceApp = EnforceApp;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/hpark-enforce/EnforceApp.jsx", error: String((e && e.message) || e) }); }

// ui_kits/hpark-enforce/phone-frame.jsx
try { (() => {
/* global React */
const {
  useState
} = React;
function StatusBar({
  dark
}) {
  const col = dark ? 'var(--hp-text)' : '#fff';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height: 44,
      flexShrink: 0,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 22px 0 26px',
      fontFamily: 'var(--font-mono)',
      fontSize: 14,
      fontWeight: 600,
      color: col
    }
  }, /*#__PURE__*/React.createElement("span", null, "9:41"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("i", {
    "data-lucide": "signal",
    style: {
      width: 16,
      height: 16
    }
  }), /*#__PURE__*/React.createElement("i", {
    "data-lucide": "wifi",
    style: {
      width: 16,
      height: 16
    }
  }), /*#__PURE__*/React.createElement("i", {
    "data-lucide": "battery-full",
    style: {
      width: 20,
      height: 16
    }
  })));
}

/** PhoneFrame — 390×844 device shell on dark canvas. */
function PhoneFrame({
  children,
  label
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: 14
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 390,
      height: 844,
      borderRadius: 46,
      padding: 5,
      background: 'linear-gradient(160deg, #26263a, #0d0d16)',
      boxShadow: '0 0 0 1px rgba(255,255,255,0.06), 0 40px 90px -30px rgba(0,0,0,0.8)',
      flexShrink: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      width: '100%',
      height: '100%',
      borderRadius: 41,
      overflow: 'hidden',
      background: 'var(--hp-bg)',
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      top: 10,
      left: '50%',
      transform: 'translateX(-50%)',
      width: 116,
      height: 32,
      background: '#000',
      borderRadius: 20,
      zIndex: 20
    }
  }), children)), label && /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-mono)',
      fontSize: 12,
      color: 'var(--hp-text-muted)'
    }
  }, label));
}
function HomeIndicator() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flexShrink: 0,
      height: 26,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 134,
      height: 5,
      borderRadius: 3,
      background: 'rgba(255,255,255,0.22)'
    }
  }));
}
Object.assign(window, {
  HPPhoneFrame: PhoneFrame,
  HPStatusBar: StatusBar,
  HPHomeIndicator: HomeIndicator
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/hpark-enforce/phone-frame.jsx", error: String((e && e.message) || e) }); }

// ui_kits/hpark-pay/PayApp.jsx
try { (() => {
/* global React, Button, Badge, Card */
const {
  useState,
  useEffect
} = React;
const Icon = ({
  name,
  size = 20,
  color,
  style
}) => /*#__PURE__*/React.createElement("i", {
  "data-lucide": name,
  style: {
    width: size,
    height: size,
    color,
    display: 'inline-flex',
    ...style
  }
});
const TABS = [['home', 'layout-dashboard', 'Home'], ['scan', 'scan-line', 'Scan'], ['citations', 'file-text', 'Citations'], ['search', 'search', 'Search'], ['profile', 'user', 'Profile']];
function BottomNav({
  active,
  onTab
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flexShrink: 0,
      display: 'flex',
      alignItems: 'stretch',
      padding: '8px 8px 4px',
      borderTop: '1px solid var(--hp-border)',
      background: 'rgba(10,10,15,0.85)',
      backdropFilter: 'var(--blur-bg)'
    }
  }, TABS.map(([key, icon, label]) => {
    const on = active === key;
    return /*#__PURE__*/React.createElement("button", {
      key: key,
      onClick: () => onTab(key),
      style: {
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: 4,
        padding: '6px 0',
        background: 'none',
        border: 'none',
        cursor: 'pointer',
        color: on ? 'var(--hp-purple-300)' : 'var(--hp-text-muted)'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: icon,
      size: 22
    }), /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 10.5,
        fontWeight: on ? 600 : 500
      }
    }, label));
  }));
}
function HomeTab({
  onPay
}) {
  const [mins, setMins] = useState(42);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflow: 'auto',
      padding: '4px 20px 20px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '4px 0 16px'
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: 'var(--hp-text-muted)'
    }
  }, "Good morning"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-heading)',
      fontWeight: 700,
      fontSize: 22,
      color: 'var(--hp-text)'
    }
  }, "Amina")), /*#__PURE__*/React.createElement("div", {
    style: {
      width: 44,
      height: 44,
      borderRadius: '50%',
      background: 'rgba(124,108,248,0.18)',
      border: '1px solid var(--hp-border)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      color: 'var(--hp-purple-300)',
      fontWeight: 700
    }
  }, "AY")), /*#__PURE__*/React.createElement("div", {
    style: {
      borderRadius: 'var(--radius-xl)',
      overflow: 'hidden',
      border: '1px solid rgba(124,108,248,0.28)',
      background: 'linear-gradient(150deg, rgba(124,108,248,0.18), rgba(0,216,214,0.08))',
      padding: 20,
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginBottom: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "hp-eyebrow"
  }, "Active session"), /*#__PURE__*/React.createElement(Badge, {
    status: "paid"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-mono)',
      fontWeight: 700,
      fontSize: 46,
      lineHeight: 1,
      color: '#fff'
    }
  }, "0:", String(mins).padStart(2, '0')), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      color: 'var(--hp-text-2)',
      paddingBottom: 8
    }
  }, "remaining")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      marginTop: 12,
      fontSize: 13,
      color: 'var(--hp-text-2)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "map-pin",
    size: 15,
    color: "var(--hp-teal)"
  }), " Zone 4 \xB7 Pepsi Roundabout \xB7 Bay 12"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 10,
      marginTop: 16
    }
  }, /*#__PURE__*/React.createElement(Button, {
    size: "md",
    variant: "secondary",
    style: {
      flex: 1
    },
    onClick: () => setMins(m => m + 30),
    icon: /*#__PURE__*/React.createElement(Icon, {
      name: "plus",
      size: 16
    })
  }, "Extend 30m"), /*#__PURE__*/React.createElement(Button, {
    size: "md",
    style: {
      flex: 1
    }
  }, "View receipt"))), /*#__PURE__*/React.createElement("div", {
    className: "hp-eyebrow",
    style: {
      margin: '6px 0 10px'
    }
  }, "Quick actions"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 12
    }
  }, [['Find parking', 'circle-parking', 'var(--hp-teal)'], ['Pay citation', 'receipt', 'var(--hp-danger)'], ['My vehicles', 'car', 'var(--hp-purple-300)'], ['Appeals', 'gavel', 'var(--hp-warning)']].map(([t, ic, c]) => /*#__PURE__*/React.createElement("button", {
    key: t,
    onClick: t === 'Pay citation' ? onPay : undefined,
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 12,
      padding: 16,
      borderRadius: 'var(--radius-lg)',
      background: 'var(--hp-surface)',
      border: '1px solid var(--hp-border)',
      cursor: 'pointer',
      textAlign: 'left',
      color: 'var(--hp-text)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 38,
      height: 38,
      borderRadius: 11,
      background: 'var(--hp-overlay)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: ic,
    size: 19,
    color: c
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      fontWeight: 600
    }
  }, t)))));
}
const CITES = [['CIT-2026-04821', 'HG-4821', 'overdue', 'No valid permit', 'SLSH 150,000'], ['CIT-2026-03194', 'HG-4821', 'paid', 'Expired meter', 'SLSH 80,000']];
function CitationsTab({
  onPay
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflow: 'auto',
      padding: '4px 20px 20px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-heading)',
      fontWeight: 700,
      fontSize: 22,
      color: 'var(--hp-text)',
      padding: '8px 0 16px'
    }
  }, "Citations"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, CITES.map(([id, plate, status, reason, fine]) => /*#__PURE__*/React.createElement(Card, {
    key: id,
    padding: 16
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginBottom: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "hp-plate",
    style: {
      fontSize: 14
    }
  }, plate), /*#__PURE__*/React.createElement(Badge, {
    status: status
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 15,
      fontWeight: 600,
      color: 'var(--hp-text)'
    }
  }, reason), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-mono)',
      fontSize: 12,
      color: 'var(--hp-text-muted)',
      marginTop: 2
    }
  }, id), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginTop: 14
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-mono)',
      fontWeight: 700,
      fontSize: 18,
      color: 'var(--hp-text)'
    }
  }, fine), status === 'overdue' ? /*#__PURE__*/React.createElement(Button, {
    size: "md",
    onClick: onPay
  }, "Pay now") : /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6,
      fontSize: 13,
      color: 'var(--hp-success)',
      fontWeight: 600
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "check",
    size: 15
  }), " Settled"))))));
}
function PaySheet({
  onClose,
  onPaid
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      zIndex: 30,
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'flex-end'
    }
  }, /*#__PURE__*/React.createElement("div", {
    onClick: onClose,
    style: {
      position: 'absolute',
      inset: 0,
      background: 'rgba(0,0,0,0.55)',
      backdropFilter: 'blur(2px)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      background: 'var(--hp-elevated)',
      borderTopLeftRadius: 24,
      borderTopRightRadius: 24,
      border: '1px solid var(--hp-border)',
      borderBottom: 'none',
      padding: '12px 20px 30px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 40,
      height: 4,
      borderRadius: 3,
      background: 'var(--hp-border-strong)',
      margin: '0 auto 18px'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-heading)',
      fontWeight: 700,
      fontSize: 22,
      color: 'var(--hp-text)',
      marginBottom: 4
    }
  }, "Pay citation"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 14,
      color: 'var(--hp-text-2)',
      marginBottom: 18
    }
  }, "CIT-2026-04821 \xB7 No valid permit"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '14px 16px',
      borderRadius: 'var(--radius-lg)',
      background: 'var(--hp-surface)',
      border: '1px solid var(--hp-border)',
      marginBottom: 14
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      color: 'var(--hp-text-2)'
    }
  }, "Amount due"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-mono)',
      fontWeight: 700,
      fontSize: 20,
      color: 'var(--hp-text)'
    }
  }, "SLSH 150,000")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '14px 16px',
      borderRadius: 'var(--radius-lg)',
      background: 'var(--hp-surface)',
      border: '1px solid var(--hp-border-focus)',
      marginBottom: 18
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "smartphone",
    size: 20,
    color: "var(--hp-teal)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 14,
      fontWeight: 600,
      color: 'var(--hp-text)'
    }
  }, "ZAAD Mobile Money"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-mono)',
      fontSize: 12,
      color: 'var(--hp-text-muted)'
    }
  }, "\u2022\u2022\u2022\u2022 4471")), /*#__PURE__*/React.createElement(Icon, {
    name: "check-circle",
    size: 20,
    color: "var(--hp-success)"
  })), /*#__PURE__*/React.createElement(Button, {
    block: true,
    size: "xl",
    onClick: onPaid
  }, "Pay SLSH 150,000")));
}
function PaidToast() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      zIndex: 40,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'rgba(10,10,15,0.92)',
      backdropFilter: 'blur(4px)',
      padding: 30,
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 92,
      height: 92,
      borderRadius: '50%',
      background: 'rgba(0,200,83,0.14)',
      border: '1px solid rgba(0,200,83,0.4)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      boxShadow: '0 0 0 8px rgba(0,200,83,0.06)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "check",
    size: 44,
    color: "var(--hp-success)"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-heading)',
      fontWeight: 700,
      fontSize: 24,
      color: 'var(--hp-text)',
      marginTop: 22
    }
  }, "Payment complete"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 14,
      color: 'var(--hp-text-2)',
      marginTop: 6
    }
  }, "Citation settled \xB7 receipt sent by SMS"));
}
function PayApp() {
  const [tab, setTab] = useState('home');
  const [sheet, setSheet] = useState(false);
  const [toast, setToast] = useState(false);
  useEffect(() => {
    if (window.lucide) window.lucide.createIcons();
  });
  useEffect(() => {
    if (toast) {
      const t = setTimeout(() => setToast(false), 2200);
      return () => clearTimeout(t);
    }
  }, [toast]);
  return /*#__PURE__*/React.createElement(React.Fragment, null, window.HPStatusBar({
    dark: true
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      display: 'flex',
      flexDirection: 'column',
      position: 'relative'
    }
  }, tab === 'home' && /*#__PURE__*/React.createElement(HomeTab, {
    onPay: () => {
      setTab('citations');
      setSheet(true);
    }
  }), tab === 'citations' && /*#__PURE__*/React.createElement(CitationsTab, {
    onPay: () => setSheet(true)
  }), tab !== 'home' && tab !== 'citations' && /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      color: 'var(--hp-text-muted)',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: TABS.find(t => t[0] === tab)[1],
    size: 34
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14
    }
  }, TABS.find(t => t[0] === tab)[2])), sheet && /*#__PURE__*/React.createElement(PaySheet, {
    onClose: () => setSheet(false),
    onPaid: () => {
      setSheet(false);
      setToast(true);
    }
  }), toast && /*#__PURE__*/React.createElement(PaidToast, null)), /*#__PURE__*/React.createElement(BottomNav, {
    active: tab,
    onTab: setTab
  }), window.HPHomeIndicator());
}
window.PayApp = PayApp;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/hpark-pay/PayApp.jsx", error: String((e && e.message) || e) }); }

// ui_kits/hpark-pay/phone-frame.jsx
try { (() => {
/* global React */
const {
  useState
} = React;
function StatusBar({
  dark
}) {
  const col = dark ? 'var(--hp-text)' : '#fff';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height: 44,
      flexShrink: 0,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 22px 0 26px',
      fontFamily: 'var(--font-mono)',
      fontSize: 14,
      fontWeight: 600,
      color: col
    }
  }, /*#__PURE__*/React.createElement("span", null, "9:41"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("i", {
    "data-lucide": "signal",
    style: {
      width: 16,
      height: 16
    }
  }), /*#__PURE__*/React.createElement("i", {
    "data-lucide": "wifi",
    style: {
      width: 16,
      height: 16
    }
  }), /*#__PURE__*/React.createElement("i", {
    "data-lucide": "battery-full",
    style: {
      width: 20,
      height: 16
    }
  })));
}

/** PhoneFrame — 390×844 device shell on dark canvas. */
function PhoneFrame({
  children,
  label
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: 14
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 390,
      height: 844,
      borderRadius: 46,
      padding: 5,
      background: 'linear-gradient(160deg, #26263a, #0d0d16)',
      boxShadow: '0 0 0 1px rgba(255,255,255,0.06), 0 40px 90px -30px rgba(0,0,0,0.8)',
      flexShrink: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      width: '100%',
      height: '100%',
      borderRadius: 41,
      overflow: 'hidden',
      background: 'var(--hp-bg)',
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      top: 10,
      left: '50%',
      transform: 'translateX(-50%)',
      width: 116,
      height: 32,
      background: '#000',
      borderRadius: 20,
      zIndex: 20
    }
  }), children)), label && /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-mono)',
      fontSize: 12,
      color: 'var(--hp-text-muted)'
    }
  }, label));
}
function HomeIndicator() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flexShrink: 0,
      height: 26,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 134,
      height: 5,
      borderRadius: 3,
      background: 'rgba(255,255,255,0.22)'
    }
  }));
}
Object.assign(window, {
  HPPhoneFrame: PhoneFrame,
  HPStatusBar: StatusBar,
  HPHomeIndicator: HomeIndicator
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/hpark-pay/phone-frame.jsx", error: String((e && e.message) || e) }); }

// vendor/ds-bundle.js
try { (() => {
/* @ds-bundle: {"format":3,"namespace":"HargeisaParkingDesignSystem_0eb67a","components":[{"name":"Button","sourcePath":"components/buttons/Button.jsx"},{"name":"Avatar","sourcePath":"components/data/Avatar.jsx"},{"name":"Badge","sourcePath":"components/data/Badge.jsx"},{"name":"KpiCard","sourcePath":"components/data/KpiCard.jsx"},{"name":"Input","sourcePath":"components/forms/Input.jsx"},{"name":"Switch","sourcePath":"components/forms/Switch.jsx"},{"name":"Card","sourcePath":"components/surfaces/Card.jsx"}],"sourceHashes":{"components/buttons/Button.jsx":"b65e4b36446f","components/data/Avatar.jsx":"58563a737572","components/data/Badge.jsx":"7f2f4acf5b56","components/data/KpiCard.jsx":"b61a41c7cf2a","components/forms/Input.jsx":"768a3f145614","components/forms/Switch.jsx":"a2281a1eebdd","components/surfaces/Card.jsx":"4ce4fcf16ab2","ui_kits/hpark-command/Dashboard.jsx":"973fee3422f0","ui_kits/hpark-command/LiveMap.jsx":"c6b247467e71","ui_kits/hpark-command/Sidebar.jsx":"80b40ca078e9","ui_kits/hpark-enforce/EnforceApp.jsx":"b72dce87138b","ui_kits/hpark-enforce/phone-frame.jsx":"d48ad69e4760","ui_kits/hpark-pay/PayApp.jsx":"5ca285750640","ui_kits/hpark-pay/phone-frame.jsx":"d48ad69e4760"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {
  const __ds_ns = window.HargeisaParkingDesignSystem_0eb67a = window.HargeisaParkingDesignSystem_0eb67a || {};
  const __ds_scope = {};
  __ds_ns.__errors = __ds_ns.__errors || [];

  // components/buttons/Button.jsx
  try {
    (() => {
      function _extends() {
        return _extends = Object.assign ? Object.assign.bind() : function (n) {
          for (var e = 1; e < arguments.length; e++) {
            var t = arguments[e];
            for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]);
          }
          return n;
        }, _extends.apply(null, arguments);
      }
      /**
       * Button — primary action control for Hargeisa Parking.
       * Variants: primary (purple, gradient-on-hover), secondary (dark+border),
       * danger, ghost. One primary action per screen.
       */
      function Button({
        variant = 'primary',
        size = 'md',
        icon = null,
        iconRight = null,
        block = false,
        disabled = false,
        type = 'button',
        children,
        style = {},
        ...rest
      }) {
        const sizes = {
          sm: {
            height: 36,
            padding: '0 14px',
            font: 14,
            radius: 8,
            gap: 7
          },
          md: {
            height: 44,
            padding: '0 18px',
            font: 15,
            radius: 8,
            gap: 8
          },
          lg: {
            height: 52,
            padding: '0 22px',
            font: 16,
            radius: 10,
            gap: 9
          },
          xl: {
            height: 60,
            padding: '0 28px',
            font: 17,
            radius: 12,
            gap: 10
          }
        };
        const s = sizes[size] || sizes.md;
        const base = {
          display: block ? 'flex' : 'inline-flex',
          width: block ? '100%' : 'auto',
          alignItems: 'center',
          justifyContent: 'center',
          gap: s.gap,
          height: s.height,
          padding: s.padding,
          fontFamily: 'var(--font-body)',
          fontSize: s.font,
          fontWeight: 600,
          lineHeight: 1,
          letterSpacing: '-0.01em',
          border: '1px solid transparent',
          borderRadius: s.radius,
          cursor: disabled ? 'not-allowed' : 'pointer',
          opacity: disabled ? 0.45 : 1,
          transition: 'transform var(--dur-fast) var(--ease-out), box-shadow var(--dur-base) var(--ease-out), background var(--dur-base) var(--ease-out), border-color var(--dur-base) var(--ease-out)',
          whiteSpace: 'nowrap',
          userSelect: 'none'
        };
        const variants = {
          primary: {
            background: 'var(--hp-purple)',
            color: '#fff',
            borderColor: 'var(--hp-purple)'
          },
          secondary: {
            background: 'var(--hp-elevated)',
            color: 'var(--hp-text)',
            borderColor: 'var(--hp-border-strong)'
          },
          danger: {
            background: 'var(--hp-danger)',
            color: '#fff',
            borderColor: 'var(--hp-danger)'
          },
          ghost: {
            background: 'transparent',
            color: 'var(--hp-text-2)',
            borderColor: 'transparent'
          }
        };
        const hoverEnter = e => {
          if (disabled) return;
          const el = e.currentTarget;
          el.style.transform = 'translateY(-1px)';
          if (variant === 'primary') {
            el.style.background = 'var(--hp-gradient)';
            el.style.boxShadow = 'var(--glow-purple-sm)';
          } else if (variant === 'secondary') {
            el.style.borderColor = 'var(--hp-border-focus)';
            el.style.boxShadow = '0 0 0 1px rgba(124,108,248,0.30)';
          } else if (variant === 'danger') {
            el.style.boxShadow = 'var(--glow-danger)';
          } else if (variant === 'ghost') {
            el.style.background = 'var(--hp-overlay)';
            el.style.color = 'var(--hp-text)';
          }
        };
        const hoverLeave = e => {
          if (disabled) return;
          const el = e.currentTarget;
          el.style.transform = 'none';
          el.style.boxShadow = 'none';
          el.style.background = variants[variant].background;
          el.style.borderColor = variants[variant].borderColor;
          if (variant === 'ghost') el.style.color = variants.ghost.color;
        };
        const press = e => {
          if (!disabled) e.currentTarget.style.transform = 'translateY(0) scale(0.98)';
        };
        const release = e => {
          if (!disabled) e.currentTarget.style.transform = 'translateY(-1px)';
        };
        return /*#__PURE__*/React.createElement("button", _extends({
          type: type,
          disabled: disabled,
          style: {
            ...base,
            ...variants[variant],
            ...style
          },
          onMouseEnter: hoverEnter,
          onMouseLeave: hoverLeave,
          onMouseDown: press,
          onMouseUp: release
        }, rest), icon && /*#__PURE__*/React.createElement("span", {
          style: {
            display: 'inline-flex',
            flexShrink: 0
          }
        }, icon), children, iconRight && /*#__PURE__*/React.createElement("span", {
          style: {
            display: 'inline-flex',
            flexShrink: 0
          }
        }, iconRight));
      }
      Object.assign(__ds_scope, {
        Button
      });
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "components/buttons/Button.jsx",
      error: String(e && e.message || e)
    });
  }

  // components/data/Avatar.jsx
  try {
    (() => {
      function _extends() {
        return _extends = Object.assign ? Object.assign.bind() : function (n) {
          for (var e = 1; e < arguments.length; e++) {
            var t = arguments[e];
            for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]);
          }
          return n;
        }, _extends.apply(null, arguments);
      }
      /**
       * Avatar — circular identity token. Image, or initials on a tinted fill.
       * Optional status dot (e.g. officer on patrol).
       */
      function Avatar({
        name = '',
        src = null,
        size = 40,
        status = null,
        // 'patrol' | 'success' | 'danger' | null
        style = {},
        ...rest
      }) {
        const initials = name.split(' ').filter(Boolean).slice(0, 2).map(p => p[0]).join('').toUpperCase();
        const statusColor = {
          patrol: 'var(--hp-map-officer)',
          success: 'var(--hp-success)',
          danger: 'var(--hp-danger)'
        }[status];
        return /*#__PURE__*/React.createElement("span", _extends({
          style: {
            position: 'relative',
            display: 'inline-flex',
            flexShrink: 0,
            ...style
          }
        }, rest), /*#__PURE__*/React.createElement("span", {
          style: {
            width: size,
            height: size,
            borderRadius: '50%',
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            overflow: 'hidden',
            background: src ? 'var(--hp-overlay)' : 'rgba(124,108,248,0.18)',
            border: '1px solid var(--hp-border)',
            color: 'var(--hp-purple-300)',
            fontFamily: 'var(--font-body)',
            fontWeight: 700,
            fontSize: size * 0.38,
            letterSpacing: '0.01em'
          }
        }, src ? /*#__PURE__*/React.createElement("img", {
          src: src,
          alt: name,
          style: {
            width: '100%',
            height: '100%',
            objectFit: 'cover'
          }
        }) : initials), statusColor && /*#__PURE__*/React.createElement("span", {
          style: {
            position: 'absolute',
            right: -1,
            bottom: -1,
            width: size * 0.28,
            height: size * 0.28,
            minWidth: 9,
            minHeight: 9,
            borderRadius: '50%',
            background: statusColor,
            border: '2px solid var(--hp-bg)'
          }
        }));
      }
      Object.assign(__ds_scope, {
        Avatar
      });
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "components/data/Avatar.jsx",
      error: String(e && e.message || e)
    });
  }

  // components/data/Badge.jsx
  try {
    (() => {
      function _extends() {
        return _extends = Object.assign ? Object.assign.bind() : function (n) {
          for (var e = 1; e < arguments.length; e++) {
            var t = arguments[e];
            for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]);
          }
          return n;
        }, _extends.apply(null, arguments);
      }
      /**
       * Badge — small status pill. Tinted fill + colored dot/glyph.
       * Presets map to Hargeisa Parking's operational statuses.
       */
      const PRESETS = {
        paid: {
          color: 'var(--hp-success)',
          tint: 'var(--hp-success-tint)',
          glyph: '✓',
          label: 'Paid'
        },
        active: {
          color: 'var(--hp-purple)',
          tint: 'var(--hp-purple-tint)',
          glyph: '●',
          label: 'Active'
        },
        review: {
          color: 'var(--hp-teal)',
          tint: 'var(--hp-teal-tint)',
          glyph: '◌',
          label: 'Appeal Review'
        },
        overdue: {
          color: 'var(--hp-danger)',
          tint: 'var(--hp-danger-tint)',
          glyph: '▲',
          label: 'Overdue'
        },
        patrol: {
          color: 'var(--hp-map-officer)',
          tint: 'var(--hp-blue-tint)',
          glyph: '●',
          label: 'On Patrol'
        },
        expiring: {
          color: 'var(--hp-warning)',
          tint: 'var(--hp-warning-tint)',
          glyph: '◷',
          label: 'Expiring'
        },
        neutral: {
          color: 'var(--hp-text-2)',
          tint: 'rgba(255,255,255,0.06)',
          glyph: '',
          label: ''
        }
      };
      function Badge({
        status = 'neutral',
        color,
        glyph,
        size = 'md',
        children,
        style = {},
        ...rest
      }) {
        const p = PRESETS[status] || PRESETS.neutral;
        const c = color || p.color;
        const tint = (PRESETS[status] || PRESETS.neutral).tint;
        const g = glyph !== undefined ? glyph : p.glyph;
        const sizes = {
          sm: {
            font: 11,
            pad: '3px 8px',
            gap: 5
          },
          md: {
            font: 12,
            pad: '4px 10px',
            gap: 6
          },
          lg: {
            font: 13,
            pad: '6px 12px',
            gap: 7
          }
        };
        const s = sizes[size] || sizes.md;
        return /*#__PURE__*/React.createElement("span", _extends({
          style: {
            display: 'inline-flex',
            alignItems: 'center',
            gap: s.gap,
            padding: s.pad,
            fontFamily: 'var(--font-body)',
            fontSize: s.font,
            fontWeight: 600,
            lineHeight: 1,
            letterSpacing: '0.01em',
            color: c,
            background: tint,
            border: `1px solid ${c}33`,
            borderRadius: 'var(--radius-pill)',
            whiteSpace: 'nowrap',
            ...style
          }
        }, rest), g && /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: '0.92em',
            lineHeight: 1
          }
        }, g), children || p.label);
      }
      Object.assign(__ds_scope, {
        Badge
      });
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "components/data/Badge.jsx",
      error: String(e && e.message || e)
    });
  }

  // components/data/KpiCard.jsx
  try {
    (() => {
      function _extends() {
        return _extends = Object.assign ? Object.assign.bind() : function (n) {
          for (var e = 1; e < arguments.length; e++) {
            var t = arguments[e];
            for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]);
          }
          return n;
        }, _extends.apply(null, arguments);
      }
      /**
       * KpiCard — dashboard metric tile. Big mono value, label, delta chip.
       * Value uses JetBrains Mono with tabular figures.
       */
      function KpiCard({
        label,
        value,
        delta = null,
        deltaDir = 'up',
        icon = null,
        accent = 'var(--hp-purple)',
        style = {},
        ...rest
      }) {
        const up = deltaDir === 'up';
        const deltaColor = up ? 'var(--hp-success)' : 'var(--hp-danger)';
        return /*#__PURE__*/React.createElement("div", _extends({
          style: {
            background: 'var(--hp-surface)',
            border: '1px solid var(--hp-border)',
            borderRadius: 'var(--radius-lg)',
            padding: 20,
            display: 'flex',
            flexDirection: 'column',
            gap: 14,
            ...style
          }
        }, rest), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between'
          }
        }, /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 12,
            fontWeight: 600,
            letterSpacing: '0.04em',
            textTransform: 'uppercase',
            color: 'var(--hp-text-muted)'
          }
        }, label), icon && /*#__PURE__*/React.createElement("span", {
          style: {
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            width: 30,
            height: 30,
            borderRadius: 8,
            background: 'rgba(124,108,248,0.12)',
            color: accent
          }
        }, icon)), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'flex-end',
            gap: 10,
            flexWrap: 'wrap'
          }
        }, /*#__PURE__*/React.createElement("span", {
          style: {
            fontFamily: 'var(--font-mono)',
            fontSize: 32,
            fontWeight: 700,
            lineHeight: 1,
            color: 'var(--hp-text)',
            fontFeatureSettings: "'tnum' 1"
          }
        }, value), delta != null && /*#__PURE__*/React.createElement("span", {
          style: {
            display: 'inline-flex',
            alignItems: 'center',
            gap: 3,
            fontFamily: 'var(--font-mono)',
            fontSize: 13,
            fontWeight: 600,
            color: deltaColor,
            paddingBottom: 3
          }
        }, /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 11
          }
        }, up ? '▲' : '▼'), delta)));
      }
      Object.assign(__ds_scope, {
        KpiCard
      });
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "components/data/KpiCard.jsx",
      error: String(e && e.message || e)
    });
  }

  // components/forms/Input.jsx
  try {
    (() => {
      function _extends() {
        return _extends = Object.assign ? Object.assign.bind() : function (n) {
          for (var e = 1; e < arguments.length; e++) {
            var t = arguments[e];
            for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]);
          }
          return n;
        }, _extends.apply(null, arguments);
      }
      /**
       * Input — text field on dark surface. Optional leading icon, label, hint,
       * and a `plate` mode for vehicle-plate entry (mono, uppercase, wide tracking).
       */
      function Input({
        label,
        hint,
        error,
        icon = null,
        plate = false,
        size = 'md',
        style = {},
        containerStyle = {},
        ...rest
      }) {
        const [focus, setFocus] = React.useState(false);
        const sizes = {
          md: 44,
          lg: 52,
          xl: 60
        };
        const h = sizes[size] || 44;
        return /*#__PURE__*/React.createElement("label", {
          style: {
            display: 'flex',
            flexDirection: 'column',
            gap: 7,
            ...containerStyle
          }
        }, label && /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 13,
            fontWeight: 600,
            color: 'var(--hp-text-2)',
            letterSpacing: '-0.005em'
          }
        }, label), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            gap: 10,
            height: h,
            padding: plate ? '0 16px' : '0 14px',
            background: 'var(--hp-overlay)',
            border: `1px solid ${error ? 'var(--hp-danger)' : focus ? 'var(--hp-border-focus)' : 'var(--hp-border)'}`,
            borderRadius: plate ? 'var(--radius-md)' : 'var(--radius-sm)',
            boxShadow: focus && !error ? 'var(--ring-focus)' : 'none',
            transition: 'border-color var(--dur-base) var(--ease-out), box-shadow var(--dur-base) var(--ease-out)'
          }
        }, icon && /*#__PURE__*/React.createElement("span", {
          style: {
            display: 'inline-flex',
            color: 'var(--hp-text-muted)',
            flexShrink: 0
          }
        }, icon), /*#__PURE__*/React.createElement("input", _extends({
          onFocus: e => {
            setFocus(true);
            rest.onFocus && rest.onFocus(e);
          },
          onBlur: e => {
            setFocus(false);
            rest.onBlur && rest.onBlur(e);
          },
          style: {
            flex: 1,
            width: '100%',
            border: 'none',
            outline: 'none',
            background: 'transparent',
            color: 'var(--hp-text)',
            fontFamily: plate ? 'var(--font-mono)' : 'var(--font-body)',
            fontSize: plate ? 22 : 15,
            fontWeight: plate ? 700 : 500,
            letterSpacing: plate ? '0.14em' : 'normal',
            textTransform: plate ? 'uppercase' : 'none',
            ...style
          }
        }, rest))), (hint || error) && /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 12,
            color: error ? 'var(--hp-danger)' : 'var(--hp-text-muted)'
          }
        }, error || hint));
      }
      Object.assign(__ds_scope, {
        Input
      });
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "components/forms/Input.jsx",
      error: String(e && e.message || e)
    });
  }

  // components/forms/Switch.jsx
  try {
    (() => {
      function _extends() {
        return _extends = Object.assign ? Object.assign.bind() : function (n) {
          for (var e = 1; e < arguments.length; e++) {
            var t = arguments[e];
            for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]);
          }
          return n;
        }, _extends.apply(null, arguments);
      }
      /**
       * Switch — toggle control. Purple when on. 44px-friendly hit area.
       */
      function Switch({
        checked = false,
        onChange,
        disabled = false,
        label,
        style = {},
        ...rest
      }) {
        const toggle = () => {
          if (!disabled && onChange) onChange(!checked);
        };
        const track = {
          width: 44,
          height: 26,
          borderRadius: 999,
          flexShrink: 0,
          background: checked ? 'var(--hp-purple)' : 'var(--hp-overlay)',
          border: `1px solid ${checked ? 'var(--hp-purple)' : 'var(--hp-border-strong)'}`,
          boxShadow: checked ? 'var(--glow-purple-sm)' : 'none',
          position: 'relative',
          cursor: disabled ? 'not-allowed' : 'pointer',
          transition: 'background var(--dur-base) var(--ease-out), box-shadow var(--dur-base) var(--ease-out)',
          opacity: disabled ? 0.5 : 1
        };
        const knob = {
          position: 'absolute',
          top: 2,
          left: checked ? 20 : 2,
          width: 20,
          height: 20,
          borderRadius: '50%',
          background: '#fff',
          transition: 'left var(--dur-base) var(--ease-out)'
        };
        return /*#__PURE__*/React.createElement("label", {
          style: {
            display: 'inline-flex',
            alignItems: 'center',
            gap: 10,
            cursor: disabled ? 'not-allowed' : 'pointer',
            ...style
          }
        }, /*#__PURE__*/React.createElement("span", _extends({
          role: "switch",
          "aria-checked": checked,
          onClick: toggle,
          style: track
        }, rest), /*#__PURE__*/React.createElement("span", {
          style: knob
        })), label && /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 14,
            color: 'var(--hp-text)',
            fontWeight: 500
          }
        }, label));
      }
      Object.assign(__ds_scope, {
        Switch
      });
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "components/forms/Switch.jsx",
      error: String(e && e.message || e)
    });
  }

  // components/surfaces/Card.jsx
  try {
    (() => {
      function _extends() {
        return _extends = Object.assign ? Object.assign.bind() : function (n) {
          for (var e = 1; e < arguments.length; e++) {
            var t = arguments[e];
            for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]);
          }
          return n;
        }, _extends.apply(null, arguments);
      }
      /**
       * Card — primary surface. Soft border, 12px radius, no drop shadow.
       * Optional purple glow on hover (interactive cards).
       */
      function Card({
        hover = false,
        glow = false,
        padding = 20,
        as = 'div',
        children,
        style = {},
        ...rest
      }) {
        const Tag = as;
        const [h, setH] = React.useState(false);
        return /*#__PURE__*/React.createElement(Tag, _extends({
          onMouseEnter: () => hover && setH(true),
          onMouseLeave: () => hover && setH(false),
          style: {
            background: 'var(--hp-surface)',
            border: '1px solid var(--hp-border)',
            borderRadius: 'var(--radius-lg)',
            padding,
            transition: 'border-color var(--dur-base) var(--ease-out), box-shadow var(--dur-base) var(--ease-out), transform var(--dur-base) var(--ease-out)',
            ...(glow || h ? {
              borderColor: 'var(--hp-border-focus)',
              boxShadow: '0 0 0 1px rgba(124,108,248,0.25), 0 10px 40px -16px rgba(124,108,248,0.45)',
              transform: hover ? 'translateY(-2px)' : 'none'
            } : {}),
            ...style
          }
        }, rest), children);
      }
      Object.assign(__ds_scope, {
        Card
      });
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "components/surfaces/Card.jsx",
      error: String(e && e.message || e)
    });
  }

  // ui_kits/hpark-command/Dashboard.jsx
  try {
    (() => {
      /* global React, KpiCard, Card, Badge */
      const LiveMap = window.HPCLiveMap;
      const Icon = window.HPCIcon;
      function ComplianceHero() {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'relative',
            overflow: 'hidden',
            borderRadius: 'var(--radius-xl)',
            border: '1px solid rgba(124,108,248,0.25)',
            background: 'linear-gradient(135deg, rgba(124,108,248,0.16), rgba(0,216,214,0.10))',
            padding: 24,
            display: 'flex',
            flexDirection: 'column',
            gap: 6,
            minHeight: 168
          }
        }, /*#__PURE__*/React.createElement("span", {
          className: "hp-eyebrow"
        }, "City compliance"), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'flex-end',
            gap: 12
          }
        }, /*#__PURE__*/React.createElement("span", {
          style: {
            fontFamily: 'var(--font-mono)',
            fontWeight: 700,
            fontSize: 64,
            lineHeight: 1,
            color: '#fff'
          }
        }, "87%"), /*#__PURE__*/React.createElement("span", {
          style: {
            display: 'inline-flex',
            alignItems: 'center',
            gap: 4,
            color: 'var(--hp-success)',
            fontFamily: 'var(--font-mono)',
            fontWeight: 600,
            fontSize: 15,
            paddingBottom: 10
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: "trending-up",
          size: 16
        }), " +4% this week")), /*#__PURE__*/React.createElement("div", {
          style: {
            marginTop: 8,
            height: 8,
            borderRadius: 999,
            background: 'rgba(255,255,255,0.08)',
            overflow: 'hidden'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            width: '87%',
            height: '100%',
            background: 'var(--hp-gradient)'
          }
        })), /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 13,
            color: 'var(--hp-text-2)',
            marginTop: 4
          }
        }, "14 of 16 zones above the 80% compliance target."));
      }
      const RECENT = [['CIT-2026-04821', 'HG-4821', 'overdue', 'No valid permit'], ['CIT-2026-04820', 'SL-09122', 'active', 'Expired meter'], ['CIT-2026-04819', 'HG-2210', 'review', 'Disabled bay'], ['CIT-2026-04818', 'HG-7741', 'active', 'Double parking']];
      function RecentCitations() {
        return /*#__PURE__*/React.createElement(Card, {
          padding: 0
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '16px 18px',
            borderBottom: '1px solid var(--hp-border)'
          }
        }, /*#__PURE__*/React.createElement("h4", {
          style: {
            fontSize: 16
          }
        }, "Recent citations"), /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 13,
            color: 'var(--hp-purple-300)',
            fontWeight: 600,
            cursor: 'pointer'
          }
        }, "View all")), /*#__PURE__*/React.createElement("div", null, RECENT.map(([id, plate, status, reason], i) => /*#__PURE__*/React.createElement("div", {
          key: id,
          style: {
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            padding: '13px 18px',
            borderBottom: i < RECENT.length - 1 ? '1px solid var(--hp-border)' : 'none'
          }
        }, /*#__PURE__*/React.createElement("span", {
          className: "hp-plate",
          style: {
            fontSize: 13
          }
        }, plate), /*#__PURE__*/React.createElement("div", {
          style: {
            minWidth: 0,
            flex: 1
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            fontFamily: 'var(--font-mono)',
            fontSize: 12.5,
            color: 'var(--hp-text-2)'
          }
        }, id), /*#__PURE__*/React.createElement("div", {
          style: {
            fontSize: 13,
            color: 'var(--hp-text)',
            whiteSpace: 'nowrap',
            overflow: 'hidden',
            textOverflow: 'ellipsis'
          }
        }, reason)), /*#__PURE__*/React.createElement(Badge, {
          status: status
        })))));
      }
      function Dashboard() {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            flexDirection: 'column',
            gap: 18
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'grid',
            gridTemplateColumns: 'repeat(4, 1fr)',
            gap: 14
          }
        }, /*#__PURE__*/React.createElement(KpiCard, {
          label: "Revenue today",
          value: "4.28M",
          delta: "+12%",
          icon: /*#__PURE__*/React.createElement(Icon, {
            name: "banknote",
            size: 17
          })
        }), /*#__PURE__*/React.createElement(KpiCard, {
          label: "Active violations",
          value: "38",
          delta: "-6%",
          deltaDir: "down",
          accent: "var(--hp-danger)",
          icon: /*#__PURE__*/React.createElement(Icon, {
            name: "triangle-alert",
            size: 17
          })
        }), /*#__PURE__*/React.createElement(KpiCard, {
          label: "Officers active",
          value: "24",
          delta: "+3",
          accent: "var(--hp-map-officer)",
          icon: /*#__PURE__*/React.createElement(Icon, {
            name: "shield",
            size: 17
          })
        }), /*#__PURE__*/React.createElement(KpiCard, {
          label: "Occupancy rate",
          value: "76%",
          delta: "+8%",
          accent: "var(--hp-teal)",
          icon: /*#__PURE__*/React.createElement(Icon, {
            name: "circle-parking",
            size: 17
          })
        })), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'grid',
            gridTemplateColumns: '1.55fr 1fr',
            gap: 18,
            alignItems: 'stretch'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            flexDirection: 'column',
            gap: 18
          }
        }, /*#__PURE__*/React.createElement(ComplianceHero, null), /*#__PURE__*/React.createElement("div", {
          style: {
            flex: 1,
            minHeight: 360
          }
        }, /*#__PURE__*/React.createElement(LiveMap, null))), /*#__PURE__*/React.createElement(RecentCitations, null)));
      }
      window.HPCDashboard = Dashboard;
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "ui_kits/hpark-command/Dashboard.jsx",
      error: String(e && e.message || e)
    });
  }

  // ui_kits/hpark-command/LiveMap.jsx
  try {
    (() => {
      /* global React */

      const MARKERS = [{
        x: 18,
        y: 30,
        c: 'var(--hp-map-paid)'
      }, {
        x: 32,
        y: 62,
        c: 'var(--hp-map-paid)'
      }, {
        x: 70,
        y: 24,
        c: 'var(--hp-map-paid)'
      }, {
        x: 55,
        y: 48,
        c: 'var(--hp-map-expiring)'
      }, {
        x: 80,
        y: 66,
        c: 'var(--hp-map-expiring)'
      }, {
        x: 44,
        y: 78,
        c: 'var(--hp-map-violation)'
      }, {
        x: 24,
        y: 50,
        c: 'var(--hp-map-violation)'
      }, {
        x: 62,
        y: 70,
        c: 'var(--hp-map-officer)',
        officer: true
      }, {
        x: 38,
        y: 38,
        c: 'var(--hp-map-officer)',
        officer: true
      }];
      const LEGEND = [['Paid', 'var(--hp-map-paid)'], ['Expiring', 'var(--hp-map-expiring)'], ['Violation', 'var(--hp-map-violation)'], ['Officer', 'var(--hp-map-officer)']];
      function LiveMap() {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'relative',
            borderRadius: 'var(--radius-lg)',
            overflow: 'hidden',
            border: '1px solid var(--hp-border)',
            background: '#0C0C14',
            minHeight: 380,
            height: '100%'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'absolute',
            inset: 0,
            backgroundImage: 'linear-gradient(rgba(124,108,248,0.06) 1px, transparent 1px),' + 'linear-gradient(90deg, rgba(124,108,248,0.06) 1px, transparent 1px),' + 'linear-gradient(115deg, rgba(255,255,255,0.05) 2px, transparent 2px),' + 'linear-gradient(200deg, rgba(255,255,255,0.04) 2px, transparent 2px)',
            backgroundSize: '46px 46px, 46px 46px, 180px 180px, 240px 240px'
          }
        }), /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'absolute',
            left: '-5%',
            top: '52%',
            width: '110%',
            height: 8,
            background: 'rgba(255,255,255,0.06)',
            transform: 'rotate(-7deg)'
          }
        }), /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'absolute',
            left: '30%',
            top: '-5%',
            width: 7,
            height: '110%',
            background: 'rgba(255,255,255,0.05)'
          }
        }), /*#__PURE__*/React.createElement("svg", {
          style: {
            position: 'absolute',
            inset: 0,
            width: '100%',
            height: '100%'
          },
          preserveAspectRatio: "none",
          viewBox: "0 0 100 100"
        }, /*#__PURE__*/React.createElement("polyline", {
          points: "38,38 50,44 62,70 80,66",
          fill: "none",
          stroke: "var(--hp-map-route)",
          strokeWidth: "0.6",
          strokeDasharray: "2 1.4",
          opacity: "0.8"
        })), MARKERS.map((m, i) => /*#__PURE__*/React.createElement("div", {
          key: i,
          style: {
            position: 'absolute',
            left: `${m.x}%`,
            top: `${m.y}%`,
            transform: 'translate(-50%,-50%)',
            width: m.officer ? 16 : 12,
            height: m.officer ? 16 : 12,
            borderRadius: '50%',
            background: m.c,
            border: m.officer ? '2px solid #fff' : 'none',
            boxShadow: `0 0 0 5px color-mix(in srgb, ${m.c} 20%, transparent)`
          }
        })), /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'absolute',
            left: 16,
            bottom: 16,
            display: 'flex',
            gap: 16,
            padding: '10px 14px',
            borderRadius: 'var(--radius-md)',
            background: 'rgba(10,10,15,0.72)',
            backdropFilter: 'var(--blur-bg)',
            border: '1px solid var(--hp-border)'
          }
        }, LEGEND.map(([label, c]) => /*#__PURE__*/React.createElement("span", {
          key: label,
          style: {
            display: 'flex',
            alignItems: 'center',
            gap: 7,
            fontSize: 12,
            color: 'var(--hp-text-2)',
            fontWeight: 500
          }
        }, /*#__PURE__*/React.createElement("span", {
          style: {
            width: 9,
            height: 9,
            borderRadius: '50%',
            background: c
          }
        }), label))), /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'absolute',
            right: 16,
            top: 16,
            display: 'flex',
            alignItems: 'center',
            gap: 7,
            padding: '7px 12px',
            borderRadius: 'var(--radius-pill)',
            background: 'rgba(10,10,15,0.72)',
            backdropFilter: 'var(--blur-bg)',
            border: '1px solid var(--hp-border)',
            fontSize: 12,
            fontWeight: 600,
            color: 'var(--hp-text)'
          }
        }, /*#__PURE__*/React.createElement("span", {
          style: {
            width: 8,
            height: 8,
            borderRadius: '50%',
            background: 'var(--hp-success)',
            boxShadow: '0 0 0 4px rgba(0,200,83,0.25)'
          }
        }), "Live \xB7 1,284 spaces"));
      }
      window.HPCLiveMap = LiveMap;
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "ui_kits/hpark-command/LiveMap.jsx",
      error: String(e && e.message || e)
    });
  }

  // ui_kits/hpark-command/Sidebar.jsx
  try {
    (() => {
      /* global React */
      const {
        useState
      } = React;
      const NAV = [{
        icon: 'layout-dashboard',
        label: 'Dashboard'
      }, {
        icon: 'map',
        label: 'Live Map'
      }, {
        icon: 'file-text',
        label: 'Citations'
      }, {
        icon: 'car',
        label: 'Vehicles'
      }, {
        icon: 'shield',
        label: 'Officers'
      }, {
        icon: 'credit-card',
        label: 'Payments'
      }, {
        icon: 'gavel',
        label: 'Appeals'
      }, {
        icon: 'bar-chart-3',
        label: 'Reports'
      }, {
        icon: 'settings',
        label: 'Settings'
      }];
      function Icon({
        name,
        size = 20,
        color,
        style
      }) {
        return /*#__PURE__*/React.createElement("i", {
          "data-lucide": name,
          style: {
            width: size,
            height: size,
            color,
            display: 'inline-flex',
            ...style
          }
        });
      }
      function Sidebar({
        active,
        onNav
      }) {
        return /*#__PURE__*/React.createElement("aside", {
          style: {
            width: 'var(--sidebar-w)',
            flexShrink: 0,
            height: '100%',
            background: 'var(--hp-bg)',
            borderRight: '1px solid var(--hp-border)',
            display: 'flex',
            flexDirection: 'column',
            padding: '20px 14px'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            gap: 11,
            padding: '4px 8px 22px'
          }
        }, /*#__PURE__*/React.createElement("img", {
          src: "../../assets/logo-mark.svg",
          width: "32",
          height: "32",
          alt: ""
        }), /*#__PURE__*/React.createElement("div", {
          style: {
            lineHeight: 1.15
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            fontFamily: 'var(--font-heading)',
            fontWeight: 700,
            fontSize: 15,
            color: 'var(--hp-text)'
          }
        }, "Hargeisa Parking"), /*#__PURE__*/React.createElement("div", {
          style: {
            fontFamily: 'var(--font-mono)',
            fontSize: 10.5,
            letterSpacing: '0.08em',
            color: 'var(--hp-text-muted)',
            textTransform: 'uppercase'
          }
        }, "Command"))), /*#__PURE__*/React.createElement("nav", {
          style: {
            display: 'flex',
            flexDirection: 'column',
            gap: 2
          }
        }, NAV.map(n => {
          const on = active === n.label;
          return /*#__PURE__*/React.createElement("button", {
            key: n.label,
            onClick: () => onNav(n.label),
            style: {
              display: 'flex',
              alignItems: 'center',
              gap: 11,
              width: '100%',
              padding: '10px 12px',
              borderRadius: 'var(--radius-md)',
              border: '1px solid transparent',
              cursor: 'pointer',
              textAlign: 'left',
              background: on ? 'var(--hp-purple-tint)' : 'transparent',
              borderColor: on ? 'rgba(124,108,248,0.35)' : 'transparent',
              color: on ? '#fff' : 'var(--hp-text-2)',
              fontFamily: 'var(--font-body)',
              fontSize: 14,
              fontWeight: on ? 600 : 500,
              transition: 'background var(--dur-fast) var(--ease-out), color var(--dur-fast) var(--ease-out)'
            },
            onMouseEnter: e => {
              if (!on) {
                e.currentTarget.style.background = 'var(--hp-overlay)';
                e.currentTarget.style.color = 'var(--hp-text)';
              }
            },
            onMouseLeave: e => {
              if (!on) {
                e.currentTarget.style.background = 'transparent';
                e.currentTarget.style.color = 'var(--hp-text-2)';
              }
            }
          }, /*#__PURE__*/React.createElement(Icon, {
            name: n.icon,
            size: 18,
            color: on ? 'var(--hp-purple-300)' : 'currentColor'
          }), n.label);
        })), /*#__PURE__*/React.createElement("div", {
          style: {
            marginTop: 'auto',
            display: 'flex',
            alignItems: 'center',
            gap: 10,
            padding: '10px 8px',
            borderTop: '1px solid var(--hp-border)'
          }
        }, /*#__PURE__*/React.createElement(Avatar, {
          name: "Naima Warsame",
          size: 34,
          status: "success"
        }), /*#__PURE__*/React.createElement("div", {
          style: {
            lineHeight: 1.25,
            minWidth: 0
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            fontSize: 13,
            fontWeight: 600,
            color: 'var(--hp-text)',
            whiteSpace: 'nowrap',
            overflow: 'hidden',
            textOverflow: 'ellipsis'
          }
        }, "Naima Warsame"), /*#__PURE__*/React.createElement("div", {
          style: {
            fontSize: 11,
            color: 'var(--hp-text-muted)'
          }
        }, "Operations lead"))));
      }
      window.HPCSidebar = Sidebar;
      window.HPCIcon = Icon;
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "ui_kits/hpark-command/Sidebar.jsx",
      error: String(e && e.message || e)
    });
  }

  // ui_kits/hpark-enforce/EnforceApp.jsx
  try {
    (() => {
      /* global React, Button, Badge, Card, Input */
      const {
        useState,
        useEffect
      } = React;
      const Icon = ({
        name,
        size = 20,
        color,
        style
      }) => /*#__PURE__*/React.createElement("i", {
        "data-lucide": name,
        style: {
          width: size,
          height: size,
          color,
          display: 'inline-flex',
          ...style
        }
      });
      const VIOLATIONS = [['No valid permit', 'parking-meter', 'SLSH 150,000'], ['Expired meter', 'timer-off', 'SLSH 80,000'], ['Disabled bay misuse', 'accessibility', 'SLSH 300,000'], ['Double parking', 'cars', 'SLSH 120,000'], ['Loading zone', 'truck', 'SLSH 100,000']];
      function ScreenShell({
        title,
        sub,
        children,
        onBack
      }) {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            flex: 1,
            minHeight: 0,
            display: 'flex',
            flexDirection: 'column'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            padding: '6px 20px 14px',
            display: 'flex',
            alignItems: 'center',
            gap: 12
          }
        }, onBack && /*#__PURE__*/React.createElement("button", {
          onClick: onBack,
          style: {
            width: 38,
            height: 38,
            borderRadius: 10,
            background: 'var(--hp-overlay)',
            border: '1px solid var(--hp-border)',
            color: 'var(--hp-text)',
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            flexShrink: 0
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: "arrow-left",
          size: 18
        })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
          style: {
            fontFamily: 'var(--font-heading)',
            fontWeight: 700,
            fontSize: 22,
            color: 'var(--hp-text)'
          }
        }, title), sub && /*#__PURE__*/React.createElement("div", {
          style: {
            fontSize: 13,
            color: 'var(--hp-text-muted)'
          }
        }, sub))), /*#__PURE__*/React.createElement("div", {
          style: {
            flex: 1,
            minHeight: 0,
            overflow: 'auto',
            padding: '0 20px 16px'
          }
        }, children));
      }
      function SearchScreen({
        onFound
      }) {
        return /*#__PURE__*/React.createElement(ScreenShell, {
          title: "Vehicle search",
          sub: "Fastest possible lookup"
        }, /*#__PURE__*/React.createElement("button", {
          onClick: onFound,
          style: {
            width: '100%',
            aspectRatio: '16/10',
            borderRadius: 'var(--radius-xl)',
            cursor: 'pointer',
            border: '1px solid rgba(124,108,248,0.3)',
            background: 'linear-gradient(160deg, rgba(124,108,248,0.16), rgba(0,216,214,0.08))',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 12,
            color: 'var(--hp-text)'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            width: 64,
            height: 64,
            borderRadius: 18,
            background: 'var(--hp-gradient)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: "scan-line",
          size: 30,
          color: "#fff"
        })), /*#__PURE__*/React.createElement("div", {
          style: {
            fontFamily: 'var(--font-heading)',
            fontWeight: 700,
            fontSize: 18
          }
        }, "Scan plate"), /*#__PURE__*/React.createElement("div", {
          style: {
            fontSize: 13,
            color: 'var(--hp-text-2)'
          }
        }, "Point camera at the number plate")), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            margin: '18px 0'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            flex: 1,
            height: 1,
            background: 'var(--hp-border)'
          }
        }), /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 12,
            color: 'var(--hp-text-muted)'
          }
        }, "or enter manually"), /*#__PURE__*/React.createElement("div", {
          style: {
            flex: 1,
            height: 1,
            background: 'var(--hp-border)'
          }
        })), /*#__PURE__*/React.createElement(Input, {
          plate: true,
          size: "xl",
          placeholder: "HG-0000",
          defaultValue: "HG-4821",
          containerStyle: {
            marginBottom: 14
          }
        }), /*#__PURE__*/React.createElement(Button, {
          block: true,
          size: "lg",
          onClick: onFound,
          icon: /*#__PURE__*/React.createElement(Icon, {
            name: "search",
            size: 18
          })
        }, "Look up vehicle"), /*#__PURE__*/React.createElement("div", {
          style: {
            marginTop: 22
          }
        }, /*#__PURE__*/React.createElement("div", {
          className: "hp-eyebrow",
          style: {
            marginBottom: 10
          }
        }, "Recent"), [['HG-2210', '2 min ago'], ['SL-09122', '14 min ago']].map(([p, t]) => /*#__PURE__*/React.createElement("div", {
          key: p,
          onClick: onFound,
          style: {
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            padding: '11px 0',
            borderBottom: '1px solid var(--hp-border)',
            cursor: 'pointer'
          }
        }, /*#__PURE__*/React.createElement("span", {
          className: "hp-plate",
          style: {
            fontSize: 14
          }
        }, p), /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 13,
            color: 'var(--hp-text-muted)',
            marginLeft: 'auto'
          }
        }, t), /*#__PURE__*/React.createElement(Icon, {
          name: "chevron-right",
          size: 16,
          color: "var(--hp-text-muted)"
        })))));
      }
      function InfoRow({
        icon,
        label,
        children
      }) {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            padding: '13px 0',
            borderBottom: '1px solid var(--hp-border)'
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: icon,
          size: 18,
          color: "var(--hp-text-muted)"
        }), /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 14,
            color: 'var(--hp-text-2)'
          }
        }, label), /*#__PURE__*/React.createElement("span", {
          style: {
            marginLeft: 'auto',
            fontSize: 14,
            fontWeight: 600,
            color: 'var(--hp-text)',
            textAlign: 'right'
          }
        }, children));
      }
      function FoundScreen({
        onBack,
        onIssue
      }) {
        return /*#__PURE__*/React.createElement(ScreenShell, {
          title: "Vehicle found",
          onBack: onBack
        }, /*#__PURE__*/React.createElement(Card, {
          glow: true,
          padding: 18,
          style: {
            marginBottom: 16
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginBottom: 14
          }
        }, /*#__PURE__*/React.createElement("span", {
          className: "hp-plate",
          style: {
            fontSize: 22
          }
        }, "HG-4821"), /*#__PURE__*/React.createElement(Badge, {
          status: "overdue"
        })), /*#__PURE__*/React.createElement(InfoRow, {
          icon: "user",
          label: "Owner"
        }, "Amina Yusuf"), /*#__PURE__*/React.createElement(InfoRow, {
          icon: "circle-parking",
          label: "Parking status"
        }, "Unpaid"), /*#__PURE__*/React.createElement(InfoRow, {
          icon: "file-text",
          label: "Outstanding"
        }, "1 citation"), /*#__PURE__*/React.createElement(InfoRow, {
          icon: "badge-check",
          label: "Permit"
        }, "None"), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            padding: '13px 0 2px'
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: "map-pin",
          size: 18,
          color: "var(--hp-text-muted)"
        }), /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 14,
            color: 'var(--hp-text-2)'
          }
        }, "Last seen"), /*#__PURE__*/React.createElement("span", {
          style: {
            marginLeft: 'auto',
            fontSize: 13,
            fontWeight: 600,
            color: 'var(--hp-text)'
          }
        }, "Pepsi Roundabout \xB7 4m"))), /*#__PURE__*/React.createElement(Button, {
          block: true,
          size: "xl",
          variant: "danger",
          onClick: onIssue,
          icon: /*#__PURE__*/React.createElement(Icon, {
            name: "file-plus",
            size: 19
          })
        }, "Issue citation"));
      }
      function ViolationScreen({
        onBack,
        onNext,
        selected,
        setSelected
      }) {
        return /*#__PURE__*/React.createElement(ScreenShell, {
          title: "Select violation",
          sub: "Step 1 of 3",
          onBack: onBack
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            flexDirection: 'column',
            gap: 10
          }
        }, VIOLATIONS.map(([name, icon, fine], i) => {
          const on = selected === i;
          return /*#__PURE__*/React.createElement("button", {
            key: name,
            onClick: () => setSelected(i),
            style: {
              display: 'flex',
              alignItems: 'center',
              gap: 13,
              padding: 15,
              textAlign: 'left',
              cursor: 'pointer',
              borderRadius: 'var(--radius-lg)',
              background: 'var(--hp-surface)',
              border: `1px solid ${on ? 'var(--hp-border-focus)' : 'var(--hp-border)'}`,
              boxShadow: on ? 'var(--glow-purple-sm)' : 'none',
              color: 'var(--hp-text)'
            }
          }, /*#__PURE__*/React.createElement("div", {
            style: {
              width: 40,
              height: 40,
              borderRadius: 11,
              flexShrink: 0,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              background: on ? 'var(--hp-purple-tint)' : 'var(--hp-overlay)',
              color: on ? 'var(--hp-purple-300)' : 'var(--hp-text-2)'
            }
          }, /*#__PURE__*/React.createElement(Icon, {
            name: icon,
            size: 19
          })), /*#__PURE__*/React.createElement("div", {
            style: {
              flex: 1
            }
          }, /*#__PURE__*/React.createElement("div", {
            style: {
              fontSize: 15,
              fontWeight: 600
            }
          }, name), /*#__PURE__*/React.createElement("div", {
            style: {
              fontFamily: 'var(--font-mono)',
              fontSize: 12.5,
              color: 'var(--hp-text-muted)'
            }
          }, fine)), /*#__PURE__*/React.createElement("div", {
            style: {
              width: 22,
              height: 22,
              borderRadius: '50%',
              border: `2px solid ${on ? 'var(--hp-purple)' : 'var(--hp-border-strong)'}`,
              background: on ? 'var(--hp-purple)' : 'transparent',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center'
            }
          }, on && /*#__PURE__*/React.createElement(Icon, {
            name: "check",
            size: 13,
            color: "#fff"
          })));
        })), /*#__PURE__*/React.createElement("div", {
          style: {
            marginTop: 16
          }
        }, /*#__PURE__*/React.createElement(Button, {
          block: true,
          size: "lg",
          disabled: selected == null,
          onClick: onNext,
          iconRight: /*#__PURE__*/React.createElement(Icon, {
            name: "arrow-right",
            size: 18
          })
        }, "Continue")));
      }
      function PhotoScreen({
        onBack,
        onNext
      }) {
        const [shots, setShots] = useState(1);
        return /*#__PURE__*/React.createElement(ScreenShell, {
          title: "Capture evidence",
          sub: "Step 2 of 3",
          onBack: onBack
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'grid',
            gridTemplateColumns: '1fr 1fr',
            gap: 10,
            marginBottom: 16
          }
        }, Array.from({
          length: 4
        }).map((_, i) => /*#__PURE__*/React.createElement("div", {
          key: i,
          style: {
            aspectRatio: '1',
            borderRadius: 'var(--radius-lg)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            border: i < shots ? '1px solid var(--hp-border)' : '1px dashed var(--hp-border-strong)',
            background: i < shots ? 'linear-gradient(160deg, #1a1a28, #101019)' : 'var(--hp-surface)',
            color: 'var(--hp-text-muted)'
          }
        }, i < shots ? /*#__PURE__*/React.createElement(Icon, {
          name: "image",
          size: 22,
          color: "var(--hp-text-2)"
        }) : /*#__PURE__*/React.createElement(Icon, {
          name: "plus",
          size: 22
        })))), /*#__PURE__*/React.createElement(Button, {
          block: true,
          variant: "secondary",
          size: "lg",
          onClick: () => setShots(s => Math.min(4, s + 1)),
          icon: /*#__PURE__*/React.createElement(Icon, {
            name: "camera",
            size: 18
          }),
          style: {
            marginBottom: 12
          }
        }, "Add photo (", shots, "/4)"), /*#__PURE__*/React.createElement(Card, {
          padding: 14,
          style: {
            display: 'flex',
            alignItems: 'center',
            gap: 11,
            marginBottom: 16
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: "map-pin",
          size: 18,
          color: "var(--hp-teal)"
        }), /*#__PURE__*/React.createElement("div", {
          style: {
            flex: 1
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            fontSize: 14,
            fontWeight: 600,
            color: 'var(--hp-text)'
          }
        }, "Pepsi Roundabout, Zone 4"), /*#__PURE__*/React.createElement("div", {
          style: {
            fontFamily: 'var(--font-mono)',
            fontSize: 12,
            color: 'var(--hp-text-muted)'
          }
        }, "9.5621\xB0 N, 44.0650\xB0 E")), /*#__PURE__*/React.createElement(Badge, {
          status: "patrol",
          glyph: ""
        }, "GPS lock")), /*#__PURE__*/React.createElement(Button, {
          block: true,
          size: "lg",
          onClick: onNext,
          iconRight: /*#__PURE__*/React.createElement(Icon, {
            name: "arrow-right",
            size: 18
          })
        }, "Review citation"));
      }
      function IssuedScreen({
        onDone
      }) {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            padding: 28,
            textAlign: 'center'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            width: 92,
            height: 92,
            borderRadius: '50%',
            background: 'rgba(0,200,83,0.14)',
            border: '1px solid rgba(0,200,83,0.4)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginBottom: 22,
            boxShadow: '0 0 0 8px rgba(0,200,83,0.06)'
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: "check",
          size: 44,
          color: "var(--hp-success)"
        })), /*#__PURE__*/React.createElement("div", {
          style: {
            fontFamily: 'var(--font-heading)',
            fontWeight: 700,
            fontSize: 26,
            color: 'var(--hp-text)'
          }
        }, "Citation issued"), /*#__PURE__*/React.createElement("div", {
          style: {
            fontSize: 14,
            color: 'var(--hp-text-2)',
            marginTop: 6,
            marginBottom: 4
          }
        }, "Completed in 24 seconds"), /*#__PURE__*/React.createElement("span", {
          className: "hp-plate",
          style: {
            fontSize: 14,
            marginTop: 8
          }
        }, "CIT-2026-04822"), /*#__PURE__*/React.createElement("div", {
          style: {
            fontSize: 13,
            color: 'var(--hp-text-muted)',
            marginTop: 14
          }
        }, "SMS sent to owner \xB7 synced to Command"), /*#__PURE__*/React.createElement("div", {
          style: {
            width: '100%',
            marginTop: 30
          }
        }, /*#__PURE__*/React.createElement(Button, {
          block: true,
          size: "lg",
          onClick: onDone
        }, "Done")));
      }
      function EnforceApp() {
        const [step, setStep] = useState('search');
        const [violation, setViolation] = useState(null);
        useEffect(() => {
          if (window.lucide) window.lucide.createIcons();
        });
        return /*#__PURE__*/React.createElement(React.Fragment, null, window.HPStatusBar({
          dark: true
        }), /*#__PURE__*/React.createElement("div", {
          style: {
            flex: 1,
            minHeight: 0,
            display: 'flex',
            flexDirection: 'column',
            paddingTop: 4
          }
        }, step === 'search' && /*#__PURE__*/React.createElement(SearchScreen, {
          onFound: () => setStep('found')
        }), step === 'found' && /*#__PURE__*/React.createElement(FoundScreen, {
          onBack: () => setStep('search'),
          onIssue: () => setStep('violation')
        }), step === 'violation' && /*#__PURE__*/React.createElement(ViolationScreen, {
          onBack: () => setStep('found'),
          onNext: () => setStep('photo'),
          selected: violation,
          setSelected: setViolation
        }), step === 'photo' && /*#__PURE__*/React.createElement(PhotoScreen, {
          onBack: () => setStep('violation'),
          onNext: () => setStep('issued')
        }), step === 'issued' && /*#__PURE__*/React.createElement(IssuedScreen, {
          onDone: () => {
            setStep('search');
            setViolation(null);
          }
        })), window.HPHomeIndicator());
      }
      window.EnforceApp = EnforceApp;
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "ui_kits/hpark-enforce/EnforceApp.jsx",
      error: String(e && e.message || e)
    });
  }

  // ui_kits/hpark-enforce/phone-frame.jsx
  try {
    (() => {
      /* global React */
      const {
        useState
      } = React;
      function StatusBar({
        dark
      }) {
        const col = dark ? 'var(--hp-text)' : '#fff';
        return /*#__PURE__*/React.createElement("div", {
          style: {
            height: 44,
            flexShrink: 0,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '0 22px 0 26px',
            fontFamily: 'var(--font-mono)',
            fontSize: 14,
            fontWeight: 600,
            color: col
          }
        }, /*#__PURE__*/React.createElement("span", null, "9:41"), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            gap: 6
          }
        }, /*#__PURE__*/React.createElement("i", {
          "data-lucide": "signal",
          style: {
            width: 16,
            height: 16
          }
        }), /*#__PURE__*/React.createElement("i", {
          "data-lucide": "wifi",
          style: {
            width: 16,
            height: 16
          }
        }), /*#__PURE__*/React.createElement("i", {
          "data-lucide": "battery-full",
          style: {
            width: 20,
            height: 16
          }
        })));
      }

      /** PhoneFrame — 390×844 device shell on dark canvas. */
      function PhoneFrame({
        children,
        label
      }) {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: 14
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            width: 390,
            height: 844,
            borderRadius: 46,
            padding: 5,
            background: 'linear-gradient(160deg, #26263a, #0d0d16)',
            boxShadow: '0 0 0 1px rgba(255,255,255,0.06), 0 40px 90px -30px rgba(0,0,0,0.8)',
            flexShrink: 0
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'relative',
            width: '100%',
            height: '100%',
            borderRadius: 41,
            overflow: 'hidden',
            background: 'var(--hp-bg)',
            display: 'flex',
            flexDirection: 'column'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'absolute',
            top: 10,
            left: '50%',
            transform: 'translateX(-50%)',
            width: 116,
            height: 32,
            background: '#000',
            borderRadius: 20,
            zIndex: 20
          }
        }), children)), label && /*#__PURE__*/React.createElement("span", {
          style: {
            fontFamily: 'var(--font-mono)',
            fontSize: 12,
            color: 'var(--hp-text-muted)'
          }
        }, label));
      }
      function HomeIndicator() {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            flexShrink: 0,
            height: 26,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            width: 134,
            height: 5,
            borderRadius: 3,
            background: 'rgba(255,255,255,0.22)'
          }
        }));
      }
      Object.assign(window, {
        HPPhoneFrame: PhoneFrame,
        HPStatusBar: StatusBar,
        HPHomeIndicator: HomeIndicator
      });
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "ui_kits/hpark-enforce/phone-frame.jsx",
      error: String(e && e.message || e)
    });
  }

  // ui_kits/hpark-pay/PayApp.jsx
  try {
    (() => {
      /* global React, Button, Badge, Card */
      const {
        useState,
        useEffect
      } = React;
      const Icon = ({
        name,
        size = 20,
        color,
        style
      }) => /*#__PURE__*/React.createElement("i", {
        "data-lucide": name,
        style: {
          width: size,
          height: size,
          color,
          display: 'inline-flex',
          ...style
        }
      });
      const TABS = [['home', 'layout-dashboard', 'Home'], ['scan', 'scan-line', 'Scan'], ['citations', 'file-text', 'Citations'], ['search', 'search', 'Search'], ['profile', 'user', 'Profile']];
      function BottomNav({
        active,
        onTab
      }) {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            flexShrink: 0,
            display: 'flex',
            alignItems: 'stretch',
            padding: '8px 8px 4px',
            borderTop: '1px solid var(--hp-border)',
            background: 'rgba(10,10,15,0.85)',
            backdropFilter: 'var(--blur-bg)'
          }
        }, TABS.map(([key, icon, label]) => {
          const on = active === key;
          return /*#__PURE__*/React.createElement("button", {
            key: key,
            onClick: () => onTab(key),
            style: {
              flex: 1,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: 4,
              padding: '6px 0',
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              color: on ? 'var(--hp-purple-300)' : 'var(--hp-text-muted)'
            }
          }, /*#__PURE__*/React.createElement(Icon, {
            name: icon,
            size: 22
          }), /*#__PURE__*/React.createElement("span", {
            style: {
              fontSize: 10.5,
              fontWeight: on ? 600 : 500
            }
          }, label));
        }));
      }
      function HomeTab({
        onPay
      }) {
        const [mins, setMins] = useState(42);
        return /*#__PURE__*/React.createElement("div", {
          style: {
            flex: 1,
            overflow: 'auto',
            padding: '4px 20px 20px'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '4px 0 16px'
          }
        }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
          style: {
            fontSize: 13,
            color: 'var(--hp-text-muted)'
          }
        }, "Good morning"), /*#__PURE__*/React.createElement("div", {
          style: {
            fontFamily: 'var(--font-heading)',
            fontWeight: 700,
            fontSize: 22,
            color: 'var(--hp-text)'
          }
        }, "Amina")), /*#__PURE__*/React.createElement("div", {
          style: {
            width: 44,
            height: 44,
            borderRadius: '50%',
            background: 'rgba(124,108,248,0.18)',
            border: '1px solid var(--hp-border)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: 'var(--hp-purple-300)',
            fontWeight: 700
          }
        }, "AY")), /*#__PURE__*/React.createElement("div", {
          style: {
            borderRadius: 'var(--radius-xl)',
            overflow: 'hidden',
            border: '1px solid rgba(124,108,248,0.28)',
            background: 'linear-gradient(150deg, rgba(124,108,248,0.18), rgba(0,216,214,0.08))',
            padding: 20,
            marginBottom: 16
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginBottom: 12
          }
        }, /*#__PURE__*/React.createElement("span", {
          className: "hp-eyebrow"
        }, "Active session"), /*#__PURE__*/React.createElement(Badge, {
          status: "paid"
        })), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'flex-end',
            gap: 8
          }
        }, /*#__PURE__*/React.createElement("span", {
          style: {
            fontFamily: 'var(--font-mono)',
            fontWeight: 700,
            fontSize: 46,
            lineHeight: 1,
            color: '#fff'
          }
        }, "0:", String(mins).padStart(2, '0')), /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 14,
            color: 'var(--hp-text-2)',
            paddingBottom: 8
          }
        }, "remaining")), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            marginTop: 12,
            fontSize: 13,
            color: 'var(--hp-text-2)'
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: "map-pin",
          size: 15,
          color: "var(--hp-teal)"
        }), " Zone 4 \xB7 Pepsi Roundabout \xB7 Bay 12"), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            gap: 10,
            marginTop: 16
          }
        }, /*#__PURE__*/React.createElement(Button, {
          size: "md",
          variant: "secondary",
          style: {
            flex: 1
          },
          onClick: () => setMins(m => m + 30),
          icon: /*#__PURE__*/React.createElement(Icon, {
            name: "plus",
            size: 16
          })
        }, "Extend 30m"), /*#__PURE__*/React.createElement(Button, {
          size: "md",
          style: {
            flex: 1
          }
        }, "View receipt"))), /*#__PURE__*/React.createElement("div", {
          className: "hp-eyebrow",
          style: {
            margin: '6px 0 10px'
          }
        }, "Quick actions"), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'grid',
            gridTemplateColumns: '1fr 1fr',
            gap: 12
          }
        }, [['Find parking', 'circle-parking', 'var(--hp-teal)'], ['Pay citation', 'receipt', 'var(--hp-danger)'], ['My vehicles', 'car', 'var(--hp-purple-300)'], ['Appeals', 'gavel', 'var(--hp-warning)']].map(([t, ic, c]) => /*#__PURE__*/React.createElement("button", {
          key: t,
          onClick: t === 'Pay citation' ? onPay : undefined,
          style: {
            display: 'flex',
            flexDirection: 'column',
            gap: 12,
            padding: 16,
            borderRadius: 'var(--radius-lg)',
            background: 'var(--hp-surface)',
            border: '1px solid var(--hp-border)',
            cursor: 'pointer',
            textAlign: 'left',
            color: 'var(--hp-text)'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            width: 38,
            height: 38,
            borderRadius: 11,
            background: 'var(--hp-overlay)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: ic,
          size: 19,
          color: c
        })), /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 14,
            fontWeight: 600
          }
        }, t)))));
      }
      const CITES = [['CIT-2026-04821', 'HG-4821', 'overdue', 'No valid permit', 'SLSH 150,000'], ['CIT-2026-03194', 'HG-4821', 'paid', 'Expired meter', 'SLSH 80,000']];
      function CitationsTab({
        onPay
      }) {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            flex: 1,
            overflow: 'auto',
            padding: '4px 20px 20px'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            fontFamily: 'var(--font-heading)',
            fontWeight: 700,
            fontSize: 22,
            color: 'var(--hp-text)',
            padding: '8px 0 16px'
          }
        }, "Citations"), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            flexDirection: 'column',
            gap: 12
          }
        }, CITES.map(([id, plate, status, reason, fine]) => /*#__PURE__*/React.createElement(Card, {
          key: id,
          padding: 16
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginBottom: 12
          }
        }, /*#__PURE__*/React.createElement("span", {
          className: "hp-plate",
          style: {
            fontSize: 14
          }
        }, plate), /*#__PURE__*/React.createElement(Badge, {
          status: status
        })), /*#__PURE__*/React.createElement("div", {
          style: {
            fontSize: 15,
            fontWeight: 600,
            color: 'var(--hp-text)'
          }
        }, reason), /*#__PURE__*/React.createElement("div", {
          style: {
            fontFamily: 'var(--font-mono)',
            fontSize: 12,
            color: 'var(--hp-text-muted)',
            marginTop: 2
          }
        }, id), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginTop: 14
          }
        }, /*#__PURE__*/React.createElement("span", {
          style: {
            fontFamily: 'var(--font-mono)',
            fontWeight: 700,
            fontSize: 18,
            color: 'var(--hp-text)'
          }
        }, fine), status === 'overdue' ? /*#__PURE__*/React.createElement(Button, {
          size: "md",
          onClick: onPay
        }, "Pay now") : /*#__PURE__*/React.createElement("span", {
          style: {
            display: 'inline-flex',
            alignItems: 'center',
            gap: 6,
            fontSize: 13,
            color: 'var(--hp-success)',
            fontWeight: 600
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: "check",
          size: 15
        }), " Settled"))))));
      }
      function PaySheet({
        onClose,
        onPaid
      }) {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'absolute',
            inset: 0,
            zIndex: 30,
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'flex-end'
          }
        }, /*#__PURE__*/React.createElement("div", {
          onClick: onClose,
          style: {
            position: 'absolute',
            inset: 0,
            background: 'rgba(0,0,0,0.55)',
            backdropFilter: 'blur(2px)'
          }
        }), /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'relative',
            background: 'var(--hp-elevated)',
            borderTopLeftRadius: 24,
            borderTopRightRadius: 24,
            border: '1px solid var(--hp-border)',
            borderBottom: 'none',
            padding: '12px 20px 30px'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            width: 40,
            height: 4,
            borderRadius: 3,
            background: 'var(--hp-border-strong)',
            margin: '0 auto 18px'
          }
        }), /*#__PURE__*/React.createElement("div", {
          style: {
            fontFamily: 'var(--font-heading)',
            fontWeight: 700,
            fontSize: 22,
            color: 'var(--hp-text)',
            marginBottom: 4
          }
        }, "Pay citation"), /*#__PURE__*/React.createElement("div", {
          style: {
            fontSize: 14,
            color: 'var(--hp-text-2)',
            marginBottom: 18
          }
        }, "CIT-2026-04821 \xB7 No valid permit"), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '14px 16px',
            borderRadius: 'var(--radius-lg)',
            background: 'var(--hp-surface)',
            border: '1px solid var(--hp-border)',
            marginBottom: 14
          }
        }, /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 14,
            color: 'var(--hp-text-2)'
          }
        }, "Amount due"), /*#__PURE__*/React.createElement("span", {
          style: {
            fontFamily: 'var(--font-mono)',
            fontWeight: 700,
            fontSize: 20,
            color: 'var(--hp-text)'
          }
        }, "SLSH 150,000")), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            gap: 12,
            padding: '14px 16px',
            borderRadius: 'var(--radius-lg)',
            background: 'var(--hp-surface)',
            border: '1px solid var(--hp-border-focus)',
            marginBottom: 18
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: "smartphone",
          size: 20,
          color: "var(--hp-teal)"
        }), /*#__PURE__*/React.createElement("div", {
          style: {
            flex: 1
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            fontSize: 14,
            fontWeight: 600,
            color: 'var(--hp-text)'
          }
        }, "ZAAD Mobile Money"), /*#__PURE__*/React.createElement("div", {
          style: {
            fontFamily: 'var(--font-mono)',
            fontSize: 12,
            color: 'var(--hp-text-muted)'
          }
        }, "\u2022\u2022\u2022\u2022 4471")), /*#__PURE__*/React.createElement(Icon, {
          name: "check-circle",
          size: 20,
          color: "var(--hp-success)"
        })), /*#__PURE__*/React.createElement(Button, {
          block: true,
          size: "xl",
          onClick: onPaid
        }, "Pay SLSH 150,000")));
      }
      function PaidToast() {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'absolute',
            inset: 0,
            zIndex: 40,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            background: 'rgba(10,10,15,0.92)',
            backdropFilter: 'blur(4px)',
            padding: 30,
            textAlign: 'center'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            width: 92,
            height: 92,
            borderRadius: '50%',
            background: 'rgba(0,200,83,0.14)',
            border: '1px solid rgba(0,200,83,0.4)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: '0 0 0 8px rgba(0,200,83,0.06)'
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: "check",
          size: 44,
          color: "var(--hp-success)"
        })), /*#__PURE__*/React.createElement("div", {
          style: {
            fontFamily: 'var(--font-heading)',
            fontWeight: 700,
            fontSize: 24,
            color: 'var(--hp-text)',
            marginTop: 22
          }
        }, "Payment complete"), /*#__PURE__*/React.createElement("div", {
          style: {
            fontSize: 14,
            color: 'var(--hp-text-2)',
            marginTop: 6
          }
        }, "Citation settled \xB7 receipt sent by SMS"));
      }
      function PayApp() {
        const [tab, setTab] = useState('home');
        const [sheet, setSheet] = useState(false);
        const [toast, setToast] = useState(false);
        useEffect(() => {
          if (window.lucide) window.lucide.createIcons();
        });
        useEffect(() => {
          if (toast) {
            const t = setTimeout(() => setToast(false), 2200);
            return () => clearTimeout(t);
          }
        }, [toast]);
        return /*#__PURE__*/React.createElement(React.Fragment, null, window.HPStatusBar({
          dark: true
        }), /*#__PURE__*/React.createElement("div", {
          style: {
            flex: 1,
            minHeight: 0,
            display: 'flex',
            flexDirection: 'column',
            position: 'relative'
          }
        }, tab === 'home' && /*#__PURE__*/React.createElement(HomeTab, {
          onPay: () => {
            setTab('citations');
            setSheet(true);
          }
        }), tab === 'citations' && /*#__PURE__*/React.createElement(CitationsTab, {
          onPay: () => setSheet(true)
        }), tab !== 'home' && tab !== 'citations' && /*#__PURE__*/React.createElement("div", {
          style: {
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            color: 'var(--hp-text-muted)',
            gap: 12
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: TABS.find(t => t[0] === tab)[1],
          size: 34
        }), /*#__PURE__*/React.createElement("span", {
          style: {
            fontSize: 14
          }
        }, TABS.find(t => t[0] === tab)[2])), sheet && /*#__PURE__*/React.createElement(PaySheet, {
          onClose: () => setSheet(false),
          onPaid: () => {
            setSheet(false);
            setToast(true);
          }
        }), toast && /*#__PURE__*/React.createElement(PaidToast, null)), /*#__PURE__*/React.createElement(BottomNav, {
          active: tab,
          onTab: setTab
        }), window.HPHomeIndicator());
      }
      window.PayApp = PayApp;
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "ui_kits/hpark-pay/PayApp.jsx",
      error: String(e && e.message || e)
    });
  }

  // ui_kits/hpark-pay/phone-frame.jsx
  try {
    (() => {
      /* global React */
      const {
        useState
      } = React;
      function StatusBar({
        dark
      }) {
        const col = dark ? 'var(--hp-text)' : '#fff';
        return /*#__PURE__*/React.createElement("div", {
          style: {
            height: 44,
            flexShrink: 0,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '0 22px 0 26px',
            fontFamily: 'var(--font-mono)',
            fontSize: 14,
            fontWeight: 600,
            color: col
          }
        }, /*#__PURE__*/React.createElement("span", null, "9:41"), /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            alignItems: 'center',
            gap: 6
          }
        }, /*#__PURE__*/React.createElement("i", {
          "data-lucide": "signal",
          style: {
            width: 16,
            height: 16
          }
        }), /*#__PURE__*/React.createElement("i", {
          "data-lucide": "wifi",
          style: {
            width: 16,
            height: 16
          }
        }), /*#__PURE__*/React.createElement("i", {
          "data-lucide": "battery-full",
          style: {
            width: 20,
            height: 16
          }
        })));
      }

      /** PhoneFrame — 390×844 device shell on dark canvas. */
      function PhoneFrame({
        children,
        label
      }) {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: 14
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            width: 390,
            height: 844,
            borderRadius: 46,
            padding: 5,
            background: 'linear-gradient(160deg, #26263a, #0d0d16)',
            boxShadow: '0 0 0 1px rgba(255,255,255,0.06), 0 40px 90px -30px rgba(0,0,0,0.8)',
            flexShrink: 0
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'relative',
            width: '100%',
            height: '100%',
            borderRadius: 41,
            overflow: 'hidden',
            background: 'var(--hp-bg)',
            display: 'flex',
            flexDirection: 'column'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            position: 'absolute',
            top: 10,
            left: '50%',
            transform: 'translateX(-50%)',
            width: 116,
            height: 32,
            background: '#000',
            borderRadius: 20,
            zIndex: 20
          }
        }), children)), label && /*#__PURE__*/React.createElement("span", {
          style: {
            fontFamily: 'var(--font-mono)',
            fontSize: 12,
            color: 'var(--hp-text-muted)'
          }
        }, label));
      }
      function HomeIndicator() {
        return /*#__PURE__*/React.createElement("div", {
          style: {
            flexShrink: 0,
            height: 26,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }
        }, /*#__PURE__*/React.createElement("div", {
          style: {
            width: 134,
            height: 5,
            borderRadius: 3,
            background: 'rgba(255,255,255,0.22)'
          }
        }));
      }
      Object.assign(window, {
        HPPhoneFrame: PhoneFrame,
        HPStatusBar: StatusBar,
        HPHomeIndicator: HomeIndicator
      });
    })();
  } catch (e) {
    __ds_ns.__errors.push({
      path: "ui_kits/hpark-pay/phone-frame.jsx",
      error: String(e && e.message || e)
    });
  }
  __ds_ns.Button = __ds_scope.Button;
  __ds_ns.Avatar = __ds_scope.Avatar;
  __ds_ns.Badge = __ds_scope.Badge;
  __ds_ns.KpiCard = __ds_scope.KpiCard;
  __ds_ns.Input = __ds_scope.Input;
  __ds_ns.Switch = __ds_scope.Switch;
  __ds_ns.Card = __ds_scope.Card;
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "vendor/ds-bundle.js", error: String((e && e.message) || e) }); }

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Avatar = __ds_scope.Avatar;

__ds_ns.Badge = __ds_scope.Badge;

__ds_ns.KpiCard = __ds_scope.KpiCard;

__ds_ns.Input = __ds_scope.Input;

__ds_ns.Switch = __ds_scope.Switch;

__ds_ns.Card = __ds_scope.Card;

})();
