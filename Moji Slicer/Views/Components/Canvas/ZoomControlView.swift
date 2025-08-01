//
//  ZoomControlView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/25/25.
//

import SwiftUI

struct ZoomControlView: View {
    @Binding var zoomLevel: Double
    @Binding var canvasOffset: CGSize
    
    private let zoomLevels: [Double] = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0]
    
    var body: some View {
        HStack(spacing: 4) {
            // Zoom Out Button
            Button {
                zoomOut()
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .disabled(zoomLevel <= zoomLevels.first ?? 0.25)
            
            // Zoom Level Display
            Button {
                resetZoom()
            } label: {
                Text("\(Int(zoomLevel * 100))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(minWidth: 40)
            }
            .buttonStyle(.plain)
            .help("Click to reset to 100%")
            
            // Zoom In Button
            Button {
                zoomIn()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .disabled(zoomLevel >= zoomLevels.last ?? 4.0)
            
            Divider()
                .frame(height: 16)
                .foregroundColor(.primary.opacity(0.2))
            
            // Resume to Center Button
            Button {
                resumeToCenter()
            } label: {
                Image(systemName: "scope")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .help("Resume to center")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(.primary.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func zoomIn() {
        if let currentIndex = zoomLevels.firstIndex(of: zoomLevel),
           currentIndex < zoomLevels.count - 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                zoomLevel = zoomLevels[currentIndex + 1]
            }
        }
    }
    
    private func zoomOut() {
        if let currentIndex = zoomLevels.firstIndex(of: zoomLevel),
           currentIndex > 0 {
            withAnimation(.easeInOut(duration: 0.2)) {
                zoomLevel = zoomLevels[currentIndex - 1]
            }
        }
    }
    
    private func resetZoom() {
        withAnimation(.easeInOut(duration: 0.3)) {
            zoomLevel = 1.0
        }
    }
    
    private func resumeToCenter() {
        withAnimation(.easeInOut(duration: 0.5)) {
            canvasOffset = .zero
            zoomLevel = 1.0
        }
    }
}

#Preview {
    ZoomControlView(
        zoomLevel: .constant(1.0), 
        canvasOffset: .constant(.zero)
    )
    .padding()
    .background(Color.gray)
}
