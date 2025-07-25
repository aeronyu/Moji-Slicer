//
//  CanvasImage.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI
import Foundation

struct CanvasImage: Identifiable, Codable {
    let id = UUID()
    var imageName: String // Store filename instead of NSImage for codability
    var position: CGPoint
    var scale: Double
    var size: CGSize // Original image size
    
    // Store the actual image data (non-codable)
    private var _imageData: Data?
    
    // Non-codable computed property for the actual image
    var image: NSImage? {
        if let data = _imageData {
            return NSImage(data: data)
        }
        // Fallback to named image
        return NSImage(named: imageName)
    }
    
    init(image: NSImage, position: CGPoint = .zero, scale: Double = 1.0) {
        self.imageName = "imported_\(UUID().uuidString)"
        self.position = position
        self.scale = scale
        self.size = image.size
        self._imageData = image.tiffRepresentation
    }
    
    init(imageName: String, position: CGPoint, scale: Double, size: CGSize) {
        self.imageName = imageName
        self.position = position
        self.scale = scale
        self.size = size
        self._imageData = nil
    }
    
    // Custom Codable implementation
    enum CodingKeys: String, CodingKey {
        case imageName, position, scale, size, imageData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imageName = try container.decode(String.self, forKey: .imageName)
        position = try container.decode(CGPoint.self, forKey: .position)
        scale = try container.decode(Double.self, forKey: .scale)
        size = try container.decode(CGSize.self, forKey: .size)
        _imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(position, forKey: .position)
        try container.encode(scale, forKey: .scale)
        try container.encode(size, forKey: .size)
        try container.encodeIfPresent(_imageData, forKey: .imageData)
    }
    
    // Calculate the display frame
    var displayFrame: CGRect {
        let scaledSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )
        return CGRect(
            x: position.x,
            y: position.y,
            width: scaledSize.width,
            height: scaledSize.height
        )
    }
}
