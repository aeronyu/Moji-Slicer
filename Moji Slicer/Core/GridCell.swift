import CoreGraphics

struct GridCell: Equatable, Identifiable {
    let index: Int
    let row: Int
    let column: Int
    let rect: CGRect

    var id: Int { index }
}
