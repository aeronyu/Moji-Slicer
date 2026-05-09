//
//  ImageSlicerTests.swift
//  Moji SlicerTests
//
//  Created for the v2 rewrite.
//

import CoreGraphics
import Testing
@testable import Moji_Slicer

struct ImageSlicerTests {
    @Test func makesEqualCellsForSimpleGrid() throws {
        let grid = SliceGrid(
            rows: 2,
            columns: 2,
            sourceRect: CGRect(x: 0, y: 0, width: 100, height: 100)
        )

        let cells = try ImageSlicer.makeCells(for: grid)

        #expect(cells.count == 4)
        #expect(cells[0] == SliceCell(index: 0, row: 0, column: 0, rect: CGRect(x: 0, y: 0, width: 50, height: 50)))
        #expect(cells[1] == SliceCell(index: 1, row: 0, column: 1, rect: CGRect(x: 50, y: 0, width: 50, height: 50)))
        #expect(cells[2] == SliceCell(index: 2, row: 1, column: 0, rect: CGRect(x: 0, y: 50, width: 50, height: 50)))
        #expect(cells[3] == SliceCell(index: 3, row: 1, column: 1, rect: CGRect(x: 50, y: 50, width: 50, height: 50)))
    }

    @Test func accountsForGapsBetweenCells() throws {
        let grid = SliceGrid(
            rows: 2,
            columns: 2,
            sourceRect: CGRect(x: 0, y: 0, width: 102, height: 104),
            horizontalGap: 2,
            verticalGap: 4
        )

        let cells = try ImageSlicer.makeCells(for: grid)

        #expect(cells[0].rect == CGRect(x: 0, y: 0, width: 50, height: 50))
        #expect(cells[1].rect == CGRect(x: 52, y: 0, width: 50, height: 50))
        #expect(cells[2].rect == CGRect(x: 0, y: 54, width: 50, height: 50))
        #expect(cells[3].rect == CGRect(x: 52, y: 54, width: 50, height: 50))
    }

    @Test func appliesPaddingInsideEachCell() throws {
        let grid = SliceGrid(
            rows: 1,
            columns: 2,
            sourceRect: CGRect(x: 10, y: 20, width: 100, height: 40),
            horizontalGap: 10,
            padding: 5
        )

        let cells = try ImageSlicer.makeCells(for: grid)

        #expect(cells.count == 2)
        #expect(cells[0].rect == CGRect(x: 15, y: 25, width: 35, height: 30))
        #expect(cells[1].rect == CGRect(x: 70, y: 25, width: 35, height: 30))
    }

    @Test func fileStemUsesOneBasedPaddedIndex() {
        let cell = SliceCell(index: 6, row: 1, column: 2, rect: .zero)

        #expect(cell.fileStem == "emoji_007")
    }

    @Test func rejectsInvalidInputs() throws {
        #expect(throws: ImageSlicerError.invalidRowCount(0)) {
            try ImageSlicer.makeCells(
                for: SliceGrid(rows: 0, columns: 1, sourceRect: CGRect(x: 0, y: 0, width: 10, height: 10))
            )
        }

        #expect(throws: ImageSlicerError.invalidColumnCount(0)) {
            try ImageSlicer.makeCells(
                for: SliceGrid(rows: 1, columns: 0, sourceRect: CGRect(x: 0, y: 0, width: 10, height: 10))
            )
        }

        #expect(throws: ImageSlicerError.negativeSpacing) {
            try ImageSlicer.makeCells(
                for: SliceGrid(rows: 1, columns: 1, sourceRect: CGRect(x: 0, y: 0, width: 10, height: 10), padding: -1)
            )
        }

        #expect(throws: ImageSlicerError.cellSizeTooSmall) {
            try ImageSlicer.makeCells(
                for: SliceGrid(rows: 1, columns: 1, sourceRect: CGRect(x: 0, y: 0, width: 10, height: 10), padding: 5)
            )
        }
    }
}
