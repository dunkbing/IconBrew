//
//  Untitled.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import AppKit

extension NSImage {
    var cgImage: CGImage? {
        var imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
    }

    func copyImage() -> NSImage {
        // Create a more reliable deep copy of the image
        guard let tiffData = tiffRepresentation,
            let imageRep = NSBitmapImageRep(data: tiffData)
        else {
            // Fallback if TIFF representation fails
            let newImage = NSImage(size: size)
            newImage.lockFocus()
            self.draw(in: NSRect(origin: .zero, size: size))
            newImage.unlockFocus()
            return newImage
        }

        return NSImage(data: imageRep.representation(using: .png, properties: [:]) ?? Data())
            ?? self
    }
}
