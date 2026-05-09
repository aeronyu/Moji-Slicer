import CoreGraphics

struct GridSpec: Equatable {
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
