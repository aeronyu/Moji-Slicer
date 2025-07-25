# Moji Slicer

A SwiftUI app for slicing grid-based emoji/meme images into individual pieces with adjustable grids and batch processing capabilities.

## 🎉 Latest Updates - Document-Style UI

### New UI Architecture

- **Left Sidebar**: Project organizer (replace tools panel)
- **Top Toolbar**: Document-style tools (Grid, Select, Label tools)
- **Infinite Canvas**: No size restrictions, pan and zoom freely
- **Floating Grid Controls**: Compact tags with slice buttons

### New Grid Creation Workflow

1. **Select Grid Tool**: Click the grid icon in top toolbar
2. **Configure Grid**: Set rows/columns, line style, thickness, color, and tag name
3. **Create Grid**: Click and drag anywhere on canvas (like drawing a shape)
4. **Adjust**: Use resize handles or move the grid as needed
5. **Individual Slice**: Use the scissors button on the floating grid tag

### Key Features

- ✅ **Document-style tool selection** (Select, Grid, Label)
- ✅ **Grid line styles** (Solid, Dashed, Dotted)
- ✅ **Floating grid tags** with slice buttons
- ✅ **Infinite canvas** with background grid
- ✅ **Project organization** with multiple projects
- ✅ **Center-based image import** (images start from canvas center)
- ✅ **Global slice button** (knife icon) with directory selection

## Current Status

✅ **Phase 1 Complete**: Modern UI Foundation

- Main canvas with zoom/pan functionality
- Sidebar with grid management tools
- Navigation split view layout

✅ **Phase 2 Partial**: Image Management

- Image import via file picker
- Multiple image selection support
- Image display on canvas with scaling

✅ **Phase 3 Mostly Complete**: Grid System

- Click-and-drag grid creation (Hold ⌥ + drag)
- Visual grid overlay with cell divisions
- Grid resize handles for adjustment
- Grid properties panel (name, dimensions, thickness, color)
- Grid selection and management

## How to Use

### Setting Up the Project

1. **Add New Files to Xcode**: You'll need to add the newly created files to your Xcode project:

   - Right-click on "Moji Slicer" group in Xcode
   - Select "Add Files to 'Moji Slicer'"
   - Navigate to and select these folders:
     - `Models/` (GridModel.swift, CanvasImage.swift)
     - `Views/` (SidebarView.swift, CanvasView.swift, GridOverlayView.swift)
     - `Controllers/` (SlicingEngine.swift)
     - `Utilities/` (Extensions.swift)

2. **Build and Run**: Press Cmd+R to build and run the app

### Using the App

#### Project Management

1. **Create Project**: Click "+" in the left sidebar to create a new project
2. **Switch Projects**: Click on any project in the sidebar to switch to it
3. **Project Info**: See image count and grid count for each project

#### Importing Images

1. Click "Import" in the top toolbar
2. Select one or multiple image files
3. Images will appear at the center of the canvas
4. Multiple images are offset slightly to avoid overlap

#### Creating Grids (New Workflow!)

1. **Select Grid Tool**: Click the grid icon in the top toolbar
2. **Configure Grid**:
   - Set grid size (rows × columns)
   - Choose line style (solid, dashed, dotted)
   - Adjust thickness slider
   - Pick color with color picker
   - Optionally enter a tag name
3. **Create Grid**: Click and drag on the canvas to create the grid
4. **Adjust Grid**:
   - Drag to move the entire grid
   - Use resize handles (circles) to adjust size
   - Click to select and see properties

#### Grid Management

1. **Floating Tags**: Hover over grids to see their tags
2. **Individual Slice**: Click the scissors icon on a selected grid's tag
3. **Hide/Show Tags**: Use the tag button in the top toolbar
4. **Select Mode**: Switch to select tool to interact with grids and images

#### Canvas Navigation

- **Pan**: Use select tool and drag empty canvas areas
- **Zoom**: Mouse wheel or trackpad gestures
- **Infinite Canvas**: No boundaries - pan anywhere you need

## Architecture

### Data Models

- **GridModel**: Represents a slicing grid with position, dimensions, and properties
- **CanvasImage**: Represents imported images with position and scale

### Views

- **ContentView**: Main app container with split view
- **SidebarView**: Left panel with tools and grid management
- **CanvasView**: Main drawing area with zoom/pan
- **GridOverlayView**: Individual grid rendering and interaction

### Controllers

- **SlicingEngine**: Handles the actual image slicing logic (WIP)

## What's Next

### Immediate Improvements Needed

1. **Add files to Xcode project** - The new Swift files need to be added to the Xcode project
2. **Fix compilation errors** - Some imports or dependencies might need adjustment
3. **Test basic functionality** - Import images and create grids

### Phase 4: Advanced Features (Planned)

- Drag & drop for images
- Individual image positioning
- Project save/load functionality
- Export/slicing implementation
- Keyboard shortcuts
- Undo/redo functionality

## Known Issues

- Files need to be manually added to Xcode project
- Some drag gestures might conflict (grid creation vs canvas pan)
- Image positioning system not yet implemented
- Export functionality is placeholder

## Getting Started

1. Add the new files to your Xcode project
2. Build and run (Cmd+R)
3. Import some emoji grid images
4. Hold ⌥ and drag to create grids
5. Experiment with grid editing in the sidebar

The foundation is solid and ready for the next phase of development!
