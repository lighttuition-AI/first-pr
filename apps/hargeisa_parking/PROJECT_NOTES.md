# Hargeisa Parking — Project notes & status

Context for picking this project back up in a fresh session. Source of truth is the
code; this captures decisions, gotchas, and what's pending. Companion to `README.md`
(architecture) and `FIREBASE_SETUP.md` (from-scratch backend runbook).

## What this is
A Somaliland smart-city parking platform (first city: Hargeisa). Three Flutter
products on a shared design system + core:
- **HPark Enforce** (`enforce_app/`) — officer app (iOS/Android): register → approval
  gate → patrol → issue citations.
- **HPark Pay** (`pay_app/`) — citizen app (iOS/Android): see/pay/appeal citations,
  district deals + coupon QR.
- **HPark Command** (`command_app/`) — admin dashboard (Flutter web): approvals,
  appeals review, officers, vehicles, zones, live map, reports.
- **`packages/hpark_core/`** — design system + models + shared data.
- **`packages/hpark_firebase/`** — Firebase Auth + Firestore repositories.

## Backend — LIVE on Firebase (project `hargeisa-parking`)
Account `app.jeeble@gmail.com`. Email/password Auth + Cloud Firestore, all three apps.
**As of 2026-06-11 there are NO mock data arrays left in the apps** — every record
comes from Firestore. The real end-to-end flow works:

> Officer **issues** a citation in Enforce → written to `citations/{id}` → the cited
> driver **sees/pays/appeals** it in Pay (matched on their plate) → the city **decides**
> the appeal in Command → status updates everywhere.

### Collections
`officers/{uid}` · `citizens/{uid}` · `vehicles/{plate}` · `citations/{id}` ·
`appeals/{id}` · `deals/{code}` · `counters/officers`.

### Repositories (`packages/hpark_firebase/lib/src/`)
- `FirebaseAuthService` — email/password (all apps).
- `FirebaseOfficerAccount` (Enforce, single `officers/{uid}` doc) +
  `FirebaseOfficerRepository` (Command, whole collection, live).
- `FirebaseVehicleRepository` — `lookup(plate)`, `knownPlates()`, `upsert`, `all`.
- `FirebaseCitationRepository` — `issue`, `watchByPlate` (Pay), `watchAll`, `setStatus`.
- `FirebaseAppealRepository` — `submit` (Pay), `watchAll` (Command), `decide`.
- `FirebaseDealRepository` — `all`/`watchAll` (Pay), `upsert`.
- `CitizenStore` (`pay_app/lib/data/`) — `citizens/{uid}` profile incl. **plate**.

### Shared models (`packages/hpark_core/lib/src/models/`)
`Officer`, `Vehicle`, `Citation` (+`CitationStatus`: outstanding/paid/appealReview/
dismissed), `Appeal` (+`AppealStatus`), `Deal`, `District`, `ViolationType`. All have
`toMap`/`fromMap` (epoch-millis dates, enums by name). `Citation` is the single shared
model used by **all three apps** (Enforce writes, Pay reads/updates, Command amends).

### Security rules (`firestore.rules`, deployed)
Officer self-registers `pending` only; only admin (custom claim `admin==true`) approves;
only an **approved** officer issues citations; a citizen may update only their own
citation's `status` to `paid`/`appealReview`; appeals must start `review`, only admins
decide; vehicles/deals admin-write, signed-in read. Deploy:
`firebase deploy --only firestore:rules --project=hargeisa-parking`.

### Citizen ↔ citation link
Citations are keyed by **plate**. A citizen stores their **plate** on their profile
(captured at signup, editable in Pay → Profile → Vehicle plate). Pay streams
`citations where plate == citizen.plate`. Citations also carry a denormalised
`ownerNationalId` (from the vehicle record at issue time).

## Seed / demo data (`tool/`)
`node seed_firestore.mjs` loads **reference data only**: officer roster (incl. 3 pending
to approve in Command), the vehicle registry (`vehicles/{plate}`), and district deals.
**Citations + appeals are NOT seeded** — they come from real usage. Needs
`tool/serviceAccountKey.json` (git-ignored, present locally). Other scripts:
`create_admin.mjs`, `create_officer.mjs`, `grant_admin.mjs`.

### Demo accounts (password `hpark2026`)
- Admin (Command): `admin@hargeisaparking.so`
- Officer, pre-approved (Enforce): `officer@hargeisaparking.so`
- Citizen (Pay): `citizen@hargeisaparking.so` — set its plate (e.g. `HG-3508`) in
  Pay → Profile to see citations; or issue one against any seeded plate from Enforce.
- Seeded vehicle plates: `HG-4821`, `HG-1190`, `HG-7732`, `HG-3508`.

## Versions / iOS / TestFlight
- **Enforce + Pay = `1.1.0+3`**; Command (web) = `1.1.0+2`. Bump the `+build` before each
  new TestFlight upload (App Store Connect rejects a reused build number).
- iOS bundle ids (`.com`): Enforce `com.hargeisaparking.enforce`, Pay
  `com.hargeisaparking.pay`. Android applicationIds still `.so`.
- **Signing — the rule that ends the pain:** use **ONLY the paid team `4696KN59VV`** and
  set `DEVELOPMENT_TEAM` on **ALL configs (Debug/Release/Profile)**. The personal team
  `A7N3LVAD8U` must NOT come back. `IPHONEOS_DEPLOYMENT_TARGET = 15.0` (Firebase needs 15+).
- **Build:** PATH needs `~/.npm-global/bin` (firebase) + `~/.pub-cache/bin` (flutterfire).
  `flutter build ipa --export-method app-store` (TestFlight) — IPAs at
  `enforce_app/build/ios/ipa/hpark_enforce.ipa` + `pay_app/build/ios/ipa/hpark_pay.ipa`.
  First iOS build per app ~12 min (compiles Firebase from source); later ~3 min.
- **TestFlight upload:** no App Store Connect API key on this Mac → upload **manually via
  Transporter.app** (drag the IPA). Create the App Store Connect app record first (Apps →
  + New App → pick the `.com` bundle id). `ITSAppUsesNonExemptEncryption=false` is set, so
  the export-compliance question is skipped. ASC account `khadar97@hotmail.com`, team
  `4696KN59VV`.

## Verify / run
```bash
cd apps/hargeisa_parking
# analyze + test each package/app:
for p in packages/hpark_core packages/hpark_firebase enforce_app pay_app command_app; do (cd $p && flutter analyze && flutter test); done
# run an app:
cd command_app && flutter run -d chrome          # admin dashboard
cd enforce_app && flutter run                     # officer app
cd pay_app && flutter run                         # citizen app
```

## Gotchas / decisions (don't re-trip these)
- **Districts = 8, not 9** — "Maxamuud Haybe" == "Mohamoud Haibe" (one district). See
  `packages/hpark_core/lib/src/data/districts.dart`.
- The officer `officers/{...}` docs are keyed by **auth uid** in practice
  (`FirebaseOfficerAccount.createPending`); the seed/`OfficerRepository.register` path
  keys by `OFR-id` for the demo roster — both coexist; Command reads the whole collection.
- **`build/` is excluded** from `flutter analyze` (the Firebase SDK checks Dart files into
  `build/ios/SourcePackages/`).
- Pay's `Citation` status changes are **optimistic** (mutate locally + write to Firestore;
  the `watchByPlate` stream reconciles).
- Command's **vehicle import page is still a UI mock** (fake dedupe preview) — the real
  registry lives in Firestore; a real CSV/xlsx parser is a pending follow-up.
- ⚠️ **Disk watch:** this Mac has filled up once during repeated iOS builds (ENOSPC).
  Clean `build/` + DerivedData between heavy builds.

## Standing workflow (user instruction)
- At the end of every "save everything", give the **PR number**.
- Before the user clears the chat, **double/triple-check everything is committed + pushed**.
- Keep version + build numbers prepared; build a new IPA as part of wrap-up.

## Pending / next
1. Confirm both `1.1.0+3` IPAs upload to TestFlight + install on device; verify the live
   citation → pay → appeal → decide flow end-to-end on real devices.
2. Real device integrations: camera/LPR, GPS, maps SDK, file picker + parser for vehicle
   import, ZAAD/eDahab payment APIs.
3. Bilingual EN/SO toggle; push notifications (appeal-decided).
4. Optional: align Android applicationIds + Pay/Command branding to `.com`.
