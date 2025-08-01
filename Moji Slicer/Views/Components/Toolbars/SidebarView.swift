//
//  SidebarView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI

struct SidebarView: View {
    @Binding var grids: [GridModel]
    @Binding var showingImagePicker: Bool
    @Binding var canvasScale: Double
    @State private var selectedGridIndex: Int?
    
    // Slicing callbacks
    let onSliceAll: () -> Void
    let onSliceSelected: (GridModel) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Moji Slicer")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Import Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Import")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack {
                    Button("Add Images") {
                        showingImagePicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            Divider()
            
            // Canvas Controls
            VStack(alignment: .leading, spacing: 8) {
                Text("Canvas")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Zoom: \(Int(canvasScale * 100))%")
                        .font(.caption)
                    
                    HStack {
                        Button("-") {
                            canvasScale = max(0.1, canvasScale - 0.1)
                        }
                        .buttonStyle(.bordered)
                        
                        Slider(value: $canvasScale, in: 0.1...3.0, step: 0.1)
                        
                        Button("+") {
                            canvasScale = min(3.0, canvasScale + 0.1)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button("Reset Zoom") {
                        canvasScale = 1.0
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
            }
            
            Divider()
            
            // Grid Management
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Grids")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("+") {
                        addNewGrid()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                
                // Grid List
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(Array(grids.enumerated()), id: \.element.id) { index, grid in
                            GridRowView(
                                grid: grid,
                                isSelected: selectedGridIndex == index,
                                onSelect: {
                                    selectedGridIndex = index
                                    selectGrid(at: index)
                                },
                                onDelete: {
                                    deleteGrid(at: index)
                                }
                            )
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            
            Divider()
            
            // Grid Properties
            if let selectedIndex = selectedGridIndex,
               selectedIndex < grids.count {
                GridPropertiesView(
                    grid: $grids[selectedIndex]
                )
            }
            
            Spacer()
            
            // Export Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Export")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 8) {
                    Button("Slice All Grids") {
                        onSliceAll()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    
                    if let selectedIndex = selectedGridIndex,
                       selectedIndex < grids.count {
                        Button("Slice Selected Grid") {
                            onSliceSelected(grids[selectedIndex])
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private func addNewGrid() {
        let newGrid = GridModel(
            name: "Grid \(grids.count + 1)",
            frame: CGRect(x: 50, y: 50, width: 300, height: 300)
        )
        grids.append(newGrid)
        selectedGridIndex = grids.count - 1
        selectGrid(at: grids.count - 1)
    }
    
    private func selectGrid(at index: Int) {
        // Deselect all grids
        for i in grids.indices {
            grids[i].isSelected = false
        }
        // Select the chosen grid
        if index < grids.count {
            grids[index].isSelected = true
        }
    }
    
    private func deleteGrid(at index: Int) {
        grids.remove(at: index)
        if selectedGridIndex == index {
            selectedGridIndex = nil
        } else if let selected = selectedGridIndex, selected > index {
            selectedGridIndex = selected - 1
        }
    }
}

struct GridRowView: View {
    let grid: GridModel
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(grid.color)
                .frame(width: 12, height: 12)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(grid.name)
                    .font(.system(size: 12, weight: .medium))
                Text("\(grid.columns)×\(grid.rows)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(4)
        .onTapGesture {
            onSelect()
        }
        .padding(.horizontal)
    }
}

struct GridPropertiesView: View {
    @Binding var grid: GridModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Properties")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                // Name
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name")
                        .font(.caption)
                    TextField("Grid name", text: $grid.name)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Dimensions
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Columns")
                            .font(.caption)
                        TextField("Cols", value: $grid.columns, format: .number)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Rows")
                            .font(.caption)
                        TextField("Rows", value: $grid.rows, format: .number)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                // Thickness
                VStack(alignment: .leading, spacing: 4) {
                    Text("Thickness: \(grid.thickness, specifier: "%.1f")px")
                        .font(.caption)
                    Slider(value: $grid.thickness, in: 0...20, step: 0.5)
                }
                
                // Color
                VStack(alignment: .leading, spacing: 4) {
                    Text("Color")
                        .font(.caption)
                    ColorPicker("Grid Color", selection: $grid.color)
                        .labelsHidden()
                }
            }
            .padding(.horizontal)
        }
    }
}
