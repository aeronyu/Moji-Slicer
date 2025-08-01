//
//  FloatingToolbarView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/25/25.
//

import SwiftUI

struct FloatingToolbarView: View {
    @Binding var selectedTool: CanvasTool
    @Binding var strokeWidth: Double
    @Binding var strokeColor: Color
    @State private var showingColorPicker = false
    
    var body: some View {
        HStack(spacing: 6) {
            // Selection Tool
            ToolButton(
                icon: "cursorarrow",
                isSelected: selectedTool == .select,
                action: { selectedTool = .select }
            )
            
            // Grid Tool
            ToolButton(
                icon: "grid",
                isSelected: selectedTool == .grid,
                action: { selectedTool = .grid }
            )
            
            // Tag Tool
            ToolButton(
                icon: "tag",
                isSelected: selectedTool == .label,
                action: { selectedTool = .label }
            )
            
            Divider()
                .frame(height: 16)
                .foregroundColor(.primary.opacity(0.2))
            
            // Color Picker
            Button {
                showingColorPicker.toggle()
            } label: {
                Circle()
                    .fill(strokeColor)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(.primary.opacity(0.2), lineWidth: 0.5)
                    )
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingColorPicker) {
                ColorPicker("Stroke Color", selection: $strokeColor)
                    .labelsHidden()
                    .padding()
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Floating Tool Button

struct ToolButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isSelected ? .blue : .clear)
                )
        }
        .buttonStyle(.plain)
    }
}

struct FloatingToolButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .help(iconTooltip(icon))
    }
    
    private func iconTooltip(_ icon: String) -> String {
            switch icon {
            case "cursorarrow": return "Select"
            case "grid": return "Grid"
            case "tag": return "Tag"
            default: return "Tool"
            }
        }
}

#Preview {
    FloatingToolbarView(
        selectedTool: .constant(.select),
        strokeWidth: .constant(2.0),
        strokeColor: .constant(.blue)
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
