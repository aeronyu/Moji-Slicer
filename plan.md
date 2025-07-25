# Moji Slicer - Action Plan

## Project Overview

A SwiftUI app for slicing grid-based emoji/meme images into individual pieces with adjustable grids and batch processing capabilities.

## Phase 1: Basic Foundation (Core UI Structure)

### 1.1 Project Setup

- [x] Basic SwiftUI project created
- [x] Set up proper project structure with organized folders
- [ ] Configure app permissions for file access

### 1.2 Main UI Layout

- [x] Create main canvas view with scrollable/zoomable area
- [x] Implement basic toolbar/sidebar for controls
- [ ] Set up status bar for grid information
- [x] Create basic navigation structure

## Phase 2: Image Management

### 2.1 Image Import System

- [x] Implement file picker for single image import
- [x] Add support for multiple image selection
- [x] Create image display on canvas with proper scaling
- [ ] Add drag & drop functionality for images

### 2.2 Canvas Management

- [x] Implement zoom in/out functionality
- [x] Add pan/scroll for large images
- [ ] Create image positioning system (drag to move)
- [ ] Implement non-overlapping placement for batch imports
- [ ] Add image deletion/removal functionality

## Phase 3: Grid System (Core Feature)

### 3.1 Basic Grid Creation

- [x] Implement click-and-drag grid creation
- [x] Create visual grid overlay with adjustable cells
- [x] Add grid resize handles (corner/edge dragging)
- [x] Implement grid deletion functionality

### 3.2 Grid Properties & Management

- [x] Create grid data model with unique IDs
- [x] Implement thickness property (border removal)
- [x] Add floating name tags for each grid
- [x] Create grid selection system (active/inactive states)

### 3.3 Grid Editing Interface

- [x] Mouse dragging for grid adjustment
- [x] Number input fields for precise positioning
- [x] Batch editing for multiple grids
- [ ] Grid duplication functionality

## Phase 4: Advanced Grid Features

### 4.1 Grid Customization

- [ ] Variable cell sizes within same grid
- [ ] Custom grid shapes (future feature placeholder)
- [ ] Grid templates/presets
- [ ] Grid snapping to image features

### 4.2 Grid Visual Enhancements

- [ ] Color coding for different grids
- [ ] Visual feedback for active/selected grids
- [ ] Grid opacity controls
- [ ] Preview mode (hide/show grids)

## Phase 5: Slicing Engine

### 5.1 Core Slicing Logic

- [ ] Calculate cell boundaries for each grid
- [ ] Extract image regions based on grid cells
- [ ] Apply thickness adjustments (border removal)
- [ ] Handle different output resolutions

### 5.2 Output Options

- [ ] Original resolution output
- [ ] Scaled resolution options
- [ ] Current visual pixel size option
- [ ] Quality/format settings (PNG, JPG, etc.)

## Phase 6: File Management & Export

### 6.1 Project Saving

- [ ] Create custom project file format (.mojislice?)
- [ ] Save canvas state (images, grids, settings)
- [ ] Implement project loading
- [ ] Auto-save functionality

### 6.2 Export System

- [ ] Directory selection for output
- [ ] Naming convention system (grid-based)
- [ ] Batch export for all grids
- [ ] Individual grid export
- [ ] Progress tracking for large exports

## Phase 7: User Experience Enhancements

### 7.1 Interface Improvements

- [ ] Keyboard shortcuts
- [ ] Context menus (right-click)
- [ ] Undo/Redo functionality
- [ ] Tooltips and help system

### 7.2 Performance Optimization

- [ ] Efficient image rendering for large files
- [ ] Background processing for exports
- [ ] Memory management for multiple images
- [ ] Responsive UI during operations

## Technical Architecture

### Data Models

```swift
// Core data structures needed:
struct GridModel {
    let id: UUID
    var name: String
    var frame: CGRect
    var rows: Int
    var columns: Int
    var thickness: Double
    var color: Color
}

struct CanvasImage {
    let id: UUID
    var image: NSImage
    var position: CGPoint
    var scale: Double
}

struct Project {
    var images: [CanvasImage]
    var grids: [GridModel]
    var canvasSize: CGSize
    var metadata: ProjectMetadata
}
```

### Key Views

- `CanvasView`: Main drawing area with zoom/pan
- `GridOverlayView`: Handles grid rendering and interaction
- `ToolbarView`: Controls and settings
- `PropertiesPanel`: Grid editing interface
- `ExportView`: Output configuration and progress

### Key Controllers

- `ImageManager`: Handles image import/export
- `GridManager`: Grid creation and manipulation
- `SlicingEngine`: Core slicing logic
- `ProjectManager`: Save/load functionality

## Development Priorities

### Must-Have (v1.0)

1. Image import and display
2. Basic grid creation and editing
3. Simple slicing and export
4. Project save/load

### Should-Have (v1.1)

1. Multiple image support
2. Grid thickness adjustments
3. Batch operations
4. Improved UI/UX

### Nice-to-Have (v1.2+)

1. Custom grid shapes
2. Advanced export options
3. Keyboard shortcuts
4. Auto-grid detection

## File Structure Recommendation

```
Moji Slicer/
├── Models/
│   ├── GridModel.swift
│   ├── CanvasImage.swift
│   └── Project.swift
├── Views/
│   ├── CanvasView.swift
│   ├── GridOverlayView.swift
│   ├── ToolbarView.swift
│   └── ExportView.swift
├── Controllers/
│   ├── ImageManager.swift
│   ├── GridManager.swift
│   └── SlicingEngine.swift
├── Utilities/
│   ├── FileManager+Extensions.swift
│   └── CGRect+Extensions.swift
└── Resources/
    └── (assets, sounds, etc.)
```

## Next Steps

1. Start with Phase 1.2 - Create the main UI layout
2. Implement basic image import (Phase 2.1)
3. Build core grid creation system (Phase 3.1)
4. Add basic slicing functionality (Phase 5.1)

This plan provides a structured approach to building your emoji slicer app, breaking down complex features into manageable chunks while maintaining focus on the core functionality you need.
