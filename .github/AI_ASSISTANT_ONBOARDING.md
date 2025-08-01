# AI Assistant Onboarding Guide - Moji Slicer

> **Quick Start**: Everything a new AI assistant needs to understand this project in one conversation

## 🚀 Project Overview

**Moji Slicer** is a modern macOS SwiftUI app for slicing grid-based images (emojis, memes) into individual pieces. Think "image slicer with intelligent grid overlays and batch processing."

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

- **Image Import**: Check `ContentView.handleImageImport`
- **Grid Interaction**: Look at `ModernGridOverlayView`
- **State Sync**: Verify `@Observable` computed properties
- **Canvas Issues**: Check `MainCanvasView` gesture handling

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

## 💡 Pro Tips

- **Always check existing copilot-instructions.md first** - Your patterns are documented
- **Use semantic_search tool** - Find examples of similar functionality
- **Follow @Observable patterns** - They're your architectural foundation
- **Test on real projects** - App has sample data for quick testing
- **Check git history** - Recent modernization work shows best practices

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

---

**TL;DR**: Modern SwiftUI app with @Observable architecture. Read copilot-instructions.md for patterns, ContentView.swift for flow, Project.swift for data model. Follow Models/Core vs UI separation. Everything centers around Project entities.
