//
//  GridProperties.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI

enum GridType: String, CaseIterable {
    case square = "Square"
    case rectangle = "Rectangle"
    
    var icon: String {
        switch self {
        case .square: return "square.grid.3x3"
        case .rectangle: return "rectangle.grid.3x2"
        }
    }
}

/// Modern @Observable implementation of GridProperties using Swift 6.1+ features
/// Automatically synchronizes square/rectangle modes and triggers SwiftUI updates
@Observable
class GridProperties {
    // MARK: - Grid Type & Mode Management
    var gridType: GridType = .square {
        didSet { validateAndUpdateDimensions() }
    }
    
    // MARK: - Single Source of Truth for Dimensions
    /// For square grids, this is the authoritative size
    var squareSize: Int = 3
    
    /// Private backing storage for rectangle dimensions
    private var _rectangleRows: Int = 3
    private var _rectangleColumns: Int = 3
    
    // MARK: - Computed Properties with Automatic Synchronization
    var rows: Int {
        get { 
            gridType == .square ? squareSize : _rectangleRows 
        }
        set { 
            if gridType == .square { 
                squareSize = max(1, newValue) // Ensure valid values
            } else { 
                _rectangleRows = max(1, newValue)
            }
        }
    }
    
    var columns: Int {
        get { 
            gridType == .square ? squareSize : _rectangleColumns 
        }
        set { 
            if gridType == .square { 
                squareSize = max(1, newValue)
            } else { 
                _rectangleColumns = max(1, newValue)
            }
        }
    }
    
    // MARK: - Visual & Styling Properties
    var thickness: Double = 0.0 // Logical thickness for slicing (0 = no pixels lost)
    var visualThickness: Double = 2.0 // Visual thickness for display guidance
    var color: Color = .blue
    var lineStyle: GridLineStyle = .solid
    var tagName: String = ""
    
    // MARK: - Convenience Computed Properties
    /// Total number of cells in the grid
    var totalCells: Int {
        rows * columns
    }
    
    /// Aspect ratio of the grid (width/height)
    var aspectRatio: Double {
        Double(columns) / Double(rows)
    }
    
    /// Whether the grid is currently square (regardless of mode)
    var isActuallySquare: Bool {
        rows == columns
    }
    
    // MARK: - Initialization
    init(
        gridType: GridType = .square,
        squareSize: Int = 3,
        rectangleRows: Int = 3,
        rectangleColumns: Int = 4,
        thickness: Double = 0.0,
        visualThickness: Double = 2.0,
        color: Color = .blue,
        lineStyle: GridLineStyle = .solid,
        tagName: String = ""
    ) {
        self.gridType = gridType
        self.squareSize = max(1, squareSize)
        self._rectangleRows = max(1, rectangleRows)
        self._rectangleColumns = max(1, rectangleColumns)
        self.thickness = thickness
        self.visualThickness = visualThickness
        self.color = color
        self.lineStyle = lineStyle
        self.tagName = tagName
        
        validateAndUpdateDimensions()
    }
    
    // MARK: - Private Validation Methods
    private func validateAndUpdateDimensions() {
        if gridType == .square {
            squareSize = max(1, min(50, squareSize))
        } else {
            _rectangleRows = max(1, min(50, _rectangleRows))
            _rectangleColumns = max(1, min(50, _rectangleColumns))
        }
    }
    
    // MARK: - Convenience Methods for Backward Compatibility
    /// Legacy method - now automatic with @Observable
    @available(*, deprecated, message: "Synchronization is now automatic with @Observable")
    func updateForSquareMode() {
        // No-op: synchronization is now automatic
    }
    
    /// Legacy method - now automatic with @Observable  
    @available(*, deprecated, message: "Synchronization is now automatic with @Observable")
    func updateSquareSizeFromDimensions() {
        // No-op: synchronization is now automatic
    }
}
