//
//  CanvasTool.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import Foundation

enum CanvasTool: String, CaseIterable {
    case select = "Select & Move"
    case grid = "Grid"
    case label = "Label"
    
    var icon: String {
        switch self {
        case .select:
            return "arrow.up.left"
        case .grid:
            return "grid"
        case .label:
            return "textformat"
        }
    }
}
