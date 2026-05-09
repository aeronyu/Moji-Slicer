//
//  ImageSlicer.swift
//  Moji Slicer
//
//  Created for the v2 rewrite.
//

import CoreGraphics

enum ImageSlicerError: Error, Equatable, LocalizedError {
    case invalidRowCount(Int)
    case invalidColumnCount(Int)
    case invalidSourceRect(CGRect)
    case negativeSpacing
    case cellSizeTooSmall

    var errorDescription: String? {
        switch self {
        case .invalidRowCount(let rows):
            return "Rows must be greater than zero. Received \(rows)."
        case .invalidColumnCount(let columns):
            return "Columns must be greater than zero. Received \(columns)."
        case .invalidSourceRect:
            return "Source rectangle must have positive width and height."
        case .negativeSpacing:
            return "Gap and padding values cannot be negative."
        case .cellSizeTooSmall:
            return "The configured gaps or padding leave no drawable area for each cell."
        }
    }
}

/// Pure slicing math for turning a grid into source-image crop rectangles.
///
/// This type does not depend on SwiftUI or AppKit. It should be used by both the
/// preview overlay and the final PNG export pipeline so the UI and export behavior
/// cannot drift apart.
enum ImageSlicer {
    static func makeCells(for grid: SliceGrid) throws -> [SliceCell] {
        try validate(grid)

        let totalGapWidth = CGFloat(grid.columns - 1) * grid.horizontalGap
        let totalGapHeight = CGFloat(grid.rows - 1) * grid.verticalGap

        let rawCellWidth = (grid.sourceRect.width - totalGapWidth) / CGFloat(grid.columns)
        let rawCellHeight = (grid.sourceRect.height - totalGapHeight) / CGFloat(grid.rows)

        let outputWidth = rawCellWidth - (grid.padding * 2)
        let outputHeight = rawCellHeight - (grid.padding * 2)

        guard outputWidth > 0, outputHeight > 0 else {
            throw ImageSlicerError.cellSizeTooSmall
        }

        var cells: [SliceCell] = []
        cells.reserveCapacity(grid.rows * grid.columns)

        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                let x = grid.sourceRect.minX
                    + CGFloat(column) * (rawCellWidth + grid.horizontalGap)
                    + grid.padding
                let y = grid.sourceRect.minY
                    + CGFloat(row) * (rawCellHeight + grid.verticalGap)
                    + grid.padding

                let rect = CGRect(
                    x: x,
                    y: y,
                    width: outputWidth,
                    height: outputHeight
                )

                cells.append(
                    SliceCell(
                        index: cells.count,
                        row: row,
                        column: column,
                        rect: rect
                    )
                )
            }
        }

        return cells
    }

    private static func validate(_ grid: SliceGrid) throws {
        guard grid.rows > 0 else {
            throw ImageSlicerError.invalidRowCount(grid.rows)
        }
        guard grid.columns > 0 else {
            throw ImageSlicerError.invalidColumnCount(grid.columns)
        }
        guard grid.sourceRect.width > 0, grid.sourceRect.height > 0 else {
            throw ImageSlicerError.invalidSourceRect(grid.sourceRect)
        }
        guard grid.horizontalGap >= 0, grid.verticalGap >= 0, grid.padding >= 0 else {
            throw ImageSlicerError.negativeSpacing
        }
    }
}
