//
//  SliceCell.swift
//  Moji Slicer
//
//  Created for the v2 rewrite.
//

import CoreGraphics

/// A single output cell produced by slicing a source image grid.
struct SliceCell: Equatable, Identifiable {
    let index: Int
    let row: Int
    let column: Int
    let rect: CGRect

    var id: Int { index }

    var fileStem: String {
        String(format: "emoji_%03d", index + 1)
    }
}
