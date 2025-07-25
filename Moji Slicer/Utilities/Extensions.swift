//
//  Extensions.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI
import AppKit

// MARK: - NSImage Extensions
extension NSImage {
    /// Get the underlying CGImage
    var cgImage: CGImage? {
        return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    /// Create NSImage from CGImage with proper size
    convenience init(cgImage: CGImage, size: CGSize) {
        self.init(size: size)
        self.lockFocus()
        let context = NSGraphicsContext.current?.cgContext
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        self.unlockFocus()
    }
}

// MARK: - View Extensions
extension View {
    /// Apply conditional modifiers
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - CGRect Extensions
extension CGRect {
    /// Get the center point of the rectangle
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    /// Create a new rectangle with adjusted size while maintaining center
    func resized(to newSize: CGSize) -> CGRect {
        let center = self.center
        return CGRect(
            x: center.x - newSize.width / 2,
            y: center.y - newSize.height / 2,
            width: newSize.width,
            height: newSize.height
        )
    }
    
    /// Check if the rectangle contains a point with some tolerance
    func contains(_ point: CGPoint, tolerance: CGFloat = 0) -> Bool {
        let expandedRect = self.insetBy(dx: -tolerance, dy: -tolerance)
        return expandedRect.contains(point)
    }
}

// MARK: - Color Extensions
extension Color {
    /// Convert Color to hex string
    var hexString: String {
        let nsColor = NSColor(self)
        guard let rgbColor = nsColor.usingColorSpace(.sRGB) else {
            return "#000000"
        }
        
        let red = Int(rgbColor.redComponent * 255)
        let green = Int(rgbColor.greenComponent * 255)
        let blue = Int(rgbColor.blueComponent * 255)
        
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
    
    /// Create Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Get random color for grids
    static var randomGridColor: Color {
        let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .cyan, .yellow]
        return colors.randomElement() ?? .blue
    }
}

// MARK: - FileManager Extensions
extension FileManager {
    /// Get documents directory URL
    var documentsDirectory: URL {
        urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// Create directory if it doesn't exist
    func createDirectoryIfNeeded(at url: URL) throws {
        if !fileExists(atPath: url.path) {
            try createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
}

// MARK: - Array Extensions
extension Array where Element == GridModel {
    /// Get the selected grid
    var selectedGrid: GridModel? {
        return first { $0.isSelected }
    }
    
    /// Get the index of the selected grid
    var selectedGridIndex: Int? {
        return firstIndex { $0.isSelected }
    }
    
    /// Deselect all grids
    mutating func deselectAll() {
        for i in indices {
            self[i].isSelected = false
        }
    }
}
