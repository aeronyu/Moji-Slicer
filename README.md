# Moji Slicer

> **Modern macOS image slicing app with SwiftUI + @Observable architecture**

**Moji Slicer** is a modern macOS SwiftUI app for slicing grid-based images (emojis, memes) into individual pieces. Think "image slicer with intelligent grid overlays and batch processing."

## 📥 Installation

### Download from Releases (Recommended)

1. Go to [Releases](../../releases)
2. Download the latest `Moji Slicer-YYYYMMDD.zip`
3. Unzip and drag `Moji Slicer.app` to your `/Applications` folder
4. Launch the app

### Build from Source

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/moji-slicer.git
cd moji-slicer

# Build release version
./scripts/build-release.sh

# Or build in Xcode
open "Moji Slicer.xcodeproj"
```

## 🚀 Project Overview

## 🏗 Architecture At-a-Glance

### Key Files to Read First

1. **`.github/copilot-instructions.md`** - Your coding standards and patterns
2. **`README.md`** - Project structure and current status
3. **`ContentView.swift`** - Root coordinator and app flow
4. **`Models/Core/Project.swift`** - Core data model
5. **`Models/UI/GridProperties.swift`** - Modern @Observable state management

### Folder Structure (Critical)

```
Models/Core/     # Business data (Project, CanvasImage, GridModel)
Models/UI/       # State management (@Observable classes)
Views/Screens/   # Main layouts (ContentView, AllBoardsView, MainCanvasView)
Views/Components/ # Reusable pieces (toolbars, overlays, controls)
Views/Sheets/    # Modals and dialogs
Controllers/     # Business logic (SlicingEngine)
```

### Current Project Structure (July 27, 2025)

```
Moji Slicer/
├── README.md                          # Updated project documentation
├── planning/                          # Feature-specific planning files
├── screenshots/                       # UI screenshots
├── Moji Slicer/                       # Main App Target
│   ├── ContentView.swift              # Root coordinator (simplified)
│   ├── Moji_SlicerApp.swift          # App entry point
│   ├── Models/                        # Data models (organized)
│   │   ├── Core/                      # Core business models
│   │   │   ├── Project.swift          # Project data model
│   │   │   ├── CanvasImage.swift      # Image representation
│   │   │   └── GridModel.swift        # Grid configuration
│   │   └── UI/                        # UI-specific models
│   │       ├── CanvasTool.swift       # Tool selection
│   │       └── GridProperties.swift   # Grid properties
│   ├── Views/                         # UI components (organized)
│   │   ├── Screens/                   # Main application screens
│   │   │   ├── AllBoardsView.swift    # Project list screen
│   │   │   └── MainCanvasView.swift   # Main canvas screen
│   │   ├── Components/                # Reusable UI components
│   │   │   ├── Canvas/                # Canvas-related components
│   │   │   │   ├── ModernGridOverlayView.swift  # Grid rendering
│   │   │   │   ├── ZoomControlView.swift        # Canvas controls
│   │   │   │   └── SampleGridView.swift         # Empty state
│   │   │   └── Toolbars/              # Toolbar components
│   │   │       ├── FloatingToolbarView.swift   # Floating toolbar
│   │   │       ├── TopToolbarView.swift        # Top toolbar
│   │   │       └── SidebarView.swift           # Left sidebar
│   │   └── Sheets/                    # Modal sheets
│   │       └── NewProjectSheet.swift  # New project creation
│   ├── Controllers/                   # Business logic
│   │   └── SlicingEngine.swift        # Core slicing functionality
│   ├── Utilities/                     # Helper extensions
│   │   └── Extensions.swift           # SwiftUI extensions
│   └── Assets.xcassets/               # App icons & assets
├── Moji SlicerTests/                  # Unit tests
└── Moji SlicerUITests/                # UI tests
```

## 🎯 Current State (July 2025)

### ✅ What Works

- **Modern SwiftUI Architecture**: @Observable classes, Swift 6.1.2+ patterns
- **Project Management**: Create/load/switch between projects
- **Image Import**: Multi-image selection with proper data handling
- **Canvas Navigation**: Pan, zoom, infinite canvas
- **Grid System**: Interactive overlays with resize handles
- **UI Organization**: Clean component hierarchy

### 🔧 What's In Progress

- **Export Pipeline**: SlicingEngine integration (mostly complete)
- **Grid Creation Workflow**: Tool selection and interaction refinement
- **UI Polish**: Final touches for production readiness

## 🧠 Key Patterns to Follow

### State Management

```swift
// ✅ Use @Observable for complex state
@Observable class GridProperties { ... }

// ✅ Pass with @Bindable
struct View: View {
    @Bindable var gridProperties: GridProperties
}
```

### Architecture Rules

- **Models/Core/** = Business logic, Codable, no UI dependencies
- **Models/UI/** = State management, @Observable classes, UI interactions
- **Computed Properties** = Single source of truth (no manual sync methods)
- **Project-Centric** = Everything revolves around Project entities

### File Naming

- **Views**: End in "View" (`ModernGridOverlayView`)
- **Sheets**: End in "Sheet" (`GridSettingsSheet`)
- **Models**: Business names (`Project`, `CanvasImage`)

## 🔍 Common Tasks & Where to Look

### Adding New Features

1. **Data Model**: Start in `Models/Core/`
2. **State Management**: Add to existing `@Observable` classes in `Models/UI/`
3. **UI Components**: Create in appropriate `Views/` subfolder
4. **Integration**: Wire up in `MainCanvasView` or `ContentView`

### Debugging Issues

- **Image Moving**: Check `MainCanvasView` drag gestures and position calculations
- **Image Resizing (Fixed Ratio)**: Look at `CanvasImage` scale property and proportional scaling
- **Image Resizing (Free Form)**: Check independent width/height scaling in canvas interactions
- **PNG Handling**: Verify `NSImage.pngData` extension and `CanvasImage` data storage
- **Grid Interaction**: Look at `ModernGridOverlayView` resize handles and drag support
- **State Sync**: Verify `@Observable` computed properties in `GridProperties`
- **Canvas Issues**: Check `MainCanvasView` gesture handling and coordinate transformations

### Tool Integration

- **Canvas Tools**: Extend `CanvasTool` enum, update `MainCanvasView`
- **UI Controls**: Add to appropriate toolbar in `Views/Components/Toolbars/`
- **Business Logic**: Implement in `Controllers/SlicingEngine.swift`

## 🎯 Quick Wins for New AI Assistant

### Immediate Understanding (5 minutes)

1. Read `.github/copilot-instructions.md` for coding patterns
2. Scan `ContentView.swift` to understand app flow
3. Check `Models/Core/Project.swift` for data structure
4. Look at `MainCanvasView.swift` for main interactions

### Getting Productive (15 minutes)

1. Understand `@Observable GridProperties` pattern
2. See how `ModernGridOverlayView` handles interactions
3. Check tool system in `CanvasTool.swift`
4. Review component hierarchy in `Views/` folders

### Expert Level (30 minutes)

1. Study `SlicingEngine.swift` for business logic
2. Understand canvas coordinate system and transformations
3. See animation patterns in grid overlay components
4. Review error handling and validation approaches

## 🚨 What NOT to Do

- ❌ **Don't add manual sync methods** - Use @Observable computed properties
- ❌ **Don't break Models/Core vs UI separation** - Keep business logic clean
- ❌ **Don't skip the copilot-instructions.md** - It has your coding standards
- ❌ **Don't create new architectural patterns** - Follow established structure

## � Planning & Documentation Strategy

### Feature-Specific Planning Documents

The `planning/` folder contains feature-specific planning files for better tracking:

```
planning/
├── STATUS_TRACKING.md        # Master status tracking (source of truth)
├── grid-system.md            # Grid overlay feature planning
├── image-management.md       # Image import/export planning
├── export-pipeline.md        # Slicing engine implementation
├── canvas-interactions.md    # Pan/zoom/selection features
└── ui-polish.md             # Production readiness tasks
```

### Visual Reference Resources

- **`screenshots/` folder**: Mock UI designs, latest app screenshots, reference images
- **`macos_automator` tool**: Live UI inspection when app is running
- **Fallback**: Use screenshots when `macos_automator` cannot access working UI

**Workflow**: Always update README.md status when features are completed or new issues arise.

## �💡 Pro Tips

- **Always check existing copilot-instructions.md first** - Your patterns are documented
- **Use semantic_search tool** - Find examples of similar functionality
- **Follow @Observable patterns** - They're your architectural foundation
- **Test on real projects** - App has sample data for quick testing
- **Check git history** - Recent modernization work shows best practices

## How to Use

### Project Management

1. **All Boards View**: Default view showing all your projects
2. **Create Project**: Use sample projects or create new ones
3. **Switch Projects**: Click on any project to enter its canvas
4. **Navigate Back**: Use the back button to return to All Boards

### Importing Images

1. Click the image import button in the top toolbar (photo icon)
2. Select one or multiple image files
3. Images will appear at the center of the canvas with debug information
4. Multiple images are offset slightly to avoid overlap

### Canvas Navigation

- **Pan**: Drag to move around the infinite canvas
- **Zoom**: Use mouse wheel or trackpad gestures
- **Reset View**: Click "Fit to Window" in zoom controls

### Grid System (Work in Progress)

- Grid creation and editing functionality is implemented
- Tools are available in the top toolbar
- Individual grid manipulation through modern overlay system

## Architecture

### Data Models (Models/Core/)

- **Project**: Represents a project with images and grids
- **CanvasImage**: Represents imported images with position and scale
- **GridModel**: Represents slicing grids with properties and positioning

### UI Models (Models/UI/)

- **CanvasTool**: Tool selection enumeration
- **GridProperties**: Grid configuration settings

### Views Architecture

- **Screens/**: Main application screens (AllBoardsView, MainCanvasView)
- **Components/**: Reusable UI components organized by category
- **Sheets/**: Modal dialogs and sheets

### Controllers

- **SlicingEngine**: Core image slicing logic (work in progress)

## 🎮 Quick Start Commands

```bash
# Open project in Xcode
open "Moji Slicer.xcodeproj"

# Key files to examine
code .github/copilot-instructions.md
code ContentView.swift
code Models/Core/Project.swift
code Models/UI/GridProperties.swift
```

## Development Status & Next Steps

### Immediate Priorities

1. **Test Current Functionality**: Verify image import and basic navigation
2. **Grid Implementation**: Complete grid creation and editing workflow
3. **Export System**: Implement actual image slicing and export
4. **Polish UI**: Refine user experience and visual consistency

### Known Issues Being Addressed

- **Deprecated API Warnings**: Fix `onChange` modifier warnings for macOS 14.0+ compatibility
- **Sandbox Permissions**: Add proper sandboxed file write permissions for export functionality
- **Performance Optimization**: Optimize rendering performance for large numbers of grids

---

**TL;DR**: Modern SwiftUI app with @Observable architecture. Read copilot-instructions.md for patterns, ContentView.swift for flow, Project.swift for data model. Follow Models/Core vs UI separation. Everything centers around Project entities.
