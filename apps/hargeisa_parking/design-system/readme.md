# Hargeisa Parking — Design System

A dark-first, civic-tech design system for **Hargeisa Parking**, the smart-city parking
platform for Hargeisa. The product should read like software from a world-class technology
company — *"Linear meets Stripe for smart-city parking"* — never like traditional municipal
software.

## Product ecosystem

| Product | Surface | Who | Purpose |
|---|---|---|---|
| **HPark Enforce** | Officer mobile app | Parking officers | Scan plates, issue citations in <30s, patrol routes |
| **HPark Pay** | Citizen mobile app | Drivers / residents | Find & pay for parking, settle citations, appeals |
| **HPark Command** | Admin web dashboard | Operations / city | Live map, KPIs, compliance score, officers, payments |

## Brand personality
Modern · Intelligent · Trustworthy · Efficient · Civic-tech. Built for speed, clarity and
operational excellence. Keywords: **Premium, Operational, Smart City, Minimal, Fast,
Data-driven, Dark Mode, Tech-forward, World-class.**

## Design principles
Fast · Clear · Minimal · Professional · Data-driven · Mobile-first · Operational.
Large touch targets, spacious layouts, generous whitespace, card-based interfaces, minimal
visual noise, clear hierarchy, **one primary action per screen.**

### Avoid
Government-software aesthetics · heavy gradients · skeuomorphism · dense tables · excessive
shadows · corporate-blue enterprise styling · generic happy-stock imagery.

---

## Sources
This system was authored from a written brand brief (no codebase or Figma was attached).
There is **no source repository or Figma file** to reference — if one exists, attach it and
this README should be updated with the links. All visual decisions below derive from the brief.

---

## CONTENT FUNDAMENTALS — how we write

**Voice:** confident, precise, operational. We sound like a calm control-room — never chatty,
never bureaucratic. Short declaratives. Every label earns its place.

- **Person:** Address the user as **you** ("Pay your parking", "You have 1 outstanding
  citation"). The system refers to itself by product name (HPark Pay), not "we".
- **Casing:** **Sentence case** for everything — buttons, labels, headings, menu items
  ("Issue citation", not "Issue Citation"). Reserve ALL-CAPS for tiny eyebrow/label text only,
  with wide tracking (e.g. `REVENUE TODAY`).
- **Tone:** Functional and reassuring. State facts and the single next action. "Vehicle found.
  1 outstanding citation." → primary action: "Issue citation".
- **Numbers & IDs:** Always monospace. Plates `HG-4821`, citations `CIT-2026-04821`, officers
  `OFR-118`, currency `SLSH 4,280,000`. Tabular figures so columns align.
- **Status language:** Terse, glyph-prefixed: `✓ Paid`, `● Active`, `◌ Appeal review`,
  `▲ Overdue`, `● On patrol`.
- **Emoji:** **None.** Status uses geometric glyphs (✓ ● ◌ ▲ ◷) and line icons — never emoji.
- **Microcopy examples:** "Scan plate", "Fastest possible vehicle lookup", "Complete citation
  in under 30 seconds", "City compliance 87% · +4% this week", "Last seen near Pepsi
  Roundabout, 4 min ago".

---

## VISUAL FOUNDATIONS

**Mode:** Dark-first, always. There is no light theme.

**Color.** Background `#0A0A0F`, surface `#141420`, elevated `#1B1B2B`, overlay `#21212F` form
a four-step dark stack — depth is built by *layering* these, not by shadow. Primary is
**Electric Purple `#7C6CF8`**; secondary is **Bright Teal `#00D8D6`**. The accent gradient
(`135°, purple→teal`) is used sparingly — primary-button hover, hero numbers, the logomark.
Semantic: success `#00C853`, warning `#FFB300`, danger `#FF5252`. Imagery is high-contrast and
slightly desaturated, cool-leaning — authentic Hargeisa streets, officers, vehicles, markets,
infrastructure. No saturated stock photography.

**Type.** Headings **Inter Tight** (bold, tight `-0.02em` tracking, line-height ~1.05). Body
**Inter** (regular/medium, line-height 1.5). Numbers/plates/IDs **JetBrains Mono** with tabular
figures. Scale: 48 / 36 / 28 / 22 / 18 / 16 / 14 / 12. Minimum body 14px; captions 12px.

**Spacing & layout.** 8px base grid (4px half-steps). Generous whitespace, roomy cards, one
clear hierarchy per screen. Touch targets ≥44px; primary mobile actions 52–60px. Desktop:
fixed 248px sidebar. Mobile: fixed 72px bottom nav.

**Radius.** 6 inputs/tags · 8 buttons · 12 cards · 16 panels/sheets · 24 hero surfaces · pill
for badges & avatars.

**Cards.** Background `#141420`, `1px solid rgba(255,255,255,0.08)` border, 12px radius,
**no drop shadow.** Interactive cards lift 2px and gain a soft purple glow on hover.

**Elevation = glow, not shadow.** We never use grey drop shadows. Depth comes from (1) the dark
surface stack, (2) 1px hairline borders, and (3) coloured glow (`box-shadow` rings in purple /
teal / danger). Popovers are the one exception and may use a soft dark shadow.

**Borders.** Hairline `rgba(255,255,255,0.08)` default; `0.14` for stronger separation; purple
`rgba(124,108,248,0.55)` for focus/selected.

**Motion.** Fast, subtle, functional. Durations 120–260ms; ease-out `cubic-bezier(.22,1,.36,1)`.
Used for: button feedback (1px lift + 0.98 press-scale), card hover (lift + glow), KPI
count-ups, smooth view transitions. **Avoid** long, bouncy or decorative looping animations.

**Hover / press.** Hover: primary button fills with the gradient + glow; secondary brightens its
border; ghost gains an overlay fill. Press: `translateY(0) scale(0.98)`. Focus: 3px purple ring.

**Transparency & blur.** Status tints are 12–16% colour fills behind pill badges. Glass/blur
(`saturate(140%) blur(16px)`) is reserved for sticky top bars and bottom sheets over the map.

**Maps.** A core surface — dark-mode map, "mission-control" aesthetic. Markers are colour-coded
dots with a soft glow ring: paid = green, expiring = yellow, violation = red, officer = blue,
patrol route = purple.

**Data viz.** Minimal, no chart junk. Series palette: purple, teal, green, amber, red. Thin
lines, no gridline clutter, mono axis labels.

---

## ICONOGRAPHY

- **System:** **Lucide** — simple line icons, consistent ~2px stroke, rounded joins. This
  matches the Linear/Raycast aesthetic in the brief.
- **Delivery:** Loaded from CDN (`https://unpkg.com/lucide@latest`) and rendered with
  `<i data-lucide="name"></i>` + `lucide.createIcons()`. *Substitution flag: the brief asked
  for "Lucide-style" icons but shipped no icon assets — Lucide is used directly as the closest
  match. If you have a custom icon set, drop the SVGs into `assets/icons/` and document here.*
- **Stroke & size:** 1.75–2px stroke; 20px in nav/inline, 18px in dense rows, 24px for primary
  mobile affordances. Icons inherit `currentColor`.
- **Status glyphs:** geometric Unicode (✓ ● ◌ ▲ ◷) used inside badges — intentional, part of
  the status language.
- **Emoji:** never.
- **Logo:** `assets/logo-mark.svg` (logomark) and `assets/logo-wordmark.svg`. *Placeholder — a
  geometric "P" parking mark in the brand gradient. Replace with final brand art when available.*

---

## INDEX — what's in this system

**Root**
- `styles.css` — global entry point (consumers link this). `@import`s only.
- `readme.md` — this guide.
- `SKILL.md` — Agent-Skills wrapper for use in Claude Code.
- `vendor/ds-bundle.js` — a served copy of the auto-generated `_ds_bundle.js`. The preview
  server doesn't expose the underscore-prefixed generated file, so the UI kits and component
  cards load this copy instead. **If components change, refresh it** (copy `_ds_bundle.js` →
  `vendor/ds-bundle.js`).

**`tokens/`** — `fonts.css`, `colors.css`, `typography.css`, `spacing.css`, `effects.css`, `base.css`.

**`components/`** (React primitives, `window.HargeisaParkingDesignSystem_*`)
- `buttons/` — **Button** (primary · secondary · danger · ghost; sm–xl)
- `surfaces/` — **Card** (hover glow)
- `data/` — **Badge** (status pills), **KpiCard** (metric tile), **Avatar**
- `forms/` — **Input** (+ plate mode), **Switch**

**`guidelines/`** — foundation specimen cards (Colors, Type, Spacing, Brand) for the DS tab.

**`assets/`** — `logo-mark.svg`, `logo-wordmark.svg`.

**`ui_kits/`** — full-screen product recreations
- `hpark-pay/` — citizen app (find & pay, citations, profile)
- `hpark-enforce/` — officer app (vehicle search, citation flow)
- `hpark-command/` — admin dashboard (compliance hero, live map, KPIs)
