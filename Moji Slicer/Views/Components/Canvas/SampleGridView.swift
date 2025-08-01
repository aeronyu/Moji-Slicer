//
//  SampleGridView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/25/25.
//

import SwiftUI

struct SampleGridView: View {
    let columns = 5
    let rows = 5
    @State private var isSelected = true
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    
    // Sample emoji data to mimic the mock UI
    private let sampleEmojis = [
        "🐺", "😄", "🐱", "😷", "🐦",
        "👨‍💼", "🧛‍♂️", "🦝", "😷", "🍜",
        "🐕", "🐮", "🦆", "🐺", "🐧",
        "👨‍💼", "🐮", "💕", "🐺", "🐕",
        "🐕", "🔪", "👟", "👨‍💼", "⚡"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Grid Content
            GridView(
                rows: rows,
                columns: columns,
                emojis: sampleEmojis,
                isSelected: isSelected
            )
            .offset(dragOffset)
            .scaleEffect(isDragging ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isDragging)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                        }
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        isDragging = false
                        // Add some spring back animation
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = .zero
                        }
                    }
            )
        }
    }
}

struct GridView: View {
    let rows: Int
    let columns: Int
    let emojis: [String]
    let isSelected: Bool
    
    private let cellSize: CGFloat = 80
    private let gridLineWidth: CGFloat = 2
    private let selectionColor = Color.blue
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<columns, id: \.self) { column in
                        GridCell(
                            emoji: emojiForPosition(row: row, column: column),
                            size: cellSize,
                            borderColor: selectionColor,
                            borderWidth: gridLineWidth
                        )
                    }
                }
            }
        }
        .overlay(
            // Selection handles (blue corner indicators)
            Group {
                if isSelected {
                    // Top-left handle
                    SelectionHandle()
                        .position(x: -8, y: -8)
                    
                    // Top-right handle
                    SelectionHandle()
                        .position(x: CGFloat(columns) * cellSize + 8, y: -8)
                    
                    // Bottom-left handle
                    SelectionHandle()
                        .position(x: -8, y: CGFloat(rows) * cellSize + 8)
                    
                    // Bottom-right handle
                    SelectionHandle()
                        .position(x: CGFloat(columns) * cellSize + 8, y: CGFloat(rows) * cellSize + 8)
                }
            }
        )
        .background(
            // Outer border
            Rectangle()
                .stroke(isSelected ? selectionColor : Color.gray.opacity(0.3), lineWidth: gridLineWidth)
        )
    }
    
    private func emojiForPosition(row: Int, column: Int) -> String {
        let index = row * columns + column
        return index < emojis.count ? emojis[index] : "❓"
    }
}

struct GridCell: View {
    let emoji: String
    let size: CGFloat
    let borderColor: Color
    let borderWidth: CGFloat
    
    var body: some View {
        Text(emoji)
            .font(.system(size: size * 0.6))
            .frame(width: size, height: size)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .stroke(borderColor.opacity(0.3), lineWidth: 0.5)
            )
    }
}

struct SelectionHandle: View {
    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    SampleGridView()
        .padding()
        .background(Color.gray.opacity(0.1))
}
