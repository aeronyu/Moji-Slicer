import CoreGraphics

struct GridFrame: Equatable, Identifiable {
    let number: Int
    let line: Int
    let column: Int
    let frame: CGRect

    var id: Int { number }
}
