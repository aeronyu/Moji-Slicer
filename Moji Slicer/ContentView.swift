import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.3x3")
                .font(.system(size: 48))
            Text("Moji Slicer v2")
                .font(.largeTitle)
            Text("Grid image tool baseline")
                .foregroundStyle(.secondary)
        }
        .padding(40)
        .frame(minWidth: 900, minHeight: 620)
    }
}

#Preview {
    ContentView()
}
