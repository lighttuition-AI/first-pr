# Hargeisa Parking

Smart-city parking platform for Hargeisa — a three-product ecosystem built on the
**Hargeisa Parking design system** (dark-first, "Linear meets Stripe for smart-city
parking"). Two mobile apps + one admin dashboard, plus the shared design-system
package they're built on.

| Product | Surface | Who | What |
|---|---|---|---|
| **HPark Enforce** | Officer app (iOS/Android) | Parking officers | Registration → **admin approval gate** → patrol home, plate scan, evidence, offline sync |
| **HPark Pay** | Citizen app (iOS/Android) | Drivers / residents | Somaliland-ID registration, citations, pay via **ZAAD / eDahab**, **district deals** with scannable coupon QR |
| **HPark Command** | Admin dashboard (web) | Operations / city | **Officer approvals**, dashboard KPIs, officer roster, 8-district zones, (live map / appeals / reports scaffolded) |

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

## Next steps
- Wire a real backend (Firebase) so approvals sync across devices; add real auth.
- Build out officer flow (LPR scan, photo/video evidence, citation issue), citizen
  appeals (video), and Command's live map / appeals / reports.
- Bilingual English / Somali toggle; replace stylized data with live data.
