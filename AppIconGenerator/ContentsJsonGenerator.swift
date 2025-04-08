//
//  ContentsJsonGenerator.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import Foundation

struct IconFileReference: Codable {
    let filename: String
    let idiom: String
    let scale: String
    let size: String
}

struct ContentsJson: Codable {
    let images: [IconFileReference]
    let info: InfoSection

    struct InfoSection: Codable {
        let version: Int
        let author: String
    }
}

class ContentsJsonGenerator {
    func generateIOSContentsJson(outputFolder: URL) {
        let iosIcons: [IconFileReference] = [
            IconFileReference(
                filename: "iPhone_20pt@2x.png", idiom: "iphone", scale: "2x", size: "20x20"),
            IconFileReference(
                filename: "iPhone_20pt@3x.png", idiom: "iphone", scale: "3x", size: "20x20"),
            IconFileReference(
                filename: "iPhone_29pt@2x.png", idiom: "iphone", scale: "2x", size: "29x29"),
            IconFileReference(
                filename: "iPhone_29pt@3x.png", idiom: "iphone", scale: "3x", size: "29x29"),
            IconFileReference(
                filename: "iPhone_40pt@2x.png", idiom: "iphone", scale: "2x", size: "40x40"),
            IconFileReference(
                filename: "iPhone_40pt@3x.png", idiom: "iphone", scale: "3x", size: "40x40"),
            IconFileReference(
                filename: "iPhone_60pt@2x.png", idiom: "iphone", scale: "2x", size: "60x60"),
            IconFileReference(
                filename: "iPhone_60pt@3x.png", idiom: "iphone", scale: "3x", size: "60x60"),
            IconFileReference(filename: "iPad_20pt.png", idiom: "ipad", scale: "1x", size: "20x20"),
            IconFileReference(
                filename: "iPad_20pt@2x.png", idiom: "ipad", scale: "2x", size: "20x20"),
            IconFileReference(filename: "iPad_29pt.png", idiom: "ipad", scale: "1x", size: "29x29"),
            IconFileReference(
                filename: "iPad_29pt@2x.png", idiom: "ipad", scale: "2x", size: "29x29"),
            IconFileReference(filename: "iPad_40pt.png", idiom: "ipad", scale: "1x", size: "40x40"),
            IconFileReference(
                filename: "iPad_40pt@2x.png", idiom: "ipad", scale: "2x", size: "40x40"),
            IconFileReference(filename: "iPad_76pt.png", idiom: "ipad", scale: "1x", size: "76x76"),
            IconFileReference(
                filename: "iPad_76pt@2x.png", idiom: "ipad", scale: "2x", size: "76x76"),
            IconFileReference(
                filename: "iPad_83.5pt@2x.png", idiom: "ipad", scale: "2x", size: "83.5x83.5"),
            IconFileReference(
                filename: "App_Store_1024pt.png", idiom: "ios-marketing", scale: "1x",
                size: "1024x1024"),
        ]

        let contentsJson = ContentsJson(
            images: iosIcons,
            info: ContentsJson.InfoSection(version: 1, author: "AppIconGenerator")
        )

        saveContentsJson(contentsJson, to: outputFolder.appendingPathComponent("Contents.json"))
    }

    func generateMacOSContentsJson(outputFolder: URL) {
        let macOSIcons: [IconFileReference] = [
            IconFileReference(filename: "icon_16x16.png", idiom: "mac", scale: "1x", size: "16x16"),
            IconFileReference(
                filename: "icon_16x16@2x.png", idiom: "mac", scale: "2x", size: "16x16"),
            IconFileReference(filename: "icon_32x32.png", idiom: "mac", scale: "1x", size: "32x32"),
            IconFileReference(
                filename: "icon_32x32@2x.png", idiom: "mac", scale: "2x", size: "32x32"),
            IconFileReference(
                filename: "icon_128x128.png", idiom: "mac", scale: "1x", size: "128x128"),
            IconFileReference(
                filename: "icon_128x128@2x.png", idiom: "mac", scale: "2x", size: "128x128"),
            IconFileReference(
                filename: "icon_256x256.png", idiom: "mac", scale: "1x", size: "256x256"),
            IconFileReference(
                filename: "icon_256x256@2x.png", idiom: "mac", scale: "2x", size: "256x256"),
            IconFileReference(
                filename: "icon_512x512.png", idiom: "mac", scale: "1x", size: "512x512"),
            IconFileReference(
                filename: "icon_512x512@2x.png", idiom: "mac", scale: "2x", size: "512x512"),
        ]

        let contentsJson = ContentsJson(
            images: macOSIcons,
            info: ContentsJson.InfoSection(version: 1, author: "AppIconGenerator")
        )

        saveContentsJson(contentsJson, to: outputFolder.appendingPathComponent("Contents.json"))
    }

    func generateWatchOSContentsJson(outputFolder: URL) {
        let watchOSIcons: [IconFileReference] = [
            IconFileReference(
                filename: "AppIcon24x24@2x.png", idiom: "watch", scale: "2x", size: "24x24"),
            IconFileReference(
                filename: "AppIcon27.5x27.5@2x.png", idiom: "watch", scale: "2x", size: "27.5x27.5"),
            IconFileReference(
                filename: "AppIcon29x29@2x.png", idiom: "watch", scale: "2x", size: "29x29"),
            IconFileReference(
                filename: "AppIcon29x29@3x.png", idiom: "watch", scale: "3x", size: "29x29"),
            IconFileReference(
                filename: "AppIcon40x40@2x.png", idiom: "watch", scale: "2x", size: "40x40"),
            IconFileReference(
                filename: "AppIcon44x44@2x.png", idiom: "watch", scale: "2x", size: "44x44"),
            IconFileReference(
                filename: "AppIcon50x50@2x.png", idiom: "watch", scale: "2x", size: "50x50"),
            IconFileReference(
                filename: "AppIcon86x86@2x.png", idiom: "watch", scale: "2x", size: "86x86"),
            IconFileReference(
                filename: "AppIcon98x98@2x.png", idiom: "watch", scale: "2x", size: "98x98"),
            IconFileReference(
                filename: "AppIcon108x108@2x.png", idiom: "watch", scale: "2x", size: "108x108"),
        ]

        let contentsJson = ContentsJson(
            images: watchOSIcons,
            info: ContentsJson.InfoSection(version: 1, author: "AppIconGenerator")
        )

        saveContentsJson(contentsJson, to: outputFolder.appendingPathComponent("Contents.json"))
    }

    private func saveContentsJson(_ contentsJson: ContentsJson, to fileURL: URL) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let jsonData = try encoder.encode(contentsJson)
            try jsonData.write(to: fileURL)
        } catch {
            print("Error saving Contents.json: \(error)")
        }
    }
}
