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
        VStack {
            Button(action: viewModel.generateIcons) {
                Text(viewModel.generationComplete ? "Generated!" : "Generate Icons")
                    .fontWeight(.semibold)
                    .frame(width: 160)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(viewModel.sourceImage == nil ? Color.gray : Color.blue)
                    )
                    .foregroundColor(.white)
            }
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
    }
}
