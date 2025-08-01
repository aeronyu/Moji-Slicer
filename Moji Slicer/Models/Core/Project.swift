//
//  Project.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI
import Foundation

struct Project: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var images: [CanvasImage] = []
    var grids: [GridModel] = []
    var createdDate: Date = Date()
    var lastModified: Date = Date()
    
    static func ==(lhs: Project, rhs: Project) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.images == rhs.images &&
               lhs.grids == rhs.grids &&
               lhs.createdDate == rhs.createdDate &&
               lhs.lastModified == rhs.lastModified
    }
    
    init(name: String) {
        self.name = name
        self.images = []
        self.grids = []
        self.createdDate = Date()
        self.lastModified = Date()
    }
}
