//
//  GridModel.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI
import Foundation

enum GridLineStyle: String, CaseIterable, Codable {
    case solid = "Solid"
    case dashed = "Dashed"
    case dotted = "Dotted"
    
    var icon: String {
        switch self {
        case .solid: return "minus"
        case .dashed: return "minus.rectangle"
        case .dotted: return "minus.circle"
        }
    }
}

struct GridModel: Identifiable, Codable, Equatable {
    var id = UUID() // Changed from let to var to fix Codable warning
    var name: String
    var frame: CGRect
    var rows: Int
    var columns: Int
    var thickness: Double // Logical thickness for slicing (0 = no pixels lost)
    var visualThickness: Double = 2.0 // Visual thickness for display
    var color: Color
    var lineStyle: GridLineStyle = .solid
    var isSelected: Bool = false
    
    // Equatable implementation
    static func == (lhs: GridModel, rhs: GridModel) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.frame == rhs.frame &&
               lhs.rows == rhs.rows &&
               lhs.columns == rhs.columns &&
               lhs.thickness == rhs.thickness &&
               lhs.visualThickness == rhs.visualThickness &&
               lhs.lineStyle == rhs.lineStyle &&
               lhs.isSelected == rhs.isSelected
    }
    
    init(
        name: String = "Grid",
        frame: CGRect = CGRect(x: 100, y: 100, width: 200, height: 200),
        rows: Int = 3,
        columns: Int = 3,
        thickness: Double = 0.0, // Logical thickness (default 0 = no pixel loss)
        visualThickness: Double = 2.0, // Visual thickness (always visible)
        color: Color = .blue,
        lineStyle: GridLineStyle = .solid
    ) {
        self.name = name
        self.frame = frame
        self.rows = rows
        self.columns = columns
        self.thickness = thickness
        self.visualThickness = visualThickness
        self.color = color
        self.lineStyle = lineStyle
    }
    
    // Codable implementation for Color
    enum CodingKeys: String, CodingKey {
        case name, frame, rows, columns, thickness, visualThickness, colorData, lineStyle
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        frame = try container.decode(CGRect.self, forKey: .frame)
        rows = try container.decode(Int.self, forKey: .rows)
        columns = try container.decode(Int.self, forKey: .columns)
        thickness = try container.decode(Double.self, forKey: .thickness)
        visualThickness = try container.decodeIfPresent(Double.self, forKey: .visualThickness) ?? 2.0
        lineStyle = try container.decodeIfPresent(GridLineStyle.self, forKey: .lineStyle) ?? .solid
        
        // Decode color from data
        let colorData = try container.decode(Data.self, forKey: .colorData)
        if let nsColor = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? NSColor {
            color = Color(nsColor)
        } else {
            color = .blue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(frame, forKey: .frame)
        try container.encode(rows, forKey: .rows)
        try container.encode(columns, forKey: .columns)
        try container.encode(thickness, forKey: .thickness)
        try container.encode(visualThickness, forKey: .visualThickness)
        try container.encode(lineStyle, forKey: .lineStyle)
        
        // Encode color to data
        let nsColor = NSColor(color)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .colorData)
    }
    
    // Calculate cell size
    var cellSize: CGSize {
        return CGSize(
            width: frame.width / Double(columns),
            height: frame.height / Double(rows)
        )
    }
    
    // Get all cell frames for slicing
    func getCellFrames() -> [CGRect] {
        var cellFrames: [CGRect] = []
        let cellWidth = frame.width / Double(columns)
        let cellHeight = frame.height / Double(rows)
        
        for row in 0..<rows {
            for col in 0..<columns {
                let x = frame.minX + (Double(col) * cellWidth) + thickness
                let y = frame.minY + (Double(row) * cellHeight) + thickness
                let width = cellWidth - (thickness * 2)
                let height = cellHeight - (thickness * 2)
                
                cellFrames.append(CGRect(x: x, y: y, width: width, height: height))
            }
        }
        
        return cellFrames
    }
}
