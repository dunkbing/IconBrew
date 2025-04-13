//
//  UnifiedIconEditor.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 13/4/25.
//

import SwiftUI

struct UnifiedIconEditor: View {
    @ObservedObject var viewModel: IconViewModel
    @Binding var sourceImage: NSImage?

    // Store original image for reset functionality
    @State private var originalImage: NSImage?

    // Basic adjustments
    @State private var brightness: Double = 0
    @State private var contrast: Double = 0
    @State private var saturation: Double = 0
    @State private var hue: Double = 0

    // Background & Shape controls
    @State private var paddingPercentage: Double = 0
    @State private var backgroundColor: Color = .clear
    @State private var useCustomBackground = false

    // Tint options
    @State private var applyTint = false
    @State private var tintColor: Color = .blue
    @State private var tintIntensity: Double = 0.5

    // Shape
    @State private var iconShape: IconShape = .roundedSquare
    @State private var cornerRadiusPercentage: Double = 10

    // Border
    @State private var addBorder = false
    @State private var borderWidth: Double = 4
    @State private var borderColor: Color = .blue

    // Control section states
    @State private var isBasicExpanded = true
    @State private var isShapeExpanded = true

    // Debouncers
    private let debouncer = Debouncer(delay: 0.3)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Icon Editor")
                .font(.headline)
                .padding(.bottom, 4)

            if sourceImage == nil {
                VStack {
                    Spacer()
                    Text("Upload an image to start editing")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // MARK: - Basic Adjustments Section
                        DisclosureGroup(
                            isExpanded: $isBasicExpanded,
                            content: {
                                VStack(alignment: .leading, spacing: 12) {
                                    DebouncedSliderControl(
                                        value: $brightness,
                                        range: -0.5...0.5,
                                        label: "Brightness",
                                        onValueChanged: applyChanges
                                    )

                                    DebouncedSliderControl(
                                        value: $contrast,
                                        range: -0.5...0.5,
                                        label: "Contrast",
                                        onValueChanged: applyChanges
                                    )

                                    DebouncedSliderControl(
                                        value: $saturation,
                                        range: -1.0...1.0,
                                        label: "Saturation",
                                        onValueChanged: applyChanges
                                    )

                                    DebouncedSliderControl(
                                        value: $hue,
                                        range: -0.5...0.5,
                                        label: "Hue",
                                        onValueChanged: applyChanges
                                    )

                                    // Color tint controls
                                    Toggle("Apply Color Tint", isOn: $applyTint)
                                        .onChange(of: applyTint) { _ in applyChanges() }

                                    if applyTint {
                                        ColorPicker("Tint Color", selection: $tintColor)
                                            .onChange(of: tintColor) { _ in
                                                debouncer.debounce {
                                                    applyChanges()
                                                }
                                            }

                                        DebouncedSliderControl(
                                            value: $tintIntensity,
                                            range: 0...1,
                                            label: "Intensity",
                                            onValueChanged: applyChanges
                                        )
                                    }
                                }
                                .padding(.top, 8)
                            },
                            label: {
                                HStack {
                                    Image(systemName: "slider.horizontal.3")
                                        .foregroundColor(.secondary)
                                    Text("Basic Adjustments")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                            }
                        )

                        Divider()

                        // MARK: - Shape & Background Section
                        DisclosureGroup(
                            isExpanded: $isShapeExpanded,
                            content: {
                                VStack(alignment: .leading, spacing: 12) {
                                    // Icon shape picker
                                    Text("Icon Shape")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Picker("Shape", selection: $iconShape) {
                                        ForEach(IconShape.allCases) { shape in
                                            Text(shape.rawValue).tag(shape)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .onChange(of: iconShape) { _ in
                                        applyChanges()
                                    }

                                    if iconShape == .roundedSquare {
                                        DebouncedSliderControl(
                                            value: $cornerRadiusPercentage,
                                            range: 0...50,  // Up to 50% of smaller dimension
                                            label: "Corner Radius (%)",
                                            onValueChanged: applyChanges
                                        )
                                    }

                                    // Padding control
                                    DebouncedSliderControl(
                                        value: $paddingPercentage,
                                        range: 0...25,  // Up to 25% of smaller dimension
                                        label: "Padding (%)",
                                        onValueChanged: applyChanges
                                    )

                                    // Border controls
                                    Toggle("Add Border", isOn: $addBorder)
                                        .onChange(of: addBorder) { _ in
                                            applyChanges()
                                        }

                                    if addBorder {
                                        ColorPicker("Border Color", selection: $borderColor)
                                            .onChange(of: borderColor) { _ in
                                                debouncer.debounce {
                                                    applyChanges()
                                                }
                                            }

                                        DebouncedSliderControl(
                                            value: $borderWidth,
                                            range: 1...15,
                                            label: "Border Width",
                                            onValueChanged: applyChanges
                                        )
                                    }

                                    // Background controls
                                    Toggle("Custom Background", isOn: $useCustomBackground)
                                        .onChange(of: useCustomBackground) { _ in
                                            applyChanges()
                                        }

                                    if useCustomBackground {
                                        ColorPicker("Background Color", selection: $backgroundColor)
                                            .onChange(of: backgroundColor) { _ in
                                                debouncer.debounce {
                                                    applyChanges()
                                                }
                                            }
                                    }
                                }
                                .padding(.top, 8)
                            },
                            label: {
                                HStack {
                                    Image(systemName: "square.on.circle")
                                        .foregroundColor(.secondary)
                                    Text("Shape & Background")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                            }
                        )

                        Divider()

                        // Action buttons - Only Reset button now
                        HStack {
                            Button("Reset") {
                                resetAllChanges()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .tint(.red.opacity(0.8))
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            if let image = sourceImage {
                originalImage = image.copyImage()
            }
        }
        .onChange(of: sourceImage) { newImage in
            if let image = newImage, originalImage == nil {
                originalImage = image.copyImage()
                resetControlValues()
            }
        }
    }

    func applyChanges() {
        guard let originalImage = self.originalImage?.copyImage() else { return }

        // Start with a copy of the original image for filters
        var processedImage = originalImage

        // Apply basic filters first
        if brightness != 0 || contrast != 0 || saturation != 0 || hue != 0 {
            processedImage = applyBasicFilters(to: processedImage)
        }

        // Apply tint if needed
        if applyTint {
            processedImage = applyTint(to: processedImage)
        }

        // Apply shape, border, background, etc.
        processedImage = applyShapeAndBorder(to: processedImage)

        // Update the source image with our changes
        sourceImage = processedImage

        // Update the edited image in the view model
        viewModel.updateEditedImage(processedImage)
    }

    private func applyBasicFilters(to image: NSImage) -> NSImage {
        guard let cgImage = image.cgImage else { return image }

        let ciImage = CIImage(cgImage: cgImage)
        var currentCIImage = ciImage

        // Brightness
        if brightness != 0 {
            let brightnessFilter = CIFilter(name: "CIColorControls")
            brightnessFilter?.setValue(currentCIImage, forKey: kCIInputImageKey)
            brightnessFilter?.setValue(brightness, forKey: kCIInputBrightnessKey)
            if let outputImage = brightnessFilter?.outputImage {
                currentCIImage = outputImage
            }
        }

        // Contrast
        if contrast != 0 {
            let contrastFilter = CIFilter(name: "CIColorControls")
            contrastFilter?.setValue(currentCIImage, forKey: kCIInputImageKey)
            contrastFilter?.setValue(1.0 + contrast, forKey: kCIInputContrastKey)
            if let outputImage = contrastFilter?.outputImage {
                currentCIImage = outputImage
            }
        }

        // Saturation
        if saturation != 0 {
            let saturationFilter = CIFilter(name: "CIColorControls")
            saturationFilter?.setValue(currentCIImage, forKey: kCIInputImageKey)
            saturationFilter?.setValue(1.0 + saturation, forKey: kCIInputSaturationKey)
            if let outputImage = saturationFilter?.outputImage {
                currentCIImage = outputImage
            }
        }

        // Hue adjustment
        if hue != 0 {
            let hueFilter = CIFilter(name: "CIHueAdjust")
            hueFilter?.setValue(currentCIImage, forKey: kCIInputImageKey)
            hueFilter?.setValue(hue * .pi, forKey: kCIInputAngleKey)
            if let outputImage = hueFilter?.outputImage {
                currentCIImage = outputImage
            }
        }

        // Convert back to NSImage
        let context = CIContext()
        if let cgImageResult = context.createCGImage(
            currentCIImage, from: currentCIImage.extent)
        {
            return NSImage(cgImage: cgImageResult, size: image.size)
        }

        return image
    }

    private func applyTint(to image: NSImage) -> NSImage {
        guard let cgImage = image.cgImage else { return image }

        let ciImage = CIImage(cgImage: cgImage)

        // Create a colored image for the tint
        let tintCIColor = CIColor(color: NSColor(tintColor))
        let colorFilter = CIFilter(name: "CIConstantColorGenerator")
        colorFilter?.setValue(tintCIColor, forKey: kCIInputColorKey)

        guard let colorImage = colorFilter?.outputImage else { return image }

        // Use blend filter to apply tint
        let blendFilter = CIFilter(name: "CISourceAtopCompositing")
        blendFilter?.setValue(colorImage, forKey: kCIInputImageKey)
        blendFilter?.setValue(ciImage, forKey: kCIInputBackgroundImageKey)

        guard let blendOutput = blendFilter?.outputImage else { return image }

        // Control the intensity of the tint by blending with the original
        let blend = CIFilter(name: "CIBlendWithMask")
        blend?.setValue(blendOutput, forKey: kCIInputImageKey)
        blend?.setValue(ciImage, forKey: kCIInputBackgroundImageKey)

        // Create a constant color filter for the mask
        let maskGenerator = CIFilter(name: "CIConstantColorGenerator")
        let maskColor = CIColor(red: tintIntensity, green: tintIntensity, blue: tintIntensity)
        maskGenerator?.setValue(maskColor, forKey: kCIInputColorKey)
        blend?.setValue(maskGenerator?.outputImage, forKey: kCIInputMaskImageKey)

        guard let outputImage = blend?.outputImage else { return image }

        // Convert back to NSImage
        let context = CIContext()
        if let cgImageResult = context.createCGImage(outputImage, from: outputImage.extent) {
            return NSImage(cgImage: cgImageResult, size: image.size)
        }

        return image
    }

    private func applyShapeAndBorder(to image: NSImage) -> NSImage {
        let imageSize = image.size
        let targetSize = imageSize
        let smallerDimension = min(targetSize.width, targetSize.height)

        // Calculate actual padding and corner radius in points
        let actualPadding = (paddingPercentage / 100) * smallerDimension
        let actualCornerRadius = (cornerRadiusPercentage / 100) * smallerDimension

        // Create a new image context
        let resultImage = NSImage(size: targetSize)
        resultImage.lockFocus()

        let rect = NSRect(origin: .zero, size: targetSize)

        // Draw background if needed
        if useCustomBackground {
            NSColor(backgroundColor).setFill()
            NSBezierPath(rect: rect).fill()
        }

        // Calculate padding if needed
        let paddedRect: NSRect
        if paddingPercentage > 0 {
            paddedRect = NSRect(
                x: actualPadding,
                y: actualPadding,
                width: targetSize.width - (actualPadding * 2),
                height: targetSize.height - (actualPadding * 2)
            )
        } else {
            paddedRect = rect
        }

        // Draw base shape with potential clipping path
        if iconShape != .square {
            // Create clipping path based on shape
            let path = NSBezierPath()

            if iconShape == .circle {
                // Create circular clipping path
                path.appendOval(in: paddedRect)
            } else if iconShape == .roundedSquare {
                // Create rounded rect clipping path
                path.appendRoundedRect(
                    paddedRect, xRadius: actualCornerRadius, yRadius: actualCornerRadius)
            }

            path.addClip()
        }

        // Draw the image
        image.draw(
            in: paddedRect,
            from: NSRect(origin: .zero, size: image.size),
            operation: .sourceOver,
            fraction: 1.0
        )

        // Add border if needed
        if addBorder {
            let borderPath = NSBezierPath()
            let borderRect = NSRect(
                x: paddedRect.minX + borderWidth / 2,
                y: paddedRect.minY + borderWidth / 2,
                width: paddedRect.width - borderWidth,
                height: paddedRect.height - borderWidth
            )

            // Create path based on shape
            if iconShape == .circle {
                borderPath.appendOval(in: borderRect)
            } else if iconShape == .roundedSquare {
                borderPath.appendRoundedRect(
                    borderRect, xRadius: actualCornerRadius, yRadius: actualCornerRadius)
            } else {
                borderPath.appendRect(borderRect)
            }

            // Set border properties
            NSColor(borderColor).setStroke()
            borderPath.lineWidth = borderWidth
            borderPath.stroke()
        }

        resultImage.unlockFocus()
        return resultImage
    }

    private func resetControlValues() {
        // Reset Basic Adjustments
        brightness = 0
        contrast = 0
        saturation = 0
        hue = 0
        applyTint = false
        tintColor = .blue
        tintIntensity = 0.5

        // Reset Shape & Background
        iconShape = .roundedSquare
        cornerRadiusPercentage = 10
        paddingPercentage = 0
        backgroundColor = .clear
        useCustomBackground = false
        addBorder = false
        borderWidth = 4
        borderColor = .blue

        // Reset UI state
        isBasicExpanded = true
        isShapeExpanded = true
    }

    private func resetAllChanges() {
        resetControlValues()
        if let original = originalImage {
            sourceImage = original.copyImage()
            viewModel.updateEditedImage(original.copyImage())
        }
    }
}
