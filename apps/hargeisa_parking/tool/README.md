# Admin scripts

Node scripts for the live Firebase backend. Run them from this folder after you've
created the Firebase project (see [`../FIREBASE_SETUP.md`](../FIREBASE_SETUP.md)).

## Setup (once)
1. Firebase console → **Project settings → Service accounts → Generate new private key**.
2. Save the downloaded file here as **`serviceAccountKey.json`** (git-ignored — it's a secret).
3. `npm install`

## Seed the database
Populates `officers`, `vehicles`, `appeals` and the id counter with the same demo data
the apps ship with, so HPark Command has pending officers to approve etc.

```bash
npm run seed
```

## Grant an admin
Admins (who can approve officers) are flagged with the `admin: true` auth claim that the
Firestore rules check. Sign up your admin account in the app first, then:

```bash
npm run grant-admin you@example.com      # or the UID
```

The user signs out and back in for the claim to take effect.
