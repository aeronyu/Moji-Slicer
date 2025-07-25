//
//  ModernGridOverlayView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI

struct ModernGridOverlayView: View {
    let grid: GridModel
    let scale: Double
    let canvasOffset: CGSize
    let geometrySize: CGSize
    let isSelected: Bool
    let isHovered: Bool
    let showTags: Bool
    let onGridChanged: (GridModel) -> Void
    let onGridSelected: () -> Void
    let onGridSlice: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var isResizing = false
    @State private var resizeHandle: ResizeHandle?
    @State private var originalFrame: CGRect = .zero
    
    enum ResizeHandle {
        case topLeft, topRight, bottomLeft, bottomRight
        case top, bottom, left, right
    }
    
    var displayFrame: CGRect {
        let canvasCenter = CGPoint(x: geometrySize.width / 2, y: geometrySize.height / 2)
        let scaledFrame = CGRect(
            x: canvasCenter.x + grid.frame.origin.x * scale + canvasOffset.width + dragOffset.width,
            y: canvasCenter.y + grid.frame.origin.y * scale + canvasOffset.height + dragOffset.height,
            width: grid.frame.size.width * scale,
            height: grid.frame.size.height * scale
        )
        return scaledFrame
    }
    
    var body: some View {
        ZStack {
            // Main grid area
            Rectangle()
                .stroke(grid.color, lineWidth: isSelected ? 3 : (isHovered ? 2 : 1.5))
                .fill(grid.color.opacity(isSelected ? 0.15 : (isHovered ? 0.08 : 0.05)))
                .frame(width: displayFrame.width, height: displayFrame.height)
                .position(
                    x: displayFrame.midX,
                    y: displayFrame.midY
                )
            
            // Grid lines
            ModernGridLinesView(
                frame: displayFrame,
                grid: grid,
                scale: scale
            )
            
            // Floating control tag (top-right corner)
            if showTags && (isSelected || isHovered) {
                FloatingGridControlView(
                    grid: grid,
                    isSelected: isSelected,
                    onSlice: onGridSlice
                )
                .position(
                    x: displayFrame.maxX - 8,
                    y: displayFrame.minY + 8
                )
            }
            
            // Resize handles (only when selected)
            if isSelected {
                ModernResizeHandlesView(
                    frame: displayFrame,
                    onHandleDrag: handleResize
                )
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isResizing {
                        isDragging = true
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    if isDragging {
                        var updatedGrid = grid
                        updatedGrid.frame.origin.x += value.translation.width / scale
                        updatedGrid.frame.origin.y += value.translation.height / scale
                        onGridChanged(updatedGrid)
                        
                        dragOffset = .zero
                        isDragging = false
                    }
                }
        )
        .onTapGesture {
            onGridSelected()
        }
    }
    
    private func handleResize(_ handle: ResizeHandle, translation: CGSize) {
        if !isResizing {
            isResizing = true
            originalFrame = grid.frame
            resizeHandle = handle
        }
        
        var newFrame = originalFrame
        let scaledTranslation = CGSize(
            width: translation.width / scale,
            height: translation.height / scale
        )
        
        switch handle {
        case .topLeft:
            newFrame.origin.x += scaledTranslation.width
            newFrame.origin.y += scaledTranslation.height
            newFrame.size.width -= scaledTranslation.width
            newFrame.size.height -= scaledTranslation.height
        case .topRight:
            newFrame.origin.y += scaledTranslation.height
            newFrame.size.width += scaledTranslation.width
            newFrame.size.height -= scaledTranslation.height
        case .bottomLeft:
            newFrame.origin.x += scaledTranslation.width
            newFrame.size.width -= scaledTranslation.width
            newFrame.size.height += scaledTranslation.height
        case .bottomRight:
            newFrame.size.width += scaledTranslation.width
            newFrame.size.height += scaledTranslation.height
        case .top:
            newFrame.origin.y += scaledTranslation.height
            newFrame.size.height -= scaledTranslation.height
        case .bottom:
            newFrame.size.height += scaledTranslation.height
        case .left:
            newFrame.origin.x += scaledTranslation.width
            newFrame.size.width -= scaledTranslation.width
        case .right:
            newFrame.size.width += scaledTranslation.width
        }
        
        // Ensure minimum size
        newFrame.size.width = max(50, newFrame.size.width)
        newFrame.size.height = max(50, newFrame.size.height)
        
        var updatedGrid = grid
        updatedGrid.frame = newFrame
        onGridChanged(updatedGrid)
    }
}

struct FloatingGridControlView: View {
    let grid: GridModel
    let isSelected: Bool
    let onSlice: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            // Grid name
            Text(grid.name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(1)
            
            if isSelected {
                // Slice button
                Button {
                    onSlice()
                } label: {
                    Image(systemName: "scissors")
                        .font(.caption2)
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .help("Slice this grid")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(grid.color)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
        )
    }
}

struct ModernGridLinesView: View {
    let frame: CGRect
    let grid: GridModel
    let scale: Double
    
    var body: some View {
        ZStack {
            // Vertical lines
            ForEach(1..<grid.columns, id: \.self) { col in
                let x = frame.minX + (frame.width / Double(grid.columns)) * Double(col)
                Path { path in
                    path.move(to: CGPoint(x: x, y: frame.minY))
                    path.addLine(to: CGPoint(x: x, y: frame.maxY))
                }
                .stroke(grid.color.opacity(0.7), lineWidth: 1)
            }
            
            // Horizontal lines
            ForEach(1..<grid.rows, id: \.self) { row in
                let y = frame.minY + (frame.height / Double(grid.rows)) * Double(row)
                Path { path in
                    path.move(to: CGPoint(x: frame.minX, y: y))
                    path.addLine(to: CGPoint(x: frame.maxX, y: y))
                }
                .stroke(grid.color.opacity(0.7), lineWidth: 1)
            }
            
            // Thickness indicators (if thickness > 0)
            if grid.thickness > 0 {
                ForEach(0..<grid.rows, id: \.self) { row in
                    ForEach(0..<grid.columns, id: \.self) { col in
                        let cellX = frame.minX + (frame.width / Double(grid.columns)) * Double(col)
                        let cellY = frame.minY + (frame.height / Double(grid.rows)) * Double(row)
                        let cellWidth = frame.width / Double(grid.columns)
                        let cellHeight = frame.height / Double(grid.rows)
                        let thickness = grid.thickness * scale
                        
                        Rectangle()
                            .stroke(Color.red.opacity(0.6), lineWidth: 1)
                            .frame(
                                width: cellWidth - thickness * 2,
                                height: cellHeight - thickness * 2
                            )
                            .position(
                                x: cellX + cellWidth / 2,
                                y: cellY + cellHeight / 2
                            )
                    }
                }
            }
        }
    }
}

struct ModernResizeHandlesView: View {
    let frame: CGRect
    let onHandleDrag: (ModernGridOverlayView.ResizeHandle, CGSize) -> Void
    
    private let handleSize: CGFloat = 8
    
    var body: some View {
        ZStack {
            // Corner handles
            ModernResizeHandle(handle: .topLeft, onDrag: onHandleDrag)
                .position(x: frame.minX, y: frame.minY)
            
            ModernResizeHandle(handle: .topRight, onDrag: onHandleDrag)
                .position(x: frame.maxX, y: frame.minY)
            
            ModernResizeHandle(handle: .bottomLeft, onDrag: onHandleDrag)
                .position(x: frame.minX, y: frame.maxY)
            
            ModernResizeHandle(handle: .bottomRight, onDrag: onHandleDrag)
                .position(x: frame.maxX, y: frame.maxY)
            
            // Edge handles
            ModernResizeHandle(handle: .top, onDrag: onHandleDrag)
                .position(x: frame.midX, y: frame.minY)
            
            ModernResizeHandle(handle: .bottom, onDrag: onHandleDrag)
                .position(x: frame.midX, y: frame.maxY)
            
            ModernResizeHandle(handle: .left, onDrag: onHandleDrag)
                .position(x: frame.minX, y: frame.midY)
            
            ModernResizeHandle(handle: .right, onDrag: onHandleDrag)
                .position(x: frame.maxX, y: frame.midY)
        }
    }
}

struct ModernResizeHandle: View {
    let handle: ModernGridOverlayView.ResizeHandle
    let onDrag: (ModernGridOverlayView.ResizeHandle, CGSize) -> Void
    
    private let handleSize: CGFloat = 10
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .overlay(
                Circle()
                    .stroke(Color.blue, lineWidth: 2)
            )
            .frame(width: handleSize, height: handleSize)
            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        onDrag(handle, value.translation)
                    }
            )
    }
}
