//
//  AdvancedIconEditing.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import SwiftUI

enum OverlayType: String, CaseIterable, Identifiable {
    case none = "None"
    case beta = "Beta"
    case dev = "Development"
    case alpha = "Alpha"
    case staging = "Staging"
    case test = "Test"
    case custom = "Custom"

    var id: String { self.rawValue }
}

enum IconShape: String, CaseIterable, Identifiable {
    case square = "Square"
    case roundedSquare = "Rounded"
    case circle = "Circle"

    var id: String { self.rawValue }
}

struct AdvancedIconEditing: View {
    @ObservedObject var viewModel: IconViewModel
    @Binding var sourceImage: NSImage?

    // Original image saved for resets
    @State private var originalImage: NSImage?

    // Border properties
    @State private var addBorder = false
    @State private var borderWidth: Double = 4
    @State private var borderColor: Color = .blue

    // Overlay properties
    @State private var overlayType: OverlayType = .none
    @State private var customOverlayText = ""
    @State private var overlayPosition: Double = 0.5  // 0.0 - 1.0 (top to bottom)
    @State private var overlayOpacity: Double = 0.8
    @State private var overlayColor: Color = .red
    @State private var overlayFontSize: Double = 18
    @State private var overlayRotation: Double = -45

    // Mask/Shape properties
    @State private var iconShape: IconShape = .roundedSquare
    @State private var customCornerRadius: Double = 20

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Preview header
            Text("Advanced Editing")
                .font(.headline)
                .padding(.bottom, 4)

            if sourceImage != nil {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Icon shape section
                        Group {
                            Text("Icon Shape")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Picker("Shape", selection: $iconShape) {
                                ForEach(IconShape.allCases) { shape in
                                    Text(shape.rawValue).tag(shape)
                                }
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: iconShape) { newValue in
                                applyChanges()
                            }

                            if iconShape == .roundedSquare {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Corner Radius")
                                            .font(.caption)
                                        Spacer()
                                        Text("\(Int(customCornerRadius))")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }

                                    Slider(value: $customCornerRadius, in: 0...60)
                                        .onChange(of: customCornerRadius) { newValue in
                                            applyChanges()
                                        }
                                }
                            }
                        }

                        Divider()

                        // Border section
                        Group {
                            Toggle("Add Border", isOn: $addBorder)
                                .onChange(of: addBorder) { newValue in
                                    applyChanges()
                                }

                            if addBorder {
                                VStack(alignment: .leading, spacing: 8) {
                                    ColorPicker("Border Color", selection: $borderColor)
                                        .onChange(of: borderColor) { newValue in
                                            applyChanges()
                                        }

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text("Border Width")
                                                .font(.caption)
                                            Spacer()
                                            Text("\(Int(borderWidth))")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }

                                        Slider(value: $borderWidth, in: 1...15)
                                            .onChange(of: borderWidth) { newValue in
                                                applyChanges()
                                            }
                                    }
                                }
                            }
                        }

                        Divider()

                        // Text overlay section
                        Group {
                            Text("Text Overlay")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Picker("Overlay Type", selection: $overlayType) {
                                ForEach(OverlayType.allCases) { overlay in
                                    Text(overlay.rawValue).tag(overlay)
                                }
                            }
                            .onChange(of: overlayType) { newValue in
                                applyChanges()
                            }

                            if overlayType == .custom {
                                TextField("Custom Text", text: $customOverlayText)
                                    .textFieldStyle(.roundedBorder)
                                    .onChange(of: customOverlayText) { newValue in
                                        if !customOverlayText.isEmpty {
                                            applyChanges()
                                        }
                                    }
                            }

                            if overlayType != .none {
                                VStack(alignment: .leading, spacing: 8) {
                                    ColorPicker("Text Color", selection: $overlayColor)
                                        .onChange(of: overlayColor) { newValue in
                                            applyChanges()
                                        }

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text("Font Size")
                                                .font(.caption)
                                            Spacer()
                                            Text("\(Int(overlayFontSize))")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }

                                        Slider(value: $overlayFontSize, in: 8...40)
                                            .onChange(of: overlayFontSize) { newValue in
                                                applyChanges()
                                            }
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text("Rotation")
                                                .font(.caption)
                                            Spacer()
                                            Text("\(Int(overlayRotation))°")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }

                                        Slider(value: $overlayRotation, in: -90...90)
                                            .onChange(of: overlayRotation) { newValue in
                                                applyChanges()
                                            }
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text("Position")
                                                .font(.caption)
                                            Spacer()
                                            Text(String(format: "%.1f", overlayPosition))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }

                                        Slider(value: $overlayPosition, in: 0...1)
                                            .onChange(of: overlayPosition) { newValue in
                                                applyChanges()
                                            }
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text("Opacity")
                                                .font(.caption)
                                            Spacer()
                                            Text(String(format: "%.1f", overlayOpacity))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }

                                        Slider(value: $overlayOpacity, in: 0...1)
                                            .onChange(of: overlayOpacity) { newValue in
                                                applyChanges()
                                            }
                                    }
                                }
                            }
                        }

                        Divider()

                        // Apply/Reset buttons
                        HStack {
                            Button("Reset") {
                                resetAdvancedEditing()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .tint(.red.opacity(0.8))

                            Spacer()

                            Button("Apply") {
                                applyChanges()
                                viewModel.updateEditedImage(sourceImage)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                    .padding()
                }
            } else {
                VStack {
                    Spacer()
                    Text("Upload an image to start editing")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .onAppear {
            if let image = sourceImage {
                originalImage = image.copyImage()
            }
        }
        .onChange(of: sourceImage) { newImage in
            // Only update original image reference if it's a new source image (not an edit)
            if let image = newImage, originalImage == nil {
                originalImage = image.copyImage()
                resetAdvancedEditing()
            }
        }
    }

    // MARK: - Methods

    func applyChanges() {
        guard let originalImage = self.originalImage?.copyImage() else { return }

        // Start with a clean copy of the original image
        var processedImage = originalImage

        // Calculate size information
        let imageSize = processedImage.size
        let targetSize = imageSize

        // Create a new image context
        let resultImage = NSImage(size: targetSize)
        resultImage.lockFocus()

        let context = NSGraphicsContext.current?.cgContext
        let rect = NSRect(origin: .zero, size: targetSize)

        // Draw base shape with potential clipping path
        if iconShape != .square {
            // Create clipping path based on shape
            let path = NSBezierPath()

            if iconShape == .circle {
                // Create circular clipping path
                path.appendOval(in: rect)
            } else if iconShape == .roundedSquare {
                // Create rounded rect clipping path
                path.appendRoundedRect(
                    rect, xRadius: customCornerRadius, yRadius: customCornerRadius)
            }

            path.addClip()
        }

        // Draw the image
        processedImage.draw(in: rect)

        // Add border if needed
        if addBorder {
            let borderPath = NSBezierPath()
            let borderRect = NSRect(
                x: borderWidth / 2,
                y: borderWidth / 2,
                width: targetSize.width - borderWidth,
                height: targetSize.height - borderWidth
            )

            // Create path based on shape
            if iconShape == .circle {
                borderPath.appendOval(in: borderRect)
            } else if iconShape == .roundedSquare {
                borderPath.appendRoundedRect(
                    borderRect, xRadius: customCornerRadius, yRadius: customCornerRadius)
            } else {
                borderPath.appendRect(borderRect)
            }

            // Set border properties
            NSColor(borderColor).setStroke()
            borderPath.lineWidth = borderWidth
            borderPath.stroke()
        }

        // Add text overlay if needed
        if overlayType != .none {
            let overlayText: String
            switch overlayType {
            case .beta:
                overlayText = "BETA"
            case .dev:
                overlayText = "DEV"
            case .alpha:
                overlayText = "ALPHA"
            case .staging:
                overlayText = "STAGING"
            case .test:
                overlayText = "TEST"
            case .custom:
                overlayText = customOverlayText
            default:
                overlayText = ""
            }

            if !overlayText.isEmpty {
                // Create attributed string
                let font = NSFont.systemFont(ofSize: overlayFontSize, weight: .bold)
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: NSColor(overlayColor).withAlphaComponent(overlayOpacity),
                ]

                let attrString = NSAttributedString(string: overlayText, attributes: attributes)
                let textSize = attrString.size()

                // Calculate position
                let centerX = targetSize.width / 2
                let centerY = targetSize.height * (1 - overlayPosition)

                // Save graphics state for rotation
                context?.saveGState()

                // Translate to the center of text position
                context?.translateBy(x: centerX, y: centerY)

                // Rotate context
                context?.rotate(by: CGFloat(overlayRotation) * .pi / 180)

                // Draw text centered at origin
                let textRect = NSRect(
                    x: -textSize.width / 2,
                    y: -textSize.height / 2,
                    width: textSize.width,
                    height: textSize.height
                )

                attrString.draw(in: textRect)

                // Restore graphics state
                context?.restoreGState()
            }
        }

        resultImage.unlockFocus()

        // Update the source image with our changes
        sourceImage = resultImage
    }

    func resetAdvancedEditing() {
        iconShape = .roundedSquare
        customCornerRadius = 20
        addBorder = false
        borderWidth = 4
        borderColor = .blue
        overlayType = .none
        customOverlayText = ""
        overlayPosition = 0.5
        overlayOpacity = 0.8
        overlayColor = .red
        overlayFontSize = 18
        overlayRotation = -45

        // Reset the image to the original
        if let original = originalImage {
            sourceImage = original.copyImage()
        }
    }
}
