//
//  IconEditorSidebar.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import SwiftUI

struct IconEditorSidebar: View {
    @ObservedObject var viewModel: IconViewModel
    @Binding var sourceImage: NSImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            UnifiedIconEditor(viewModel: viewModel, sourceImage: $sourceImage)
                .padding(.top, sourceImage == nil ? 16 : 0)
        }
        .frame(width: 280)
        .background(Color(.windowBackgroundColor).opacity(0.3))
    }
}
