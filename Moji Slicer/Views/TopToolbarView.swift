//
//  TopToolbarView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI

struct TopToolbarView: View {
    @Binding var selectedTool: CanvasTool
    @Binding var gridProperties: GridProperties
    @Binding var showGridTags: Bool
    let onImportImages: () -> Void
    let onGlobalSlice: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Left: Tool Selection
            HStack(spacing: 8) {
                ForEach(CanvasTool.allCases, id: \.self) { tool in
                    ToolButton(
                        tool: tool,
                        isSelected: selectedTool == tool,
                        onSelect: {
                            selectedTool = tool
                        }
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Divider()
                .frame(height: 20)
            
            // Center: Tool-specific controls
            if selectedTool == .grid {
                GridToolControls(gridProperties: $gridProperties)
            }
            
            Spacer()
            
            // Right: Global Actions
            HStack(spacing: 12) {
                // Import Images
                Button {
                    onImportImages()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "photo.badge.plus")
                        Text("Import")
                    }
                }
                .buttonStyle(.bordered)
                
                // Toggle Grid Tags
                Button {
                    showGridTags.toggle()
                } label: {
                    Image(systemName: showGridTags ? "tag.fill" : "tag")
                }
                .buttonStyle(.bordered)
                .help("Toggle Grid Tags")
                
                // Global Slice (Knife Icon)
                Button {
                    onGlobalSlice()
                } label: {
                    Image(systemName: "scissors")
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderedProminent)
                .help("Slice All Grids")
                
                // New Board
                Button {
                    // TODO: Implement new board
                } label: {
                    Image(systemName: "plus.rectangle")
                }
                .buttonStyle(.bordered)
                .help("New Board")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .border(Color.gray.opacity(0.3), width: 0.5)
    }
}

struct ToolButton: View {
    let tool: CanvasTool
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: tool.icon)
                    .font(.system(size: 14))
                Text(tool.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color.accentColor : Color.clear)
        .foregroundColor(isSelected ? .white : .primary)
        .cornerRadius(6)
    }
}

struct GridToolControls: View {
    @Binding var gridProperties: GridProperties
    
    var body: some View {
        HStack(spacing: 12) {
            // Grid Size
            HStack(spacing: 4) {
                Text("Size:")
                    .font(.caption)
                
                HStack(spacing: 2) {
                    TextField("Cols", value: $gridProperties.columns, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 40)
                    
                    Text("×")
                        .font(.caption)
                    
                    TextField("Rows", value: $gridProperties.rows, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 40)
                }
            }
            
            Divider()
                .frame(height: 16)
            
            // Line Style
            HStack(spacing: 4) {
                Text("Style:")
                    .font(.caption)
                
                Picker("Line Style", selection: $gridProperties.lineStyle) {
                    ForEach(GridLineStyle.allCases, id: \.self) { style in
                        HStack {
                            Image(systemName: style.icon)
                            Text(style.rawValue)
                        }
                        .tag(style)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 80)
            }
            
            // Thickness
            HStack(spacing: 4) {
                Text("Thickness:")
                    .font(.caption)
                
                Slider(value: $gridProperties.thickness, in: 0...10, step: 0.5)
                    .frame(width: 60)
                
                Text("\(gridProperties.thickness, specifier: "%.1f")")
                    .font(.caption2)
                    .frame(width: 25)
            }
            
            // Color
            ColorPicker("", selection: $gridProperties.color)
                .labelsHidden()
                .frame(width: 30)
            
            Divider()
                .frame(height: 16)
            
            // Tag Name
            HStack(spacing: 4) {
                Text("Tag:")
                    .font(.caption)
                
                TextField("Grid name", text: $gridProperties.tagName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(6)
    }
}
