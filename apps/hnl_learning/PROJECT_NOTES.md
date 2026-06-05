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
  dashboard. Voiceover Studio (**record _or upload_** your own clip per line) +
  Picture Studio (upload-your-own per slot). The Voiceover Studio is now the
  single home for **every sound in the app** — screen/game lines, the splash
  music, and an **Animals section** (by continent → animal → Sound / Somali
  name / English name). Every clip plays at its natural length; an uploaded clip
  is a file the grown-up saved (a Voice Memo exported to Files, or a sound saved
  from the web) — picked via the system document picker so Files/iCloud are
  reachable. See `lib/services/vo_service.dart` (`importFile`, `splashMusicSource`).
- **Arabic World** (4th island): game 1 = alphabet board (tap a letter → hear
  it; 28 letters recordable in the VO Studio); game 2 = letter tracing (finger
  drag over a hollow guide, 8-colour palette, ◀/▶, Clear, "Done!" + "Traced
  N/28"; finishing all 28 → confetti + a big uploaded GIF). **game 3 = letter
  order** (`GameType.arabicOrder`, `ArabicOrderGame` in `game.dart`): 28 empty
  boxes sit in alphabet order (RTL, Alif top-right) each showing a faint ghost
  glyph as a gentle guide; the 28 letters are shuffled in a tray below. Drag a
  letter onto its box → right box snaps it (glyph turns solid + the letter is
  spoken + a little confetti), wrong box gives a gentle shake. Fill all 28 →
  celebrate + play again (reshuffled). Explore-only (no timer/score), like the
  other two. Completion card is the shared `_FinishCard` (also used by tracing).
- **Animals** (5th island, 🦒): tap → an interactive continent map (7 original
  blob landmasses). Tap a continent → a shuffled quiz of up to 20 animals from
  that continent's pool (`models/animals.dart` — ~370 animals: Africa 70, Asia
  68, N.America 60, Europe 58, S.America 49, Oceania 46, Antarctica 20; ids are
  continent-suffixed so they stay unique). Each shows a picture (emoji default;
  uploadable real photo in Img slot `animal-<id>`) + **English** / **Somali**
  buttons that announce the name (EN via TTS; SO plays the family's recording or
  attempts Somali TTS — record inline with the mic). Next → confetti → next;
  finishing serves fresh animals next visit (per-child `animalsSeen`). Somali
  names are best-effort defaults (loan transliterations where Somali borrows the
  word) — meant to be re-recorded. Each animal card also has a big bright
  **"Hear the sound"** button (full width, under EN/SO): it speaks a
  kid-friendly onomatopoeia for the animal (`Animal.sound`, emoji-keyed in
  `kAnimalSounds` — "Roar!", "Moo!", "Bzzz!" — never scary), or plays a real
  recording if one exists. **Press-and-hold** the button to record a real sound
  (`animal-<id>-sound`); a 🎙️ shows when a custom one is set. Bundled real-sound
  assets can drop in later (free CC sources are mostly `.ogg`, which iOS can't
  play, so a curated pack is a deliberate follow-up).
- **Fruit & Veggies** (6th island, 🍎🥕): a world sheet with **2 games** — Fruits
  & Veggies (`GameType.produceQuiz`, `screens/produce_quiz.dart`,
  `models/produce.dart`). Each is a shuffled guessing session of up to 20 items
  (`AppState.startProduce` + per-child `produceSeen`, reshuffles when exhausted)
  — a **BIG** picture (emoji default; uploadable real photo in Img slot `<id>`) +
  the name in **English / Somali**, each with its own speaker **and** its own
  record mic (both languages voiceable inline or in the Studio under "Fruits &
  Veggies"). Pools are distinct-emoji only (~17 fruits, ~19 veggies) so a child
  can tell them apart — well under 100 by design. Somali names are best-effort
  re-recordable defaults (same convention as animals).
- **Launch splash** (`widgets/splash.dart`): the three Somali sisters, each in a
  round badge with a **colourful progress ring** that fills (sparkles at the
  leading edge, a glow when complete) while her name is announced — Nimoo →
  Ladan → Hibo, one ring at a time, over a looping harp. **The ring fill is the
  clock**: each name gets a guaranteed ~2 s slot (fixed timers, not audio
  callbacks — the latter proved unreliable on-device and let names overlap /
  get cut). The splash **fade is tied to the last ring finishing** (boot gate
  gets `onComplete`; 10 s safety net), so the names never bleed into the app
  behind it. Cold start always lands on **home** — `_load` never resumes a
  mid-activity screen (game / continents / animal-quiz / break / rewards /
  gate), so the app can't flash the island before the splash.
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
- Switch live in **Settings (Tweaks) → Look**. `AppState.setSkin(id)` swaps
  `activeSkin` + saves; `app.pal` now returns `activeSkin.palette`.
- **Looks are per-child.** Each profile remembers its own Look (`Child.skin`);
  switching profiles re-applies that kid's Look via `_applyActiveChildSkin()`.
  A child with no pick falls back to `_baseSkin` (the saved `tweaks.skin`
  default; `kDefaultSkin` on a fresh install). Old single-skin saves migrate
  cleanly — children with no `skin` inherit `_baseSkin`.
- Looks (`kReadySkins`): **Sunshine** (polished default) · **Jungle** (clay +
  monkeys/bananas) · **Ocean** (glassy water + original shark family,
  `widgets/sea.dart`) · **Crayon Pop** (neubrutalism + original hero squad,
  `widgets/comic.dart`) · **Moonlit Calm** (cozy DARK + cat-&-mouse night) ·
  **Somali Village** (warm savanna: 3 original sisters + aqal hut + acacia tree,
  `widgets/village.dart`). Classic was turned into Somali Village (still in
  `kSkins` for save-compat, dropped from the picker). All scene art is original.
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
  onboarding, the 12 games + rounds, VO lines + `buildVoRegistry()`, Arabic
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
- **`file_picker ^11`** (audio upload). API is **static** now —
  `FilePicker.pickFiles(...)`, *not* `FilePicker.platform.pickFiles(...)`.
  We use `FileType.custom` + `kAudioExtensions` (in `vo_service.dart`) on purpose:
  it forces the iOS **document picker** (Files/iCloud/exported Voice Memos),
  unlike `FileType.audio` which can route to the music library and need
  `NSAppleMusicUsageDescription`. The document-picker path needs **no extra
  Info.plist key**. Uploaded clips are copied into the app Documents dir as
  `vo_<id>.<ext>` (web: stored as a `data:` URL), same persistence model as
  recordings. iOS build pulls file_picker's deps via SPM — the generated
  `**/swiftpm/` dirs are build artifacts (don't commit them).
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
flutter test           # 35 tests (content, mission, multi-child, board, skins, icons, animals, VO upload, Arabic order, Fruit & Veggies)
# Home map: 6 islands (now 210px so all six fit). Somali Village sisters live
# in the lower band (around the hut) so they're never hidden behind an island.
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
