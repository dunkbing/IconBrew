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
    @Published var originalImage: NSImage?
    @Published var isImageDragging = false
    @Published var isGenerating = false
    @Published var generationComplete = false
    @Published var outputFolderURL: URL?
    @Published var showCompletionAlert = false

    @AppStorage("selectedOutputFolder", store: UserDefaults(suiteName: Constants.AppGroup))
    var selectedOutputFolder: URL?

    // Platform toggles
    @AppStorage("iOSSelected", store: UserDefaults(suiteName: Constants.AppGroup))
    var iOSSelected = true
    @AppStorage("macOSSelected", store: UserDefaults(suiteName: Constants.AppGroup))
    var macOSSelected = true
    @AppStorage("watchOSSelected", store: UserDefaults(suiteName: Constants.AppGroup))
    var watchOSSelected = true
    @AppStorage("unifiedAppleIconsSelected", store: UserDefaults(suiteName: Constants.AppGroup))
    var unifiedAppleIconsSelected = false
    @AppStorage("androidSelected", store: UserDefaults(suiteName: Constants.AppGroup))
    var androidSelected = true
    @AppStorage("webSelected", store: UserDefaults(suiteName: Constants.AppGroup))
    var webSelected = true

    // Error handling
    @Published var errorMessage: String?
    @Published var showError = false

    @Published var showSidebar = true

    @Published var editedImage: NSImage?

    func updateEditedImage(_ image: NSImage?) {
        self.editedImage = image?.copyImage()
    }

    func selectImage(completion: @escaping (NSImage?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.image]

        panel.begin { response in
            if response == .OK, let url = panel.url {
                if let image = NSImage(contentsOf: url) {
                    print("selected image", image.size)
                    DispatchQueue.main.async {
                        self.sourceImage = image
                        self.originalImage = image
                        self.editedImage = nil
                        self.generationComplete = false
                        completion(image)
                    }
                }
            }
        }
    }

    func selectOutputFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.title = "Select Output Folder"
        panel.message = "Choose a folder to save generated icons"

        panel.begin { [weak self] response in
            guard let self = self else { return }

            if response == .OK, let url = panel.url {
                DispatchQueue.main.async {
                    self.selectedOutputFolder = url
                }
            }
        }
    }

    func loadDroppedImage(
        from providers: [NSItemProvider], completion: @escaping (NSImage?) -> Void
    ) {
        if let provider = providers.first {
            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) {
                data, error in
                if let imageData = data, let droppedImage = NSImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.sourceImage = droppedImage
                        self.editedImage = nil  // Reset edited image when new source is dropped
                        self.generationComplete = false
                        completion(droppedImage)
                    }
                } else if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to load image: \(error.localizedDescription)"
                        self.showError = true
                    }
                }
            }
        }
    }

    func generateIcons() {
        guard let finalImage = editedImage ?? sourceImage else { return }

        if !iOSSelected && !macOSSelected && !watchOSSelected && !androidSelected && !webSelected {
            self.errorMessage = "Please select at least one platform"
            self.showError = true
            return
        }

        if selectedOutputFolder == nil {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.canCreateDirectories = true
            panel.title = "Select Output Folder"
            panel.message = "Choose a folder to save generated icons"

            panel.begin { [weak self] response in
                guard let self = self else { return }

                if response == .OK, let url = panel.url {
                    self.selectedOutputFolder = url
                    self.proceedWithIconGeneration(sourceImage: finalImage)
                }
            }
        } else {
            proceedWithIconGeneration(sourceImage: finalImage)
        }
    }

    private func proceedWithIconGeneration(sourceImage: NSImage) {
        isGenerating = true
        generationComplete = false

        // Create a subfolder within the selected output folder
        let outputFolder = selectedOutputFolder!.appendingPathComponent(
            "AppIcons-\(Int(Date().timeIntervalSince1970))")

        do {
            try FileManager.default.createDirectory(
                at: outputFolder, withIntermediateDirectories: true)

            DispatchQueue.global(qos: .userInitiated).async {
                let iconGenerator = IconGenerator()

                if self.unifiedAppleIconsSelected
                    && (self.iOSSelected || self.macOSSelected || self.watchOSSelected)
                {
                    // Generate unified Apple icons
                    iconGenerator.generateUnifiedAppleIcons(
                        from: sourceImage,
                        outputFolder: outputFolder,
                        generateiOS: self.iOSSelected,
                        generatemacOS: self.macOSSelected,
                        generatewatchOS: self.watchOSSelected
                    )
                } else {
                    // Generate separate platform icons
                    if self.iOSSelected {
                        iconGenerator.generateIOSIcons(
                            from: sourceImage, outputFolder: outputFolder)
                    }

                    if self.macOSSelected {
                        iconGenerator.generateMacOSIcons(
                            from: sourceImage, outputFolder: outputFolder)
                    }

                    if self.watchOSSelected {
                        iconGenerator.generateWatchOSIcons(
                            from: sourceImage, outputFolder: outputFolder)
                    }
                }

                if self.androidSelected {
                    iconGenerator.generateAndroidIcons(
                        from: sourceImage, outputFolder: outputFolder)
                }

                if self.webSelected {
                    iconGenerator.generateWebIcons(from: sourceImage, outputFolder: outputFolder)
                }

                // Update UI on main thread
                DispatchQueue.main.async {
                    self.isGenerating = false
                    self.generationComplete = true
                    self.outputFolderURL = outputFolder
                    self.showCompletionAlert = true

                    // Show the folder in Finder
                    NSWorkspace.shared.open(outputFolder)
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isGenerating = false

                // Try to provide a more user-friendly error message
                let nsError = error as NSError
                print(nsError)
                if nsError.domain == NSCocoaErrorDomain
                    && (nsError.code == NSFileWriteNoPermissionError
                        || nsError.code == NSFileWriteVolumeReadOnlyError)
                {
                    self.errorMessage =
                        "Permission denied: You don't have permission to write to the selected folder. Please choose a different folder."
                } else if error.localizedDescription.contains("Permission denied") {
                    self.errorMessage =
                        "Permission denied: You don't have permission to write to the selected folder. Please choose a different folder."
                } else {
                    self.errorMessage =
                        "Error creating output directory: \(error.localizedDescription)"
                }
                self.showError = true
            }
        }
    }
}
