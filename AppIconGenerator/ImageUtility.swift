//
//  ImageUtility.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import AppKit

class ImageUtility {
    static func resizeImage(_ image: NSImage, toSize size: CGSize) -> NSImage {
        return createExactSizeImage(image, size: Int(size.width)) ?? NSImage(size: size)
    }

    static func saveImage(_ image: NSImage, to fileURL: URL) {
        // Create parent directory if it doesn't exist
        let directory = fileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        // Get a bitmap representation with exact pixel dimensions
        let pixelWidth = Int(image.size.width)
        let pixelHeight = Int(image.size.height)

        let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelWidth,
            pixelsHigh: pixelHeight,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )

        // Draw the image into the bitmap rep
        bitmapRep?.size = image.size
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep!)
        NSGraphicsContext.current?.imageInterpolation = .high

        image.draw(
            in: NSRect(origin: .zero, size: image.size),
            from: NSRect(origin: .zero, size: image.size),
            operation: .copy,
            fraction: 1.0
        )

        NSGraphicsContext.restoreGraphicsState()

        // Convert to PNG data
        guard let imageData = bitmapRep?.representation(using: .png, properties: [:]) else {
            print("Failed to create PNG data")
            return
        }

        // Debug info to verify dimensions
        print("Saving image to \(fileURL.path) with size \(pixelWidth)x\(pixelHeight)")

        do {
            try imageData.write(to: fileURL)
        } catch {
            print("Error saving image: \(error)")
        }
    }

    static func createIconWithExactSize(_ sourceImage: NSImage, pixelSize: Int) -> NSData? {
        // Create a bitmap with exact pixel dimensions
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelSize,
            pixelsHigh: pixelSize,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )

        guard let bitmap = bitmap else { return nil }

        // Create a graphics context with this bitmap
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

        if let context = NSGraphicsContext.current {
            // Set high quality interpolation
            context.imageInterpolation = .high

            // Clear the background (for transparency)
            NSColor.clear.set()
            NSRect(origin: .zero, size: CGSize(width: pixelSize, height: pixelSize)).fill()

            // Draw the source image scaled to fit the exact dimensions
            sourceImage.draw(
                in: NSRect(origin: .zero, size: CGSize(width: pixelSize, height: pixelSize)),
                from: NSRect(origin: .zero, size: sourceImage.size),
                operation: .sourceOver,
                fraction: 1.0
            )
        }

        NSGraphicsContext.restoreGraphicsState()

        // Create PNG data directly from the bitmap
        return bitmap.representation(using: .png, properties: [:]) as NSData?
    }

    static func createExactSizeImage(_ sourceImage: NSImage, size: Int) -> NSImage? {
        // Create bitmap with exact pixel dimensions
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: size,
            pixelsHigh: size,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )

        guard let bitmap = bitmap else { return nil }

        // Draw into the bitmap
        NSGraphicsContext.saveGraphicsState()
        let context = NSGraphicsContext(bitmapImageRep: bitmap)
        NSGraphicsContext.current = context
        context?.imageInterpolation = .high

        // Clear background for transparency
        NSColor.clear.set()
        NSRect(origin: .zero, size: CGSize(width: size, height: size)).fill()

        // Draw the image scaled to fit
        sourceImage.draw(
            in: NSRect(origin: .zero, size: CGSize(width: size, height: size)),
            from: NSRect(origin: .zero, size: sourceImage.size),
            operation: .sourceOver,
            fraction: 1.0
        )

        NSGraphicsContext.restoreGraphicsState()

        // Create new image with this representation only
        let newImage = NSImage(size: CGSize(width: size, height: size))
        newImage.addRepresentation(bitmap)

        // Remove any other representations to avoid confusion
        for rep in newImage.representations where rep != bitmap {
            newImage.removeRepresentation(rep)
        }

        return newImage
    }
}
