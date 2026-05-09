import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var image: NSImage?
    @State private var imageName = "No image selected"
    @State private var rows = 3
    @State private var columns = 3
    @State private var horizontalGap = 0.0
    @State private var verticalGap = 0.0
    @State private var padding = 0.0
    @State private var cropRect: CGRect?
    @State private var showingImporter = false
    @State private var message: String?
    @State private var isErrorMessage = false

    private var safeHorizontalGap: Double { max(horizontalGap, 0) }
    private var safeVerticalGap: Double { max(verticalGap, 0) }
    private var safePadding: Double { max(padding, 0) }

    private var activeCropRect: CGRect? {
        guard let image else { return nil }
        return normalizedCropRect(for: image)
    }

    private var frames: [GridFramePlan] {
        guard let bounds = activeCropRect else { return [] }
        let spec = GridSpec(
            rows: rows,
            columns: columns,
            bounds: bounds,
            horizontalGap: safeHorizontalGap,
            verticalGap: safeVerticalGap,
            padding: safePadding
        )
        return (try? GridFramePlanner.makeFrames(for: spec)) ?? []
    }

    var body: some View {
        HStack(spacing: 0) {
            controls
                .frame(width: 300)
                .padding()

            Divider()

            preview
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 960, minHeight: 640)
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false,
            onCompletion: importImage
        )
        .onChange(of: horizontalGap) { _, newValue in
            if newValue < 0 { horizontalGap = 0 }
        }
        .onChange(of: verticalGap) { _, newValue in
            if newValue < 0 { verticalGap = 0 }
        }
        .onChange(of: padding) { _, newValue in
            if newValue < 0 { padding = 0 }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Moji Slicer v2")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 8) {
                Text("Image")
                    .font(.headline)
                Text(imageName)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Button("Import Image") {
                    showingImporter = true
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Grid")
                    .font(.headline)
                Stepper("Rows: \(rows)", value: $rows, in: 1...30)
                Stepper("Columns: \(columns)", value: $columns, in: 1...30)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Spacing")
                    .font(.headline)
                numericField("Horizontal gap", value: $horizontalGap)
                numericField("Vertical gap", value: $verticalGap)
                numericField("Padding", value: $padding)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Slice Frame")
                    .font(.headline)
                Text("Drag the frame or its corner handles in the preview.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("Reset Frame") {
                    resetCropRect()
                }
                .disabled(image == nil)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Output")
                    .font(.headline)
                Text("\(frames.count) frames")
                    .foregroundStyle(.secondary)

                Button("Export PNGs") {
                    exportFrames()
                }
                .disabled(image == nil || frames.isEmpty)

                if let message {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(isErrorMessage ? .red : .secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer()
        }
    }

    private var preview: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
            if let image, let cropRect = activeCropRect {
                GridPreview(
                    image: image,
                    cropRect: cropRect,
                    frames: frames,
                    onCropRectChanged: { newRect in
                        self.cropRect = newRect
                    }
                )
                .padding(32)
            } else {
                ContentUnavailableView(
                    "Import a grid image",
                    systemImage: "square.grid.3x3",
                    description: Text("Set rows, columns, gaps, and padding to preview each output frame.")
                )
            }
        }
    }

    private func numericField(_ label: String, value: Binding<Double>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", value: value, format: .number)
                .frame(width: 72)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func importImage(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else { return }
            let scoped = url.startAccessingSecurityScopedResource()
            defer {
                if scoped { url.stopAccessingSecurityScopedResource() }
            }
            guard let loadedImage = NSImage(contentsOf: url) else {
                showMessage("Could not load image.", isError: true)
                return
            }
            image = loadedImage
            imageName = url.lastPathComponent
            cropRect = CGRect(origin: .zero, size: loadedImage.size)
            showMessage("Loaded \(url.lastPathComponent).", isError: false)
        } catch {
            showMessage(error.localizedDescription, isError: true)
        }
    }

    private func exportFrames() {
        guard let image else {
            showMessage("Import an image before exporting.", isError: true)
            return
        }

        let panel = NSOpenPanel()
        panel.title = "Choose Export Folder"
        panel.prompt = "Export"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false

        guard panel.runModal() == .OK, let directory = panel.url else {
            return
        }

        let scoped = directory.startAccessingSecurityScopedResource()
        defer {
            if scoped { directory.stopAccessingSecurityScopedResource() }
        }

        do {
            let urls = try GridImageExporter.exportPNGFrames(from: image, frames: frames, to: directory)
            showMessage("Exported \(urls.count) PNG files.", isError: false)
            NSWorkspace.shared.activateFileViewerSelecting(urls)
        } catch {
            showMessage(error.localizedDescription, isError: true)
        }
    }

    private func resetCropRect() {
        guard let image else { return }
        cropRect = CGRect(origin: .zero, size: image.size)
    }

    private func normalizedCropRect(for image: NSImage) -> CGRect {
        let imageBounds = CGRect(origin: .zero, size: image.size)
        guard var rect = cropRect else { return imageBounds }
        rect = rect.standardized.intersection(imageBounds)
        if rect.width < 1 || rect.height < 1 {
            return imageBounds
        }
        return rect
    }

    private func showMessage(_ text: String, isError: Bool) {
        message = text
        isErrorMessage = isError
    }
}

private struct GridPreview: View {
    let image: NSImage
    let cropRect: CGRect
    let frames: [GridFramePlan]
    let onCropRectChanged: (CGRect) -> Void

    var body: some View {
        GeometryReader { geometry in
            let metrics = PreviewMetrics(imageSize: image.size, availableSize: geometry.size)

            ZStack(alignment: .topLeading) {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: metrics.displaySize.width, height: metrics.displaySize.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                ForEach(frames) { frame in
                    let displayRect = metrics.displayRect(for: frame.rect)
                    Rectangle()
                        .stroke(.blue, lineWidth: 1)
                        .frame(width: displayRect.width, height: displayRect.height)
                        .position(x: displayRect.midX, y: displayRect.midY)
                }

                ResizableCropOverlay(
                    cropRect: cropRect,
                    metrics: metrics,
                    onCropRectChanged: onCropRectChanged
                )
            }
        }
    }
}

private struct ResizableCropOverlay: View {
    let cropRect: CGRect
    let metrics: PreviewMetrics
    let onCropRectChanged: (CGRect) -> Void

    private let minimumSize: CGFloat = 12
    private let handleSize: CGFloat = 12

    var body: some View {
        let displayRect = metrics.displayRect(for: cropRect)

        ZStack(alignment: .topLeading) {
            Rectangle()
                .stroke(.orange, style: StrokeStyle(lineWidth: 2, dash: [7, 4]))
                .background(Color.orange.opacity(0.08))
                .frame(width: displayRect.width, height: displayRect.height)
                .position(x: displayRect.midX, y: displayRect.midY)
                .contentShape(Rectangle())
                .gesture(moveGesture())

            ForEach(CropHandle.allCases, id: \.self) { handle in
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: handleSize, height: handleSize)
                    .position(handle.position(in: displayRect))
                    .gesture(resizeGesture(for: handle))
            }
        }
    }

    private func moveGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                let delta = CGSize(
                    width: value.translation.width / metrics.scale,
                    height: value.translation.height / metrics.scale
                )
                updateCropRect(cropRect.offsetBy(dx: delta.width, dy: delta.height))
            }
    }

    private func resizeGesture(for handle: CropHandle) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let dx = value.translation.width / metrics.scale
                let dy = value.translation.height / metrics.scale
                var rect = cropRect

                switch handle {
                case .topLeft:
                    rect.origin.x += dx
                    rect.origin.y += dy
                    rect.size.width -= dx
                    rect.size.height -= dy
                case .topRight:
                    rect.origin.y += dy
                    rect.size.width += dx
                    rect.size.height -= dy
                case .bottomLeft:
                    rect.origin.x += dx
                    rect.size.width -= dx
                    rect.size.height += dy
                case .bottomRight:
                    rect.size.width += dx
                    rect.size.height += dy
                }

                updateCropRect(rect)
            }
    }

    private func updateCropRect(_ rect: CGRect) {
        let imageBounds = CGRect(origin: .zero, size: metrics.imageSize)
        let normalized = rect.standardized
        let clamped = CGRect(
            x: min(max(normalized.minX, imageBounds.minX), imageBounds.maxX - minimumSize),
            y: min(max(normalized.minY, imageBounds.minY), imageBounds.maxY - minimumSize),
            width: min(max(normalized.width, minimumSize), imageBounds.maxX - min(max(normalized.minX, imageBounds.minX), imageBounds.maxX - minimumSize)),
            height: min(max(normalized.height, minimumSize), imageBounds.maxY - min(max(normalized.minY, imageBounds.minY), imageBounds.maxY - minimumSize))
        )
        onCropRectChanged(clamped)
    }
}

private enum CropHandle: CaseIterable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    func position(in rect: CGRect) -> CGPoint {
        switch self {
        case .topLeft:
            return CGPoint(x: rect.minX, y: rect.minY)
        case .topRight:
            return CGPoint(x: rect.maxX, y: rect.minY)
        case .bottomLeft:
            return CGPoint(x: rect.minX, y: rect.maxY)
        case .bottomRight:
            return CGPoint(x: rect.maxX, y: rect.maxY)
        }
    }
}

private struct PreviewMetrics {
    let imageSize: CGSize
    let availableSize: CGSize

    var scale: CGFloat {
        min(
            availableSize.width / max(imageSize.width, 1),
            availableSize.height / max(imageSize.height, 1)
        )
    }

    var displaySize: CGSize {
        CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    }

    var origin: CGPoint {
        CGPoint(
            x: (availableSize.width - displaySize.width) / 2,
            y: (availableSize.height - displaySize.height) / 2
        )
    }

    func displayRect(for imageRect: CGRect) -> CGRect {
        CGRect(
            x: origin.x + imageRect.minX * scale,
            y: origin.y + imageRect.minY * scale,
            width: imageRect.width * scale,
            height: imageRect.height * scale
        )
    }
}

#Preview {
    ContentView()
}
