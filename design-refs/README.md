# design-refs/

The home for every design idea's reference images — screenshots, phone photos,
Claude Design exports, sketches. Anything visual that helps Claude Code build it.

## 📁 One subfolder per idea (this is how we scale)

Every new idea gets its **own folder** named after it. That keeps 1000 ideas tidy
instead of one giant pile of images:

```
design-refs/
├── IDEA-INTAKE-CHECKLIST.md   ← copy this for each new idea
├── README.md                  ← you are here
├── eshaqo-home-screen/
│   ├── checklist.md           ← the filled-out intake checklist
│   ├── mockup-1.png
│   └── mockup-2.png
└── farm-sales-tracker/
    ├── checklist.md
    └── sketch.jpg
```

## How to use it (every new idea)

1. Make a new folder: `design-refs/<short-idea-name>/`.
2. Copy `IDEA-INTAKE-CHECKLIST.md` into it as `checklist.md` and fill it out.
3. Drop your images in that same folder.
4. Tell Claude: *"new idea — see design-refs/farm-sales-tracker/"*.

That one line points Claude at the checklist **and** the images together. Done.

## Why folders (not a flat pile)

Reference images live next to the code, version-controlled in Git, grouped per
idea — so months and hundreds of ideas later, we always know what each picture was
for and why a screen looks the way it does.
