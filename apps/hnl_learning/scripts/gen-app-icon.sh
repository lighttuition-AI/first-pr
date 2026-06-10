#!/usr/bin/env bash
# Slice the 1024 master icon into every iOS AppIcon slot.
# First generate the master:  flutter test tool/gen_app_icon.dart
# Then:                       scripts/gen-app-icon.sh [master.png]
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MASTER="${1:-/tmp/hnl_icon_1024.png}"
SET="$APP_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset"

[ -f "$MASTER" ] || { echo "✗ master not found: $MASTER (run: flutter test tool/gen_app_icon.dart)"; exit 1; }

# Flatten any alpha (App Store rejects transparency) via a jpeg round-trip.
flat="$(mktemp -t hnlicon).png"
sips -s format jpeg "$MASTER" --out "${flat%.png}.jpg" >/dev/null
sips -s format png "${flat%.png}.jpg" --out "$flat" >/dev/null

for f in "$SET"/Icon-App-*.png; do
  name="$(basename "$f")"          # e.g. Icon-App-83.5x83.5@2x.png
  dims="${name#Icon-App-}"; dims="${dims%.png}"   # 83.5x83.5@2x
  wh="${dims%@*}"                  # 83.5x83.5
  scale="${dims#*@}"; scale="${scale%x}"          # 2
  w="${wh%x*}"                     # 83.5
  px="$(awk "BEGIN{printf \"%d\", ($w)*($scale)}")"
  sips -z "$px" "$px" "$flat" --out "$f" >/dev/null
  printf '  %-28s %spx\n' "$name" "$px"
done

rm -f "$flat" "${flat%.png}.jpg"
echo "✓ All AppIcon slots regenerated from $(basename "$MASTER")."
