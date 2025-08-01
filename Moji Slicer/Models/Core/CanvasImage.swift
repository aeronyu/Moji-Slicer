//
//  CanvasImage.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI
import Foundation

// Extension to help with NSImage data conversion
extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation,
              let bitmapImageRep = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        return bitmapImageRep.representation(using: .png, properties: [:])
    }
}

struct CanvasImage: Identifiable, Codable, Equatable {
    var id = UUID() // Changed from let to var to fix Codable warning
    var imageName: String // Store filename instead of NSImage for codability
    var position: CGPoint
    var scale: Double
    var size: CGSize // Original image size
    
    // Store the actual image data (non-codable)
    private var _imageData: Data?
    
    // Equatable implementation
    static func == (lhs: CanvasImage, rhs: CanvasImage) -> Bool {
        return lhs.id == rhs.id &&
               lhs.imageName == rhs.imageName &&
               lhs.position == rhs.position &&
               lhs.scale == rhs.scale &&
               lhs.size == rhs.size &&
               lhs._imageData == rhs._imageData
    }
    
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
        
        // Ensure we properly capture the image data
        if let tiffData = image.tiffRepresentation {
            self._imageData = tiffData
            print("CanvasImage init: Successfully stored image data (\(tiffData.count) bytes)")
        } else {
            print("CanvasImage init: Warning - failed to get TIFF representation")
            // Try alternative data formats
            if let pngData = image.pngData {
                self._imageData = pngData
                print("CanvasImage init: Stored PNG data instead (\(pngData.count) bytes)")
            } else {
                print("CanvasImage init: Error - no image data could be stored")
                self._imageData = nil
            }
        }
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
