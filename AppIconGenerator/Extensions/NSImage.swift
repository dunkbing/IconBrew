//
//  Untitled.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import AppKit

extension NSImage {
    var cgImage: CGImage? {
        guard let imageData = tiffRepresentation else { return nil }
        guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }
        guard let cgImage = CGImageSourceCreateImageAtIndex(sourceData, 0, nil) else { return nil }

        // We need to ensure the CGImage has the exact pixel dimensions we want
        let width = Int(size.width)
        let height = Int(size.height)

        // If the dimensions match, return the CGImage directly
        if cgImage.width == width && cgImage.height == height {
            return cgImage
        }

        // Otherwise, create a new CGImage with the correct dimensions
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard
            let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: bitmapInfo.rawValue
            )
        else { return nil }

        // Draw the image in the context with high quality
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        return context.makeImage()
    }

    func copyImage() -> NSImage {
        // Create a reliable deep copy of the image
        let newSize = self.size
        let newImage = NSImage(size: newSize)

        newImage.lockFocus()

        // Ensure we're using high quality interpolation
        NSGraphicsContext.current?.imageInterpolation = .high

        // Draw at the exact target size
        self.draw(
            in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: self.size),
            operation: .copy, fraction: 1.0)

        newImage.unlockFocus()

        return newImage
    }

    func resizedBitmap(to size: CGSize) -> NSImage {
        // Create a bitmap representation with exact pixel dimensions
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!

        // Set the desired size - this ensures the bitmap keeps track of the exact pixel dimensions
        bitmap.size = size

        // Draw the image into the bitmap representation
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        NSGraphicsContext.current?.imageInterpolation = .high

        // Draw with clear background to ensure transparency
        NSColor.clear.set()
        NSRect(origin: .zero, size: size).fill()

        // Draw the original image scaled to fit
        draw(
            in: NSRect(origin: .zero, size: size),
            from: NSRect(origin: .zero, size: self.size),
            operation: .sourceOver,
            fraction: 1.0)

        NSGraphicsContext.restoreGraphicsState()

        // Create a new image with the bitmap representation
        let newImage = NSImage(size: size)
        newImage.addRepresentation(bitmap)

        return newImage
    }
}
