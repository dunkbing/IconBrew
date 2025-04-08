//
//  GenerationControlsView.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import SwiftUI

struct GenerationControlsView: View {
    @ObservedObject var viewModel: IconViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Output Folder:")
                    .font(.subheadline)

                Button(action: viewModel.selectOutputFolder) {
                    Text("Select")
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal, 2)

            if let selectedFolder = viewModel.selectedOutputFolder {
                Text(selectedFolder.path)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        NSWorkspace.shared.open(selectedFolder)
                    }
            } else {
                Text("Not selected")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: viewModel.generateIcons) {
                Text(viewModel.generationComplete ? "Generate Again" : "Generate Icons")
                    .fontWeight(.semibold)
                    .frame(minWidth: 160)
                    .padding(.vertical, 8)
            }
            .buttonStyle(GenerateButtonStyle(isEnabled: viewModel.sourceImage != nil))
            .disabled(viewModel.sourceImage == nil || viewModel.isGenerating)

            if viewModel.isGenerating {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.8)
                    .padding(.top, 5)
            }

            if let outputURL = viewModel.outputFolderURL, viewModel.generationComplete {
                HStack {
                    Text("Icons saved to:")
                        .font(.caption)
                    Text("\(outputURL.path)")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .onTapGesture {
                            NSWorkspace.shared.open(outputURL)
                        }
                }
                .padding(.top, 5)
            }
        }
        .padding(.vertical)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }
}

struct GenerateButtonStyle: ButtonStyle {
    var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isEnabled
                            ? (configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
                            : Color.gray)
            )
            .foregroundColor(.white)
    }
}
