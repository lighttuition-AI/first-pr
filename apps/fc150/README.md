# FC150 — Challenge Arena

A premium Flutter app for **PlayStation 5 FC/FIFA players**: challenge each other in the
app, play the match on a real PS5, then track scores, leagues, rankings and animated
football-style **player cards**. The app manages the competition around the game — it does
not host gameplay.

Recreated in idiomatic Flutter from the `design_handoff_fc150_challenge_arena` design
reference (dark-first, electric-purple + teal, glow-not-shadow). No EA/FIFA assets — the
card art is original.

## Highlights
- **Animated player card** with four variants — neon, holo (rotating foil), mono, and
  tiered platinum/gold/silver winner cards — plus an idle shine sweep.
- **Home · Arena · League · Cards · Admin** in a blurred 5-tab shell.
- Multi-step **challenge flow**, **result submit**, **Top-3 winners** overlay with
  confetti, and a **half-season card upgrade** reveal (rating count-up + confetti).
- Set your card photo from the gallery (`image_picker`).

## Run
```bash
flutter pub get
flutter run            # any booted simulator/device
```

See **[PROJECT_NOTES.md](PROJECT_NOTES.md)** for architecture, design fidelity notes,
signing, and the Firebase follow-ups.
