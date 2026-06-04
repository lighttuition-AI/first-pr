# Workspace

A monorepo of cross-platform apps (Flutter — iOS / Android / Web) plus design
intake. Kept tidy so it's easy to navigate as more apps are added.

## Layout

```
.
├── apps/                 # one folder per shippable application
│   └── hnl_learning/      # HNL Learning — kids' educational learning app (Flutter)
├── design-refs/          # incoming design ideas + intake checklist
└── README.md             # you are here
```

## Apps

| App | What it is | Stack | Status |
|-----|------------|-------|--------|
| [`apps/hnl_learning`](apps/hnl_learning) | Audio-first educational app for kids 2–8 (3 worlds · 7 games · record-your-voice + upload-your-art studios) | Flutter | Playable build |

## Conventions

- **New app →** create a folder under `apps/`. Each app is self-contained
  (its own `pubspec.yaml`, `.gitignore`, and `README.md` with run instructions).
- **New design idea →** drop it in `design-refs/<idea-name>/` and follow
  `design-refs/IDEA-INTAKE-CHECKLIST.md`.
- **Branches & PRs →** work on a branch, open a PR, squash-merge to `main` to
  keep history clean (one tidy commit per change).
