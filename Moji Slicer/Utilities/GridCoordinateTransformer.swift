//
//  GridCoordinateTransformer.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/27/25.
//

import SwiftUI

/// Utility class for handling coordinate transformations between canvas and image space
struct GridCoordinateTransformer {
    
    /// Transform grid coordinates from canvas space to image space for slicing
    /// - Parameters:
    ///   - grid: The grid model with canvas coordinates
    ///   - canvasImage: The canvas image to slice
    /// - Returns: A new GridModel with coordinates transformed to image space
    static func transformGridToImageSpace(_ grid: GridModel, for canvasImage: CanvasImage) -> GridModel {
        // Convert grid coordinates from canvas space to image space
        let imageFrame = canvasImage.displayFrame
        
        // Calculate the intersection of grid and image
        let intersection = grid.frame.intersection(imageFrame)
        
        // Transform to image-relative coordinates
        let relativeFrame = CGRect(
            x: intersection.minX - imageFrame.minX,
            y: intersection.minY - imageFrame.minY,
            width: intersection.width,
            height: intersection.height
        )
        
        // Scale to original image size (accounting for canvas scale)
        let scaleFactor = 1.0 / canvasImage.scale
        let imageSpaceFrame = CGRect(
            x: relativeFrame.minX * scaleFactor,
            y: relativeFrame.minY * scaleFactor,
            width: relativeFrame.width * scaleFactor,
            height: relativeFrame.height * scaleFactor
        )
        
        // Create new grid with transformed coordinates
        return GridModel(
            name: grid.name,
            frame: imageSpaceFrame,
            rows: grid.rows,
            columns: grid.columns,
            thickness: grid.thickness,
            visualThickness: grid.visualThickness,
            color: grid.color,
            lineStyle: grid.lineStyle
        )
    }
    
    /// Validate that a grid intersects with an image and can be sliced
    /// - Parameters:
    ///   - grid: The grid model to validate
    ///   - canvasImage: The canvas image to check intersection with
    /// - Returns: True if the grid can be sliced from the image
    static func gridIntersectsImage(_ grid: GridModel, _ canvasImage: CanvasImage) -> Bool {
        let imageFrame = canvasImage.displayFrame
        return grid.frame.intersects(imageFrame)
    }
    
    /// Calculate the effective slicing area for a grid-image pair
    /// - Parameters:
    ///   - grid: The grid model
    ///   - canvasImage: The canvas image
    /// - Returns: The intersection rectangle in canvas coordinates, or nil if no intersection
    static func slicingArea(for grid: GridModel, on canvasImage: CanvasImage) -> CGRect? {
        let imageFrame = canvasImage.displayFrame
        let intersection = grid.frame.intersection(imageFrame)
        return intersection.isEmpty ? nil : intersection
    }
}