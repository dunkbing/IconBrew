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
        HStack(spacing: 0) {
            // Main content
            VStack(spacing: 20) {
                HStack {
                    HeaderView()
                    Spacer()

                    // Toggle sidebar button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            iconViewModel.showSidebar.toggle()
                        }
                    }) {
                        Image(
                            systemName: iconViewModel.showSidebar ? "sidebar.right" : "sidebar.left"
                        )
                        .font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                    .help(iconViewModel.showSidebar ? "Hide Editor" : "Show Editor")

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
                    webSelected: $iconViewModel.webSelected,
                    unifiedAppleIconsSelected: $iconViewModel.unifiedAppleIconsSelected
                )

                GenerationControlsView(
                    viewModel: iconViewModel
                )
            }
            .padding(30)

            if iconViewModel.showSidebar {
                Divider()
                IconEditorSidebar(
                    viewModel: iconViewModel,
                    sourceImage: $iconViewModel.sourceImage
                )
                .transition(.move(edge: .trailing))
            }
        }
        .frame(minWidth: iconViewModel.showSidebar ? 880 : 600, minHeight: 550)
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

            Text("Editor Features:")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Label(
                    "Basic: Adjust brightness, contrast, saturation, and more",
                    systemImage: "slider.horizontal.3")
                Label(
                    "Advanced: Add borders, text overlays, change icon shape",
                    systemImage: "wand.and.stars")
                Label(
                    "Background: Add custom backgrounds or padding", systemImage: "rectangle.fill")
                Label(
                    "Shape: Create rounded corners or circular icons",
                    systemImage: "square.on.circle")
            }
            .padding(.leading)

            Divider()

            Text("Instructions:")
                .font(.headline)

            Text(
                "1. Drag and drop an image or click to select a source image.\n2. Use the editor panel to customize your icon's appearance.\n3. Select the platforms you want to generate icons for.\n4. Choose an output folder or let the app prompt you when generating.\n5. Click 'Generate Icons'.\n6. The generated icons will be saved to a timestamped folder within your selected output location."
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
        .frame(width: 500, height: 550)
    }
}
