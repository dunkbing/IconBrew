//
//  ImageDropView.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImageDropView: View {
    @Binding var sourceImage: NSImage?
    @Binding var isImageDragging: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    sourceImage == nil
                        ? Color.gray.opacity(0.2)
                        : Color.gray.opacity(0.1))

            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isImageDragging ? Color.blue : Color.gray.opacity(0.3),
                    style: StrokeStyle(
                        lineWidth: isImageDragging ? 2 : 1,
                        dash: [6],
                        dashPhase: 0
                    )
                )

            if let image = sourceImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Drag and drop an image or click to select")
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(height: 240)
        .onTapGesture {
            IconViewModel().selectImage { newImage in
                sourceImage = newImage
            }
        }
        .onDrop(of: [UTType.image.identifier], isTargeted: $isImageDragging) { providers in
            let viewModel = IconViewModel()
            viewModel.loadDroppedImage(from: providers) { newImage in
                sourceImage = newImage
            }
            return true
        }
    }
}
