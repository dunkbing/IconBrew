//
//  DebouncedSliderControl.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import SwiftUI

struct DebouncedSliderControl: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var label: String
    var onValueChanged: () -> Void

    @State private var isDragging = false
    @State private var localValue: Double
    private let debouncer = Debouncer(delay: 0.3)  // 300ms delay

    init(
        value: Binding<Double>, range: ClosedRange<Double>, label: String,
        onValueChanged: @escaping () -> Void
    ) {
        self._value = value
        self.range = range
        self.label = label
        self.onValueChanged = onValueChanged
        self._localValue = State(initialValue: value.wrappedValue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                Spacer()
                Text(String(format: "%.2f", localValue))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            HStack {
                Slider(
                    value: $localValue,
                    in: range,
                    onEditingChanged: { editing in
                        isDragging = editing

                        if !editing {
                            value = localValue
                            onValueChanged()
                        } else {
                            debouncer.debounce {
                                value = localValue
                                onValueChanged()
                            }
                        }
                    }
                )

                Button(action: {
                    localValue = 0
                    value = 0
                    onValueChanged()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
            }
        }
        .onChange(of: value) { newValue in
            if !isDragging {
                localValue = newValue
            }
        }
    }
}
