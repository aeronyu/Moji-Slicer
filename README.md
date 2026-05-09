# Moji Slicer

Moji Slicer is a macOS app for turning a grid image of emojis, stickers, or small icons into individual PNG files that can be reused in chat apps.

This branch starts the **Moji Slicer v2** rewrite. The immediate goal is to replace the half-abandoned mixed canvas/project-management implementation with a smaller, reliable workflow:

1. Import one source image.
2. Configure rows, columns, gaps, and padding.
3. Preview the calculated output frames.
4. Export each frame as a PNG.

## v2 Scope

### First milestone

- Establish a clean SwiftUI app shell.
- Keep GitHub Actions green for Xcode build and focused unit tests.
- Move the old code-quality demo out of the active app path.
- Add small, testable grid-layout logic before reconnecting image export.

### Product workflow

```text
Import image -> configure grid -> preview frames -> export PNG files
```

### Non-goals for the v2 foundation

- Multi-board project management.
- Infinite whiteboard behavior.
- Multiple image layers.
- Code quality analyzer UI.
- Complex drag handles before the grid math and export path are proven.

## Architecture Direction

```text
Moji Slicer/
├── ContentView.swift          # Thin v2 app shell
├── Core/                      # Pure grid calculation and export logic
├── Features/
│   ├── Import/                # Image loading
│   ├── GridEditor/            # Grid controls
│   ├── PreviewCanvas/         # Visual frame overlay
│   └── Export/                # PNG writing
└── Tests/                     # Deterministic grid/export tests
```

## Development

Open the project in Xcode:

```bash
open "Moji Slicer.xcodeproj"
```

GitHub Actions runs an app build plus focused unit tests on pull requests. The current CI intentionally excludes legacy code-quality files from compilation while the v2 app path is rebuilt.
