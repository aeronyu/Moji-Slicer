//
//  SlicingEngine.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI
import CoreGraphics

class SlicingEngine: ObservableObject {
    
    /// Slice a single grid from an image
    static func sliceGrid(_ grid: GridModel, from image: NSImage, outputDirectory: URL) throws -> [URL] {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw SlicingError.invalidImage
        }
        
        let cellFrames = grid.getCellFrames()
        var outputURLs: [URL] = []
        
        for (index, cellFrame) in cellFrames.enumerated() {
            let row = index / grid.columns
            let col = index % grid.columns
            
            // Create cropping rectangle
            let cropRect = CGRect(
                x: cellFrame.origin.x,
                y: cellFrame.origin.y,
                width: cellFrame.size.width,
                height: cellFrame.size.height
            )
            
            // Crop the image
            if let croppedCGImage = cgImage.cropping(to: cropRect) {
                let croppedImage = NSImage(cgImage: croppedCGImage, size: cellFrame.size)
                
                // Generate filename
                let filename = "\(grid.name)_\(row)_\(col).png"
                let outputURL = outputDirectory.appendingPathComponent(filename)
                
                // Save the image
                try saveImage(croppedImage, to: outputURL)
                outputURLs.append(outputURL)
            }
        }
        
        return outputURLs
    }
    
    /// Slice all grids from an image
    static func sliceAllGrids(_ grids: [GridModel], from image: NSImage, outputDirectory: URL) throws -> [URL] {
        var allOutputURLs: [URL] = []
        
        for grid in grids {
            let gridOutputURLs = try sliceGrid(grid, from: image, outputDirectory: outputDirectory)
            allOutputURLs.append(contentsOf: gridOutputURLs)
        }
        
        return allOutputURLs
    }
    
    /// Save an NSImage to a file URL
    private static func saveImage(_ image: NSImage, to url: URL) throws {
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            throw SlicingError.failedToSaveImage
        }
        
        try pngData.write(to: url)
    }
    
    /// Create output directory structure
    static func createOutputDirectory(baseName: String) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputDirectory = documentsPath.appendingPathComponent("MojiSlicer_\(baseName)_\(Date().timeIntervalSince1970)")
        
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        return outputDirectory
    }
}

enum SlicingError: LocalizedError {
    case invalidImage
    case failedToSaveImage
    case invalidOutputDirectory
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Unable to process the selected image"
        case .failedToSaveImage:
            return "Failed to save the sliced image"
        case .invalidOutputDirectory:
            return "Invalid output directory"
        }
    }
}
