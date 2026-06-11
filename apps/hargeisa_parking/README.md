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
├── packages/hpark_firebase/ # Firebase Auth + Firestore repositories (LIVE — officers, vehicles, citations, appeals, deals)
├── enforce_app/           # HPark Enforce  (Flutter, Android/iOS)
├── pay_app/               # HPark Pay      (Flutter, Android/iOS)
├── command_app/           # HPark Command  (Flutter, web)
├── firestore.rules        # DB security rules — enforce the approval gate server-side
├── firebase.json          # Firebase project config
├── FIREBASE_SETUP.md       # step-by-step: turn on the real backend
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
tests in `packages/hpark_core/test/`. **This is now live on Firebase** — officers
self-register against Firebase Auth, their record lives in Firestore (`officers/{uid}`),
and an admin's approval in Command unlocks Enforce on the officer's device in real time.
The Firestore security rules enforce the gate server-side (an officer can only create
their own `pending` record; only an admin can approve).

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

## What's built — running on live Firebase (Auth + Firestore)

All three apps run on the **real backend** (project `hargeisa-parking`): email/password
Firebase Auth, and Cloud Firestore for the shared data. There are **no mock data arrays
left in the apps** — every record comes from the database, and the end-to-end flow is real:

> An officer **issues** a citation in Enforce → it's written to Firestore → the cited
> driver **sees and pays/appeals** it in Pay (matched on their number plate) → the city
> **decides** the appeal in Command → the citation status updates everywhere.

- **Enforce** — register → Firestore approval gate → patrol shell; full citation flow
  (scan or LPR → **Firestore vehicle lookup** → violation → photo/video evidence with
  GPS+timestamp → review → **issued to `citations/{id}`**). Offline writes queue in
  Firestore and flush on reconnect.
- **Pay** — register (with vehicle plate) → home streams **your citations from Firestore**
  (by plate) → pay (ZAAD/eDahab) or **video appeal** → both persist to Firestore; districts
  → **deals from Firestore** → coupon QR.
- **Command** — dashboard, **live officer approvals**, officers, vehicle data, zones, live
  map, **live appeals review** (watch → uphold/dismiss writes back to `appeals` + the
  `citation`), reports.

### Firestore collections
`officers/{uid}` · `citizens/{uid}` · `vehicles/{plate}` · `citations/{id}` ·
`appeals/{id}` · `deals/{code}` · `counters/officers`. Security rules
(`firestore.rules`, deployed) enforce: officers self-register `pending` only; only admins
approve; only **approved** officers issue citations; a citizen may only flip their own
citation to `paid`/`appealReview`; appeals start as `review` and only admins decide.

The Firebase-backed repositories live in `packages/hpark_firebase/`
(`FirebaseOfficerRepository`/`Account`, `FirebaseVehicleRepository`,
`FirebaseCitationRepository`, `FirebaseAppealRepository`, `FirebaseDealRepository`).
Reference/registry data is loaded with `tool/seed_firestore.mjs` (officer roster, vehicle
registry, district deals); citations + appeals are created by real app usage, not seeded.

## Next steps
- Real device integrations: camera/LPR, GPS, a maps SDK, a real file picker + parser for
  the bulk **vehicle import** (Command's import preview is still a UI mock), ZAAD/eDahab
  payment APIs.
- Bilingual English / Somali toggle.
- Push notifications (e.g. notify a driver when their appeal is decided).
