# hpark_firebase

Firebase Auth + Cloud Firestore implementations of the Hargeisa Parking backend
seams defined in `hpark_core`.

- `FirebaseOfficerRepository` — a Firestore-backed `OfficerRepository` (live snapshot
  sync, so approvals propagate in real time). Drop-in for `OfficerRepository.demo()`.
- `FirebaseAuthService` — a Firebase Auth implementation of `AuthService`.
- `initBackend(options:)` — initialises Firebase and returns an `HParkBackend`,
  falling back to the in-memory demo backend if Firebase isn't configured.

The apps depend on the **interfaces** in `hpark_core`, never on Firebase directly, so
turning the backend on is a dependency + one line in `main()`. See
[`../../FIREBASE_SETUP.md`](../../FIREBASE_SETUP.md) and the security rules in
`../../firestore.rules`.
