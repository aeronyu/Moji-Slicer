import AppKit
import Foundation

enum GridImageExporterError: Error, LocalizedError {
    case missingImageData
    case failedToCrop(Int)
    case failedToEncode(Int)

    var errorDescription: String? {
        switch self {
        case .missingImageData:
            return "Could not read bitmap data from the selected image."
        case .failedToCrop(let index):
            return "Could not crop frame \(index + 1)."
        case .failedToEncode(let index):
            return "Could not encode frame \(index + 1) as PNG."
        }
    }
}

enum GridImageExporter {
    static func exportPNGFrames(
        from image: NSImage,
        frames: [GridFramePlan],
        to directory: URL,
        filePrefix: String = "emoji"
    ) throws -> [URL] {
        var proposedRect = CGRect(origin: .zero, size: image.size)
        guard let cgImage = image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil) else {
            throw GridImageExporterError.missingImageData
        }

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let scaleX = CGFloat(cgImage.width) / max(image.size.width, 1)
        let scaleY = CGFloat(cgImage.height) / max(image.size.height, 1)
        var outputURLs: [URL] = []
        outputURLs.reserveCapacity(frames.count)

        for frame in frames {
            let cropRect = CGRect(
                x: frame.rect.minX * scaleX,
                y: frame.rect.minY * scaleY,
                width: frame.rect.width * scaleX,
                height: frame.rect.height * scaleY
            ).integral

            guard let cropped = cgImage.cropping(to: cropRect) else {
                throw GridImageExporterError.failedToCrop(frame.index)
            }

            let bitmap = NSBitmapImageRep(cgImage: cropped)
            guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
                throw GridImageExporterError.failedToEncode(frame.index)
            }

            let fileName = String(format: "%@_%03d.png", filePrefix, frame.index + 1)
            let outputURL = directory.appendingPathComponent(fileName)
            try pngData.write(to: outputURL, options: .atomic)
            outputURLs.append(outputURL)
        }

        return outputURLs
    }
}
