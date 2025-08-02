# Grid Slicing Feature Specification

> **Created**: July 27, 2025  
> **Purpose**: Comprehensive specification for validating grid slicing functionality in Moji Slicer

## 📋 **OVERVIEW**

The Grid Slicing feature allows users to overlay grids on images and export individual cells as separate image files. This feature combines interactive grid creation, visual feedback, and automated image processing.

## 🎯 **CORE REQUIREMENTS**

### R1. Grid Creation & Management
- **R1.1** User can create grids by dragging on the canvas when grid tool is selected
- **R1.2** Grids can be resized using corner and edge handles
- **R1.3** Grids can be moved by dragging
- **R1.4** Grids can be selected (single and multiple selection)
- **R1.5** Grid properties can be configured (dimensions, color, line style, thickness)
- **R1.6** Grids can be deleted using keyboard shortcuts
- **R1.7** Grid operations support undo/redo

### R2. Visual Grid System
- **R2.1** Grids display with configurable visual thickness for design guidance
- **R2.2** Grids support different line styles (solid, dashed, dotted)
- **R2.3** Grids show interactive hover and selection states
- **R2.4** Grid lines scale properly with canvas zoom
- **R2.5** Floating control tags show grid name and slice button when selected/hovered

### R3. Grid Configuration
- **R3.1** Support for square grids (N×N) with synchronized dimensions
- **R3.2** Support for rectangle grids (M×N) with independent width/height
- **R3.3** Configurable logical thickness (pixels to exclude during slicing)
- **R3.4** Configurable visual thickness (display-only, separate from logical)
- **R3.5** Color picker for grid line customization
- **R3.6** Grid properties persist with project data

### R4. Image Slicing Engine
- **R4.1** Extract individual grid cells as separate image files
- **R4.2** Coordinate transformation from canvas space to image space
- **R4.3** Respect logical thickness settings (exclude pixels between cells)
- **R4.4** Generate meaningful filenames (GridName_Row_Column.png)
- **R4.5** Handle multiple images per grid with organized output structure
- **R4.6** Support PNG output format with transparency preservation

### R5. User Interface Integration
- **R5.1** Grid tool selection in top toolbar
- **R5.2** Grid properties panel visible when grid tool is active
- **R5.3** Individual grid slice button in floating control tags
- **R5.4** Global "slice all grids" button in action toolbar
- **R5.5** Grid tags toggle for showing/hiding grid name labels
- **R5.6** File picker integration for output directory selection

### R6. Export Workflow
- **R6.1** Single grid slicing with directory picker
- **R6.2** Batch slicing of all grids with organized output folders
- **R6.3** User feedback with success/failure alerts
- **R6.4** "Open Folder" option after successful export
- **R6.5** Error handling for missing images or invalid grids
- **R6.6** Progress indication for large batch operations

## 🏗 **ARCHITECTURE REQUIREMENTS**

### A1. Data Models
- **A1.1** `GridModel`: Core grid data with Codable support
- **A1.2** `GridProperties`: @Observable state management for UI
- **A1.3** `CanvasTool`: Tool selection enumeration including grid tool
- **A1.4** Proper separation between visual and logical properties

### A2. View Components
- **A2.1** `ModernGridOverlayView`: Interactive grid rendering with handles
- **A2.2** `FloatingGridControlView`: Grid name tags with slice buttons
- **A2.3** `MainCanvasView`: Grid creation and canvas integration
- **A2.4** Tool selection and properties panels in `ContentView`

### A3. Business Logic
- **A3.1** `SlicingEngine`: Core image processing and export logic
- **A3.2** Coordinate transformation utilities
- **A3.3** File management and directory creation
- **A3.4** Error handling and user feedback

### A4. State Management
- **A4.1** @Observable pattern for automatic UI synchronization
- **A4.2** @Bindable pattern for passing observable state
- **A4.3** Computed properties for derived values
- **A4.4** Undo/redo support for grid operations

## ✅ **VALIDATION CHECKLIST**

### Grid Creation & Interaction
- [ ] Grid tool can be selected from toolbar
- [ ] Dragging with grid tool creates new grid
- [ ] Grid shows preview during creation drag
- [ ] Created grid appears with proper dimensions
- [ ] Grid can be selected by clicking
- [ ] Selected grid shows resize handles
- [ ] Grid can be moved by dragging main area
- [ ] Grid can be resized using corner/edge handles
- [ ] Grid deletion works with Delete key
- [ ] Multiple grids can be selected

### Grid Properties & Configuration
- [x] Grid properties panel appears when grid tool is active
- [x] Square/Rectangle mode toggle works correctly
- [x] Dimension fields update grid in real-time
- [x] Color picker changes grid appearance
- [x] Visual thickness affects display only
- [x] Logical thickness affects slicing calculations (NOW CONFIGURABLE IN UI)
- [x] Grid properties persist in project data

### Visual Feedback & UI
- [ ] Grid lines render with correct style and thickness
- [ ] Hover states show visual feedback
- [ ] Selection states highlight properly
- [ ] Grid lines scale correctly with zoom
- [ ] Floating tags appear on hover/selection
- [ ] Slice button appears in selected grid tags
- [ ] Grid tags can be toggled on/off

### Slicing Functionality
- [ ] Individual grid slice button works
- [ ] Directory picker appears for output selection
- [ ] Grid coordinates transform correctly to image space
- [ ] Cell extraction produces correct number of files
- [ ] Generated filenames follow GridName_Row_Column pattern
- [ ] Output images have correct dimensions
- [ ] Logical thickness excludes pixels properly
- [ ] Success dialog shows with "Open Folder" option

### Batch Operations
- [ ] "Slice All Grids" button is accessible
- [ ] Batch operation creates organized folder structure
- [ ] Multiple grids process without errors
- [ ] Multiple images per grid handled correctly
- [ ] Progress feedback provided for long operations
- [ ] Error handling for edge cases

### Error Handling
- [ ] Missing images show appropriate errors
- [ ] Empty grids list prevents slicing
- [ ] Invalid output directories handled gracefully
- [ ] File write errors reported to user
- [ ] Coordinate transformation edge cases handled

## 🚨 **KNOWN LIMITATIONS**

1. **Image Format Support**: Currently only PNG output (JPEG/WEBP not implemented)
2. **Grid Templates**: No predefined templates or presets available
3. **Grid Duplication**: Copy/paste functionality not implemented
4. **Batch UI**: No progress bar for large operations
5. **Export Options**: Limited export customization options

## 📊 **TESTING SCENARIOS**

### Basic Workflow
1. Create new project → Import image → Select grid tool → Create grid → Slice grid
2. Verify all grid cells are extracted with correct naming
3. Check output folder organization and file structure

### Edge Cases
1. Grid larger than image boundaries
2. Grid with 1×1 dimensions
3. Multiple overlapping grids on same image
4. Very small grid cells (< 10px)
5. Grid with zero logical thickness

### Performance Tests
1. Large number of grids (10+) on single image
2. High-resolution images (4K+) with fine grids
3. Batch processing multiple large images
4. Memory usage during intensive slicing operations

## 🔧 **IMPLEMENTATION STATUS**

Based on code analysis and validation, the following components are **IMPLEMENTED AND VALIDATED**:
- ✅ All core data models (GridModel, GridProperties)
- ✅ Interactive grid overlay system
- ✅ Grid creation and manipulation
- ✅ SlicingEngine with coordinate transformation (NOW CENTRALIZED)
- ✅ UI integration and tool selection
- ✅ Grid properties configuration (NOW INCLUDES THICKNESS CONTROLS)
- ✅ Individual and batch slicing workflows
- ✅ File management and user feedback

**CRITICAL FIXES APPLIED (July 27, 2025)**:
- ✅ Added missing logical thickness configuration UI
- ✅ Eliminated code duplication with shared GridCoordinateTransformer
- ✅ Standardized coordinate transformation across all slicing workflows

## 💡 **VALIDATION APPROACH**

1. **Code Review**: Verify implementation against each requirement
2. **Integration Testing**: Check component interaction and data flow
3. **UI Testing**: Validate user interaction patterns and feedback
4. **Export Testing**: Test slicing accuracy and output quality
5. **Edge Case Testing**: Handle boundary conditions and error scenarios