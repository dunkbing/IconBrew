//
//  ImageUtility.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import AppKit


class ImageUtility {
    static func resizeImage(_ image: NSImage, toSize size: CGSize) -> NSImage {
        let targetSize = size
        let newImage = NSImage(size: targetSize)
        
        newImage.lockFocus()
        
        NSGraphicsContext.current?.imageInterpolation = .high
        
        image.draw(in: NSRect(origin: .zero, size: targetSize),
                 from: NSRect(origin: .zero, size: image.size),
                 operation: .sourceOver,
                 fraction: 1.0)
        
        newImage.unlockFocus()
        
        return newImage
    }
    
    static func saveImage(_ image: NSImage, to fileURL: URL) {
        // Create parent directory if it doesn't exist
        let directory = fileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        guard let imageData = bitmapRep.representation(using: .png, properties: [:]) else { return }
        
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("Error saving image: \(error)")
        }
    }
}
