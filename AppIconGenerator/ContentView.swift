//
//  ContentView.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var iconViewModel = IconViewModel()
    @State private var showingInfo = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                HeaderView()
                Spacer()
                Button(action: { showingInfo = true }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)
                .sheet(isPresented: $showingInfo) {
                    InfoView(isPresented: $showingInfo)
                }
            }

            ImageDropView(
                sourceImage: $iconViewModel.sourceImage,
                isImageDragging: $iconViewModel.isImageDragging
            )

            PlatformSelectionView(
                iOSSelected: $iconViewModel.iOSSelected,
                macOSSelected: $iconViewModel.macOSSelected,
                watchOSSelected: $iconViewModel.watchOSSelected,
                androidSelected: $iconViewModel.androidSelected,
                webSelected: $iconViewModel.webSelected
            )

            GenerationControlsView(
                viewModel: iconViewModel
            )
        }
        .padding(30)
        .alert("Icon Generation Complete", isPresented: $iconViewModel.showCompletionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Icons have been saved to the output folder.")
        }
    }
}

struct HeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 36))
                .foregroundColor(.blue)

            Text("App Icon Generator")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

struct InfoView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 36))
                    .foregroundColor(.blue)

                Text("App Icon Generator")
                    .font(.title)
                    .fontWeight(.bold)
            }

            Divider()

            Text("This application generates icons for:")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Label("iOS: All required sizes for iPhone and iPad", systemImage: "apple.logo")
                Label(
                    "macOS: Standard icon sizes from 16x16 to 512x512@2x",
                    systemImage: "desktopcomputer")
                Label("watchOS: Standard Apple Watch app icon sizes", systemImage: "applewatch")
                Label(
                    "Android: All density buckets plus Play Store",
                    systemImage: "rectangle.grid.1x2")
                Label("Web: Favicons, touch icons, and manifest icons", systemImage: "globe")
            }
            .padding(.leading)

            Divider()

            Text("Instructions:")
                .font(.headline)

            Text(
                "1. Drag and drop an image or click to select a source image.\n2. Select the platforms you want to generate icons for.\n3. Click 'Generate Icons'.\n4. The generated icons will be saved to a folder that will open automatically."
            )
            .padding(.leading)

            Spacer()

            HStack {
                Spacer()
                Button("Close") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(30)
        .frame(width: 500, height: 400)
    }
}
