//
//  CanvasView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI

struct CanvasView: View {
    @Binding var images: [NSImage]
    @Binding var grids: [GridModel]
    @Binding var scale: Double
    @Binding var offset: CGSize
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var isCreatingGrid = false
    @State private var gridStartPoint: CGPoint = .zero
    @State private var gridCurrentPoint: CGPoint = .zero
    @State private var selectedGridIndex: Int?
    @State private var draggedGridIndex: Int?
    @State private var resizeHandle: ResizeHandle?
    
    enum ResizeHandle {
        case topLeft, topRight, bottomLeft, bottomRight
        case top, bottom, left, right
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.gray.opacity(0.1)
                
                // Canvas content
                ZStack {
                    // Images
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                width: image.size.width * scale,
                                height: image.size.height * scale
                            )
                            .position(
                                x: geometry.size.width / 2 + offset.width + dragOffset.width,
                                y: geometry.size.height / 2 + offset.height + dragOffset.height
                            )
                    }
                    
                    // Grids
                    ForEach(Array(grids.enumerated()), id: \.element.id) { index, grid in
                        GridOverlayView(
                            grid: grid,
                            scale: scale,
                            canvasOffset: CGSize(
                                width: offset.width + dragOffset.width,
                                height: offset.height + dragOffset.height
                            ),
                            isSelected: grid.isSelected,
                            onGridChanged: { newGrid in
                                grids[index] = newGrid
                            }
                        )
                    }
                    
                    // Grid creation preview - DISABLED, using MainCanvasView now
                    // if isCreatingGrid {
                    //     GridCreationPreview(...)
                    // }
                }
                .clipped()
            }
        }
        .gesture(
            SimultaneousGesture(
                // Pan gesture for canvas
                DragGesture()
                    .onChanged { value in
                        if !isCreatingGrid && selectedGridIndex == nil {
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
                    .modifiers(.option)
                    .onChanged { value in
                        if !isCreatingGrid {
                            isCreatingGrid = true
                            gridStartPoint = value.startLocation
                        }
                        gridCurrentPoint = value.location
                    }
                    .onEnded { value in
                        if isCreatingGrid {
                            createGridFromDrag(
                                start: gridStartPoint,
                                end: value.location,
                                in: CGRect(origin: .zero, size: CGSize(width: 1000, height: 1000)) // TODO: Use actual canvas size
                            )
                            isCreatingGrid = false
                        }
                    }
            )
        )
        .onTapGesture { location in
            // Deselect all grids when clicking on empty space
            deselectAllGrids()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Text("Hold ⌥ + drag to create grid")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Fit to Window") {
                        resetView()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    private func createGridFromDrag(start: CGPoint, end: CGPoint, in canvasRect: CGRect) {
        let minX = min(start.x, end.x)
        let minY = min(start.y, end.y)
        let width = abs(end.x - start.x)
        let height = abs(end.y - start.y)
        
        // Convert screen coordinates to canvas coordinates
        let canvasX = minX - offset.width - dragOffset.width
        let canvasY = minY - offset.height - dragOffset.height
        
        let gridFrame = CGRect(
            x: canvasX,
            y: canvasY,
            width: width,
            height: height
        )
        
        if width > 50 && height > 50 { // Minimum size requirement
            let newGrid = GridModel(
                name: "Grid \(grids.count + 1)",
                frame: gridFrame,
                rows: 3,
                columns: 3,
                thickness: 0.0,
                color: .blue
            )
            
            grids.append(newGrid)
        }
    }
    
    private func deselectAllGrids() {
        for i in grids.indices {
            grids[i].isSelected = false
        }
        selectedGridIndex = nil
    }
    
    private func resetView() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 1.0
            offset = .zero
            dragOffset = .zero
        }
    }
}
