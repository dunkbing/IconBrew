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

    // Keeps track of whether the slider is currently being dragged
    @State private var isDragging = false

    // Local value that updates immediately for UI responsiveness
    @State private var localValue: Double

    // Debouncer for handling delayed updates
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
                            // When the user stops dragging, update the binding
                            // and trigger the callback
                            value = localValue
                            onValueChanged()
                        } else {
                            // While dragging, setup the debounced update
                            debouncer.debounce {
                                // This will run after the debounce period
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
            // Keep local value in sync with external changes
            if !isDragging {
                localValue = newValue
            }
        }
    }
}
