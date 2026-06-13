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
  **game 4 = flip the letters** (`GameType.arabicFlip`, `ArabicFlipGame`): a 7×4
  RTL poster (Alif top-right) where every card starts "turned around" — a solid
  colour back showing the glyph mirrored & dim + a flip-arrows hint. Tap → a 3D
  `rotateY` flip to the correct, upright letter (white card, colour border, name)
  and the letter is spoken. It has its **own 28 letter recordings** (`ar-*-flip`,
  via `flipVoId`), grouped under "Flip the Letters" in the Studio — separate from
  the alphabet board's `ar-*` lines so the flip cards can be voiced on their own.
  Reveal all 28 → confetti, then the whole board flips back (colours
  re-cycled) for a fresh round. **game 5 = letter sounds** (`GameType.arabicSounds`,
  `ArabicSoundsGame`): the harakat wall-chart — a 4×7 RTL grid of 28 consonant
  cards, each holding the **3 short-vowel forms** (read right-to-left as a · i · u,
  fatha/kasra/damma). That's **84 separately-tappable cells**, each with its own
  recordable sound. Tap a cell → just that syllable plays (highlights while
  speaking). Data is `kHarakatLetters`/`kHarakatForms` in `content.dart` (built
  from `kArabicLetters` + a per-letter syllable table; ids are `ar-<letter>-a|i|u`,
  disjoint from the whole-letter ids). The 84 sounds are recorded in a dedicated
  **"ARABIC — LETTER SOUNDS (HARAKAT)"** Studio section (28 expandable consonant
  tiles × 3 lines), mirroring the Animals/Produce nested pattern. Both games are
  explore-only and fit the stage with no scroll (LayoutBuilder-sized cells).
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

## Backend — Firebase · analytics + crash reporting LIVE; data-sync pending (1.3.0+6)
- **Project `hnl-learning`** (Firebase CLI logged in as app.jeeble@gmail.com). Scope: cloud
  for **user data only** — recordings, photos, child profiles, progress + Analytics/
  Crashlytics. **Educational content stays bundled** (offline-first; NOT moved to a backend).
- **Foundation (done):** `firebase_core` + `firebase_analytics`; `Firebase.initializeApp(options:
  DefaultFirebaseOptions.currentPlatform)` in `main.dart`, **wrapped in try/catch** so a bad
  config / no network never blocks launch (logs `app_open`). `flutterfire configure` registered
  the iOS + Android apps and generated `lib/firebase_options.dart`, `ios/Runner/
  GoogleService-Info.plist`, `android/app/google-services.json`, `firebase.json` (all committed —
  Firebase client config is **not** a secret; security is via Firestore/Storage rules). Android
  gradle got the standard `com.google.gms.google-services` plugin.
- **iOS min bumped 13 → 15** (Firebase SDK via SPM requires 15; pbxproj ×3 + Podfile). Fine —
  iPhone 15 Pro is iOS 17+, and iOS 15+ is ~all active devices.
- `analysis_options.yaml` now **excludes `build/`** (the Firebase SDK checks Dart test files into
  `build/ios/SourcePackages/`, which polluted `flutter analyze`).
- **Crashlytics + Analytics (done, 1.3.0+6):** `firebase_crashlytics` routes uncaught
  `FlutterError` + `PlatformDispatcher` errors (off in debug via
  `setCrashlyticsCollectionEnabled(!kDebugMode)`). `services/analytics.dart` (`Analytics`) is a
  throw-proof wrapper; events wired: `app_open`, `world_open`, `game_start`, `recording_saved`.
  Verified building + initialising cleanly on the iPad + iPhone sims.
- **Data sync (NOT done — blocked, this is the next round).** Design: anonymous-auth (later a
  Parent Sign-In) + a **non-destructive backup mirror** under `users/{uid}` — Firestore for the
  small `hnl-save-v1` blob (profiles+progress), Storage for media (recordings = files; images/gifs
  = base64 in prefs → upload decoded). Restore ONLY when local is empty (fresh install) so it can
  never harm on-device data. **Security rules are written + ready** (`firestore.rules`,
  `storage.rules`, wired in `firebase.json`: own-uid-only). **Backend state (2026-06-11):**
  ✅ **Cloud Firestore is ENABLED and `firestore.rules` is DEPLOYED** to the `(default)` db
  (`firebase deploy --only firestore:rules`) — so the **profiles+progress sync is buildable now**.
  ⛔ **Cloud Storage NOT enabled** (needs the Blaze plan; owner has no card on hand) → media backup
  (recordings/photos) is deferred; deploy `storage.rules` once it's on. ⛔ **Parent Sign-In still
  needed** — anonymous auth gets a new uid each reinstall, so cross-device/reinstall restore requires
  an Apple/Google login behind the gate (Apple entitlement + device testing). So the **next sync
  round** can build the Firestore profiles/progress mirror (anon-auth, non-destructive) immediately;
  media + true cross-device wait on Storage(Blaze) + Sign-In. Sync code not shipped yet (unverifiable
  end-to-end without sign-in).
- **Android build still not verified** (gradle is Firebase-ready; needs an emulator run for Play).

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
  `UIRequiresFullScreen`; also `SystemChrome.setPreferredOrientations` in main.dart).
  On the simulator the window may show portrait after a reinstall → rotate with **⌘→**
  (Device → Rotate). On a real iPad: hold landscape.
- **iPhone (universal binary, `TARGETED_DEVICE_FAMILY=1,2`):** runs on iPhone in landscape and,
  since 1.3.0, **fills the screen edge-to-edge** (the `Stage` in `app.dart` detects phone-class
  screens — `min(w,h)<600` — and drops the tablet "device" bezel). It's still the landscape iPad
  UI, just full-screen; a true **portrait layout is the one remaining big redesign** (~20 screens
  on an absolutely-positioned canvas — a dedicated project, intentionally NOT rushed).
  - 🐞 **Fixed-stage clamp bug (FIXED 1.3.0):** the `SizedBox(1366×1024)` stage used to be
    constraint-**clamped** on any screen shorter than 1024px (every iPhone, the 11" iPad) → content
    overflowed. The 13" iPad (exactly 1024 tall) was the only size that worked, which hid it. Fix:
    wrap the stage in **`FittedBox(BoxFit.contain)`** (both phone + tablet paths) so it lays out at
    full size then scales. Don't reintroduce a bare `Transform.scale` over the fixed SizedBox.
  - A phone held **upright** shows a friendly "Turn me sideways to play!" `_RotateHint` (the app is
    landscape-only). ⚠️ The **iPhone sim won't auto-rotate**, so `simctl` screenshots come out
    portrait showing the landscape frame rotated — rotate the PNG (`sips -r 270`) to read it.
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
flutter test           # 38 tests (content, mission, multi-child, board, skins, icons, animals, VO upload, Arabic order/flip/sounds, Fruit & Veggies)
# Home map: 6 islands (now 210px so all six fit). Somali Village sisters are a
# family group in the clear bottom-CENTRE (in front of a raised aqal hut), kept
# off the "Tap an island" bubble + Robo (left) and the Daily Mission card (right).
flutter run -d chrome  # quick web run
# iPad simulator used during dev: "iPad Pro 13-inch (M5)"
#   udid 9C1A4EAC-B929-46AD-912D-6D29B9704D56
flutter run -d 9C1A4EAC-B929-46AD-912D-6D29B9704D56
# screenshot the sim:  xcrun simctl io booted screenshot out.png
```

## TestFlight — SHIPPED (first build uploaded 2026-06-06)
A signed App Store IPA has been **built and delivered to App Store Connect → TestFlight**.
Locked-in identity (all permanent / must match App Store Connect):
- **Bundle ID `com.hnllearning.com`** — the App ID registered under the PAID team.
  (Earlier we briefly used `com.hnllearning.app`; that profile was auto-created under a
  FREE *personal* team, so the registered/uploadable id is `.com`. Don't revert.)
- **Paid signing team `4696KN59VV`** = "Khadar Ainashe" (Individual). Set as
  `DEVELOPMENT_TEAM` on the 3 Runner configs + automatic signing. ⚠️ Gotcha: the cert
  name shows "Khadar Ainashe (BLGU4D968K)" — `BLGU4D968K` is a CERT id, **not** the team;
  the team is `4696KN59VV` (confirmed by the issued provisioning profile + Xcode plist).
- **Display name** `HNL Learning`; **version `1.4.1+10`** (1.0.0+1 was the first
  TestFlight build; 1.1.0 added Flip the Letters + Letter Sounds; +3 moved the harakat
  Studio section; 1.3.1+8 locked **all** inline recording behind the 1-2-3-4 grown-up
  gate + gave the game shell a back arrow instead of an "X"; 1.4.0+9 added **10 themed
  Flip & Match games** to Discovery World (`GameType.memory`, ids `mem-*`, explore-only,
  themed decks: Arabic/animals/sea/fruit/veggie/numbers/shapes/vehicles/food/weather),
  made the recording gate ARM-only (entering the code no longer auto-starts recording —
  the grown-up taps the mic to begin), and moved the Settings gear to the bottom-LEFT on
  play screens so it stops overlapping the Next button; 1.4.1+10 **removed planet
  collecting from gameplay** (deleted the "you unlocked a planet" reveal + the rewards
  collection screen + the 🪐 chip/break button/parent stats; finishing a game no longer
  jumps to a collecting area) and made tapping a game **play through its whole world** —
  `startGame` queues all of that world's games from the tapped one; `finishGame` advances
  to the next, and the last game (or the back button, via `backToWorld`) drops back into
  that world's games sheet via `AppState.resumeWorld` (one step back, not out to the island
  map). NOTE: the planet *data* (`kPlanets`/`Planet`) is kept — still used by the logo
  branding + the Picture Studio slots — and the inert `Game.reward` field remains on each
  game (no longer awarded). **Bump the `+build` in pubspec before each new upload** — it
  must increase monotonically — App Store Connect rejects a reused build number).
  **STANDING RULE: after every improvement, build a fresh App-Store IPA + reveal it in
  Finder for the user to push to TestFlight.**
- **App icon (1.2.0+)**: the **three Somali Village sisters** (pink · gold · purple, tiaras
  + scepters) on a warm savanna ground — original art composed from `widgets/village.dart`
  `SomaliGirl`. Reproducible: `flutter test tool/gen_app_icon.dart` renders the 1024 master
  to `/tmp/hnl_icon_1024.png`, then `scripts/gen-app-icon.sh` slices it into every
  `AppIcon.appiconset` slot (alpha stripped via a jpeg round-trip — App Store rejects
  transparency). Tweak the composition in `SisterIcon` (in the tool) + re-run both.
  (Earlier icon was a branded Robo on sunshine.)
- **Info.plist purpose strings**: mic + photo (used) AND camera + location (NOT used —
  required only because bundled `file_picker` references those APIs; without them the
  upload fails with App Store error **90683**). Also `ITSAppUsesNonExemptEncryption=false`.
- Xcode 26 upgraded the project (objectVersion 60, UIScene manifest); `SceneDelegate.swift`
  is present so launch is fine.

**Build + upload a new build:** bump `version:` build in `pubspec.yaml` (e.g. `1.1.0+4`) →
`flutter build ipa --export-method app-store` (needs the user logged into Xcode for the
paid team) → IPA at `build/ios/ipa/hnl_learning.ipa`. Automatic signing creates the
distribution cert + App Store profile on the fly.

**Upload (scripted, no Transporter):** an App Store Connect **API key** drives uploads via
`xcrun altool`. One-time: `scripts/setup-asc-key.sh ~/Downloads/AuthKey_XXXX.p8 <ISSUER_ID>`
(stores the `.p8` + Key/Issuer IDs in `~/.appstoreconnect/`, **outside git**). Then either
`scripts/ship-testflight.sh` (build + upload) or `scripts/upload-testflight.sh` (upload an
existing IPA). See `scripts/README.md`. Secrets never touch the repo (`.gitignore` blocks
`*.p8` / `*-asc.env`). The old manual path (drag the IPA into the **Transporter** app) still
works as a fallback.

**Privacy policy** (required for external testing + App Store): lives at `docs/privacy.html`,
hosted free on **GitHub Pages** → **https://lighttuition-ai.github.io/first-pr/privacy.html**
(repo is public; Pages serves `main` `/docs`). It's honest: the app collects nothing,
everything stays on-device.

**Still pending (user-side in App Store Connect):**
- *Internal testing* (fastest, no review): TestFlight ▸ Internal Testing ▸ add testers
  (self + up to 100), install via the TestFlight app. No Beta App Review needed.
- *External testing / public*: needs Beta App Description + Feedback Email + the Privacy
  Policy URL above + **screenshots** + submit for **Beta App Review**. Sign-In required =
  **OFF** (no login). Review note: the Settings/parent area is behind a child-lock —
  tap the gear, enter **1-2-3-4**.
- *Full App Store release* (later): screenshots per device, description, category
  (Education / made-for-kids), age rating, "Data Not Collected" privacy answers.
- If Apple emails about a missing `PrivacyInfo.xcprivacy` (UserDefaults reason) — add it;
  not blocking for TestFlight.

## Possible next ideas (not started)
- Default letter voice via **Arabic TTS** locale (currently English TTS says the
  transliteration as a placeholder until the user records).
- Optional **name** field per child.
- Run/verify on the **Android emulator** (`Pixel_7_API_35`).
- More Arabic-world games (the world sheet shows "More soon" slots).
