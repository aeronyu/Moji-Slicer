import CoreGraphics
import Foundation

struct GridFramePlan: Equatable, Identifiable {
    let index: Int
    let row: Int
    let column: Int
    let rect: CGRect

    var id: Int { index }
}

enum GridFramePlannerError: Error, Equatable, LocalizedError {
    case invalidRows(Int)
    case invalidColumns(Int)
    case invalidBounds
    case negativeSpacing
    case cellTooSmall

    var errorDescription: String? {
        switch self {
        case .invalidRows(let rows):
            return "Rows must be greater than zero. Received \(rows)."
        case .invalidColumns(let columns):
            return "Columns must be greater than zero. Received \(columns)."
        case .invalidBounds:
            return "Grid bounds must have positive width and height."
        case .negativeSpacing:
            return "Gap and padding values cannot be negative."
        case .cellTooSmall:
            return "The grid settings leave no usable area for each cell."
        }
    }
}

enum GridFramePlanner {
    static func makeFrames(for spec: GridSpec) throws -> [GridFramePlan] {
        try validate(spec)

        let totalGapWidth = CGFloat(spec.columns - 1) * spec.horizontalGap
        let totalGapHeight = CGFloat(spec.rows - 1) * spec.verticalGap
        let rawWidth = (spec.bounds.width - totalGapWidth) / CGFloat(spec.columns)
        let rawHeight = (spec.bounds.height - totalGapHeight) / CGFloat(spec.rows)
        let outputWidth = rawWidth - spec.padding * 2
        let outputHeight = rawHeight - spec.padding * 2

        guard outputWidth > 0, outputHeight > 0 else {
            throw GridFramePlannerError.cellTooSmall
        }

        var frames: [GridFramePlan] = []
        frames.reserveCapacity(spec.rows * spec.columns)

        for row in 0..<spec.rows {
            for column in 0..<spec.columns {
                let x = spec.bounds.minX + CGFloat(column) * (rawWidth + spec.horizontalGap) + spec.padding
                let y = spec.bounds.minY + CGFloat(row) * (rawHeight + spec.verticalGap) + spec.padding
                let rect = CGRect(x: x, y: y, width: outputWidth, height: outputHeight)
                frames.append(GridFramePlan(index: frames.count, row: row, column: column, rect: rect))
            }
        }

        return frames
    }

    private static func validate(_ spec: GridSpec) throws {
        guard spec.rows > 0 else { throw GridFramePlannerError.invalidRows(spec.rows) }
        guard spec.columns > 0 else { throw GridFramePlannerError.invalidColumns(spec.columns) }
        guard spec.bounds.width > 0, spec.bounds.height > 0 else { throw GridFramePlannerError.invalidBounds }
        guard spec.horizontalGap >= 0, spec.verticalGap >= 0, spec.padding >= 0 else { throw GridFramePlannerError.negativeSpacing }
    }
}
