//
//  ContentView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedImages: [CanvasImage] = []
    @State private var grids: [GridModel] = []
    @State private var projects: [Project] = []
    @State private var selectedProject: Project?
    @State private var showingImagePicker = false
    @State private var showingDirectoryPicker = false
    @State private var canvasScale: Double = 1.0
    @State private var canvasOffset: CGSize = .zero
    @State private var selectedTool: CanvasTool = .select
    @State private var newGridProperties = GridProperties()
    @State private var showGridTags = true
    
    var body: some View {
        NavigationSplitView {
            // Left Sidebar - Project Organizer
            ProjectOrganizerView(
                projects: $projects,
                selectedProject: $selectedProject
            )
            .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        } detail: {
            VStack(spacing: 0) {
                // Top Toolbar
                TopToolbarView(
                    selectedTool: $selectedTool,
                    gridProperties: $newGridProperties,
                    showGridTags: $showGridTags,
                    onImportImages: { showingImagePicker = true },
                    onGlobalSlice: { showingDirectoryPicker = true }
                )
                
                // Main Canvas Area
                MainCanvasView(
                    images: $selectedImages,
                    grids: $grids,
                    scale: $canvasScale,
                    offset: $canvasOffset,
                    selectedTool: $selectedTool,
                    gridProperties: $newGridProperties,
                    showGridTags: $showGridTags
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .fileImporter(
            isPresented: $showingImagePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            handleImageImport(result)
        }
        .fileImporter(
            isPresented: $showingDirectoryPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            handleDirectorySelection(result)
        }
    }
    
    private func handleImageImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            var newImages: [CanvasImage] = []
            let centerOffset = CGPoint(x: 0, y: 0) // Center of infinite canvas
            var imageOffset = centerOffset
            
            for (index, url) in urls.enumerated() {
                if let nsImage = NSImage(contentsOf: url) {
                    let canvasImage = CanvasImage(
                        image: nsImage,
                        position: CGPoint(
                            x: imageOffset.x + CGFloat(index * 20), // Slight offset for multiple images
                            y: imageOffset.y + CGFloat(index * 20)
                        ),
                        scale: 1.0
                    )
                    newImages.append(canvasImage)
                }
            }
            selectedImages.append(contentsOf: newImages)
            
        case .failure(let error):
            print("Failed to import images: \(error.localizedDescription)")
        }
    }
    
    private func handleDirectorySelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let directory = urls.first else { return }
            // TODO: Implement global slicing
            print("Selected directory for slicing: \(directory)")
        case .failure(let error):
            print("Failed to select directory: \(error.localizedDescription)")
        }
    }
}

// MARK: - Supporting Types

enum CanvasTool: String, CaseIterable {
    case select = "Select"
    case grid = "Grid"
    case label = "Label"
    
    var icon: String {
        switch self {
        case .select: return "cursorarrow"
        case .grid: return "grid"
        case .label: return "textformat"
        }
    }
}

struct GridProperties {
    var rows: Int = 3
    var columns: Int = 3
    var thickness: Double = 0.0
    var color: Color = .blue
    var lineStyle: GridLineStyle = .solid
    var tagName: String = ""
}

struct Project: Identifiable, Codable {
    let id = UUID()
    var name: String
    var images: [CanvasImage]
    var grids: [GridModel]
    var createdDate: Date
    var lastModified: Date
    
    init(name: String) {
        self.name = name
        self.images = []
        self.grids = []
        self.createdDate = Date()
        self.lastModified = Date()
    }
}

#Preview {
    ContentView()
}
