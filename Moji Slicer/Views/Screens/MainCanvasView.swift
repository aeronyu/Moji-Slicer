//
//  MainCanvasView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI
import AppKit

struct MainCanvasView: View {
    @Binding var images: [CanvasImage]
    @Binding var grids: [GridModel]
    @Binding var scale: Double
    @Binding var offset: CGSize
    @Binding var selectedTool: CanvasTool
    @Bindable var gridProperties: GridProperties  // Changed to @Bindable for @Observable
    @Binding var showGridTags: Bool
    @Binding var selectedGridID: UUID?
    
    @StateObject private var undoManager = CanvasUndoManager()
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var isCreatingGrid = false
    @State private var gridStartPoint: CGPoint = .zero
    @State private var gridCurrentPoint: CGPoint = .zero
    
    @State private var hoveredGridID: UUID?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                canvasBackground
                canvasContent(geometry: geometry)
            }
            .gesture(createCanvasGesture(geometry: geometry))
            .onTapGesture { location in
                handleCanvasTap(at: location)
            }
            .onHover { isHovering in
                // Set appropriate cursor based on tool
                if isHovering {
                    switch selectedTool {
                    case .select:
                        NSCursor.openHand.set()
                    case .grid:
                        NSCursor.crosshair.set()
                    default:
                        NSCursor.arrow.set()
                    }
                } else {
                    NSCursor.arrow.set()
                }
            }
        }
        .focusable()
        .onKeyPress(.delete) {
            print("🗑️ Delete key pressed")
            print("   Grid count: \(grids.count)")
            print("   Selected grid ID: \(selectedGridID?.uuidString ?? "none")")
            
            // Print all grid selection states
            for (index, grid) in grids.enumerated() {
                print("   Grid \(index): \(grid.name) - isSelected: \(grid.isSelected), ID: \(grid.id.uuidString)")
            }
            
            // Try multiple approaches to find selected grid
            var selectedGridIndex: Int?
            
            // Method 1: Find by selectedGridID
            if let selectedID = selectedGridID {
                selectedGridIndex = grids.firstIndex { $0.id == selectedID }
                print("📍 Method 1 (selectedGridID): Found index \(selectedGridIndex?.description ?? "none")")
            }
            
            // Method 2: Find by isSelected flag
            if selectedGridIndex == nil {
                selectedGridIndex = grids.firstIndex { $0.isSelected }
                print("📍 Method 2 (isSelected): Found index \(selectedGridIndex?.description ?? "none")")
            }
            
            // Method 3: Use any visible/hovered grid as fallback
            if selectedGridIndex == nil && hoveredGridID != nil {
                selectedGridIndex = grids.firstIndex { $0.id == hoveredGridID }
                print("📍 Method 3 (hoveredGridID): Found index \(selectedGridIndex?.description ?? "none")")
            }
            
            if let index = selectedGridIndex {
                let selectedGrid = grids[index]
                print("✅ Deleting grid: \(selectedGrid.name) at index \(index)")
                
                // Record undo action
                undoManager.recordAction(.removeGrid(selectedGrid, at: index))
                
                // Remove the grid with animation
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    grids.remove(at: index)
                    
                    // Clear selection
                    selectedGridID = nil
                    hoveredGridID = nil
                }
                
                print("✅ Grid deleted successfully. Remaining count: \(grids.count)")
                return .handled
            } else {
                print("❌ No selected grid found for deletion")
                
                // Debug: Force select the first grid if any exist
                if !grids.isEmpty {
                    print("🔧 Debug: Force selecting first grid")
                    selectedGridID = grids[0].id
                    grids[0].isSelected = true
                    return .handled
                }
                
                return .ignored
            }
        }
        .onKeyPress(.init("z")) {
            if NSEvent.modifierFlags.contains(.command) && NSEvent.modifierFlags.contains(.shift) {
                var tempGrids = grids
                var tempImages = images
                if undoManager.redo(grids: &tempGrids, images: &tempImages) {
                    grids = tempGrids
                    images = tempImages
                }
                return .handled
            } else if NSEvent.modifierFlags.contains(.command) {
                var tempGrids = grids
                var tempImages = images
                if undoManager.undo(grids: &tempGrids, images: &tempImages) {
                    grids = tempGrids
                    images = tempImages
                }
                return .handled
            }
            return .ignored
        }
    }
    
    // MARK: - View Components
    
    private var canvasBackground: some View {
        Color.white
            .ignoresSafeArea()
    }
    
    private func canvasContent(geometry: GeometryProxy) -> some View {
        ZStack {
            // COORDINATE SYSTEM: (0,0) is at canvas center
            // - Positive X: right of center
            // - Positive Y: below center  
            // - Negative X: left of center
            // - Negative Y: above center
            
            debugOverlay
            imagesLayer(geometry: geometry)
            gridsLayer(geometry: geometry)
            gridCreationPreview(geometry: geometry)
        }
    }
    
    private var debugOverlay: some View {
        Color.clear
            .onAppear {
                print("🖼️ Canvas displaying \(images.count) images")
                print("🔧 Current tool: \(selectedTool.rawValue)")
                print("📏 Current scale: \(scale), offset: \(offset)")
                if images.isEmpty {
                    print("   No images to display")
                } else {
                    for (index, img) in images.enumerated() {
                        print("   Image \(index + 1): \(img.imageName) - has data: \(img.image != nil)")
                    }
                }
            }
    }
    
    private func imagesLayer(geometry: GeometryProxy) -> some View {
        ForEach(images) { canvasImage in
            if let nsImage = canvasImage.image {
                imageView(canvasImage: canvasImage, nsImage: nsImage, geometry: geometry)
            } else {
                missingImagePlaceholder(canvasImage: canvasImage, geometry: geometry)
            }
        }
    }
    
    private func imageView(canvasImage: CanvasImage, nsImage: NSImage, geometry: GeometryProxy) -> some View {
        Image(nsImage: nsImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: canvasImage.size.width * scale,
                height: canvasImage.size.height * scale
            )
            .position(
                // Center-based coordinate system: (0,0) is at canvas center
                x: geometry.size.width / 2 + (canvasImage.position.x * scale) + offset.width,
                y: geometry.size.height / 2 + (canvasImage.position.y * scale) + offset.height
            )
            .border(Color.green, width: 2) // Debug border to see image bounds
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if selectedTool == .select {
                            // Move image logic here
                        }
                    }
            )
            .onAppear {
                print("✅ Rendering image: \(canvasImage.imageName)")
                print("   Position: \(canvasImage.position)")
                print("   Size: \(canvasImage.size)")
                print("   Scale: \(scale)")
                print("   Final frame size: \(canvasImage.size.width * scale) x \(canvasImage.size.height * scale)")
                print("   Canvas position: x=\(geometry.size.width / 2 + (canvasImage.position.x * scale) + offset.width), y=\(geometry.size.height / 2 + (canvasImage.position.y * scale) + offset.height)")
            }
    }
    
    private func missingImagePlaceholder(canvasImage: CanvasImage, geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(Color.red.opacity(0.5))
            .frame(
                width: max(canvasImage.size.width * scale, 50),
                height: max(canvasImage.size.height * scale, 50)
            )
            .position(
                x: geometry.size.width / 2 + (canvasImage.position.x * scale) + offset.width,
                y: geometry.size.height / 2 + (canvasImage.position.y * scale) + offset.height
            )
            .overlay(
                Text("Missing Image")
                    .font(.caption)
                    .foregroundColor(.white)
            )
            .onAppear {
                print("❌ Missing image data for: \(canvasImage.imageName)")
                print("   Expected position: \(canvasImage.position)")
                print("   Expected size: \(canvasImage.size)")
            }
    }
    
    private func gridsLayer(geometry: GeometryProxy) -> some View {
        ForEach(grids) { grid in
            ModernGridOverlayView(
                grid: grid,
                scale: scale,
                canvasOffset: CGSize(
                    width: offset.width + dragOffset.width,
                    height: offset.height + dragOffset.height
                ),
                geometrySize: geometry.size,
                isSelected: selectedGridID == grid.id,
                isHovered: hoveredGridID == grid.id,
                showTags: showGridTags,
                onGridChanged: { newGrid in
                    if let index = grids.firstIndex(where: { $0.id == grid.id }) {
                        grids[index] = newGrid
                    }
                },
                onGridSelected: {
                    print("🎯 Grid selected: \(grid.name)")
                    // Deselect all grids first
                    for i in grids.indices {
                        grids[i].isSelected = false
                    }
                    // Select the clicked grid
                    if let index = grids.firstIndex(where: { $0.id == grid.id }) {
                        grids[index].isSelected = true
                        selectedGridID = grid.id
                        print("✅ Grid \(grid.name) marked as selected")
                    }
                },
                onGridSlice: {
                    sliceGrid(grid)
                }
            )
            .onHover { isHovered in
                hoveredGridID = isHovered ? grid.id : nil
            }
        }
    }
    
    private func gridCreationPreview(geometry: GeometryProxy) -> some View {
        Group {
            if isCreatingGrid && selectedTool == .grid {
                GridCreationPreview(
                    startPoint: gridStartPoint,
                    currentPoint: gridCurrentPoint,
                    canvasOffset: CGSize(
                        width: offset.width + dragOffset.width,
                        height: offset.height + dragOffset.height
                    ),
                    geometrySize: geometry.size,
                    gridProperties: gridProperties
                )
            }
        }
    }
    
    private var floatingUI: some View {
        ZStack {
            floatingToolbar
            zoomControls
        }
    }
    
    private var floatingToolbar: some View {
        VStack {
            Spacer()
            
            FloatingToolbarView(
                selectedTool: $selectedTool,
                strokeWidth: $gridProperties.thickness, // Logical thickness (slicing)
                strokeColor: $gridProperties.color
            )
            .padding(.bottom, 20) // Align with zoom controls
        }
    }
    
    private var zoomControls: some View {
        VStack {
            Spacer()
            
            HStack {
                ZoomControlView(
                    zoomLevel: $scale,
                    canvasOffset: $offset
                )
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.bottom, 20)
        }
    }
    
    private func createCanvasGesture(geometry: GeometryProxy) -> some Gesture {
        // Use ExclusiveGesture to prevent conflicts between different gestures
        ExclusiveGesture(
            // Grid creation gesture (highest priority when grid tool is selected)
            DragGesture()
                .onChanged { value in
                    if selectedTool == .grid {
                        if !isCreatingGrid {
                            isCreatingGrid = true
                            gridStartPoint = value.startLocation
                            print("🎯 Starting grid creation at: \(value.startLocation)")
                        }
                        gridCurrentPoint = value.location
                    }
                }
                .onEnded { value in
                    if isCreatingGrid && selectedTool == .grid {
                        print("🎯 Ending grid creation from \(gridStartPoint) to \(value.location)")
                        createGridFromDrag(
                            start: gridStartPoint,
                            end: value.location,
                            geometry: geometry
                        )
                        isCreatingGrid = false
                    }
                },
            
            // Pan gesture for canvas navigation (works with select & move tool)
            DragGesture()
                .onChanged { value in
                    if selectedTool == .select && !isCreatingGrid {
                        isDragging = true
                        dragOffset = value.translation
                        
                        // Provide visual feedback for panning
                        NSCursor.closedHand.set()
                    }
                }
                .onEnded { value in
                    if isDragging {
                        withAnimation(.easeOut(duration: 0.2)) {
                            offset.width += value.translation.width
                            offset.height += value.translation.height
                            dragOffset = .zero
                        }
                        isDragging = false
                        
                        // Reset cursor
                        NSCursor.openHand.set()
                    }
                }
        )
    }
    
    private func handleCanvasTap(at location: CGPoint) {
        // Deselect all grids when tapping on empty canvas
        for i in grids.indices {
            grids[i].isSelected = false
        }
        selectedGridID = nil
    }
    
    private func createGridFromDrag(start: CGPoint, end: CGPoint, geometry: GeometryProxy) {
        let minX = min(start.x, end.x)
        let minY = min(start.y, end.y)
        let width = abs(end.x - start.x)
        let height = abs(end.y - start.y)
        
        print("📐 Grid creation details:")
        print("   Start: \(start), End: \(end)")
        print("   Width: \(width), Height: \(height)")
        print("   Current scale: \(scale)")
        print("   Current offset: \(offset)")
        print("   Geometry size: \(geometry.size)")
        
        // Get the canvas center from the geometry
        let canvasCenterX = geometry.size.width / 2
        let canvasCenterY = geometry.size.height / 2
        
        // Convert screen coordinates to canvas coordinates (center-based system)
        // The canvas uses (0,0) at center, so we need to adjust accordingly
        let canvasX = (minX - canvasCenterX - offset.width) / scale
        let canvasY = (minY - canvasCenterY - offset.height) / scale
        
        let gridFrame = CGRect(
            x: canvasX,
            y: canvasY,
            width: width / scale,
            height: height / scale
        )
        
        print("   Canvas center: (\(canvasCenterX), \(canvasCenterY))")
        print("   Canvas frame: \(gridFrame)")
        print("   Grid properties: rows=\(gridProperties.rows), columns=\(gridProperties.columns), thickness=\(gridProperties.thickness), visualThickness=\(gridProperties.visualThickness)")
        
        if width > 50 && height > 50 { // Minimum size requirement
            let gridName = gridProperties.tagName.isEmpty ? "Grid \(grids.count + 1)" : gridProperties.tagName
            
            let newGrid = GridModel(
                name: gridName,
                frame: gridFrame,
                rows: gridProperties.rows,
                columns: gridProperties.columns,
                thickness: gridProperties.thickness, // Use logical thickness for slicing
                visualThickness: gridProperties.visualThickness, // Use visual thickness for display
                color: gridProperties.color,
                lineStyle: gridProperties.lineStyle
            )
            
            print("✅ Created grid: \(newGrid.name)")
            print("   Logical thickness (slicing): \(newGrid.thickness)")
            print("   Visual thickness (display): \(newGrid.visualThickness)")
            
            // Record undo action
            undoManager.recordAction(.addGrid(newGrid))
            
            // Deselect all existing grids
            for i in grids.indices {
                grids[i].isSelected = false
            }
            
            // Add new grid and select it
            var selectableGrid = newGrid
            selectableGrid.isSelected = true
            grids.append(selectableGrid)
            selectedGridID = newGrid.id
            
            // Reset tag name for next grid
            gridProperties.tagName = ""
        } else {
            print("❌ Grid too small: width=\(width), height=\(height) (minimum 50x50)")
        }
    }
    
    private func deleteSelectedGrid() {
        guard let selectedID = selectedGridID,
              let index = grids.firstIndex(where: { $0.id == selectedID }) else {
            return
        }
        
        let deletedGrid = grids[index]
        undoManager.recordAction(.removeGrid(deletedGrid, at: index))
        
        grids.remove(at: index)
        selectedGridID = nil
        
        print("🗑️ Deleted grid: \(deletedGrid.name)")
    }
    
    private func performUndo() {
        if undoManager.undo(grids: &grids, images: &images) {
            selectedGridID = nil
            print("↶ Undo performed")
        }
    }
    
    private func performRedo() {
        if undoManager.redo(grids: &grids, images: &images) {
            selectedGridID = nil
            print("↷ Redo performed")
        }
    }
    
    private func sliceGrid(_ grid: GridModel) {
        print("🔪 Starting to slice grid: \(grid.name)")
        
        // Show file picker for output directory
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.title = "Choose Output Directory for \(grid.name)"
        panel.prompt = "Select"
        
        guard panel.runModal() == .OK,
              let outputURL = panel.url else {
            print("❌ User cancelled directory selection")
            return
        }
        
        // Create subdirectory for this grid
        let gridOutputURL = outputURL.appendingPathComponent("Grid_\(grid.name)_\(Date().timeIntervalSince1970)")
        
        do {
            try FileManager.default.createDirectory(at: gridOutputURL, withIntermediateDirectories: true)
            
            // Slice this grid against all images
            var totalSlices = 0
            for canvasImage in images {
                guard let nsImage = canvasImage.image else {
                    print("⚠️ Skipping image \(canvasImage.imageName) - no image data")
                    continue
                }
                
                // Transform grid coordinates to image coordinates
                let transformedGrid = GridCoordinateTransformer.transformGridToImageSpace(grid, for: canvasImage)
                
                let sliceURLs = try SlicingEngine.sliceGrid(transformedGrid, from: nsImage, outputDirectory: gridOutputURL)
                totalSlices += sliceURLs.count
                print("✅ Sliced \(sliceURLs.count) pieces from \(canvasImage.imageName)")
            }
            
            print("🎉 Successfully sliced grid \(grid.name) into \(totalSlices) pieces")
            print("📁 Output saved to: \(gridOutputURL.path)")
            
            // Show success alert
            showSlicingSuccess(gridName: grid.name, totalSlices: totalSlices, outputPath: gridOutputURL.path)
            
        } catch {
            print("❌ Error slicing grid: \(error.localizedDescription)")
            showSlicingError(error)
        }
    }
    
    // MARK: - Coordinate Transformation Helper
    
    // MARK: - User Feedback
    
    private func showSlicingSuccess(gridName: String, totalSlices: Int, outputPath: String) {
        let alert = NSAlert()
        alert.messageText = "Grid Sliced Successfully!"
        alert.informativeText = "Grid '\(gridName)' was sliced into \(totalSlices) pieces.\n\nOutput saved to:\n\(outputPath)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Open Folder")
        
        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: outputPath)
        }
    }
    
    private func showSlicingError(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "Slicing Failed"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

struct InfiniteCanvasBackground: View {
    var body: some View {
        ZStack {
            // Main background
            Color.gray.opacity(0.05)
            
            // Grid pattern for infinite canvas feel
            Canvas { context, size in
                let gridSpacing: CGFloat = 20
                
                context.stroke(
                    Path { path in
                        // Vertical lines
                        for x in stride(from: 0, through: size.width, by: gridSpacing) {
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: size.height))
                        }
                        
                        // Horizontal lines
                        for y in stride(from: 0, through: size.height, by: gridSpacing) {
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: size.width, y: y))
                        }
                    },
                    with: .color(.gray.opacity(0.1)),
                    lineWidth: 0.5
                )
            }
        }
    }
}

struct GridCreationPreview: View {
    let startPoint: CGPoint
    let currentPoint: CGPoint
    let canvasOffset: CGSize
    let geometrySize: CGSize
    let gridProperties: GridProperties
    
    var body: some View {
        let minX = min(startPoint.x, currentPoint.x)
        let minY = min(startPoint.y, currentPoint.y)
        let width = abs(currentPoint.x - startPoint.x)
        let height = abs(currentPoint.y - startPoint.y)
        
        ZStack {
            // Main grid outline
            Rectangle()
                .stroke(gridProperties.color.opacity(0.8), lineWidth: 2)
                .fill(gridProperties.color.opacity(0.1))
                .frame(width: width, height: height)
                .position(
                    x: minX + width / 2,
                    y: minY + height / 2
                )
            
            // Grid lines preview
            if width > 100 && height > 100 {
                GridLinesPreview(
                    frame: CGRect(x: minX, y: minY, width: width, height: height),
                    rows: gridProperties.rows,
                    columns: gridProperties.columns,
                    color: gridProperties.color,
                    lineStyle: gridProperties.lineStyle
                )
            }
        }
    }
}

struct GridLinesPreview: View {
    let frame: CGRect
    let rows: Int
    let columns: Int
    let color: Color
    let lineStyle: GridLineStyle
    
    var body: some View {
        ZStack {
            // Vertical lines
            ForEach(1..<columns, id: \.self) { col in
                let x = frame.minX + (frame.width / Double(columns)) * Double(col)
                Path { path in
                    path.move(to: CGPoint(x: x, y: frame.minY))
                    path.addLine(to: CGPoint(x: x, y: frame.maxY))
                }
                .stroke(color.opacity(0.6), style: strokeStyle)
            }
            
            // Horizontal lines
            ForEach(1..<rows, id: \.self) { row in
                let y = frame.minY + (frame.height / Double(rows)) * Double(row)
                Path { path in
                    path.move(to: CGPoint(x: frame.minX, y: y))
                    path.addLine(to: CGPoint(x: frame.maxX, y: y))
                }
                .stroke(color.opacity(0.6), style: strokeStyle)
            }
        }
    }
    
    private var strokeStyle: StrokeStyle {
        switch lineStyle {
        case .solid:
            return StrokeStyle(lineWidth: 1)
        case .dashed:
            return StrokeStyle(lineWidth: 1, dash: [5, 3])
        case .dotted:
            return StrokeStyle(lineWidth: 1, dash: [2, 2])
        }
    }
}
