//
//  IconViewModel.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import SwiftUI
import UniformTypeIdentifiers

class IconViewModel: ObservableObject {
    @Published var sourceImage: NSImage?
    @Published var isImageDragging = false
    @Published var isGenerating = false
    @Published var generationComplete = false
    @Published var outputFolderURL: URL?

    // Platform toggles
    @Published var iOSSelected = true
    @Published var macOSSelected = true
    @Published var watchOSSelected = true
    @Published var androidSelected = true
    @Published var webSelected = true

    func selectImage(completion: @escaping (NSImage?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.image]

        panel.begin { response in
            if response == .OK, let url = panel.url {
                if let image = NSImage(contentsOf: url) {
                    self.sourceImage = image
                    self.generationComplete = false
                    completion(image)
                }
            }
        }
    }

    func loadDroppedImage(from providers: [NSItemProvider], completion: @escaping (NSImage?) -> Void) {
        if let provider = providers.first {
            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                if let imageData = data, let droppedImage = NSImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.sourceImage = droppedImage
                        self.generationComplete = false
                        completion(droppedImage)
                    }
                }
            }
        }
    }

    func generateIcons() {
        guard let sourceImage = sourceImage else { return }

        isGenerating = true
        generationComplete = false

        // Create a temporary output directory
        let outputFolder = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("AppIcons-\(Int(Date().timeIntervalSince1970))")

        do {
            try FileManager.default.createDirectory(at: outputFolder, withIntermediateDirectories: true)

            // A background task to not block the UI
            DispatchQueue.global(qos: .userInitiated).async {
                let iconGenerator = IconGenerator()

                // Generate icons for each selected platform
                if self.iOSSelected {
                    iconGenerator.generateIOSIcons(from: sourceImage, outputFolder: outputFolder)
                }

                if self.macOSSelected {
                    iconGenerator.generateMacOSIcons(from: sourceImage, outputFolder: outputFolder)
                }

                if self.watchOSSelected {
                    iconGenerator.generateWatchOSIcons(from: sourceImage, outputFolder: outputFolder)
                }

                if self.androidSelected {
                    iconGenerator.generateAndroidIcons(from: sourceImage, outputFolder: outputFolder)
                }

                if self.webSelected {
                    iconGenerator.generateWebIcons(from: sourceImage, outputFolder: outputFolder)
                }

                // Update UI on main thread
                DispatchQueue.main.async {
                    self.isGenerating = false
                    self.generationComplete = true
                    self.outputFolderURL = outputFolder

                    // Show the folder in Finder
                    NSWorkspace.shared.open(outputFolder)
                }
            }
        } catch {
            print("Error creating output directory: \(error)")
            isGenerating = false
        }
    }
}
