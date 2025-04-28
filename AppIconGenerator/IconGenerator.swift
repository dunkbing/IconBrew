//
//  IconGenerator.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import AppKit

class IconGenerator {
    func generateMacOSIcons(from sourceImage: NSImage, outputFolder: URL) {
        let sizes = [
            ("icon_16x16", 16),
            ("icon_16x16@2x", 32),
            ("icon_32x32", 32),
            ("icon_32x32@2x", 64),
            ("icon_128x128", 128),
            ("icon_128x128@2x", 256),
            ("icon_256x256", 256),
            ("icon_256x256@2x", 512),
            ("icon_512x512", 512),
            ("icon_512x512@2x", 1024),
        ]

        let platformFolder = outputFolder.appendingPathComponent("macOS")
        try? FileManager.default.createDirectory(
            at: platformFolder, withIntermediateDirectories: true)

        for (name, size) in sizes {
            // Generate an icon with exact pixel dimensions
            if let iconData = ImageUtility.createIconWithExactSize(sourceImage, pixelSize: size) {
                let fileURL = platformFolder.appendingPathComponent("\(name).png")

                // Create parent directory if needed
                let directory = fileURL.deletingLastPathComponent()
                try? FileManager.default.createDirectory(
                    at: directory, withIntermediateDirectories: true)

                // Write the data directly
                do {
                    try iconData.write(to: fileURL)
                    print("Saved icon \(name).png with exact size \(size)x\(size)")
                } catch {
                    print("Error saving icon: \(error)")
                }
            }
        }

        let jsonGenerator = ContentsJsonGenerator()
        jsonGenerator.generateMacOSContentsJson(outputFolder: platformFolder)
    }

    // Update other platform methods similarly
    // For example, iOS icons:
    func generateIOSIcons(from sourceImage: NSImage, outputFolder: URL) {
        let sizes = [
            ("iPhone_20pt@2x", 40),
            ("iPhone_20pt@3x", 60),
            ("iPhone_29pt@2x", 58),
            ("iPhone_29pt@3x", 87),
            ("iPhone_40pt@2x", 80),
            ("iPhone_40pt@3x", 120),
            ("iPhone_60pt@2x", 120),
            ("iPhone_60pt@3x", 180),
            ("iPad_20pt", 20),
            ("iPad_20pt@2x", 40),
            ("iPad_29pt", 29),
            ("iPad_29pt@2x", 58),
            ("iPad_40pt", 40),
            ("iPad_40pt@2x", 80),
            ("iPad_76pt", 76),
            ("iPad_76pt@2x", 152),
            ("iPad_83.5pt@2x", 167),
            ("App_Store_1024pt", 1024),
        ]

        let platformFolder = outputFolder.appendingPathComponent("iOS")
        try? FileManager.default.createDirectory(
            at: platformFolder, withIntermediateDirectories: true)

        for (name, size) in sizes {
            // Generate an icon with exact pixel dimensions
            if let iconData = ImageUtility.createIconWithExactSize(sourceImage, pixelSize: size) {
                let fileURL = platformFolder.appendingPathComponent("\(name).png")

                // Create parent directory if needed
                let directory = fileURL.deletingLastPathComponent()
                try? FileManager.default.createDirectory(
                    at: directory, withIntermediateDirectories: true)

                // Write the data directly
                do {
                    try iconData.write(to: fileURL)
                } catch {
                    print("Error saving icon: \(error)")
                }
            }
        }

        let jsonGenerator = ContentsJsonGenerator()
        jsonGenerator.generateIOSContentsJson(outputFolder: platformFolder)
    }

    func generateWatchOSIcons(from sourceImage: NSImage, outputFolder: URL) {
        let sizes = [
            ("AppIcon24x24@2x", 48),
            ("AppIcon27.5x27.5@2x", 55),
            ("AppIcon29x29@2x", 58),
            ("AppIcon29x29@3x", 87),
            ("AppIcon40x40@2x", 80),
            ("AppIcon44x44@2x", 88),
            ("AppIcon50x50@2x", 100),
            ("AppIcon86x86@2x", 172),
            ("AppIcon98x98@2x", 196),
            ("AppIcon108x108@2x", 216),
        ]

        let platformFolder = outputFolder.appendingPathComponent("watchOS")
        try? FileManager.default.createDirectory(
            at: platformFolder, withIntermediateDirectories: true)

        for (name, size) in sizes {
            if let iconData = ImageUtility.createIconWithExactSize(sourceImage, pixelSize: size) {
                let fileURL = platformFolder.appendingPathComponent("\(name).png")

                // Create parent directory if needed
                let directory = fileURL.deletingLastPathComponent()
                try? FileManager.default.createDirectory(
                    at: directory, withIntermediateDirectories: true)

                // Write the data directly
                do {
                    try iconData.write(to: fileURL)
                } catch {
                    print("Error saving icon: \(error)")
                }
            }
        }

        let jsonGenerator = ContentsJsonGenerator()
        jsonGenerator.generateWatchOSContentsJson(outputFolder: platformFolder)
    }

    func generateUnifiedAppleIcons(
        from sourceImage: NSImage,
        outputFolder: URL,
        generateiOS: Bool,
        generatemacOS: Bool,
        generatewatchOS: Bool
    ) {
        // Create a unified Apple directory
        let unifiedFolder = outputFolder.appendingPathComponent("Apple")
        try? FileManager.default.createDirectory(
            at: unifiedFolder, withIntermediateDirectories: true)

        var allIcons: [IconFileReference] = []

        // iOS icons
        if generateiOS {
            let iosSizes = [
                ("iPhone_20pt@2x", 40, "iphone", "2x", "20x20"),
                ("iPhone_20pt@3x", 60, "iphone", "3x", "20x20"),
                ("iPhone_29pt@2x", 58, "iphone", "2x", "29x29"),
                ("iPhone_29pt@3x", 87, "iphone", "3x", "29x29"),
                ("iPhone_40pt@2x", 80, "iphone", "2x", "40x40"),
                ("iPhone_40pt@3x", 120, "iphone", "3x", "40x40"),
                ("iPhone_60pt@2x", 120, "iphone", "2x", "60x60"),
                ("iPhone_60pt@3x", 180, "iphone", "3x", "60x60"),
                ("iPad_20pt", 20, "ipad", "1x", "20x20"),
                ("iPad_20pt@2x", 40, "ipad", "2x", "20x20"),
                ("iPad_29pt", 29, "ipad", "1x", "29x29"),
                ("iPad_29pt@2x", 58, "ipad", "2x", "29x29"),
                ("iPad_40pt", 40, "ipad", "1x", "40x40"),
                ("iPad_40pt@2x", 80, "ipad", "2x", "40x40"),
                ("iPad_76pt", 76, "ipad", "1x", "76x76"),
                ("iPad_76pt@2x", 152, "ipad", "2x", "76x76"),
                ("iPad_83.5pt@2x", 167, "ipad", "2x", "83.5x83.5"),
                ("App_Store_1024pt", 1024, "ios-marketing", "1x", "1024x1024"),
            ]

            for (name, size, idiom, scale, dimensions) in iosSizes {
                let resizedImage = ImageUtility.resizeImage(
                    sourceImage,
                    toSize: CGSize(width: size, height: size)
                )
                let filename = "\(name).png"
                ImageUtility.saveImage(
                    resizedImage, to: unifiedFolder.appendingPathComponent(filename))

                allIcons.append(
                    IconFileReference(
                        filename: filename,
                        idiom: idiom,
                        scale: scale,
                        size: dimensions))
            }
        }

        // macOS icons
        if generatemacOS {
            let macOSSizes = [
                ("icon_16x16", 16, "mac", "1x", "16x16"),
                ("icon_16x16@2x", 32, "mac", "2x", "16x16"),
                ("icon_32x32", 32, "mac", "1x", "32x32"),
                ("icon_32x32@2x", 64, "mac", "2x", "32x32"),
                ("icon_128x128", 128, "mac", "1x", "128x128"),
                ("icon_128x128@2x", 256, "mac", "2x", "128x128"),
                ("icon_256x256", 256, "mac", "1x", "256x256"),
                ("icon_256x256@2x", 512, "mac", "2x", "256x256"),
                ("icon_512x512", 512, "mac", "1x", "512x512"),
                ("icon_512x512@2x", 1024, "mac", "2x", "512x512"),
            ]

            for (name, size, idiom, scale, dimensions) in macOSSizes {
                let resizedImage = ImageUtility.resizeImage(
                    sourceImage,
                    toSize: CGSize(width: size, height: size)
                )
                let filename = "\(name).png"
                ImageUtility.saveImage(
                    resizedImage, to: unifiedFolder.appendingPathComponent(filename))

                allIcons.append(
                    IconFileReference(
                        filename: filename,
                        idiom: idiom,
                        scale: scale,
                        size: dimensions))
            }
        }

        // watchOS icons
        if generatewatchOS {
            let watchOSSizes = [
                ("AppIcon24x24@2x", 48, "watch", "2x", "24x24"),
                ("AppIcon27.5x27.5@2x", 55, "watch", "2x", "27.5x27.5"),
                ("AppIcon29x29@2x", 58, "watch", "2x", "29x29"),
                ("AppIcon29x29@3x", 87, "watch", "3x", "29x29"),
                ("AppIcon40x40@2x", 80, "watch", "2x", "40x40"),
                ("AppIcon44x44@2x", 88, "watch", "2x", "44x44"),
                ("AppIcon50x50@2x", 100, "watch", "2x", "50x50"),
                ("AppIcon86x86@2x", 172, "watch", "2x", "86x86"),
                ("AppIcon98x98@2x", 196, "watch", "2x", "98x98"),
                ("AppIcon108x108@2x", 216, "watch", "2x", "108x108"),
            ]

            for (name, size, idiom, scale, dimensions) in watchOSSizes {
                let resizedImage = ImageUtility.resizeImage(
                    sourceImage,
                    toSize: CGSize(width: size, height: size)
                )
                let filename = "\(name).png"
                ImageUtility.saveImage(
                    resizedImage, to: unifiedFolder.appendingPathComponent(filename))

                allIcons.append(
                    IconFileReference(
                        filename: filename,
                        idiom: idiom,
                        scale: scale,
                        size: dimensions))
            }
        }

        // Generate unified Contents.json
        let contentsJson = ContentsJson(
            images: allIcons,
            info: ContentsJson.InfoSection(version: 1, author: "AppIconGenerator")
        )

        // Save unified Contents.json
        let jsonGenerator = ContentsJsonGenerator()
        jsonGenerator.saveContentsJson(
            contentsJson, to: unifiedFolder.appendingPathComponent("Contents.json"))
    }

    func generateAndroidIcons(from sourceImage: NSImage, outputFolder: URL) {
        let sizes = [
            ("mipmap-mdpi", 48),
            ("mipmap-hdpi", 72),
            ("mipmap-xhdpi", 96),
            ("mipmap-xxhdpi", 144),
            ("mipmap-xxxhdpi", 192),
            ("playstore", 512),
        ]

        let platformFolder = outputFolder.appendingPathComponent("Android")
        try? FileManager.default.createDirectory(
            at: platformFolder, withIntermediateDirectories: true)

        for (name, size) in sizes {
            let resizedImage = ImageUtility.resizeImage(
                sourceImage,
                toSize: CGSize(width: size, height: size)
            )
            let filePath =
                name == "playstore"
                ? platformFolder.appendingPathComponent("ic_launcher-playstore.png")
                : platformFolder.appendingPathComponent("\(name)/ic_launcher.png")

            // Create subdirectories for Android density buckets
            if name != "playstore" {
                let densityFolder = platformFolder.appendingPathComponent(name)
                try? FileManager.default.createDirectory(
                    at: densityFolder, withIntermediateDirectories: true)
            }

            ImageUtility.saveImage(resizedImage, to: filePath)
        }
    }

    func generateWebIcons(from sourceImage: NSImage, outputFolder: URL) {
        let sizes = [
            ("favicon", 16),
            ("favicon", 32),
            ("favicon", 48),
            ("favicon", 64),
            ("apple-touch-icon", 180),
            ("icon", 192),
            ("icon", 512),
        ]

        let platformFolder = outputFolder.appendingPathComponent("Web")
        try? FileManager.default.createDirectory(
            at: platformFolder, withIntermediateDirectories: true)

        for (name, size) in sizes {
            let resizedImage = ImageUtility.resizeImage(
                sourceImage,
                toSize: CGSize(width: size, height: size)
            )

            let filename: String
            if name == "favicon" && size <= 64 {
                filename = "favicon-\(size)x\(size).png"
            } else if name == "apple-touch-icon" {
                filename = "apple-touch-icon.png"
            } else {
                filename = "\(name)-\(size)x\(size).png"
            }

            ImageUtility.saveImage(
                resizedImage, to: platformFolder.appendingPathComponent(filename))
        }

        generateWebManifestJson(outputFolder: platformFolder)
    }

    private func generateWebManifestJson(outputFolder: URL) {
        let manifest = """
            {
              "name": "My App",
              "short_name": "App",
              "icons": [
                {
                  "src": "icon-192x192.png",
                  "sizes": "192x192",
                  "type": "image/png"
                },
                {
                  "src": "icon-512x512.png",
                  "sizes": "512x512",
                  "type": "image/png"
                }
              ],
              "theme_color": "#ffffff",
              "background_color": "#ffffff",
              "display": "standalone"
            }
            """

        do {
            try manifest.write(
                to: outputFolder.appendingPathComponent("manifest.json"),
                atomically: true,
                encoding: .utf8
            )
        } catch {
            print("Error generating web manifest: \(error)")
        }
    }
}
