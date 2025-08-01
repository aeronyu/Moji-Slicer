//
//  TopToolbarView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI

struct TopToolbarView: View {
    @Binding var selectedTool: CanvasTool
    @Bindable var gridProperties: GridProperties  // Changed to @Bindable for @Observable
    @Binding var showGridTags: Bool
    let onImportImages: () -> Void
    let onGlobalSlice: () -> Void
    
    @State private var showToolLabels = true
    
    var body: some View {
        HStack(spacing: 16) {
            // Left: Tool Selection
            HStack(spacing: 4) {
                ForEach(CanvasTool.allCases, id: \.self) { tool in
                    AppleStyleToolButton(
                        tool: tool,
                        isSelected: selectedTool == tool,
                        showLabel: showToolLabels,
                        onSelect: {
                            selectedTool = tool
                        }
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            Divider()
                .frame(height: 24)
            
            // Center: Tool-specific controls
            if selectedTool == .grid {
                GridToolControls(gridProperties: gridProperties)  // Remove $ since we're passing @Bindable directly
            }
            
            Spacer()
            
            // Right: Actions
            HStack(spacing: 8) {
                // Text Labels Toggle
                Button {
                    showToolLabels.toggle()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: showToolLabels ? "textformat" : "textformat.size.smaller")
                            .font(.system(size: 16))
                        if showToolLabels {
                            Text("Labels")
                                .font(.caption2)
                        }
                    }
                }
                .buttonStyle(AppleToolbarButtonStyle())
                .help("Toggle Tool Labels")
                
                Divider()
                    .frame(height: 24)
                
                // Import Images
                Button {
                    onImportImages()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 16))
                        if showToolLabels {
                            Text("Import")
                                .font(.caption2)
                        }
                    }
                }
                .buttonStyle(AppleToolbarButtonStyle())
                .help("Import Images")
                
                // Toggle Grid Tags
                Button {
                    showGridTags.toggle()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: showGridTags ? "tag.fill" : "tag")
                            .font(.system(size: 16))
                            .foregroundColor(showGridTags ? .blue : .primary)
                        if showToolLabels {
                            Text("Tags")
                                .font(.caption2)
                        }
                    }
                }
                .buttonStyle(AppleToolbarButtonStyle())
                .help("Toggle Grid Tags")
                
                // Global Slice (Knife Icon)
                Button {
                    onGlobalSlice()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "scissors")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                        if showToolLabels {
                            Text("Slice All")
                                .font(.caption2)
                        }
                    }
                }
                .buttonStyle(AppleToolbarButtonStyle(isProminent: true))
                .help("Slice All Grids")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(NSColor.separatorColor))
                .frame(maxHeight: .infinity, alignment: .bottom)
        )
    }
}

// MARK: - Apple-Style Tool Button

struct AppleStyleToolButton: View {
    let tool: CanvasTool
    let isSelected: Bool
    let showLabel: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            VStack(spacing: 2) {
                Image(systemName: tool.icon)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 20, height: 20)
                
                if showLabel {
                    Text(tool.rawValue)
                        .font(.caption2)
                        .lineLimit(1)
                }
            }
            .frame(minWidth: showLabel ? 44 : 32, minHeight: showLabel ? 44 : 32)
        }
        .buttonStyle(AppleToolbarButtonStyle(isSelected: isSelected))
    }
}

// MARK: - Apple-Style Button Style

struct AppleToolbarButtonStyle: ButtonStyle {
    let isSelected: Bool
    let isProminent: Bool
    
    init(isSelected: Bool = false, isProminent: Bool = false) {
        self.isSelected = isSelected
        self.isProminent = isProminent
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(
                isSelected ? .white :
                isProminent ? .red :
                (configuration.isPressed ? .blue : .primary)
            )
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        isSelected ? Color.blue :
                        (configuration.isPressed ? Color.blue.opacity(0.2) : Color.clear)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct GridToolControls: View {
    @Bindable var gridProperties: GridProperties  // Changed to @Bindable for @Observable
    @FocusState private var isSquareSizeFocused: Bool
    @FocusState private var isRowsFocused: Bool
    @FocusState private var isColumnsFocused: Bool
    
    private var isRectangleInputsDisabled: Bool {
        gridProperties.gridType == .square || isSquareSizeFocused
    }
    
    private var isSquareInputDisabled: Bool {
        gridProperties.gridType == .rectangle || isRowsFocused || isColumnsFocused
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Grid Type Toggle
            HStack(spacing: 6) {
                Text("Type:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Grid Type", selection: $gridProperties.gridType) {
                    ForEach(GridType.allCases, id: \.self) { type in
                        Label(type.rawValue, systemImage: type.icon)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
                .onChange(of: gridProperties.gridType) { _, newType in
                    // Synchronization is now automatic with @Observable
                    // No manual sync needed!
                }
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue.opacity(0.1))
                        .padding(-4)
                )
            }
            
            Divider()
                .frame(height: 20)
            
            // Grid Size Controls with enhanced visual feedback
            Group {
                if gridProperties.gridType == .square {
                    // Square Grid: Single input
                    HStack(spacing: 6) {
                        Text("Size:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("3", value: $gridProperties.squareSize, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 35)
                            .focused($isSquareSizeFocused)
                            .disabled(isSquareInputDisabled)
                            .opacity(isSquareInputDisabled ? 0.5 : 1.0)
                            .onChange(of: gridProperties.squareSize) { _, newSize in
                                gridProperties.rows = newSize
                                gridProperties.columns = newSize
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.blue, lineWidth: isSquareSizeFocused ? 2 : 0)
                                    .padding(-2)
                            )
                        
                        Text("× \(gridProperties.squareSize)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                    }
                } else {
                    // Rectangle Grid: Separate inputs
                    HStack(spacing: 6) {
                        Text("Size:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 2) {
                            TextField("3", value: $gridProperties.columns, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 35)
                                .focused($isColumnsFocused)
                                .disabled(isRectangleInputsDisabled)
                                .opacity(isRectangleInputsDisabled ? 0.5 : 1.0)
                                .onChange(of: gridProperties.columns) { _, _ in
                                    // Synchronization is now automatic with @Observable
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.blue, lineWidth: isColumnsFocused ? 2 : 0)
                                        .padding(-2)
                                )
                            
                            Text("×")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            TextField("3", value: $gridProperties.rows, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 35)
                                .focused($isRowsFocused)
                                .disabled(isRectangleInputsDisabled)
                                .opacity(isRectangleInputsDisabled ? 0.5 : 1.0)
                                .onChange(of: gridProperties.rows) { _, _ in
                                    // Synchronization is now automatic with @Observable
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.blue, lineWidth: isRowsFocused ? 2 : 0)
                                        .padding(-2)
                                )
                        }
                    }
                }
            }
            
            Divider()
                .frame(height: 20)
            
            // Line Style
            HStack(spacing: 6) {
                Text("Style:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
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
                .frame(width: 90)
            }
            
            // Thickness
            HStack(spacing: 6) {
                Text("Thickness:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(value: $gridProperties.thickness, in: 0...10, step: 0.5)
                    .frame(width: 80)
                
                Text("\(gridProperties.thickness, specifier: "%.1f")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 25)
            }
            
            // Color
            HStack(spacing: 6) {
                Text("Color:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ColorPicker("", selection: $gridProperties.color)
                    .labelsHidden()
                    .frame(width: 35)
            }
            
            Divider()
                .frame(height: 20)
            
            // Tag Name
            HStack(spacing: 6) {
                Text("Name:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("Grid name", text: $gridProperties.tagName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}
