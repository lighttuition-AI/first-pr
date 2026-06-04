# HNL Learning — Flutter app

An **audio-first, touch-first educational app for children ages 2–8**, rebuilt in
Flutter from the Claude Design handoff (`HNL Learning.html`). A friendly
monkey-scientist robot, **Robo**, *speaks* every instruction and guides a
non-reading child through drag-and-drop / tap mini-games across three learning
worlds, earning collectible **planets**.

> Tagline (for parents): *"Healthy screen time that builds logic, memory, and focus."*
> Offline-first · ad-free · generous (nothing paywalled).

This is a faithful, idiomatic Flutter port of the HTML/React design prototype —
matched on layout, spacing, color, typography, copy, interaction, and motion.

---

## Run it

```bash
cd hnl_learning
flutter pub get

flutter run -d chrome      # fastest: opens in your browser
# or
flutter run                # on a connected iPad / iPhone / Android device
```

The app renders a fixed **1366 × 1024 iPad-landscape stage** that scales
uniformly (letterboxed) to fit any screen — so it looks right on an iPad, a
phone, or a browser window.

Verify the port:

```bash
flutter analyze        # static analysis — clean
flutter test           # unit tests (7 games · 45 VO lines · 78 image slots …)
flutter build web      # full compile
```

---

## What's implemented (the whole app)

**Full flow:** parent onboarding (3 modular steps) → child setup (age · topics ·
avatar/photo · "adventure ready") → home map (3 island worlds) → daily mission +
session timer → all **7 mini-games** → planet rewards → parent gate + dashboard.

**The 7 games — all playable:**
1. **Logic — "Which one?"** (tap-pick: bigger car, odd-one-out, what flies)
2. **Counting — "Count & drop"** (drag exactly N items into the basket)
3. **Shapes & Patterns — "Finish the pattern"** (drag the next piece)
4. **Memory — "Flip & match"** (tap pairs)
5. **Letters — "Letter sounds"** (tap the picture that starts with the letter)
6. **Sorting — "Sort it out"** (drag items into the right group)
7. **Science — "Discover!"** (a fun fact, then a quick question)

Correct → **+8 score, confetti, bouncing stars, Robo cheer**, then a reward
reveal. Wrong → the element **shakes left-right** and Robo says "try again" — no
penalty, always encouraging.

**Two creative-control systems (both were explicit client requirements):**
- 🎙️ **Voiceover Studio** — record **your own voice** for every one of the 45
  spoken lines. If a recording exists it plays; otherwise the device TTS voice is
  the stand-in. Clips persist offline.
- 🖼️ **Picture Studio** — upload **your own art** from the gallery for any of the
  78 image slots. One upload applies everywhere that picture appears; everything
  rounds to fit the design. Nothing ever looks broken (falls back to the emoji).

Plus: a live **Tweaks** panel (color theme · font · celebration · session length ·
mascot on/off · sound), the **parent gate** (tap 1-2-3-4 in order), and a parent
**dashboard** (streak/time/stars/planets, a 7-axis cognitive radar, per-skill
bars, a printable certificate, and settings).

---

## How it maps to the design

| Design concept | Flutter implementation |
|---|---|
| `localStorage` save | `shared_preferences` (`lib/state/app_state.dart`) |
| Design tokens (color/type/radii/shadow) | `lib/theme/tokens.dart` |
| All content (topics, games, VO lines) | `lib/models/content.dart` |
| Robo, planets, avatars, confetti (SVG) | `CustomPainter` (`lib/widgets/`) |
| Voiceover engine + Studio | `flutter_tts` + `record` + `audioplayers` (`lib/services/vo_service.dart`, `lib/screens/voice_studio.dart`) |
| Image slots + Picture Studio | `image_picker`, bytes persisted locally (`lib/services/image_service.dart`, `lib/screens/picture_studio.dart`) |
| Drag-and-drop games | Flutter `Draggable` / `DragTarget` |
| Fonts: Baloo 2 + Nunito | `google_fonts` |

### Fidelity notes & deliberate placeholders
- **Game pictures and icons are emoji**, exactly as in the design — they stand in
  for the custom illustrated art the client will supply (swap them per-slot in the
  Picture Studio, or drop in real assets later).
- **Robo** and the **avatars/planets** are drawn as vectors (`CustomPainter`);
  they can be upgraded to polished illustrated sprites.
- **Fonts** load via `google_fonts` (cached after first fetch). For a strictly
  offline-from-first-launch build, bundle the `.ttf` files as assets instead.
- **Voiceover** uses the device's text-to-speech as the default voice (the
  prototype used the browser's). Production can ship pre-recorded default clips.
- **Web caveat:** recorded voice clips use a temporary blob URL on web and won't
  persist across reload (they persist fine on iOS/Android). Everything else —
  including uploaded pictures — persists everywhere.
