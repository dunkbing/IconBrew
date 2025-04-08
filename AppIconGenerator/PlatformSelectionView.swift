//
//  PlatformSelectionView.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import SwiftUI

struct PlatformSelectionView: View {
    @Binding var iOSSelected: Bool
    @Binding var macOSSelected: Bool
    @Binding var watchOSSelected: Bool
    @Binding var androidSelected: Bool
    @Binding var webSelected: Bool
    @Binding var unifiedAppleIconsSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Select Target Platforms:")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                Text("Apple Platforms")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 20) {
                    Toggle("iOS", isOn: $iOSSelected)
                    Toggle("macOS", isOn: $macOSSelected)
                    Toggle("watchOS", isOn: $watchOSSelected)
                }
                .padding(.horizontal)

                Toggle(
                    "Generate unified Apple icons (single Contents.json)",
                    isOn: $unifiedAppleIconsSelected
                )
                .padding(.horizontal)
                .disabled(!iOSSelected && !macOSSelected && !watchOSSelected)
            }
            .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: 12) {
                Text("Other Platforms")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 20) {
                    Toggle("Android", isOn: $androidSelected)
                    Toggle("Web", isOn: $webSelected)
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}
