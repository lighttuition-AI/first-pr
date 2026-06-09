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
  shows once per session. The bottom nav has **6 tabs**.
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
- **Challenge flow** supports **1v1** and full **2v2 team matches**: Type → (2v2: pick
  teammate → pick two opponents | 1v1: pick opponent) → Time → Confirm. The confirm and
  "match locked" screens show the full roster. Reach it via Arena → **New challenge**
  (challenging a player's card stays a quick 1v1 path). Code: `lib/flows/challenge_flow.dart`.
- **Competitions** (`lib/models/competition.dart`, `lib/data/competitions.dart`): the League
  screen has a header **switcher** (`flows/competition_picker.dart`) between **Premier League**
  (league: table/fixtures/results), **Champions League** and **World Cup** (cups: group-stage
  tables + a knockout bracket — QF/SF/Final). Active competition lives in `AppState`.

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
