//
//  AllBoardsView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/25/25.
//

import SwiftUI

struct AllBoardsView: View {
    @Binding var projects: [Project]
    let onSelectProject: (Project) -> Void
    
    @State private var selectedCategory: BoardCategory?
    
    // Board categories matching the design
    private var boardCategories: [BoardCategory] {
        [
            BoardCategory(
                name: "All Boards", 
                icon: "square.grid.2x2",
                color: .blue,
                count: projects.count
            ),
            BoardCategory(
                name: "Recents", 
                icon: "clock",
                color: .orange,
                count: min(7, projects.count)
            ),
            BoardCategory(
                name: "Shared", 
                icon: "person.2",
                color: .blue,
                count: 0
            ),
            BoardCategory(
                name: "Favorites", 
                icon: "heart.fill",
                color: .red,
                count: 0
            )
        ]
    }
    
    private var currentProjects: [Project] {
        if let category = selectedCategory {
            switch category.name {
            case "Recents":
                return Array(projects.sorted { $0.lastModified > $1.lastModified }.prefix(7))
            case "Shared":
                return [] // TODO: Implement shared projects
            case "Favorites":
                return [] // TODO: Implement favorites
            default:
                return projects
            }
        }
        return projects
    }
    
    private var hasProjectsWithoutContent: Bool {
        !currentProjects.isEmpty && allProjectsEmptyOfImages
    }
    
    private var allProjectsEmptyOfImages: Bool {
        currentProjects.allSatisfy { $0.images.isEmpty }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Sidebar
            VStack(alignment: .leading, spacing: 0) {
                // Sidebar Header
                HStack {
                    Text("Boards")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Board Categories
                VStack(spacing: 4) {
                    ForEach(boardCategories, id: \.name) { category in
                        BoardCategoryRow(
                            category: category,
                            isSelected: selectedCategory?.name == category.name,
                            onSelect: {
                                selectedCategory = category
                            }
                        )
                    }
                }
                .padding(.horizontal, 12)
                
                Spacer()
            }
            .frame(width: 280)
            .background(Color(red: 0.24, green: 0.24, blue: 0.24))
            
            // Main Content Area
            VStack(alignment: .leading, spacing: 0) {
                // Main Header
                HStack {
                    Text(selectedCategory?.name ?? "All Boards")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Top-right controls (grid/list view, search, etc.)
                    HStack(spacing: 16) {
                        Button {
                            // TODO: Toggle view mode
                        } label: {
                            Image(systemName: "square.grid.2x2")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            // TODO: Toggle list view
                        } label: {
                            Image(systemName: "list.bullet")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            // TODO: Search
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Boards Grid or Empty State
                ScrollView {
                    if currentProjects.isEmpty {
                        // Empty state when no projects
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Image(systemName: "square.grid.2x2")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("No Projects Yet")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("Create your first project to start slicing images")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                            
                            Button {
                                createNewBoard()
                            } label: {
                                Text("Create New Project")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else if hasProjectsWithoutContent {
                        // Show projects but also show "nothing to slice" hint
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 220, maximum: 280), spacing: 20)
                        ], spacing: 20) {
                            ForEach(currentProjects) { project in
                                BoardThumbnailView(
                                    project: project,
                                    onSelect: {
                                        onSelectProject(project)
                                    }
                                )
                            }
                            
                            // Add New Board Card
                            NewBoardCard {
                                createNewBoard()
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                        
                        // Nothing to slice hint
                        if allProjectsEmptyOfImages {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange.opacity(0.6))
                                
                                Text("Nothing to Slice Yet")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text("Your projects don't have any images yet. Import some images to start slicing!")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.5))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 60)
                            }
                            .padding(.bottom, 40)
                        }
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 220, maximum: 280), spacing: 20)
                        ], spacing: 20) {
                            ForEach(currentProjects) { project in
                                BoardThumbnailView(
                                    project: project,
                                    onSelect: {
                                        onSelectProject(project)
                                    }
                                )
                            }
                            
                            // Add New Board Card
                            NewBoardCard {
                                createNewBoard()
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.15, green: 0.15, blue: 0.15))
        }
        .onAppear {
            // Default to "All Boards" category
            if selectedCategory == nil {
                selectedCategory = boardCategories.first
            }
        }
    }
    
    private func createNewBoard() {
        let newProject = Project(name: "Untitled")
        projects.append(newProject)
        onSelectProject(newProject)
    }
}
    
struct BoardThumbnailView: View {
    let project: Project
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                // Thumbnail Image Area
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.25, green: 0.25, blue: 0.25))
                    .aspectRatio(4/3, contentMode: .fit)
                    .overlay {
                        if let firstImage = project.images.first?.image {
                            Image(nsImage: firstImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            // Empty state with subtle grid pattern like blank canvas
                            ZStack {
                                // Clean white background
                                Color.white
                                
                                // Subtle grid pattern
                                Canvas { context, size in
                                    let gridSpacing: CGFloat = 20
                                    let gridColor = Color.gray.opacity(0.1)
                                    
                                    // Vertical lines
                                    for x in stride(from: 0, through: size.width, by: gridSpacing) {
                                        let path = Path { path in
                                            path.move(to: CGPoint(x: x, y: 0))
                                            path.addLine(to: CGPoint(x: x, y: size.height))
                                        }
                                        context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
                                    }
                                    
                                    // Horizontal lines
                                    for y in stride(from: 0, through: size.height, by: gridSpacing) {
                                        let path = Path { path in
                                            path.move(to: CGPoint(x: 0, y: y))
                                            path.addLine(to: CGPoint(x: size.width, y: y))
                                        }
                                        context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
                                    }
                                }
                                
                                // Centered empty state indicator
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 24, weight: .light))
                                        .foregroundColor(.gray.opacity(0.4))
                                    Text("Blank Canvas")
                                        .font(.caption)
                                        .foregroundColor(.gray.opacity(0.6))
                                }
                            }
                            .cornerRadius(12)
                        }
                    }
                
                // Project Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(formatDate(project.lastModified))
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct NewBoardCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack {
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "plus")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("New Board")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(4/3, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
        )
    }
}

struct BoardCategory {
    let name: String
    let icon: String
    let color: Color
    let count: Int
}

struct BoardCategoryRow: View {
    let category: BoardCategory
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    .frame(width: 20)
                
                Text(category.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                
                Spacer()
                
                if category.count > 0 {
                    Text("\(category.count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.5))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? .white.opacity(0.2) : .white.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.white.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AllBoardsView(
        projects: .constant([
            Project(name: "Sample Project 1"),
            Project(name: "Sample Project 2"),
            Project(name: "Sample Project 3")
        ]),
        onSelectProject: { _ in }
    )
}
