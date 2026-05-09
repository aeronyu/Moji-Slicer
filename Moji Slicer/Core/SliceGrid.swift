//
//  SliceGrid.swift
//  Moji Slicer
//
//  Created for the v2 rewrite.
//

import CoreGraphics

/// User-configurable grid settings for slicing a source image.
///
/// The grid math is expressed in source-image pixel coordinates, not SwiftUI view
/// coordinates. Keeping this model UI-independent makes the slicing behavior easy to
/// unit test and reuse from both preview and export flows.
struct SliceGrid: Equatable {
    var rows: Int
    var columns: Int
    var sourceRect: CGRect
    var horizontalGap: CGFloat
    var verticalGap: CGFloat
    var padding: CGFloat

    init(
        rows: Int,
        columns: Int,
        sourceRect: CGRect,
        horizontalGap: CGFloat = 0,
        verticalGap: CGFloat = 0,
        padding: CGFloat = 0
    ) {
        self.rows = rows
        self.columns = columns
        self.sourceRect = sourceRect
        self.horizontalGap = horizontalGap
        self.verticalGap = verticalGap
        self.padding = padding
    }
}
