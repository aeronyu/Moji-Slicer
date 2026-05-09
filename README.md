# Moji Slicer

Moji Slicer is a native macOS app for turning one grid image of emojis, stickers, or small icons into individual PNG files.

It is designed for cases where you have a single image that contains many emojis arranged in rows and columns, and you want to quickly slice that sheet into separate custom emoji files for chat apps, messaging tools, or personal asset libraries.

## Repository Description

Suggested GitHub About description:

```text
A native macOS app for slicing emoji, sticker, and icon grid images into individual PNG files.
```

## Current Status

Moji Slicer is currently in an early v2 rewrite. The app now has the core workflow working:

- Import one image.
- Configure the number of rows and columns.
- Adjust horizontal gap, vertical gap, and padding.
- Drag and resize the slicing frame directly on the preview canvas.
- Preview the generated slice boxes.
- Export each slice as a PNG file.

The app is usable for basic grid slicing, but some polishing work is still planned.

## Download

Published builds are available from the repository's GitHub Releases page.

The first planned downloadable release is:

```text
v0.1.0
```

Download the macOS ZIP file, unzip it, and move `Moji Slicer.app` to your Applications folder.

### macOS security note

Current release builds are unsigned and not notarized. macOS may show a Gatekeeper warning the first time you open the app.

## Features

### Image import

Import a source image from your Mac using the built-in file picker.

### Grid controls

Set the grid layout with:

- Rows
- Columns
- Horizontal gap
- Vertical gap
- Padding

These settings control how the image is divided into output frames.

### Resizable slicing frame

The orange slicing frame defines the area of the image that should be sliced.

You can:

- Drag the frame to move it.
- Drag the corner handles to resize it.
- Reset the frame back to the full image.

The blue grid boxes update based on the current slicing frame and grid settings.

### PNG export

Export the current grid as individual PNG files. Files are written to a folder you choose through the macOS folder picker.

Output files use a stable numbered naming pattern such as:

```text
emoji_001.png
emoji_002.png
emoji_003.png
```

## Basic Workflow

1. Open the app.
2. Click **Import Image**.
3. Choose an image that contains a grid of emojis, stickers, or icons.
4. Set the row and column count.
5. Adjust gap and padding values if needed.
6. Drag or resize the orange slicing frame to match the grid area.
7. Confirm the blue preview boxes line up with each emoji.
8. Click **Export PNGs**.
9. Choose an output folder.

## Releasing

The repository includes a GitHub Actions release workflow.

To publish a new release:

1. Update the `VERSION` file, for example `0.1.0`.
2. Commit and merge that change to `main`.
3. Create and push a matching tag:

```bash
git tag v0.1.0
git push origin v0.1.0
```

The release workflow will build the macOS app, create a ZIP file, generate a SHA-256 checksum, and attach both files to a GitHub Release.

## Development

Open the project in Xcode:

```bash
open "Moji Slicer.xcodeproj"
```

Build and run the app from Xcode.

The project includes GitHub Actions CI for:

- Xcode app build
- Focused unit tests

## Project Structure

```text
Moji Slicer/
├── ContentView.swift              # Main SwiftUI app flow
├── Core/
│   ├── GridSpec.swift             # Grid configuration model
│   ├── GridFramePlan.swift        # Calculated output frame model and planner
│   └── GridImageExporter.swift    # PNG export logic
└── ...

Moji SlicerTests/
├── GridFramePlannerTests.swift    # Grid calculation tests
├── GridImageExporterTests.swift   # PNG export smoke tests
└── Moji_SlicerTests.swift         # Test target smoke test
```

## Notes

This project was originally a more experimental canvas-style app. The current v2 rewrite intentionally focuses on a smaller and more reliable single-image slicing workflow.

Some old code may still exist in the repository while the rewrite continues, but the active app path is centered around the v2 image slicing flow.

## Planned Improvements

- Verify export orientation with more real-world emoji sheets.
- Add edge handles in addition to corner handles.
- Add optional transparent-border trimming.
- Add better visual cursor feedback while resizing.
- Add saved presets for common grid sizes.
- Improve UI polish and keyboard shortcuts.
