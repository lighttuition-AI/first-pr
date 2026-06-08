# Hargeisa Parking

Smart-city parking platform for Hargeisa — a three-product ecosystem built on the
**Hargeisa Parking design system** (dark-first, "Linear meets Stripe for smart-city
parking"). Two mobile apps + one admin dashboard, plus the shared design-system
package they're built on.

| Product | Surface | Who | What |
|---|---|---|---|
| **HPark Enforce** | Officer app (iOS/Android) | Parking officers | Registration → **admin approval gate** → patrol home, plate scan, evidence, offline sync |
| **HPark Pay** | Citizen app (iOS/Android) | Drivers / residents | Somaliland-ID registration, citations, pay via **ZAAD / eDahab**, **video appeals**, payment history, **district deals** with scannable coupon QR |
| **HPark Command** | Admin dashboard (web) | Operations / city | **Officer approvals**, KPIs, officer roster, vehicle-data import (dedupe), 8-district zones, live map, appeals review, reports |

## Two builds in this folder

```
hargeisa_parking/
├── packages/hpark_core/   # shared Flutter package — design system + models + data
│   ├── lib/src/theme/     #   HpColors, HpType, HpSpace/Radius/Size, HParkTheme.dark
│   ├── lib/src/models/    #   Officer, ApprovalStatus, District
│   ├── lib/src/data/      #   OfficerRepository (+ seeded mock), 8 Hargeisa districts
│   └── lib/src/widgets/   #   HpButton, HpCard, HpBadge, HpKpiCard, HpAvatar, HpInput, HpLogoMark
├── enforce_app/           # HPark Enforce  (Flutter, Android/iOS)
├── pay_app/               # HPark Pay      (Flutter, Android/iOS)
├── command_app/           # HPark Command  (Flutter, web)
│
├── index.html             # design prototype launcher (the original HTML/React mockups)
├── HPark *.html + */*.jsx  # the high-fidelity web prototypes — the visual reference
└── design-system/         # the prototype's CSS design tokens + component bundle
```

The **Flutter apps are the real build**; the **HTML/React files are the design prototype**
(the pixel target) exported from Claude Design. See `docs/design-chat.md` for the
original intent.

## The officer approval workflow ⭐

Officers must be **approved before they can operate** — this keeps unauthorized people
from claiming to be officers:

1. An officer self-registers in **HPark Enforce** → their account is created **pending**
   and they're held on a locked "waiting for approval" screen.
2. An admin opens **HPark Command → Officer approvals**, verifies the national ID /
   badge, and **approves** (assigning a district) or **rejects**.
3. Approval flips the account to `approved`; the officer app unlocks the patrol home.
   Rejected / suspended officers stay locked out.

This is modelled in `hpark_core`'s `OfficerRepository` + `ApprovalStatus`, with unit
tests in `packages/hpark_core/test/`. The current build uses a **seeded in-memory mock**
so each app runs and the flow is demoable on its own (the officer app even has a
clearly-labelled "simulate admin approval" button). To make an approval in Command
unlock Enforce **across devices**, swap the mock for a shared backend — **Firebase
Auth + Firestore** is the recommended fit; `OfficerRepository` is the seam to implement.

## Run

```bash
# Admin dashboard (web)
cd command_app && flutter run -d chrome

# Officer app  (emulator/simulator or device)
cd enforce_app && flutter run        # demo logins: HG-OFR-118 (approved) · HG-OFR-127 (pending)

# Citizen app
cd pay_app && flutter run
```

Fonts (Inter / Inter Tight / JetBrains Mono) load via `google_fonts` on first run, so
the first launch needs internet. Tooling: Flutter 3.44.1 / Dart 3.12.1.

## Districts

The brief listed 9 entries but **Maxamuud Haybe = Mohamoud Haibe** (one district, two
spellings), so the canonical list is **8 distinct districts** — see
`packages/hpark_core/lib/src/data/districts.dart`. Swap in the official map + boundaries
when available.

## What's built

All three apps are now functionally complete as interactive prototypes (real state,
simulated camera / map / file I/O):

- **Enforce** — register → approval gate → patrol shell (Patrol / Activity / Profile);
  full citation flow (scan or simulated LPR → vehicle lookup → violation → photo/video
  evidence with GPS+timestamp → review → issued); offline toggle that queues + syncs.
- **Pay** — register → home (balance + ZAAD/eDahab pay) → citation detail → **video
  appeal** (record → review → submit) → payment history; districts → deals → coupon QR.
- **Command** — dashboard, officer approvals, officers, **vehicle import w/ dedupe**,
  zones, **live map**, **appeals review** (watch → uphold/dismiss), **reports**.

## Next steps
- **Backend (Firebase):** swap the in-memory repositories for Firebase Auth + Firestore
  so approvals/citations/appeals sync across devices; real officer & citizen auth;
  Firestore security rules. `OfficerRepository` is the first seam.
- Real device integrations: camera/LPR, GPS, a maps SDK, file picker for imports,
  ZAAD/eDahab payment APIs.
- Bilingual English / Somali toggle; replace stylized data with live data.
