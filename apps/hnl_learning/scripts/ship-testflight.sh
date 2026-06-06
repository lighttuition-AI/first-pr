#!/usr/bin/env bash
# Build a signed App Store IPA and upload it to TestFlight in one command.
#
#   scripts/ship-testflight.sh
#
# ⚠️ Bump `version:` (the +build number) in pubspec.yaml FIRST — App Store
# Connect rejects a build number that was already uploaded.
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$APP_DIR"

ver="$(grep '^version:' pubspec.yaml | awk '{print $2}')"
echo "▶ Building App Store IPA for $ver …"
flutter build ipa --export-method app-store

exec "$APP_DIR/scripts/upload-testflight.sh"
