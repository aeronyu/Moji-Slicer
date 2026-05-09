import AppKit
import Foundation
import Testing
@testable import Moji_Slicer

struct GridImageExporterTests {
    @Test func exportsPNGFilesForFrames() throws {
        let image = makeTestImage(width: 20, height: 10)
        let frames = [
            GridFramePlan(index: 0, row: 0, column: 0, rect: CGRect(x: 0, y: 0, width: 10, height: 10)),
            GridFramePlan(index: 1, row: 0, column: 1, rect: CGRect(x: 10, y: 0, width: 10, height: 10))
        ]
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let urls = try GridImageExporter.exportPNGFrames(from: image, frames: frames, to: directory)

        #expect(urls.count == 2)
        #expect(FileManager.default.fileExists(atPath: urls[0].path))
        #expect(FileManager.default.fileExists(atPath: urls[1].path))
        #expect((try Data(contentsOf: urls[0])).isEmpty == false)
        #expect((try Data(contentsOf: urls[1])).isEmpty == false)
    }

    private func makeTestImage(width: Int, height: Int) -> NSImage {
        let image = NSImage(size: NSSize(width: width, height: height))
        image.lockFocus()
        NSColor.red.setFill()
        NSRect(x: 0, y: 0, width: width / 2, height: height).fill()
        NSColor.blue.setFill()
        NSRect(x: width / 2, y: 0, width: width / 2, height: height).fill()
        image.unlockFocus()
        return image
    }
}
