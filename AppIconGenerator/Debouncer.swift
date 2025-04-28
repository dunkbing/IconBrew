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
        workItem?.cancel()

        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem

        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }

    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}
