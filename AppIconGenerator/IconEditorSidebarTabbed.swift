//
//  IconEditorSidebarTabbed.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import SwiftUI

struct IconEditorSidebarTabbed: View {
    @ObservedObject var viewModel: IconViewModel
    @Binding var sourceImage: NSImage?
    @State private var selectedTab = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Icon Editor")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)

            Divider()

            Picker("", selection: $selectedTab) {
                Text("Basic").tag(0)
                Text("Advanced").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            if sourceImage == nil {
                Spacer()
                VStack {
                    Image(systemName: "photo")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                    Text("Upload an image to start editing")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                // Preview area
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
                .padding()

                Divider()

                // Tab content
                TabView(selection: $selectedTab) {
                    // Basic editing tab
                    ScrollView {
                        BasicIconEditor(viewModel: viewModel, sourceImage: $sourceImage)
                            .padding()
                    }
                    .tag(0)

                    // Advanced editing tab
                    ScrollView {
                        AdvancedIconEditing(viewModel: viewModel, sourceImage: $sourceImage)
                            .padding()
                    }
                    .tag(1)
                }
                //                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .frame(width: 280)
        .background(Color(.windowBackgroundColor).opacity(0.3))
    }
}

// Split out the basic editing functionality into its own component
struct BasicIconEditor: View {
    @ObservedObject var viewModel: IconViewModel
    @Binding var sourceImage: NSImage?
    @State private var brightness: Double = 0
    @State private var contrast: Double = 0
    @State private var saturation: Double = 0
    @State private var hue: Double = 0
    @State private var roundedCorners: Double = 0
    @State private var padding: Double = 0
    @State private var backgroundColor: Color = .clear
    @State private var showColorPicker = false
    @State private var useCustomBackground = false
    @State private var applyTint = false
    @State private var tintColor: Color = .blue
    @State private var tintIntensity: Double = 0.5

    // Store original image for reset functionality
    @State private var originalImage: NSImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Image adjustments
            Group {
                Text("Adjustments")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                SliderControl(value: $brightness, range: -0.5...0.5, label: "Brightness")
                    .onChange(of: brightness) { _ in applyFilters() }

                SliderControl(value: $contrast, range: -0.5...0.5, label: "Contrast")
                    .onChange(of: contrast) { _ in applyFilters() }

                SliderControl(value: $saturation, range: -1.0...1.0, label: "Saturation")
                    .onChange(of: saturation) { _ in applyFilters() }

                SliderControl(value: $hue, range: -0.5...0.5, label: "Hue")
                    .onChange(of: hue) { _ in applyFilters() }
            }

            Divider()

            // Shape and background
            Group {
                Text("Shape & Background")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                SliderControl(value: $roundedCorners, range: 0...60, label: "Rounded Corners")
                    .onChange(of: roundedCorners) { _ in applyShapeChanges() }

                SliderControl(value: $padding, range: 0...60, label: "Padding")
                    .onChange(of: padding) { _ in applyShapeChanges() }

                Toggle("Custom Background", isOn: $useCustomBackground)
                    .onChange(of: useCustomBackground) { _ in applyShapeChanges() }

                if useCustomBackground {
                    ColorPicker("Background Color", selection: $backgroundColor)
                        .onChange(of: backgroundColor) { _ in applyShapeChanges() }
                }
            }

            Divider()

            // Tint options
            Group {
                Text("Color Tint")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Toggle("Apply Tint", isOn: $applyTint)
                    .onChange(of: applyTint) { _ in applyTintChanges() }

                if applyTint {
                    ColorPicker("Tint Color", selection: $tintColor)
                        .onChange(of: tintColor) { _ in applyTintChanges() }

                    SliderControl(value: $tintIntensity, range: 0...1, label: "Intensity")
                        .onChange(of: tintIntensity) { _ in applyTintChanges() }
                }
            }

            Divider()

            // Action buttons
            HStack {
                Button("Reset") {
                    resetAllChanges()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                //                .buttonBorderShape(.capsule)
                .tint(.red.opacity(0.8))

                Spacer()

                Button("Apply") {
                    // Current image is already applied through editing
                    viewModel.updateEditedImage(sourceImage)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                //                .buttonBorderShape(.capsule)
            }
        }
        .onAppear {
            if let image = sourceImage {
                originalImage = image.copyImage() as? NSImage
            }
        }
        .onChange(of: sourceImage) { newImage in
            if let image = newImage {
                originalImage = image.copy() as? NSImage
                resetControlValues()
            }
        }
    }

    // MARK: - Methods

    private func applyFilters() {
        guard let originalImage = originalImage else { return }

        let tempImage = originalImage.copyImage() as? NSImage

        // Apply filters in sequence using CIFilter
        if let sourceImage = tempImage,
            let cgImage = sourceImage.cgImage
        {
            let ciImage = CIImage(cgImage: cgImage)

            // Create the filter chain
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
                let resultImage = NSImage(cgImage: cgImageResult, size: sourceImage.size)

                // Apply shape changes on top of filters
                self.sourceImage = resultImage
                applyShapeChanges()
            }
        }
    }

    private func applyShapeChanges() {
        guard var currentImage = sourceImage?.copy() as? NSImage else { return }

        if useCustomBackground || padding > 0 || applyTint {
            let imageSize = currentImage.size
            let targetSize = NSSize(
                width: imageSize.width,
                height: imageSize.height
            )

            let newImage = NSImage(size: targetSize)
            newImage.lockFocus()

            // Draw background if needed
            if useCustomBackground {
                let nsColor = NSColor(backgroundColor)
                nsColor.setFill()
                NSBezierPath(rect: NSRect(origin: .zero, size: targetSize)).fill()
            }

            // Calculate padding
            let paddingX = padding
            let paddingY = padding
            let drawRect = NSRect(
                x: paddingX,
                y: paddingY,
                width: targetSize.width - (paddingX * 2),
                height: targetSize.height - (paddingY * 2)
            )

            // Draw original image with padding
            currentImage.draw(
                in: drawRect,
                from: NSRect(origin: .zero, size: currentImage.size),
                operation: .sourceOver,
                fraction: 1.0
            )

            newImage.unlockFocus()
            currentImage = newImage
        }

        // Apply tinting on top if needed
        if applyTint {
            applyTintToImage(currentImage)
        } else {
            self.sourceImage = currentImage
        }
    }

    private func applyTintChanges() {
        applyFilters()  // Reapply the entire chain including shape changes
    }

    private func applyTintToImage(_ image: NSImage) {
        guard let cgImage = image.cgImage else { return }

        let ciImage = CIImage(cgImage: cgImage)

        // Create a colored image for the tint
        let tintCIColor = CIColor(color: NSColor(tintColor))
        let colorFilter = CIFilter(name: "CIConstantColorGenerator")
        colorFilter?.setValue(tintCIColor, forKey: kCIInputColorKey)

        guard let colorImage = colorFilter?.outputImage else { return }

        // Use blend filter to apply tint
        let blendFilter = CIFilter(name: "CISourceAtopCompositing")
        blendFilter?.setValue(colorImage, forKey: kCIInputImageKey)
        blendFilter?.setValue(ciImage, forKey: kCIInputBackgroundImageKey)

        guard let blendOutput = blendFilter?.outputImage else { return }

        // Blend the tinted image with the original based on intensity
        let finalFilter = CIFilter(name: "CISourceOverCompositing")
        finalFilter?.setValue(blendOutput.cropped(to: ciImage.extent), forKey: kCIInputImageKey)
        finalFilter?.setValue(ciImage, forKey: kCIInputBackgroundImageKey)

        guard let finalOutput = finalFilter?.outputImage else { return }

        // Convert back to NSImage
        let context = CIContext()
        if let cgImageResult = context.createCGImage(finalOutput, from: finalOutput.extent) {
            let resultImage = NSImage(cgImage: cgImageResult, size: image.size)
            self.sourceImage = resultImage
        }
    }

    private func resetControlValues() {
        brightness = 0
        contrast = 0
        saturation = 0
        hue = 0
        roundedCorners = 0
        padding = 0
        backgroundColor = .clear
        useCustomBackground = false
        applyTint = false
        tintColor = .blue
        tintIntensity = 0.5
    }

    private func resetAllChanges() {
        resetControlValues()
        if let original = originalImage {
            sourceImage = original.copyImage() as? NSImage
        }
    }
}
