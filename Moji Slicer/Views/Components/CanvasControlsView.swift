//
//  CanvasControlsView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/27/25.
//

import SwiftUI

struct CanvasControlsView: View {
    @Binding var selectedTool: CanvasTool
    @Binding var scale: Double
    @Binding var offset: CGSize
    @Binding var showGridTags: Bool
    @State private var showGridSettings = false
    @Bindable var gridProperties: GridProperties
    
    let onImportImages: () -> Void
    let onGlobalSlice: () -> Void  // Keep for potential future use
    
    var body: some View {
        VStack(spacing: 0) {
            // Top: Main tools (similar to reference)
            mainToolsSection
            
            Divider()
            
            // Middle: Tool-specific controls
            toolSpecificControls
            
            Spacer()
            
            // Bottom: Simplified view controls
            viewControlsSection
        }
        .frame(width: 60)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundColor(Color(NSColor.separatorColor))
                .frame(maxWidth: .infinity, alignment: .trailing)
        )
        .sheet(isPresented: $showGridSettings) {
            GridSettingsSheet(gridProperties: gridProperties)
        }
    }
    
    // MARK: - Main Tools Section
    private var mainToolsSection: some View {
        VStack(spacing: 8) {
            // Selection & Move tool (merged select and hand functionality)
            toolButton(.select, systemImage: "arrow.up.left.and.arrow.down.right")
            
            // Grid creation
            Button {
                if selectedTool == .grid {
                    showGridSettings = true
                } else {
                    selectedTool = .grid
                }
            } label: {
                toolButtonContent(.grid, systemImage: "grid")
            }
            .buttonStyle(ModernToolButtonStyle(isSelected: selectedTool == .grid))
            .help(selectedTool == .grid ? "Grid Settings" : "Grid Tool")
            
            Divider()
                .padding(.horizontal, 8)
            
            // Import images
            Button {
                onImportImages()
            } label: {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .help("Import Images")
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Tool-Specific Controls
    private var toolSpecificControls: some View {
        VStack(spacing: 8) {
            if selectedTool == .grid {
                gridToolControls
            } else if selectedTool == .select {
                selectionToolControls
            }
        }
        .padding(.vertical, 8)
    }
    
    private var gridToolControls: some View {
        VStack(spacing: 8) {
            Button {
                showGridSettings = true
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .help("Grid Settings")
            
            Button {
                showGridTags.toggle()
            } label: {
                Image(systemName: showGridTags ? "tag.fill" : "tag")
                    .font(.system(size: 16))
                    .foregroundColor(showGridTags ? .primary : .secondary)
                    .frame(width: 36, height: 36)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .help("Toggle Grid Tags")
        }
    }
    
    private var selectionToolControls: some View {
        VStack(spacing: 8) {
            Button {
                // Align to grid functionality
            } label: {
                Image(systemName: "square.grid.3x3")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .help("Align to Grid")
            
            Button {
                onGlobalSlice()
            } label: {
                Image(systemName: "scissors")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                    .frame(width: 36, height: 36)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .help("Slice All")
        }
    }
    
    // MARK: - View Controls Section (simplified)
    private var viewControlsSection: some View {
        VStack(spacing: 8) {
            // Show grid tags toggle
            Button {
                showGridTags.toggle()
            } label: {
                Image(systemName: showGridTags ? "tag.fill" : "tag")
                    .font(.system(size: 16))
                    .foregroundColor(showGridTags ? .primary : .primary)
                    .frame(width: 36, height: 32)
                    .background(showGridTags ? Color.secondary.opacity(0.1) : Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .help("Toggle Grid Labels")
        }
        .padding(.bottom, 12)
    }
    
    // MARK: - Helper Methods
    private func toolButton(_ tool: CanvasTool, systemImage: String) -> some View {
        Button {
            selectedTool = tool
        } label: {
            toolButtonContent(tool, systemImage: systemImage)
        }
        .buttonStyle(ModernToolButtonStyle(isSelected: selectedTool == tool))
        .help(tool.rawValue)
    }
    
    private func toolButtonContent(_ tool: CanvasTool, systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 18))
            .foregroundColor(selectedTool == tool ? .white : .primary)
            .frame(width: 44, height: 44)
    }
}

// MARK: - Modern Tool Button Style
struct ModernToolButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.primary : (configuration.isPressed ? Color.gray.opacity(0.2) : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    CanvasControlsView(
        selectedTool: .constant(.select),
        scale: .constant(1.0),
        offset: .constant(.zero),
        showGridTags: .constant(false),
        gridProperties: GridProperties(),
        onImportImages: {},
        onGlobalSlice: {}
    )
    .frame(height: 600)
}
