//
//  HapticFeedBackGenerator.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/15.
//
import UIKit
import CoreHaptics

class HapticFeedbackGenerator {
    static let shared = HapticFeedbackGenerator()
    private init() {}

    func simpleHapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
