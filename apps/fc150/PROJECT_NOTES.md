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
- **Photo:** `image_picker` (gallery) → photo on the player card.
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
screens/    app_shell.dart (blurred 5-tab bottom nav + IndexedStack), home, arena,
            league, cards, admin
flows/      top3_popup.dart, challenge_flow.dart, result_submit.dart, card_detail.dart,
            profile_sheet.dart, notifications_sheet.dart
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
- **Screens:** Home, Arena (Pool/Active/History + 4-step challenge flow + result submit),
  League (Table/Fixtures/Results), Cards (collection + detail + half-season Reveal), Admin
  (KPIs + Approvals/Disputes/Season). Top-3 winners overlay shows once per session.

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

## TODO / follow-ups (not blocking the prototype)
1. **Firebase**: `flutterfire configure`, then wire Auth + Firestore repositories behind
   the current seed accessors; move card photo to Storage; FCM for the notification kinds
   listed in the handoff (challenge/locked/result/card/top3).
2. **Challenge / result state machine** persisted to Firestore (pending→accepted→locked→
   completed/disputed/no-show; auto-approve at 12h; no-show = 3–0).
3. **League engine**: Win 3 / Draw 1 / Loss 0; 38 games; card auto-update at game 19 and
   38, each snapshot saved to the collection.
4. **Real flag assets** keyed by ISO code (currently original geometric CSS-style bands).
5. **Share card** action (currently a no-op button).
6. Admin tile/visibility gated to real admins.
