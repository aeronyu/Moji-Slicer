//
//  ContentView.swift
//  Moji Slicer
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.3x3")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Moji Slicer v2")
                .font(.largeTitle.weight(.semibold))

            Text("Import an image, configure a grid, preview cells, and export clean PNG files.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 480)
        }
        .padding(40)
        .frame(minWidth: 900, minHeight: 620)
    }
}

#Preview {
    ContentView()
}
