# FC150 — Challenge Arena · PROJECT NOTES

> Read this first when picking up the project.

## What it is
A premium mobile app for **PlayStation 5 FC/FIFA players** who challenge each other in
the app, then play the match physically on a real PS5. The app does **not** host gameplay
— it manages challenges, leagues, scores, rankings, animated football-style **player
cards**, and progression. Seed player is **Khadar Agab · Netherlands · ATT · 94 OVR**.

Built from the design handoff `design_handoff_fc150_challenge_arena` (a React/HTML
reference). The handoff was treated as the visual + UX spec and **re-implemented in
idiomatic Flutter** — not ported.

## Stack
- **Flutter** (Dart 3.12+, Flutter 3.44) — iOS + Android.
- **State:** `provider` (`AppState`) for current-user / active-tab / league sub-tab /
  top-3-seen; screen-local state for sheets and flows.
- **Fonts:** `google_fonts` — Inter (body), Inter Tight (headings), JetBrains Mono
  (numbers/IDs/PSN).
- **Icons:** `lucide_icons` (Lucide line set, ~2px stroke) — matches the spec.
- **Confetti:** `confetti` (Top-3 + card-upgrade reveal).
- **Photo:** `image_picker` (gallery) → in-app crop/position editor → photo on the
  player card. **Share:** `share_plus` (WhatsApp / Email via the OS share sheet) +
  `gal` (save card image to the gallery); `path_provider` for the temp/saved files.
- **Persistence:** `shared_preferences` (last active tab).
- **Firebase:** target backend (Auth, Firestore, Storage, FCM) — **not yet wired**. The
  app currently runs entirely off the seed data in `lib/data/seed_data.dart`, which is
  shaped to map onto the suggested Firestore collections.

## Architecture (`lib/`)
```
theme/      tokens.dart (colors/spacing/radii/glows), app_theme.dart (type + ThemeData)
models/     models.dart (Player, Stats, LeagueRow, Fixture, MatchResult, Invite,
            CareerCard, AppNotification, PendingReg, Dispute)
data/       seed_data.dart (all seed content + flags + byId), mirrors AppData.jsx
state/      app_state.dart (ChangeNotifier)
widgets/    fc_card.dart (the hero player card), primitives.dart (Pill, StatusPill,
            GButton, Surface, StatBars, Segmented, CountUp, FCConfetti, Eyebrow,
            SectionTitle), sheet.dart (bottom-sheet shell), common.dart (avatar, toast)
screens/    app_shell.dart (blurred 6-tab bottom nav + IndexedStack), home, arena,
            league, cards, roster, admin
flows/      top3_popup.dart, challenge_flow.dart, result_submit.dart, card_detail.dart,
            profile_sheet.dart, notifications_sheet.dart, photo_crop.dart,
            photo_viewer.dart, share_card.dart
```

## Design fidelity
- **Dark-first only** — there is no light theme. Four-step dark stack (bg/surface/
  elevated/overlay), electric-purple + teal, **glow not shadow**. Hex values match the
  handoff README exactly (see `theme/tokens.dart`).
- **Player card** (`FCCard`): aspect 1:1.5, radius 18, four variants — `neon` (default),
  `holo` (rotating iridescent foil + multi-stop accent), `mono` (flat surface), and
  `platinum` (tier metals: platinum/gold/silver winner cards with metallic nameplate).
  Idle shine-sweep + holo rotation are disabled under reduced motion. All sizing is
  width-relative so the same widget renders crisply from 102px podium cards to 232px hero.
- **Stat→colour:** ≥85 success · ≥70 teal · ≥55 warning · <55 danger.
- **Screens:** Home, Arena (Pool/Active/History + **"New challenge"** flow + result submit),
  League (competition-aware), Cards (collection + detail + half-season Reveal), **Roster**
  (admin squad-builder), Admin (KPIs + Approvals/Disputes/Season). Top-3 winners overlay
  shows once per session.
- **Admin auth & tab gating** (`flows/admin_login.dart`, `AppState.isAdmin`): players see a
  **4-tab** nav (Home/Arena/League/Cards); the management tabs (**Roster + "Control"**) appear
  only after an admin signs in via the lock icon in the Home header. **The portal is disguised**
  — the sign-in/out sheets and the 6th tab say nothing about "admin"/"FC150" (the tab is labelled
  **Control**), so a player who taps the lock just sees a generic "Sign in". Two prototype admin
  accounts live in `AppState.adminEmails` / `adminPassword` (do NOT surface these in the UI; they
  move to Firebase Auth + an `admin` claim). `isAdmin` persists; QA: `--dart-define=FC_QA_ADMIN=true`
  (also implied by `FC_QA_TAB>=4`).
- **Avatars expand** anywhere: `AvatarInitials` is tappable → full-screen viewer of the photo, or a
  large gradient initials circle if there's no photo (`flows/photo_viewer.dart` `showAvatarViewer`).
  Pass `expandable: false` where the avatar sits in a tile that must own the tap (challenge picker).
- **Card collection = one card per competition** (`screens/cards_screen.dart`): Premier League /
  Champions League / World Cup / **Friendly challenges**, each with a live progress line. The
  Friendly card reflects the persisted record (`AppState.friendlyPlayed/Won/Drawn/Lost`); ranking is
  by **games played** (volume first). Log a friendly result from an accepted invite on Home
  (`flows/friendly_result.dart` → `completeFriendly`).
- **Broadcast** (`flows/broadcast.dart`): Admin → Season → **Broadcast** composes a message and
  `AppState.pushBroadcast`es it; every device shows it once as a popup on next open
  (`pendingBroadcast` / `markBroadcastSeen`, tracked by id, checked in `AppShell.initState`).
- **Admin Season** generates fixtures for **all three competitions** (Premier League / Champions
  League / World Cup) with per-competition state; **disputes** clear from the queue when
  Upheld or sent to Replay.
- **Roster — admin squad-builder** (`screens/roster_screen.dart`): approved players land in
  one shared pool (`Seed.roster`, ~50 — more than a competition holds). The admin drafts
  them into a competition via a **Premier League / World Cup** switcher; each has a **cap**
  (`AppState.rosterCaps`: PL 38, WC 32) shown by a capacity meter. Adding past the cap is
  refused with a toast, so the admin chooses who plays and who sits out. An **All / In / Out**
  filter reviews the picks. Selections live in `AppState` (`rosterFor` / `toggleRoster` /
  `isFull`) — the 12 named players start pre-placed in the league.
- **Player photo** (`flows/`): from the profile sheet, **Photo** picks from the gallery then
  opens an in-app **crop/position editor** (`photo_crop.dart` — pinch-zoom + drag inside a
  card-shaped frame, captured via `RepaintBoundary.toImage`). The chosen photo shows on the
  card; **tapping it expands** full-screen (`photo_viewer.dart`, Hero + zoom). **Share card**
  (`share_card.dart`) rasterises the card and offers **WhatsApp / Email** (OS share sheet via
  `share_plus`) and **Save to gallery** (`gal`).
  - ⚠️ **`captureBoundaryPng` must NOT call `boundary.debugNeedsPaint`** — that getter throws a
    `LateInitializationError` in release/profile builds (asserts stripped), which silently broke
    crop + share on TestFlight while working on the debug simulator. It now `await`s
    `WidgetsBinding.instance.endOfFrame` before rasterising. Test photo/share on a **release**
    build, not just debug.
- **Home — upcoming matches** are grouped by competition (Premier League / Champions League /
  World Cup) plus **Friendly challenges**. Accepting a **Challenge invitation** removes it and
  adds it to the friendly group; ✕ declines (state in `AppState.invites` / `acceptInvite` /
  `declineInvite` / `acceptedFriendlies`).
- **Challenge flow** supports **1v1** and full **2v2 team matches**: Type → (2v2: pick
  teammate → pick two opponents | 1v1: pick opponent) → Time → Confirm. The confirm and
  "match locked" screens show the full roster. Reach it via Arena → **New challenge**
  (challenging a player's card stays a quick 1v1 path). Code: `lib/flows/challenge_flow.dart`.
- **Competitions** (`lib/models/competition.dart`, `lib/data/competitions.dart`): the League
  screen has a header **switcher** (`flows/competition_picker.dart`) between **Premier League**
  (league: table/fixtures/results), **Champions League** and **World Cup** (cups: group-stage
  tables + a knockout bracket — QF/SF/Final). Active competition lives in `AppState`.

## Persistence & data model (read before "real app" work)
- **What persists today (single device):** all mutable state is written to `shared_preferences`
  as it changes and reloaded in `AppState._restore()` on launch — active tab + competition, the
  **card photo** (`photo`), **admin sign-in** (`isAdmin`), **broadcasts** (`broadcast*`), the admin
  **roster draft** (`rosters`, JSON), accepted/declined **invitations** (`invitesAccepted/Declined`),
  and the **friendly record** (`friendly`, JSON). So close-and-reopen remembers everything **for that
  device/player**. Guards: `_tabTouched` / `_adminTouched` stop a late prefs load from clobbering a
  session change.
- **Still seed-backed (not yet real):** the player identity (`Seed.me` = Khadar), the 12 named
  players + ~38 generated roster fillers, the league table, fixtures, cup brackets, disputes and
  pending registrations all come from `lib/data/seed_data.dart` + `lib/data/competitions.dart`.
  These are in-memory demo content — they are the same on every device and don't sync.

## Roadmap — turning this into a real multi-user app (the big next milestone)
The current build is a **polished, fully-persistent single-device prototype**. A real product that
players register for and use against each other needs a **backend** — this is the next major task:
1. **Firebase**: `flutterfire configure` (project + `GoogleService-Info.plist` / `google-services.json`).
2. **Auth**: real sign-up/sign-in (email or Sign in with Apple). Admins = a Firestore custom claim,
   replacing the hardcoded `AppState.adminEmails`/`adminPassword`.
3. **Firestore collections**: `users` (profile, PSN, photo URL, position, ratings), `competitions`,
   `rosters` (entrant sets per competition), `challenges`/`results` (the friendly + league/cup match
   results — the **source of truth** the cards and rankings compute from), `broadcasts`.
4. **Storage**: move the cropped card photo off the device into Cloud Storage (URL on the user doc).
5. **Cloud Functions / rules**: rankings (incl. friendly "most games played"), card upgrades at
   milestones, dispute resolution, the approve→roster→season flow; security rules so players can only
   write their own data and only admins can write rosters/broadcasts/season.
6. **FCM**: push for challenge/locked/result/card/broadcast.
Replace the `Seed.*` accessors with Firestore repositories behind the same shapes; the UI is already
built against those shapes, so it's mostly a data-layer swap. Until then, "no dummy data" is only
possible per-device (the player's own progress), not across players.

## Run
```
cd apps/fc150
flutter run                 # any booted simulator/device
flutter run -d <id>         # specific device (see: flutter devices)
```
First run on Google Fonts needs network to fetch the font files (cached after).

## iOS / signing
- Bundle id: `com.fc150.fc150`. Display name: **FC150**. Portrait-only.
- Photo-library + camera usage strings are set in `ios/Runner/Info.plist`.
- For signed device/IPA builds use the paid Apple team **`4696KN59VV`** on every config
  (Debug/Release/Profile). Simulator runs do not need signing.
- IPA: `flutter build ipa --export-method development`.

## Releasing to TestFlight
- **Version & build number** live in `pubspec.yaml` as `version: X.Y.Z+build` →
  CFBundleShortVersionString `X.Y.Z` + CFBundleVersion `build`. **Bump the `+build`
  number on every upload** (TestFlight rejects a re-used build number for the same
  version). First TestFlight upload was `1.0.0+1`.
- **Build the App Store IPA:** `flutter build ipa --export-method app-store`
  → output at `build/ios/ipa/fc150.ipa`. Signs with the paid team `4696KN59VV`.
- **Distribution signing:** TestFlight needs an **Apple Distribution** certificate +
  an App Store provisioning profile. If the build fails with a signing/provisioning
  error, open `ios/Runner.xcworkspace` in Xcode once (Signing & Capabilities → the
  4696KN59VV team, automatic signing) so Xcode can create the distribution assets, or
  archive via **Product → Archive → Distribute App → App Store Connect**.
- **Upload to TestFlight:** the app must exist in App Store Connect with bundle id
  `com.fc150.fc150`. Then upload the `.ipa` with the **Transporter** app (App Store →
  free) — sign in, drag the `.ipa`, Deliver — or `xcrun altool --upload-app -f
  build/ios/ipa/fc150.ipa -t ios -u <apple-id> -p <app-specific-password>`. After
  processing it appears under TestFlight.

## TODO / follow-ups (not blocking the prototype)
1. **Firebase**: `flutterfire configure`, then wire Auth + Firestore repositories behind
   the current seed accessors; move card photo to Storage; FCM for the notification kinds
   listed in the handoff (challenge/locked/result/card/top3). Persist the **Roster** draft
   (`AppState._rosters`) as each competition's entrant set, and the cropped card photo path.
2. **Challenge / result state machine** persisted to Firestore (pending→accepted→locked→
   completed/disputed/no-show; auto-approve at 12h; no-show = 3–0).
3. **League engine**: Win 3 / Draw 1 / Loss 0; 38 games; card auto-update at game 19 and
   38, each snapshot saved to the collection.
4. **Real flag assets** keyed by ISO code (currently original geometric CSS-style bands).
5. **Share card** action (currently a no-op button).
6. Admin tile/visibility gated to real admins.
