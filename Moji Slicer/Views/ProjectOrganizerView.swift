//
//  ProjectOrganizerView.swift
//  Moji Slicer
//
//  Created by Aaron Yu on 7/24/25.
//

import SwiftUI

struct ProjectOrganizerView: View {
    @Binding var projects: [Project]
    @Binding var selectedProject: Project?
    @State private var showingNewProjectSheet = false
    @State private var newProjectName = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Projects")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    showingNewProjectSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Projects List
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(projects) { project in
                        ProjectRowView(
                            project: project,
                            isSelected: selectedProject?.id == project.id,
                            onSelect: {
                                selectedProject = project
                            }
                        )
                    }
                }
            }
            
            Spacer()
            
            // Recent Files Section
            VStack(alignment: .leading, spacing: 8) {
                Divider()
                
                Text("Recent")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 4) {
                    ForEach(projects.prefix(3)) { project in
                        HStack {
                            Image(systemName: "doc")
                                .foregroundColor(.secondary)
                            Text(project.name)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .onTapGesture {
                            selectedProject = project
                        }
                    }
                }
            }
            .padding(.bottom)
        }
        .sheet(isPresented: $showingNewProjectSheet) {
            NewProjectSheet(
                projectName: $newProjectName,
                onCreateProject: createProject
            )
        }
        .onAppear {
            // Create default project if none exist
            if projects.isEmpty {
                let defaultProject = Project(name: "Untitled Project")
                projects.append(defaultProject)
                selectedProject = defaultProject
            }
        }
    }
    
    private func createProject() {
        let newProject = Project(name: newProjectName.isEmpty ? "Untitled Project" : newProjectName)
        projects.append(newProject)
        selectedProject = newProject
        newProjectName = ""
        showingNewProjectSheet = false
    }
}

struct ProjectRowView: View {
    let project: Project
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                
                HStack {
                    Text("\(project.images.count) images")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(project.grids.count) grids")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.caption)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .onTapGesture {
            onSelect()
        }
    }
}

struct NewProjectSheet: View {
    @Binding var projectName: String
    let onCreateProject: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Project Name", text: $projectName)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreateProject()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(width: 400, height: 200)
    }
}
