#!/usr/bin/env bash
# Upload an already-built App Store IPA to TestFlight via the App Store Connect
# API key (no Transporter, no Apple ID password).
#
#   scripts/upload-testflight.sh [path/to.ipa]
#
# Defaults to build/ios/ipa/hnl_learning.ipa. Credentials + the .p8 key live in
# ~/.appstoreconnect/ (installed once by setup-asc-key.sh) — never in git.
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IPA="${1:-$APP_DIR/build/ios/ipa/hnl_learning.ipa}"
ENV_FILE="$HOME/.appstoreconnect/hnl-asc.env"

[ -f "$ENV_FILE" ] || {
  echo "✗ No API key installed ($ENV_FILE missing)."
  echo "  Run:  scripts/setup-asc-key.sh ~/Downloads/AuthKey_XXXX.p8 <ISSUER_ID>"
  exit 1
}
# shellcheck disable=SC1090
source "$ENV_FILE"
: "${ASC_KEY_ID:?ASC_KEY_ID not set in $ENV_FILE}"
: "${ASC_ISSUER_ID:?ASC_ISSUER_ID not set in $ENV_FILE}"

[ -f "$IPA" ] || {
  echo "✗ IPA not found: $IPA"
  echo "  Build it first:  flutter build ipa --export-method app-store"
  exit 1
}

# altool finds the key at ~/.appstoreconnect/private_keys/AuthKey_<KEYID>.p8.
echo "↑ Uploading $(basename "$IPA") to TestFlight (key $ASC_KEY_ID)…"
xcrun altool --upload-app --type ios --file "$IPA" \
  --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"
echo "✓ Uploaded. Build shows in App Store Connect → TestFlight after processing (a few min)."
