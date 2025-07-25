//
//  GridOverlayView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI

struct GridOverlayView: View {
    let grid: GridModel
    let scale: Double
    let canvasOffset: CGSize
    let isSelected: Bool
    let onGridChanged: (GridModel) -> Void
    
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
        let scaledFrame = CGRect(
            x: grid.frame.origin.x * scale + canvasOffset.width + dragOffset.width,
            y: grid.frame.origin.y * scale + canvasOffset.height + dragOffset.height,
            width: grid.frame.size.width * scale,
            height: grid.frame.size.height * scale
        )
        return scaledFrame
    }
    
    var body: some View {
        ZStack {
            // Main grid area
            Rectangle()
                .stroke(grid.color, lineWidth: isSelected ? 3 : 2)
                .fill(grid.color.opacity(0.1))
                .frame(width: displayFrame.width, height: displayFrame.height)
                .position(
                    x: displayFrame.midX,
                    y: displayFrame.midY
                )
            
            // Grid lines
            GridLinesView(
                frame: displayFrame,
                rows: grid.rows,
                columns: grid.columns,
                color: grid.color,
                thickness: grid.thickness * scale
            )
            
            // Grid name tag
            if isSelected {
                Text(grid.name)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(grid.color)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .position(
                        x: displayFrame.minX + 40,
                        y: displayFrame.minY - 10
                    )
            }
            
            // Resize handles (only when selected)
            if isSelected {
                ResizeHandlesView(
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
            var updatedGrid = grid
            updatedGrid.isSelected = true
            onGridChanged(updatedGrid)
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

struct GridLinesView: View {
    let frame: CGRect
    let rows: Int
    let columns: Int
    let color: Color
    let thickness: Double
    
    var body: some View {
        ZStack {
            // Vertical lines
            ForEach(1..<columns, id: \.self) { col in
                let x = frame.minX + (frame.width / Double(columns)) * Double(col)
                Path { path in
                    path.move(to: CGPoint(x: x, y: frame.minY))
                    path.addLine(to: CGPoint(x: x, y: frame.maxY))
                }
                .stroke(color.opacity(0.7), lineWidth: 1)
            }
            
            // Horizontal lines
            ForEach(1..<rows, id: \.self) { row in
                let y = frame.minY + (frame.height / Double(rows)) * Double(row)
                Path { path in
                    path.move(to: CGPoint(x: frame.minX, y: y))
                    path.addLine(to: CGPoint(x: frame.maxX, y: y))
                }
                .stroke(color.opacity(0.7), lineWidth: 1)
            }
            
            // Thickness indicators (if thickness > 0)
            if thickness > 0 {
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<columns, id: \.self) { col in
                        let cellX = frame.minX + (frame.width / Double(columns)) * Double(col)
                        let cellY = frame.minY + (frame.height / Double(rows)) * Double(row)
                        let cellWidth = frame.width / Double(columns)
                        let cellHeight = frame.height / Double(rows)
                        
                        Rectangle()
                            .stroke(Color.red.opacity(0.5), lineWidth: 1)
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

struct ResizeHandlesView: View {
    let frame: CGRect
    let onHandleDrag: (GridOverlayView.ResizeHandle, CGSize) -> Void
    
    private let handleSize: CGFloat = 8
    
    var body: some View {
        ZStack {
            // Corner handles
            ResizeHandle(handle: .topLeft, onDrag: onHandleDrag)
                .position(x: frame.minX, y: frame.minY)
            
            ResizeHandle(handle: .topRight, onDrag: onHandleDrag)
                .position(x: frame.maxX, y: frame.minY)
            
            ResizeHandle(handle: .bottomLeft, onDrag: onHandleDrag)
                .position(x: frame.minX, y: frame.maxY)
            
            ResizeHandle(handle: .bottomRight, onDrag: onHandleDrag)
                .position(x: frame.maxX, y: frame.maxY)
            
            // Edge handles
            ResizeHandle(handle: .top, onDrag: onHandleDrag)
                .position(x: frame.midX, y: frame.minY)
            
            ResizeHandle(handle: .bottom, onDrag: onHandleDrag)
                .position(x: frame.midX, y: frame.maxY)
            
            ResizeHandle(handle: .left, onDrag: onHandleDrag)
                .position(x: frame.minX, y: frame.midY)
            
            ResizeHandle(handle: .right, onDrag: onHandleDrag)
                .position(x: frame.maxX, y: frame.midY)
        }
    }
}

struct ResizeHandle: View {
    let handle: GridOverlayView.ResizeHandle
    let onDrag: (GridOverlayView.ResizeHandle, CGSize) -> Void
    
    private let handleSize: CGFloat = 8
    
    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: handleSize, height: handleSize)
            .cornerRadius(2)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        onDrag(handle, value.translation)
                    }
            )
    }
}
