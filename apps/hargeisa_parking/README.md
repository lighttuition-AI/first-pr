# Hargeisa Parking

Smart-city parking platform for Hargeisa — a three-product ecosystem built on the
**Hargeisa Parking design system** (dark-first, "Linear meets Stripe for smart-city
parking"). This folder holds the **launcher** (`index.html`) plus the three product
prototypes it links to.

| Product | Surface | Who | What |
|---|---|---|---|
| **HPark Enforce** | Officer mobile app | Parking officers | Badge login, district assignment, LPR plate scan, photo + video evidence, offline queue + sync |
| **HPark Pay** | Citizen mobile app | Drivers / residents | Somaliland-ID registration, outstanding fees, pay via **ZAAD / eDahab**, video appeals, interactive 9-district deals map |
| **HPark Command** | Admin web dashboard | Operations / city | Live officer-tracking map, compliance & revenue KPIs, zone management, bulk vehicle-data import with dedupe, appeals review, reports |

`index.html` is the entry point — a landing page that introduces the ecosystem and
links to each app, with a scannable QR that opens **HPark Pay** on a phone.

## Run it

The launcher is plain HTML and opens on its own, but the three apps are React
prototypes that load `.jsx` over HTTP (in-browser Babel), so they need a local
static server — `file://` won't fetch them.

```bash
cd "apps/hargeisa_parking"
python3 -m http.server 8000
# open http://localhost:8000/  → click through to each app
```

An internet connection is required: React, Babel, Lucide icons and the QR library
load from CDNs.

## Structure

```
apps/hargeisa_parking/
├── index.html              # ← launcher / landing page (the entry point)
├── HPark Enforce.html      # officer-app prototype
├── HPark Pay.html          # citizen-app prototype
├── HPark Command.html      # admin-dashboard prototype
├── assets/                 # logo-mark.svg, logo-wordmark.svg
├── design-system/          # the bound design system — tokens + compiled component bundle
│   ├── styles.css          #   global entry (@imports the tokens)
│   ├── tokens/             #   colors · fonts · typography · spacing · effects · base
│   ├── _ds_bundle.js       #   compiled React primitives (Button, Card, Badge, KpiCard, Input…)
│   └── readme.md           #   full design-system guide
├── shared/                 # phone-frame.jsx, browser-window.jsx (device chrome)
├── pay/  enforce/  command/ # per-app React screens (core / auth / flow / etc.)
└── docs/                   # design-handoff-README.md, design-chat.md (provenance)
```

## Status

**Web prototype.** These are high-fidelity, interactive HTML/React prototypes exported
from Claude Design — they define the visual + interaction target. They are **not** the
production apps yet: the plan is to rebuild **HPark Enforce** and **HPark Pay** (mobile)
and **HPark Command** (web) for real, matching these pixel-for-pixel. See
[`docs/design-chat.md`](docs/design-chat.md) for the full design conversation and intent.

### Known follow-ups (from the design brief)
- Drop in the real Hargeisa map + district boundaries (the 9-district map is stylized).
- Confirm the district list — the brief had a likely duplicate (Maxamuud Haybe /
  Mohamoud Haibe); all 9 are kept as written for now.
- Deepen DMV-integration / collections escalation, multi-vehicle management, and a
  bilingual English / Somali toggle.
