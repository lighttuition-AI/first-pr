# TestFlight upload scripts

One-command uploads to TestFlight using an **App Store Connect API key** — no
Transporter app, no Apple ID password. Secrets live in `~/.appstoreconnect/`
(outside the repo); nothing secret is committed.

## One-time setup

1. **Generate the key** in [App Store Connect](https://appstoreconnect.apple.com)
   → **Users and Access** → **Integrations** tab → **App Store Connect API** →
   **+**. Name it (e.g. `Claude Code Upload`), role **App Manager**, **Generate**.
2. **Download** the key — `AuthKey_XXXXXXXXXX.p8` (downloadable only once).
3. Copy the **Issuer ID** (the UUID at the top of that page).
4. Install it:
   ```bash
   scripts/setup-asc-key.sh ~/Downloads/AuthKey_XXXXXXXXXX.p8 <ISSUER_ID>
   ```
   This copies the `.p8` to `~/.appstoreconnect/private_keys/` and writes
   `~/.appstoreconnect/hnl-asc.env` (Key ID + Issuer ID), all `chmod 600`.

## Every release

```bash
# 1) bump the build number in pubspec.yaml  (e.g. 1.1.0+3 → 1.1.0+4)
# 2) build + upload in one go:
scripts/ship-testflight.sh
```

Or, if an IPA is already built:

```bash
scripts/upload-testflight.sh                 # build/ios/ipa/hnl_learning.ipa
scripts/upload-testflight.sh path/to/My.ipa  # or a specific IPA
```

The build appears in App Store Connect → TestFlight after a few minutes of
processing. Revoke the key any time in App Store Connect to cut off access.
