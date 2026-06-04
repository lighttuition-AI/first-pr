# HNL Learning — Project notes & status

Context for picking this project back up in a fresh session. Source of truth
is the code; this captures decisions, gotchas, and what's pending.

## What this is
A Flutter rebuild of the **HNL Learning** design (Claude Design handoff) — an
audio-first, touch-first educational app for kids 2–8. Originally ported the
whole prototype, then extended on request. Lives at `apps/hnl_learning/` in the
`first-pr` repo (workspace `~/Desktop/Claude Code`).

Design handoff bundle (re-fetchable, ~10 MB gzip):
`https://api.anthropic.com/v1/design/h/dOm3373G_gNorEPyz6jfEA`

## Repo / workflow conventions
- Apps live under `apps/`. Design ideas under `design-refs/`. See root `README.md`.
- **Branch → PR → squash-merge to `main`** (one tidy commit per change). Keep a
  single `main` branch. Commits end with the `Co-Authored-By: Claude` trailer;
  PR bodies end with the "Generated with Claude Code" line.
- The repo's default branch must stay **`main`** (it was once mis-set to a stray
  `fix/readme-typo` branch — fixed via `gh repo edit --default-branch main`).

## Feature inventory (all shipped, PRs #5–#11)
- Full design port: onboarding → child setup → home map → daily mission/timer →
  7 mini-games (drag + tap, confetti/shake) → planet rewards → parent gate +
  dashboard. Voiceover Studio (record-your-own per line) + Picture Studio
  (upload-your-own per slot).
- **Arabic World** (4th island): game 1 = alphabet board (tap a letter → hear
  it; 28 letters recordable in the VO Studio); game 2 = letter tracing (finger
  drag over a hollow guide, 8-colour palette, ◀/▶, Clear, "Done!" + "Traced
  N/28"; finishing all 28 → confetti + a big uploaded GIF).
- **GIF Studio** (Settings / Tweaks, gated): upload celebration GIFs; one plays
  on full-alphabet completion (falls back to Robo if none).
- **Multiple child profiles**: each child has its own profile + isolated
  progress. Switch via the home profile-chip dropdown; add/remove/switch in the
  Parent dashboard "Children" card.
- Settings/Tweaks gear is behind the 1-2-3-4 child-lock gate.

## Looks (visual themes / "skins")
- The whole app is reskinnable. `theme/skins.dart` defines a `Skin` (palette +
  neutrals + radii + shadow language + type pairing + full-stage background) and
  holds **every Look as data** — this is the single tidy home for them. A global
  `activeSkin` drives the design tokens, so switching a Look reskins all screens
  with **no per-screen changes**.
- Switch live in **Settings (Tweaks) → Look**. Selection persists (tweaks key
  `skin`). `AppState.setSkin(id)` swaps `activeSkin` + saves; `app.pal` now returns
  `activeSkin.palette`.
- All 5 looks shipped (`kReadySkins`): **Sunshine** (polished default) · **Jungle**
  (clay + monkeys/bananas) · **Ocean** (glassy water + original shark family,
  `widgets/sea.dart`) · **Crayon Pop** (neubrutalism + original hero squad,
  `widgets/comic.dart`) · **Moonlit Calm** (cozy DARK theme + original cat-&-mouse
  night scene) · **Classic** (original, 1:1).
- `Skin.brightness` flags dark looks. `Skin.cardBorder` (a `Border?`) is honored by
  the shared card surfaces. Surface `Colors.white` fills across all screens were
  migrated to `C.card` (a no-op on light looks; required for Moonlit's dark cards).
  Map dots + scrims are skin-aware (light dots on dark). Remaining literal whites
  are intentional (text, icons, toggle knobs, illustration/eye/highlight art).
- A skin may carry an **animated scene** (`Skin.sceneBuilder` → `FloatingScene` in
  `widgets/scene.dart`): ambient drifting "characters" drawn behind the content,
  wrapped in `IgnorePointer`. Home goes transparent when `activeSkin.hasScene` so
  the scene shows on the hub. **IP note:** themed scenes use *original* characters
  (generic animals/shapes), never copyrighted ones (no Pinkfong Baby Shark art,
  Teen Titans, or Tom & Jerry) — App-Store-safe.
- The old per-palette/font Tweaks controls were folded into Looks. `palette`/`font`
  fields remain in the save for back-compat but no longer drive rendering.

## Architecture quick map (lib/)
- `theme/skins.dart` — the `Skin` class, all Looks, `activeSkin` + `setActiveSkin`.
- `theme/tokens.dart` — `C`/`R`/`Sh`/`AppText`: thin skin-aware views over
  `activeSkin` (re-exports skins.dart). `C.inkA()` stays dark on every skin
  (shadows/scrims); stage size (1366×1024) + `kTap` live here.
- `models/content.dart` — ALL content: topics, avatars, worlds, planets,
  onboarding, the 9 games + rounds, VO lines + `buildVoRegistry()`, Arabic
  letters (`kArabicLetters`).
- `state/app_state.dart` — `AppState` (ChangeNotifier): `List<Child>` + active
  index, routing, persistence (shared_preferences key `hnl-save-v1`, migrates
  old single-profile saves), tweaks, session/mission. Also `FxController`.
- `services/` — `vo_service` (flutter_tts + recorded override), `image_service`
  (slots, base64 in prefs), `gif_service` (base64 list in prefs).
- `widgets/` — Robo, Planet, Avatar (CustomPaint), speech bubble, kid button,
  Img slot, confetti FX, shaker.
- `screens/` — onboarding, setup, home, game (shell + all games incl. alphabet
  board + tracing), break, rewards, parent (gate + dashboard), the studios,
  tweaks, child_switcher.
- `app.dart` — iPad stage scaling + the routed screen + overlays (studios,
  tweaks, gate, child switcher). `main.dart` — providers + service init.

## Gotchas / decisions (don't re-trip these)
- **`record` is pinned `^6.1.1`** — `5.x` resolved an incompatible
  `record_linux 0.7.2` that broke the iOS Dart compile. Don't downgrade.
- **iOS permissions** in `ios/Runner/Info.plist`: `NSMicrophoneUsageDescription`
  (recording) + `NSPhotoLibraryUsageDescription` (image/GIF picker). Missing
  these = hard crash on iOS. Android has `RECORD_AUDIO` in the manifest.
- **Landscape-locked** on iPad/iPhone (Info.plist orientations +
  `UIRequiresFullScreen`). On the simulator the window may show portrait after a
  reinstall → rotate with **⌘→** (Device → Rotate). On a real iPad: hold landscape.
- Images/GIFs stored as **base64 in shared_preferences** (works on mobile + web,
  no dart:io). Fine for small assets; large GIFs could bloat storage — switch to
  file-based if needed.
- The whole UI lives in a fixed **1366×1024 stage** scaled to fit. Text must be
  under a `Material` (added in `app.dart`) or it shows the debug yellow underline.
- Vector widgets (Planet/Avatar) create their `AnimationController` in
  `initState`, not as a lazy field (lazy → Ticker built during dispose → crash).
- `FxController.fire()` defers `notifyListeners` if called mid-build.
- Game pictures are **emoji placeholders by design** (swappable in Picture Studio).
- Fonts via `google_fonts` (downloaded/cached). For strict offline-from-first-
  launch, bundle the `.ttf`s.

## Verify / run
```bash
cd apps/hnl_learning
flutter pub get
flutter analyze        # clean
flutter test           # 10 tests (content counts, mission, multi-child, board renders)
flutter run -d chrome  # quick web run
# iPad simulator used during dev: "iPad Pro 13-inch (M5)"
#   udid 9C1A4EAC-B929-46AD-912D-6D29B9704D56
flutter run -d 9C1A4EAC-B929-46AD-912D-6D29B9704D56
# screenshot the sim:  xcrun simctl io booted screenshot out.png
```

## PENDING — TestFlight (waiting on the user)
The user will do the Apple login steps. To proceed I need from them:
1. **Bundle ID** they own (currently placeholder `com.hnllearning.hnlLearning`).
2. **Apple Developer Program** membership (paid) + Apple ID added in Xcode.

Then: set bundle ID + signing → `flutter build ipa` → upload via Xcode Organizer
or Transporter → App Store Connect → TestFlight → add testers. Full walkthrough
is in the chat; summarized in the root steps above.

## Possible next ideas (not started)
- Default letter voice via **Arabic TTS** locale (currently English TTS says the
  transliteration as a placeholder until the user records).
- Optional **name** field per child.
- Run/verify on the **Android emulator** (`Pixel_7_API_35`).
- More Arabic-world games (the world sheet shows "More soon" slots).
