//
//  ImageDropView.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImageDropView: View {
    @ObservedObject var viewModel: IconViewModel
    @State private var isHovering = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    viewModel.sourceImage == nil
                        ? Color.gray.opacity(0.2)
                        : Color.gray.opacity(0.1)
                )
                .animation(.easeInOut, value: viewModel.sourceImage != nil)

            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    viewModel.isImageDragging
                        ? Color.blue
                        : (isHovering ? Color.blue.opacity(0.5) : Color.gray.opacity(0.3)),
                    style: StrokeStyle(
                        lineWidth: viewModel.isImageDragging ? 2 : (isHovering ? 1.5 : 1),
                        dash: [6],
                        dashPhase: 0
                    )
                )
                .animation(.easeInOut, value: viewModel.isImageDragging)
                .animation(.easeInOut, value: isHovering)

            if let image = viewModel.sourceImage {
                VStack {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                        .cornerRadius(8)
                        .shadow(radius: 2)

                    Text("Click or drag a new image to replace")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)

                    Text("Drag and drop an image or click to select")
                        .foregroundColor(.gray)

                    Text("Recommended: Use a square image at least 1024×1024 pixels")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
        }
        .frame(height: 240)
        .onTapGesture {
            viewModel.selectImage { newImage in
                viewModel.sourceImage = newImage
            }
        }
        .onHover { hovering in
            isHovering = hovering
        }
        .onDrop(of: [UTType.image.identifier], isTargeted: $viewModel.isImageDragging) {
            providers in
            viewModel.loadDroppedImage(from: providers) { newImage in
                viewModel.sourceImage = newImage
            }
            return true
        }
    }
}
