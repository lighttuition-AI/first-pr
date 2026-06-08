# Going live with Firebase

The apps run today on an **in-memory demo backend** (seeded data, no network). This
guide turns on the **real backend** — Firebase Auth (logins) + Cloud Firestore
(shared database) — so an approval in HPark Command instantly unlocks HPark Enforce
on a real officer's phone, and citations/appeals sync everywhere.

Everything is already written: the Firebase code lives in
`packages/hpark_firebase/`, and the database security rules are in
`firestore.rules`. You just need to create the Firebase project and flip a switch.

> **Why this wasn't turned on automatically:** wiring Firebase into the apps needs
> *your* Firebase project (API keys + native config files). I kept it out of the
> three working apps so their builds stay green until you're ready — turning it on
> is the steps below.

---

## 1. One-time tooling

```bash
npm install -g firebase-tools          # the Firebase CLI
dart pub global activate flutterfire_cli
firebase login                         # opens the browser
```

## 2. Create the Firebase project

1. Go to <https://console.firebase.google.com> → **Add project** → name it
   e.g. `hargeisa-parking`.
2. In the console: **Build → Authentication → Get started → Email/Password → Enable.**
3. **Build → Firestore Database → Create database → Production mode.**

## 3. Connect each app

Run this inside **each** app folder (`enforce_app`, `pay_app`, `command_app`). It
generates `lib/firebase_options.dart` and the native config for that app:

```bash
cd enforce_app   && flutterfire configure --project=hargeisa-parking
cd ../pay_app    && flutterfire configure --project=hargeisa-parking
cd ../command_app && flutterfire configure --project=hargeisa-parking
```

Pick the platforms each app targets when prompted (Enforce/Pay → Android, iOS;
Command → Web).

## 4. Deploy the security rules

From this folder (`apps/hargeisa_parking/`):

```bash
firebase deploy --only firestore:rules --project=hargeisa-parking
```

These rules (`firestore.rules`) enforce the **approval gate in the database itself**:
an officer can only register as `pending`, and **only an admin can approve them** —
so even a tampered app can't grant itself officer powers. Only *approved* officers
can write citations.

## 5. Flip an app from demo → Firebase

In the app's `pubspec.yaml`, add:

```yaml
dependencies:
  hpark_firebase:
    path: ../packages/hpark_firebase
```

Then initialise the backend in `main()` and pass the repository down. Example for
**command_app** (the shell currently calls `OfficerRepository.demo()`):

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:hpark_firebase/hpark_firebase.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final backend = await initBackend(options: DefaultFirebaseOptions.currentPlatform);
  runApp(HParkCommandApp(backend: backend));   // pass backend.officers into CommandShell
}
```

`initBackend` returns a `HParkBackend` whose `.officers` is a `FirebaseOfficerRepository`
— the **same `OfficerRepository` interface** the screens already use, so nothing in
the UI changes. (If Firebase isn't configured it falls back to the demo backend, so
the app never crashes mid-setup.)

Change `CommandShell` / `EnforceRoot` to accept the repository instead of calling
`OfficerRepository.demo()` directly, and you're live.

## 6. Make yourself an admin

Admins are flagged with the custom auth claim `admin: true`. After you've signed up
your admin account once, set the claim with a tiny Node script (run locally with a
service-account key from **Project settings → Service accounts**):

```js
const admin = require('firebase-admin');
admin.initializeApp({ credential: admin.credential.cert(require('./serviceAccountKey.json')) });
admin.auth().setCustomUserClaims('THE_ADMIN_UID', { admin: true })
  .then(() => console.log('done'));
```

(The user signs out/in once for the claim to take effect.)

## Platform notes
- **Android:** `cloud_firestore` needs `minSdkVersion 23` — bump it in
  `android/app/build.gradle.kts` if the build complains.
- **iOS:** set the platform to `13.0` in `ios/Podfile`, then `pod install`.
- **Web (Command):** no native config — `flutterfire configure` writes everything
  into `firebase_options.dart`.

## Data model (collections)
- `users/{uid}` → `{ role: 'officer' | 'citizen', officerId? }`
- `officers/{OFR-id}` → the `Officer` fields (see `Officer.toMap`)
- `vehicles/{plate}` · `citations/{id}` · `appeals/{id}` · `counters/officers`

Once this is done, tell me and I'll wire the auth screens (officer & citizen login)
and move citations/appeals/vehicles onto Firestore too.
