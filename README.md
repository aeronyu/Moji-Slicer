# Moji Slicer

Moji Slicer is a macOS app for turning one grid image of emojis, stickers, or small icons into individual PNG files that can be reused in chat apps.

This repository is being rewritten as **Moji Slicer v2**. The old implementation mixed project management, canvas rendering, grid editing, image import, export, and a code-quality demo into the same app flow. The v2 direction is intentionally smaller and more reliable: import one image, define the grid, preview the slice boxes, and export clean PNGs.

## Product Scope

### Core workflow

1. Import a source image that contains a regular grid of emojis or stickers.
2. Configure the grid:
   - rows
   - columns
   - crop bounds
   - horizontal / vertical gap
   - optional padding inside each cell
3. Preview the calculated slice rectangles on top of the image.
4. Export each cell as a PNG.
5. Optionally auto-trim transparent or near-empty borders around each emoji.

### Non-goals for the v2 foundation

- Multi-board project management
- Infinite whiteboard canvas behavior
- Multiple image layers
- Code quality analyzer UI
- Complex drag/resize handles before the slicing math is proven

Those features can come later, but the first milestone should make the actual emoji slicing work correctly.

## Architecture

The rewrite separates the core image-slicing logic from SwiftUI so the important math can be tested without launching the app.

```text
Moji Slicer/
├── Core/
│   ├── SliceGrid.swift       # Input settings for rows, columns, crop, gaps, padding
│   ├── SliceCell.swift       # Output cell metadata: index, row, column, rect
│   └── ImageSlicer.swift     # Pure grid-to-rect calculation
├── Features/
│   ├── Import/               # Image loading
│   ├── GridEditor/           # Row/column/crop/gap controls
│   ├── PreviewCanvas/        # Overlay slice rectangles on source image
│   └── Export/               # PNG export pipeline
└── ContentView.swift         # Thin coordinator only
```

## Milestones

### Milestone 1: Proven slicing core

- [x] Add a clean `SliceGrid` model.
- [x] Add a clean `SliceCell` output model.
- [x] Add `ImageSlicer.makeCells(...)` for deterministic grid math.
- [x] Add unit tests for equal grids, gaps, padding, and invalid inputs.

### Milestone 2: Minimal app shell

- [ ] Replace the current mixed `ContentView` with a focused import + grid + preview flow.
- [ ] Show the selected image.
- [ ] Draw calculated slice boxes.
- [ ] Add rows / columns / gap / padding controls.

### Milestone 3: Export

- [ ] Crop source image into PNG cells.
- [ ] Export files into a user-selected folder.
- [ ] Use stable file names such as `emoji_001.png`.
- [ ] Report skipped cells and export errors clearly.

### Milestone 4: Polish

- [ ] Auto-trim transparent or empty borders.
- [ ] Remember recent settings.
- [ ] Add drag handles for crop bounds.
- [ ] Add keyboard shortcuts.

## Development

Open the project in Xcode:

```bash
open "Moji Slicer.xcodeproj"
```

Run the unit tests from Xcode. The slicing core should stay independent of SwiftUI and AppKit wherever possible.
