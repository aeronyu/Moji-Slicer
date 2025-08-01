# GitHub Copilot Instructions for Moji Slicer

> **Moji Slicer**: macOS image slicing app with modern SwiftUI + @Observable architecture

# Apply these instructions to all Swift/SwiftUI files

applyTo:

- "\*_/_.swift"

# Core Architecture

- **Models/Core/**: Data models (Project, CanvasImage, GridModel)
- **Models/UI/**: @Observable state classes (GridProperties, UndoManager)
- **Views/Screens/**: Full layouts (ContentView, AllBoardsView, MainCanvasView)
- **Views/Components/**: Reusable UI (ModernGridOverlayView, toolbars)
- **Views/Sheets/**: Modals (GridSettingsSheet, NewProjectSheet)

# Swift 6.1.2+ Patterns

- Use `@Observable` classes for complex state, `@Bindable` for passing them
- Leverage computed properties for automatic synchronization (no manual sync methods)
- Project-centric workflow: everything revolves around Project entities with images and grids

# Documentation Update Protocol

**When completing features or fixing bugs, ALWAYS update:**

1. **README.md**: "Known Issues Being Addressed" section
2. **planning/STATUS_TRACKING.md**: Move items between COMPLETED/IN PROGRESS/PENDING
3. **Relevant planning/[feature].md files**: Update specific feature status
4. **.github/prompts/copilot.prompt.md**: Update task scope if needed

**Reference Resources:**

- **planning/STATUS_TRACKING.md**: Source of truth for what's implemented vs. pending
- **screenshots/ folder**: Mock UI designs, latest app screenshots, reference images
- **macos_automator tool**: Live UI inspection when app is running
- **Fallback**: Use screenshots when macos_automator cannot access working UI

**Planning Documents Structure:**

```
planning/
├── STATUS_TRACKING.md         # Master status tracking (ALWAYS CHECK FIRST)
├── grid-system.md            # Grid overlay feature planning
├── image-management.md       # Image import/export planning
├── export-pipeline.md        # Slicing engine implementation
├── canvas-interactions.md    # Pan/zoom/selection features
└── ui-polish.md             # Production readiness tasks
```

# Tool-use guidelines

toolInstructions:
macos_automator:
description: >
Whenever you need to inspect or manipulate the macOS app’s UI,
call the `macos_automator` tool.
sequentialthinking:
description: >
For any multi-step reasoning or planning, invoke the `sequentialthinking` tool.
context7:
description: >
To look up up-to-date Swift/SwiftUI docs or code examples,
invoke the `context7` tool.
memory:
description: >
To store or retrieve conversation state (e.g. user preferences, prior answers),
invoke the `memory` tool.
sequential-thinking:
description: >
Alias for `sequentialthinking`; use interchangeably for planning tasks.
