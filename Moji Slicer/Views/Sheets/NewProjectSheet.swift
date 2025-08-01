import SwiftUI

struct NewProjectSheet: View {
    @State private var localProjectName: String = ""
    let onCreateProject: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(onCreateProject: @escaping (String) -> Void) {
        self.onCreateProject = onCreateProject
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Board Name", text: $localProjectName)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Board")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreateProject(localProjectName)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(localProjectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .frame(width: 400, height: 200)
    }
}
