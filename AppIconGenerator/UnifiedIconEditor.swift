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
    @State private var padding: Double = 0
    @State private var backgroundColor: Color = .clear
    @State private var useCustomBackground = false

    // Tint options
    @State private var applyTint = false
    @State private var tintColor: Color = .blue
    @State private var tintIntensity: Double = 0.5

    // Shape properties
    @State private var iconShape: IconShape = .roundedSquare
    @State private var customCornerRadius: Double = 20

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

    // Control section states
    @State private var isBasicExpanded = true
    @State private var isShapeExpanded = true
    @State private var isOverlayExpanded = false

    // Debouncers
    private let colorDebouncer = Debouncer(delay: 0.3)
    private let textDebouncer = Debouncer(delay: 0.5)

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
                // Preview
                HStack {
                    Spacer()
                    if let image = sourceImage {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .shadow(radius: 1)
                    }
                    Spacer()
                }
                .padding(.bottom, 12)

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
                                                colorDebouncer.debounce {
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
                                            value: $customCornerRadius,
                                            range: 0...60,
                                            label: "Corner Radius",
                                            onValueChanged: applyChanges
                                        )
                                    }

                                    // Padding control
                                    DebouncedSliderControl(
                                        value: $padding,
                                        range: 0...60,
                                        label: "Padding",
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
                                                colorDebouncer.debounce {
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
                                                colorDebouncer.debounce {
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

                        // MARK: - Text Overlay Section
                        DisclosureGroup(
                            isExpanded: $isOverlayExpanded,
                            content: {
                                VStack(alignment: .leading, spacing: 12) {
                                    Picker("Overlay Type", selection: $overlayType) {
                                        ForEach(OverlayType.allCases) { overlay in
                                            Text(overlay.rawValue).tag(overlay)
                                        }
                                    }
                                    .onChange(of: overlayType) { _ in
                                        applyChanges()
                                    }

                                    if overlayType == .custom {
                                        TextField("Custom Text", text: $customOverlayText)
                                            .textFieldStyle(.roundedBorder)
                                            .onChange(of: customOverlayText) { _ in
                                                if !customOverlayText.isEmpty {
                                                    textDebouncer.debounce {
                                                        applyChanges()
                                                    }
                                                }
                                            }
                                    }

                                    if overlayType != .none {
                                        ColorPicker("Text Color", selection: $overlayColor)
                                            .onChange(of: overlayColor) { _ in
                                                colorDebouncer.debounce {
                                                    applyChanges()
                                                }
                                            }

                                        DebouncedSliderControl(
                                            value: $overlayFontSize,
                                            range: 8...40,
                                            label: "Font Size",
                                            onValueChanged: applyChanges
                                        )

                                        DebouncedSliderControl(
                                            value: $overlayRotation,
                                            range: -90...90,
                                            label: "Rotation",
                                            onValueChanged: applyChanges
                                        )

                                        DebouncedSliderControl(
                                            value: $overlayPosition,
                                            range: 0...1,
                                            label: "Position",
                                            onValueChanged: applyChanges
                                        )

                                        DebouncedSliderControl(
                                            value: $overlayOpacity,
                                            range: 0...1,
                                            label: "Opacity",
                                            onValueChanged: applyChanges
                                        )
                                    }
                                }
                                .padding(.top, 8)
                            },
                            label: {
                                HStack {
                                    Image(systemName: "textformat")
                                        .foregroundColor(.secondary)
                                    Text("Text Overlay")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                            }
                        )

                        Divider()

                        // Action buttons
                        HStack {
                            Button("Reset") {
                                resetAllChanges()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .tint(.red.opacity(0.8))

                            Spacer()

                            Button("Apply") {
                                // Current image is already applied through editing
                                viewModel.updateEditedImage(sourceImage)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
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
            // Only update original image reference if it's a new source image (not an edit)
            if let image = newImage, originalImage == nil {
                originalImage = image.copyImage()
                resetControlValues()
            }
        }
    }

    // MARK: - Methods

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

        // Create a new image context
        let resultImage = NSImage(size: targetSize)
        resultImage.lockFocus()

        let context = NSGraphicsContext.current?.cgContext
        let rect = NSRect(origin: .zero, size: targetSize)

        // Draw background if needed
        if useCustomBackground {
            NSColor(backgroundColor).setFill()
            NSBezierPath(rect: rect).fill()
        }

        // Calculate padding if needed
        let paddedRect: NSRect
        if padding > 0 {
            paddedRect = NSRect(
                x: padding,
                y: padding,
                width: targetSize.width - (padding * 2),
                height: targetSize.height - (padding * 2)
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
                    paddedRect, xRadius: customCornerRadius, yRadius: customCornerRadius)
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
        customCornerRadius = 20
        padding = 0
        backgroundColor = .clear
        useCustomBackground = false
        addBorder = false
        borderWidth = 4
        borderColor = .blue

        // Reset Text Overlay
        overlayType = .none
        customOverlayText = ""
        overlayPosition = 0.5
        overlayOpacity = 0.8
        overlayColor = .red
        overlayFontSize = 18
        overlayRotation = -45

        // Reset UI state
        isBasicExpanded = true
        isShapeExpanded = true
        isOverlayExpanded = false
    }

    private func resetAllChanges() {
        resetControlValues()
        if let original = originalImage {
            sourceImage = original.copyImage()
        }
    }
}
