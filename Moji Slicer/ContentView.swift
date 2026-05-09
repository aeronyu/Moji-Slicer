//
//  ContentView.swift
//  Moji Slicer
//
//  v2 rewrite shell.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedImage: NSImage?
    @State private var selectedImageName = "No image selected"
    @State private var rows = 3
    @State private var columns = 3
    @State private var horizontalGap: Double = 0
    @State private var verticalGap: Double = 0
    @State private var padding: Double = 0
    @State private var showingImporter = false
    @State private var lastError: String?

    private var sourceRect: CGRect {
        guard let selectedImage else { return .zero }
        return CGRect(origin: .zero, size: selectedImage.size)
    }

    private var currentGrid: SliceGrid? {
        guard selectedImage != nil else { return nil }
        return SliceGrid(
            rows: rows,
            columns: columns,
            sourceRect: sourceRect,
            horizontalGap: horizontalGap,
            verticalGap: verticalGap,
            padding: padding
        )
    }

    private var cells: [SliceCell] {
        guard let currentGrid else { return [] }
        do {
            return try ImageSlicer.makeCells(for: currentGrid)
        } catch {
            return []
        }
    }

    var body: some View {
        NavigationSplitView {
            controlsPanel
                .navigationSplitViewColumnWidth(min: 260, ideal: 300)
        } detail: {
            previewArea
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false,
            onCompletion: handleImport
        )
        .frame(minWidth: 980, minHeight: 680)
    }

    private var controlsPanel: some View {
        Form {
            Section("Image") {
                Text(selectedImageName)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)

                Button("Import Image") {
                    showingImporter = true
                }
            }

            Section("Grid") {
                Stepper("Rows: \(rows)", value: $rows, in: 1...30)
                Stepper("Columns: \(columns)", value: $columns, in: 1...30)
            }

            Section("Spacing") {
                LabeledContent("Horizontal gap") {
                    TextField("0", value: $horizontalGap, format: .number)
                        .frame(width: 72)
                }

                LabeledContent("Vertical gap") {
                    TextField("0", value: $verticalGap, format: .number)
                        .frame(width: 72)
                }

                LabeledContent("Padding") {
                    TextField("0", value: $padding, format: .number)
                        .frame(width: 72)
                }
            }

            Section("Preview") {
                Text("\(cells.count) output cells")
                    .foregroundStyle(.secondary)

                if let lastError {
                    Text(lastError)
                        .foregroundStyle(.red)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Moji Slicer")
    }

    private var previewArea: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)

            if let selectedImage {
                ImagePreview(image: selectedImage, cells: cells)
                    .padding(32)
            } else {
                ContentUnavailableView(
                    "Import an emoji grid image",
                    systemImage: "square.grid.3x3",
                    description: Text("Choose an image, set rows and columns, then verify the slice boxes before export.")
                )
            }
        }
        .navigationTitle("Preview")
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else { return }
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            guard let image = NSImage(contentsOf: url) else {
                lastError = "Could not load image."
                return
            }

            selectedImage = image
            selectedImageName = url.lastPathComponent
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }
}

private struct ImagePreview: View {
    let image: NSImage
    let cells: [SliceCell]

    var body: some View {
        GeometryReader { geometry in
            let scale = previewScale(in: geometry.size)
            let imageSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let origin = CGPoint(
                x: (geometry.size.width - imageSize.width) / 2,
                y: (geometry.size.height - imageSize.height) / 2
            )

            ZStack(alignment: .topLeading) {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: imageSize.width, height: imageSize.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                ForEach(cells) { cell in
                    Rectangle()
                        .stroke(.blue, lineWidth: 1)
                        .frame(width: cell.rect.width * scale, height: cell.rect.height * scale)
                        .position(
                            x: origin.x + cell.rect.midX * scale,
                            y: origin.y + cell.rect.midY * scale
                        )
                }
            }
        }
    }

    private func previewScale(in availableSize: CGSize) -> CGFloat {
        guard image.size.width > 0, image.size.height > 0 else { return 1 }
        let widthScale = availableSize.width / image.size.width
        let heightScale = availableSize.height / image.size.height
        return max(0.01, min(widthScale, heightScale))
    }
}

#Preview {
    ContentView()
}
