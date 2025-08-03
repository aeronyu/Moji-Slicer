//
//  ContentView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedImages: [CanvasImage] = []
    @State private var grids: [GridModel] = []
    @State private var projects: [Project] = []
    @State private var selectedProject: Project?
    @State private var selectedTool: CanvasTool = .select
    @State private var showingImagePicker: Bool = false
    @State private var scale: Double = 1.0
    @State private var offset: CGSize = .zero
    @State private var gridProperties = GridProperties()  // @Observable class instance
    @State private var showGridTags = true
    @State private var selectedGridID: UUID?
    @State private var showingAllBoards = true  // Show All Boards view by default
    @State private var showingGridSettings = false
    
    var body: some View {
        if showingAllBoards {
            allBoardsView
        } else {
            canvasView
        }
    }
    
    private var allBoardsView: some View {
        AllBoardsView(
            projects: $projects,
            onSelectProject: { project in
                selectedProject = project
                showingAllBoards = false
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var canvasView: some View {
        VStack(spacing: 0) {
            topToolbar
            mainCanvasWithZoomControls
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fileImporter(
            isPresented: $showingImagePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            handleImageImport(result)
        }
        .onChange(of: selectedProject) { newProject in
            // Load selected project data
            if let project = newProject {
                selectedImages = project.images
                grids = project.grids
                if let firstGrid = project.grids.first {
                    selectedGridID = firstGrid.id
                }
                
                // Auto-open import if project has no images
                if selectedImages.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingImagePicker = true
                    }
                }
            } else {
                selectedImages = []
                grids = []
            }
        }
        .onChange(of: selectedImages) { _ in
            syncCanvasToProject()
        }
        .onChange(of: grids) { _ in
            syncCanvasToProject()
        }
        .onAppear {
            // Create sample projects on first launch
            if projects.isEmpty {
                createSampleProjects()
            }
        }
        .sheet(isPresented: $showingGridSettings) {
            GridSettingsSheet(gridProperties: gridProperties)
        }
    }
    
    private var topToolbar: some View {
        HStack(spacing: 16) {
            backButton
            
            Divider()
                .frame(height: 24)
            
            projectNameField
            
            Spacer()
            
            toolSelection
            gridPropertiesSection
            
            Spacer()
            
            actionButtons
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 0))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.separator.opacity(0.5))
                .frame(maxHeight: .infinity, alignment: .bottom)
        )
    }
    
    private var backButton: some View {
        Button {
            showingAllBoards = true
            selectedProject = nil
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 32, height: 32)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                .contentShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .help("Back to All Boards")
    }
    
    private var projectNameField: some View {
        Group {
            if let project = selectedProject {
                TextField("Project Name", text: Binding(
                    get: { project.name },
                    set: { newName in
                        if var updatedProject = selectedProject {
                            updatedProject.name = newName
                            selectedProject = updatedProject
                            syncCanvasToProject()
                        }
                    }
                ))
                .textFieldStyle(.plain)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: 200)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
            }
        }
    }
    
    private var toolSelection: some View {
        HStack(spacing: 2) {
            toolButton(.select)
            toolButton(.grid)
            toolButton(.label)
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 2)
        .background(.quaternary.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.separator.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func toolButton(_ tool: CanvasTool) -> some View {
        Button {
            selectedTool = tool
        } label: {
            Image(systemName: tool.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(selectedTool == tool ? .white : .primary)
                .frame(width: 32, height: 32)
                .background(
                    selectedTool == tool ? 
                        .primary : Color.clear, 
                    in: RoundedRectangle(cornerRadius: 6)
                )
                .contentShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .help(tool.rawValue)
        .animation(.easeInOut(duration: 0.15), value: selectedTool)
    }
    
    private var gridPropertiesSection: some View {
        Group {
            if selectedTool == .grid {
                HStack(spacing: 10) {
                    // Simplified grid type and size
                    HStack(spacing: 6) {
                        if gridProperties.gridType == .square {
                            Text("\(gridProperties.squareSize)×\(gridProperties.squareSize)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        } else {
                            Text("\(gridProperties.columns)×\(gridProperties.rows)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        
                        // Color indicator
                        Circle()
                            .fill(gridProperties.color)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Circle()
                                    .stroke(.quaternary, lineWidth: 2)
                            )
                    }
                    
                    // Settings button to open detailed popup
                    Button {
                        showingGridSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(.quaternary.opacity(0.6), in: RoundedRectangle(cornerRadius: 6))
                            .contentShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .help("Grid Settings")
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.separator.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 8) {
            // Import images
            Button {
                showingImagePicker = true
            } label: {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(.quaternary.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))
                    .contentShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .help("Import Images")
            
            // Toggle grid tags
            Button {
                showGridTags.toggle()
            } label: {
                Image(systemName: showGridTags ? "tag.fill" : "tag")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(showGridTags ? .white : .primary)
                    .frame(width: 36, height: 36)
                    .background(
                        showGridTags ? 
                            .primary : .quaternary.opacity(0.6), 
                        in: RoundedRectangle(cornerRadius: 8)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .help("Toggle Grid Tags")
            .animation(.easeInOut(duration: 0.15), value: showGridTags)
            
            // Slice all grids
            Button {
                print("🔪 Global slice requested")
                sliceAllGrids()
            } label: {
                Image(systemName: "scissors")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(.red, in: RoundedRectangle(cornerRadius: 8))
                    .contentShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .help("Slice All Grids")
        }
    }
    
    private var mainCanvasWithZoomControls: some View {
        // Main Canvas Area (full width without sidebar)
        ZStack {
                MainCanvasView(
                    images: $selectedImages,
                    grids: $grids,
                    scale: $scale,
                    offset: $offset,
                    selectedTool: $selectedTool,
                    gridProperties: gridProperties,
                    showGridTags: $showGridTags,
                    selectedGridID: $selectedGridID
                )
                
                // Zoom controls overlay - bottom left
                VStack {
                    Spacer()
                    HStack {
                        VStack(spacing: 4) {
                            // Zoom in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    scale = min(4.0, scale + 0.25)
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                                    .frame(width: 28, height: 28)
                                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                            .disabled(scale >= 4.0)
                            .help("Zoom In")
                            
                            // Zoom level display/reset
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    scale = 1.0
                                }
                            } label: {
                                Text("\(Int(scale * 100))%")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.primary)
                                    .frame(width: 28, height: 24)
                                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                            .help("Reset to 100%")
                            
                            // Zoom out
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    scale = max(0.25, scale - 0.25)
                                }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                                    .frame(width: 28, height: 28)
                                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                            .disabled(scale <= 0.25)
                            .help("Zoom Out")
                            
                            // Fit to view
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    scale = 1.0
                                    offset = .zero
                                }
                            } label: {
                                Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
                                    .font(.system(size: 10))
                                    .foregroundColor(.primary)
                                    .frame(width: 28, height: 28)
                                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                            .help("Fit to View")
                        }
                        .padding(.leading, 16)
                        .padding(.bottom, 16)
                        
                        Spacer()
                    }
                }
            }
            .onAppear {
                // Auto-open import dialog if no images are loaded
                if selectedImages.isEmpty && !showingImagePicker {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showingImagePicker = true
                    }
                }
            }
    }
    
    // MARK: - Functions
    private func syncCanvasToProject() {
        if var project = selectedProject {
            project.images = selectedImages
            project.grids = grids
            project.lastModified = Date()
            
            // Update the project in the projects array
            if let projectIndex = projects.firstIndex(where: { $0.id == project.id }) {
                projects[projectIndex] = project
                selectedProject = project
            }
        }
    }
    
    private func handleImageImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            print("🎯 Importing \(urls.count) images")
            for (index, url) in urls.enumerated() {
                // Ensure security scoped access for sandboxed apps
                let accessing = url.startAccessingSecurityScopedResource()
                defer {
                    if accessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                
                if let nsImage = NSImage(contentsOf: url) {
                    print("✅ Successfully loaded image: \(url.lastPathComponent)")
                    print("   Original size: \(nsImage.size)")
                    print("   Valid representations: \(nsImage.representations.count)")
                    
                    // Calculate a reasonable size for the image
                    let maxDimension: CGFloat = 300
                    let aspectRatio = nsImage.size.width / nsImage.size.height
                    let displaySize: CGSize
                    
                    if nsImage.size.width > nsImage.size.height {
                        displaySize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
                    } else {
                        displaySize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
                    }
                    
                    var canvasImage = CanvasImage(
                        image: nsImage,
                        // Center-based coordinate system: (0,0) is center, small offsets for multiple images
                        position: CGPoint(x: 0 + (index * 30), y: 0 + (index * 30)) 
                    )
                    canvasImage.imageName = url.lastPathComponent
                    canvasImage.size = displaySize // Set a reasonable display size
                    
                    print("📦 Created CanvasImage:")
                    print("   Name: \(canvasImage.imageName)")
                    print("   Position: \(canvasImage.position)")
                    print("   Display size: \(canvasImage.size)")
                    print("   Has image data: \(canvasImage.image != nil)")
                    
                    selectedImages.append(canvasImage)
                } else {
                    print("❌ Failed to load image from: \(url)")
                    print("   File exists: \(FileManager.default.fileExists(atPath: url.path))")
                    print("   Is readable: \(FileManager.default.isReadableFile(atPath: url.path))")
                }
            }
            print("📊 Total images after import: \(selectedImages.count)")
            // Explicitly sync to ensure images are saved to project
            syncCanvasToProject()
        case .failure(let error):
            print("❌ Failed to import images: \(error.localizedDescription)")
        }
    }
    
    private func createSampleProjects() {
        // Create multiple sample boards like in the design
        var sampleProjects: [Project] = []
        
        // Create boards with varied timestamps to show different dates
        let now = Date()
        
        let projectData = [
            ("testing", Calendar.current.date(byAdding: .day, value: -1, to: now)!),
            ("Untitled", Calendar.current.date(byAdding: .hour, value: -18, to: now)!),
            ("Untitled", Calendar.current.date(byAdding: .day, value: -30, to: now)!),
            ("Programming HW1", Calendar.current.date(byAdding: .day, value: -3, to: now)!),
            ("Wifi", Calendar.current.date(byAdding: .day, value: -7, to: now)!),
            ("Untitled", Calendar.current.date(byAdding: .hour, value: -12, to: now)!),
            ("Cloud Billing", Calendar.current.date(byAdding: .day, value: -2, to: now)!)
        ]
        
        for (name, date) in projectData {
            var project = Project(name: name)
            project.lastModified = date
            project.createdDate = date
            sampleProjects.append(project)
        }
        
        self.projects = sampleProjects
    }
    
    private func sliceAllGrids() {
        guard !grids.isEmpty else {
            showSlicingAlert(title: "No Grids", message: "Please create some grids before slicing.")
            return
        }
        
        guard let project = selectedProject, !project.images.isEmpty else {
            showSlicingAlert(title: "No Images", message: "Please import some images before slicing.")
            return
        }
        
        print("🔪 Starting to slice all grids...")
        
        // Show file picker for output directory
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.title = "Choose Output Directory for All Grids"
        panel.prompt = "Select"
        
        guard panel.runModal() == .OK,
              let outputURL = panel.url else {
            print("❌ User cancelled directory selection")
            return
        }
        
        // Create main output directory
        let mainOutputURL = outputURL.appendingPathComponent("MojiSlicer_AllGrids_\(Date().timeIntervalSince1970)")
        
        do {
            try FileManager.default.createDirectory(at: mainOutputURL, withIntermediateDirectories: true)
            
            var totalSlices = 0
            var processedGrids = 0
            
            // Process each grid
            for grid in grids {
                print("🔪 Processing grid: \(grid.name)")
                
                // Create subdirectory for this grid
                let gridOutputURL = mainOutputURL.appendingPathComponent("Grid_\(grid.name)")
                try FileManager.default.createDirectory(at: gridOutputURL, withIntermediateDirectories: true)
                
                // Slice this grid against all images
                for (imageIndex, canvasImage) in project.images.enumerated() {
                    guard let nsImage = canvasImage.image else {
                        print("⚠️ Skipping image \(canvasImage.imageName) - no image data")
                        continue
                    }
                    
                    // Transform grid coordinates to image coordinates
                    let transformedGrid = GridCoordinateTransformer.transformGridToImageSpace(grid, for: canvasImage)
                    
                    // Create subdirectory for this image
                    let imageOutputURL = gridOutputURL.appendingPathComponent("Image_\(imageIndex + 1)_\(canvasImage.imageName)")
                    try FileManager.default.createDirectory(at: imageOutputURL, withIntermediateDirectories: true)
                    
                    let sliceURLs = try SlicingEngine.sliceGrid(transformedGrid, from: nsImage, outputDirectory: imageOutputURL)
                    totalSlices += sliceURLs.count
                    print("✅ Sliced \(sliceURLs.count) pieces from \(canvasImage.imageName) with grid \(grid.name)")
                }
                
                processedGrids += 1
            }
            
            print("🎉 Successfully processed \(processedGrids) grids and created \(totalSlices) slices")
            print("📁 Output saved to: \(mainOutputURL.path)")
            
            // Show success alert
            showSlicingSuccess(processedGrids: processedGrids, totalSlices: totalSlices, outputPath: mainOutputURL.path)
            
        } catch {
            print("❌ Error slicing grids: \(error.localizedDescription)")
            showSlicingAlert(title: "Slicing Failed", message: error.localizedDescription)
        }
    }
    
    // MARK: - User Feedback
    
    private func showSlicingSuccess(processedGrids: Int, totalSlices: Int, outputPath: String) {
        let alert = NSAlert()
        alert.messageText = "All Grids Sliced Successfully!"
        alert.informativeText = "Processed \(processedGrids) grids and created \(totalSlices) slices.\n\nOutput saved to:\n\(outputPath)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Open Folder")
        
        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: outputPath)
        }
    }
    
    private func showSlicingAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

}

// MARK: - Supporting Types

#Preview {
    ContentView()
}
