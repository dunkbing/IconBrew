//
//  ContentView.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var iconViewModel = IconViewModel()

    var body: some View {
        VStack(spacing: 20) {
            HeaderView()

            ImageDropView(
                sourceImage: $iconViewModel.sourceImage,
                isImageDragging: $iconViewModel.isImageDragging
            )

            PlatformSelectionView(
                iOSSelected: $iconViewModel.iOSSelected,
                macOSSelected: $iconViewModel.macOSSelected,
                watchOSSelected: $iconViewModel.watchOSSelected,
                androidSelected: $iconViewModel.androidSelected,
                webSelected: $iconViewModel.webSelected
            )

            GenerationControlsView(
                viewModel: iconViewModel
            )
        }
        .padding(30)
    }
}

struct HeaderView: View {
    var body: some View {
        Text("App Icon Generator")
            .font(.largeTitle)
            .fontWeight(.bold)
    }
}
