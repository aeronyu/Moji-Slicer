//
//  MainCanvasView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI

struct MainCanvasView: View {
    @Binding var images: [CanvasImage]
    @Binding var grids: [GridModel]
    @Binding var scale: Double
    @Binding var offset: CGSize
    @Binding var selectedTool: CanvasTool
    @Binding var gridProperties: GridProperties
    @Binding var showGridTags: Bool
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var isCreatingGrid = false
    @State private var gridStartPoint: CGPoint = .zero
    @State private var gridCurrentPoint: CGPoint = .zero
    @State private var selectedGridID: UUID?
    @State private var hoveredGridID: UUID?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Infinite Canvas Background
                InfiniteCanvasBackground()
                
                // Canvas Content Container
                ZStack {
                    // Images
                    ForEach(images) { canvasImage in
                        if let nsImage = canvasImage.image {
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(
                                    width: canvasImage.size.width * scale,
                                    height: canvasImage.size.height * scale
                                )
                                .position(
                                    x: geometry.size.width / 2 + canvasImage.position.x * scale + offset.width + dragOffset.width,
                                    y: geometry.size.height / 2 + canvasImage.position.y * scale + offset.height + dragOffset.height
                                )
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if selectedTool == .select {
                                                // Move image logic here
                                            }
                                        }
                                )
                        }
                    }
                    
                    // Grids
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
                                selectedGridID = grid.id
                            },
                            onGridSlice: {
                                sliceGrid(grid)
                            }
                        )
                        .onHover { isHovered in
                            hoveredGridID = isHovered ? grid.id : nil
                        }
                    }
                    
                    // Grid Creation Preview
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
                .clipped()
            }
        }
        .gesture(
            createCanvasGesture()
        )
        .onTapGesture { location in
            handleCanvasTap(at: location)
        }
    }
    
    private func createCanvasGesture() -> some Gesture {
        SimultaneousGesture(
            // Pan gesture for canvas navigation
            DragGesture()
                .onChanged { value in
                    if selectedTool == .select && !isCreatingGrid {
                        isDragging = true
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    if isDragging {
                        offset.width += value.translation.width
                        offset.height += value.translation.height
                        dragOffset = .zero
                        isDragging = false
                    }
                },
            
            // Grid creation gesture
            DragGesture()
                .onChanged { value in
                    if selectedTool == .grid {
                        if !isCreatingGrid {
                            isCreatingGrid = true
                            gridStartPoint = value.startLocation
                        }
                        gridCurrentPoint = value.location
                    }
                }
                .onEnded { value in
                    if isCreatingGrid && selectedTool == .grid {
                        createGridFromDrag(
                            start: gridStartPoint,
                            end: value.location
                        )
                        isCreatingGrid = false
                    }
                }
        )
    }
    
    private func handleCanvasTap(at location: CGPoint) {
        selectedGridID = nil
    }
    
    private func createGridFromDrag(start: CGPoint, end: CGPoint) {
        let minX = min(start.x, end.x)
        let minY = min(start.y, end.y)
        let width = abs(end.x - start.x)
        let height = abs(end.y - start.y)
        
        // Convert screen coordinates to canvas coordinates
        let canvasX = (minX - offset.width - dragOffset.width) / scale
        let canvasY = (minY - offset.height - dragOffset.height) / scale
        
        let gridFrame = CGRect(
            x: canvasX,
            y: canvasY,
            width: width / scale,
            height: height / scale
        )
        
        if width > 50 && height > 50 { // Minimum size requirement
            let gridName = gridProperties.tagName.isEmpty ? "Grid \(grids.count + 1)" : gridProperties.tagName
            
            let newGrid = GridModel(
                name: gridName,
                frame: gridFrame,
                rows: gridProperties.rows,
                columns: gridProperties.columns,
                thickness: gridProperties.thickness,
                color: gridProperties.color,
                lineStyle: gridProperties.lineStyle
            )
            
            grids.append(newGrid)
            selectedGridID = newGrid.id
            
            // Reset tag name for next grid
            gridProperties.tagName = ""
        }
    }
    
    private func sliceGrid(_ grid: GridModel) {
        // TODO: Implement individual grid slicing
        print("Slicing grid: \(grid.name)")
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
