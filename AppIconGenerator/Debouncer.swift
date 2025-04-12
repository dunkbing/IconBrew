//
//  Debouncer.swift
//  AppIconGenerator
//
//  Created by Bùi Đặng Bình on 8/4/25.
//

import Foundation

class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func debounce(action: @escaping () -> Void) {
        // Cancel the previous work item if it hasn't executed yet
        workItem?.cancel()

        // Create a new work item
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem

        // Schedule the new work item after the delay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }

    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}
