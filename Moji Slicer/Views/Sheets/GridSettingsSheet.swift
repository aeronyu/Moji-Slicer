//
//  GridSettingsSheet.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/27/25.
//

import SwiftUI

struct GridSettingsSheet: View {
    @Bindable var gridProperties: GridProperties
    @State private var previewRows: Int = 3
    @State private var previewColumns: Int = 3
    @State private var dragStartPoint: CGPoint?
    @State private var dragCurrentPoint: CGPoint?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Grid Type Selection
                gridTypeSelection
                
                Divider()
                
                // Grid Configuration
                HStack(spacing: 40) {
                    // Left: Configuration Controls
                    VStack(alignment: .leading, spacing: 24) {
                        gridSizeControls
                        gridVisualizationSettings
                    }
                    .frame(width: 320)
                    
                    Divider()
                    
                    // Right: Interactive Preview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Preview")
                            .font(.headline)
                        
                        gridPreview
                    }
                    .frame(width: 320)
                }
                
                Spacer()
                
                // Action Buttons
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .keyboardShortcut(.escape)
                    
                    Spacer()
                    
                    Button("Apply") {
                        applySettings()
                        dismiss()
                    }
                    .keyboardShortcut(.return)
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(32)
            .frame(width: 800, height: 600)
            .navigationTitle("Grid Settings")
        }
        .onAppear {
            updatePreviewValues()
        }
    }
    
    // MARK: - Grid Type Selection
    private var gridTypeSelection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Grid Type")
                .font(.headline)
            
            HStack(spacing: 24) {
                ForEach(GridType.allCases, id: \.self) { type in
                    Button {
                        gridProperties.gridType = type
                        updatePreviewValues()
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: type.icon)
                                .font(.system(size: 28))
                                .foregroundColor(gridProperties.gridType == type ? .blue : .secondary)
                            
                            Text(type.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(gridProperties.gridType == type ? .blue : .primary)
                        }
                        .frame(width: 100, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(gridProperties.gridType == type ? Color.blue.opacity(0.1) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(gridProperties.gridType == type ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Grid Size Controls
    private var gridSizeControls: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Dimensions")
                .font(.headline)
            
            if gridProperties.gridType == .square {
                squareGridControls
            } else {
                rectangleGridControls
            }
        }
    }
    
    private var squareGridControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Grid Size")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                TextField("Size", value: $previewRows, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .onChange(of: previewRows) { _, newValue in
                        previewColumns = newValue
                    }
                
                Text("× \(previewRows)")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            Slider(value: Binding(
                get: { Double(previewRows) },
                set: { newValue in
                    previewRows = Int(newValue)
                    previewColumns = Int(newValue)
                }
            ), in: 1...10, step: 1) {
                Text("Grid Size")
            }
        }
    }
    
    private var rectangleGridControls: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Manual input controls
            VStack(alignment: .leading, spacing: 12) {
                Text("Manual Input")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Columns")
                            .font(.caption)
                        TextField("Cols", value: $previewColumns, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                    
                    Text("×")
                        .font(.title2)
                        .padding(.horizontal, 8)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Rows")
                            .font(.caption)
                        TextField("Rows", value: $previewRows, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                    
                    Spacer()
                }
            }
            
            // Visual grid creation area
            VStack(alignment: .leading, spacing: 12) {
                Text("Visual Creation")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Click and drag to create a grid visually")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                visualGridCreator
            }
        }
    }
    
    // MARK: - Visual Grid Creator
    private var visualGridCreator: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            if let start = dragStartPoint, let current = dragCurrentPoint {
                visualGrid(start: start, current: current)
            } else {
                Text("Click and drag to create grid")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .gesture(
            DragGesture(coordinateSpace: .local)
                .onChanged { value in
                    if dragStartPoint == nil {
                        dragStartPoint = value.startLocation
                    }
                    dragCurrentPoint = value.location
                    updateGridFromDrag(start: value.startLocation, current: value.location)
                }
                .onEnded { _ in
                    dragStartPoint = nil
                    dragCurrentPoint = nil
                }
        )
    }
    
    private func visualGrid(start: CGPoint, current: CGPoint) -> some View {
        let minX = min(start.x, current.x)
        let maxX = max(start.x, current.x)
        let minY = min(start.y, current.y)
        let maxY = max(start.y, current.y)
        
        let width = maxX - minX
        let height = maxY - minY
        
        let cellWidth = width / CGFloat(previewColumns)
        let cellHeight = height / CGFloat(previewRows)
        
        return ZStack {
            // Background
            Rectangle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: width, height: height)
                .position(x: (minX + maxX) / 2, y: (minY + maxY) / 2)
            
            // Grid lines
            ForEach(0...previewColumns, id: \.self) { col in
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 1, height: height)
                    .position(x: minX + CGFloat(col) * cellWidth, y: (minY + maxY) / 2)
            }
            
            ForEach(0...previewRows, id: \.self) { row in
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: width, height: 1)
                    .position(x: (minX + maxX) / 2, y: minY + CGFloat(row) * cellHeight)
            }
        }
    }
    
    // MARK: - Grid Visualization Settings
    private var gridVisualizationSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Appearance")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Line Color")
                        .font(.subheadline)
                    Spacer()
                    ColorPicker("", selection: $gridProperties.color)
                        .frame(width: 40)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Visual Thickness")
                        .font(.subheadline)
                    Slider(value: $gridProperties.visualThickness, in: 0.5...5.0, step: 0.5) {
                        Text("Thickness")
                    }
                    Text("\(gridProperties.visualThickness, specifier: "%.1f")px")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Grid Name (Optional)")
                        .font(.subheadline)
                    TextField("Enter grid name", text: $gridProperties.tagName)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }
    
    // MARK: - Grid Preview
    private var gridPreview: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                // Preview grid
                ForEach(0...previewColumns, id: \.self) { col in
                    Rectangle()
                        .fill(gridProperties.color)
                        .frame(width: gridProperties.visualThickness, height: 200)
                        .position(x: CGFloat(col) * (200 / CGFloat(previewColumns)), y: 100)
                }
                
                ForEach(0...previewRows, id: \.self) { row in
                    Rectangle()
                        .fill(gridProperties.color)
                        .frame(width: 200, height: gridProperties.visualThickness)
                        .position(x: 100, y: CGFloat(row) * (200 / CGFloat(previewRows)))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            Text("\(previewColumns) × \(previewRows) grid (\(previewColumns * previewRows) cells)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Helper Methods
    private func updatePreviewValues() {
        previewRows = gridProperties.rows
        previewColumns = gridProperties.columns
    }
    
    private func updateGridFromDrag(start: CGPoint, current: CGPoint) {
        let width = abs(current.x - start.x)
        let height = abs(current.y - start.y)
        
        // Calculate grid dimensions based on drag area
        let cellSize: CGFloat = 20 // Minimum cell size
        let cols = max(1, Int(width / cellSize))
        let rows = max(1, Int(height / cellSize))
        
        previewColumns = min(cols, 10)
        previewRows = min(rows, 10)
    }
    
    private func applySettings() {
        if gridProperties.gridType == .square {
            gridProperties.squareSize = previewRows
        } else {
            gridProperties.rows = previewRows
            gridProperties.columns = previewColumns
        }
    }
}

#Preview {
    GridSettingsSheet(gridProperties: GridProperties())
}
