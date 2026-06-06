#!/usr/bin/env bash
# One-time setup: install an App Store Connect API key for TestFlight uploads.
#
# Generate the key first (App Store Connect → Users and Access → Integrations →
# App Store Connect API → "+"), download the AuthKey_XXXXXXXXXX.p8 (one-time
# download), and copy the Issuer ID (a UUID at the top of that page).
#
# Then run:
#   scripts/setup-asc-key.sh ~/Downloads/AuthKey_XXXXXXXXXX.p8 <ISSUER_ID>
#
# Secrets are stored OUTSIDE the repo, in ~/.appstoreconnect/ — never in git.
set -euo pipefail

P8="${1:?usage: setup-asc-key.sh <path-to-AuthKey_XXXX.p8> <ISSUER_ID>}"
ISSUER="${2:?usage: setup-asc-key.sh <path-to-AuthKey_XXXX.p8> <ISSUER_ID>}"

[ -f "$P8" ] || { echo "✗ Key file not found: $P8"; exit 1; }

base="$(basename "$P8")"          # expected: AuthKey_<KEYID>.p8
keyid="${base#AuthKey_}"
keyid="${keyid%.p8}"
if [ "$base" = "$keyid" ] || [ -z "$keyid" ]; then
  echo "✗ Expected a file named AuthKey_<KEYID>.p8 — got '$base'."
  echo "  Rename it to match, or pass the original downloaded file."
  exit 1
fi

dir="$HOME/.appstoreconnect"
keys="$dir/private_keys"
mkdir -p "$keys"
chmod 700 "$dir" "$keys"
cp "$P8" "$keys/$base"
chmod 600 "$keys/$base"

cat > "$dir/hnl-asc.env" <<EOF
# App Store Connect API credentials (do NOT commit). Used by upload-testflight.sh.
export ASC_KEY_ID="$keyid"
export ASC_ISSUER_ID="$ISSUER"
EOF
chmod 600 "$dir/hnl-asc.env"

echo "✓ Installed API key $keyid → $keys/$base"
echo "✓ Wrote credentials → $dir/hnl-asc.env"
echo "  You can now upload with:  scripts/upload-testflight.sh"
