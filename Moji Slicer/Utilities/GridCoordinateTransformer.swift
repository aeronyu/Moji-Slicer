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
        // Get the image's actual frame in canvas coordinates
        // Canvas uses center-based coordinates, but image display uses position as top-left
        let imageDisplayFrame = CGRect(
            x: canvasImage.position.x - canvasImage.size.width * canvasImage.scale / 2,
            y: canvasImage.position.y - canvasImage.size.height * canvasImage.scale / 2,
            width: canvasImage.size.width * canvasImage.scale,
            height: canvasImage.size.height * canvasImage.scale
        )
        
        // Calculate the intersection of grid and image in canvas space
        let intersection = grid.frame.intersection(imageDisplayFrame)
        
        // If no intersection, return a zero-sized grid
        if intersection.isEmpty {
            return GridModel(
                name: grid.name,
                frame: CGRect.zero,
                rows: grid.rows,
                columns: grid.columns,
                thickness: grid.thickness,
                visualThickness: grid.visualThickness,
                color: grid.color,
                lineStyle: grid.lineStyle
            )
        }
        
        // Transform intersection to image-relative coordinates (top-left origin)
        let relativeFrame = CGRect(
            x: intersection.minX - imageDisplayFrame.minX,
            y: intersection.minY - imageDisplayFrame.minY,
            width: intersection.width,
            height: intersection.height
        )
        
        // Scale to original image pixel coordinates
        let scaleFactor = 1.0 / canvasImage.scale
        let imageSpaceFrame = CGRect(
            x: relativeFrame.minX * scaleFactor,
            y: relativeFrame.minY * scaleFactor,
            width: relativeFrame.width * scaleFactor,
            height: relativeFrame.height * scaleFactor
        )
        
        // Ensure the frame is within image bounds
        let clampedFrame = CGRect(
            x: max(0, imageSpaceFrame.minX),
            y: max(0, imageSpaceFrame.minY),
            width: min(imageSpaceFrame.width, canvasImage.size.width - max(0, imageSpaceFrame.minX)),
            height: min(imageSpaceFrame.height, canvasImage.size.height - max(0, imageSpaceFrame.minY))
        )
        
        // Create new grid with transformed coordinates
        return GridModel(
            name: grid.name,
            frame: clampedFrame,
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
        let imageDisplayFrame = CGRect(
            x: canvasImage.position.x - canvasImage.size.width * canvasImage.scale / 2,
            y: canvasImage.position.y - canvasImage.size.height * canvasImage.scale / 2,
            width: canvasImage.size.width * canvasImage.scale,
            height: canvasImage.size.height * canvasImage.scale
        )
        return grid.frame.intersects(imageDisplayFrame)
    }
    
    /// Calculate the effective slicing area for a grid-image pair
    /// - Parameters:
    ///   - grid: The grid model
    ///   - canvasImage: The canvas image
    /// - Returns: The intersection rectangle in canvas coordinates, or nil if no intersection
    static func slicingArea(for grid: GridModel, on canvasImage: CanvasImage) -> CGRect? {
        let imageDisplayFrame = CGRect(
            x: canvasImage.position.x - canvasImage.size.width * canvasImage.scale / 2,
            y: canvasImage.position.y - canvasImage.size.height * canvasImage.scale / 2,
            width: canvasImage.size.width * canvasImage.scale,
            height: canvasImage.size.height * canvasImage.scale
        )
        let intersection = grid.frame.intersection(imageDisplayFrame)
        return intersection.isEmpty ? nil : intersection
    }
}