import CoreGraphics
import Testing
@testable import Moji_Slicer

struct GridFramePlannerTests {
    @Test func simpleTwoByTwoGrid() throws {
        let spec = GridSpec(rows: 2, columns: 2, bounds: CGRect(x: 0, y: 0, width: 100, height: 100))
        let frames = try GridFramePlanner.makeFrames(for: spec)

        #expect(frames.count == 4)
        #expect(frames[0].rect == CGRect(x: 0, y: 0, width: 50, height: 50))
        #expect(frames[3].rect == CGRect(x: 50, y: 50, width: 50, height: 50))
    }

    @Test func gridWithGapsAndPadding() throws {
        let spec = GridSpec(
            rows: 1,
            columns: 2,
            bounds: CGRect(x: 10, y: 20, width: 100, height: 40),
            horizontalGap: 10,
            padding: 5
        )
        let frames = try GridFramePlanner.makeFrames(for: spec)

        #expect(frames.count == 2)
        #expect(frames[0].rect == CGRect(x: 15, y: 25, width: 35, height: 30))
        #expect(frames[1].rect == CGRect(x: 70, y: 25, width: 35, height: 30))
    }
}
