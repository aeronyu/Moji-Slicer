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
    @State private var showingImporter = false
    @State private var message: String?

    private var frames: [GridFramePlan] {
        guard let image else { return [] }
        let spec = GridSpec(
            rows: rows,
            columns: columns,
            bounds: CGRect(origin: .zero, size: image.size),
            horizontalGap: horizontalGap,
            verticalGap: verticalGap,
            padding: padding
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
                Text("Output")
                    .font(.headline)
                Text("\(frames.count) frames")
                    .foregroundStyle(.secondary)
                if let message {
                    Text(message)
                        .foregroundStyle(.red)
                }
            }

            Spacer()
        }
    }

    private var preview: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
            if let image {
                GridPreview(image: image, frames: frames)
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
                message = "Could not load image."
                return
            }
            image = loadedImage
            imageName = url.lastPathComponent
            message = nil
        } catch {
            message = error.localizedDescription
        }
    }
}

private struct GridPreview: View {
    let image: NSImage
    let frames: [GridFramePlan]

    var body: some View {
        GeometryReader { geometry in
            let scale = min(
                geometry.size.width / max(image.size.width, 1),
                geometry.size.height / max(image.size.height, 1)
            )
            let displaySize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let origin = CGPoint(x: (geometry.size.width - displaySize.width) / 2, y: (geometry.size.height - displaySize.height) / 2)

            ZStack(alignment: .topLeading) {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: displaySize.width, height: displaySize.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                ForEach(frames) { frame in
                    Rectangle()
                        .stroke(.blue, lineWidth: 1)
                        .frame(width: frame.rect.width * scale, height: frame.rect.height * scale)
                        .position(x: origin.x + frame.rect.midX * scale, y: origin.y + frame.rect.midY * scale)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
