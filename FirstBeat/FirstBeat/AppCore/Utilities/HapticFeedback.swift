//
//  HapticFeedback.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/3/26.
//

import UIKit

/// Provides non-blocking haptic feedback by dispatching to a background queue
enum HapticFeedback {

    /// Provides a light impact haptic feedback without blocking the main thread
    static func light() {
        DispatchQueue.global(qos: .userInitiated).async {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }

    /// Provides a medium impact haptic feedback without blocking the main thread
    static func medium() {
        DispatchQueue.global(qos: .userInitiated).async {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }

    /// Provides a heavy impact haptic feedback without blocking the main thread
    static func heavy() {
        DispatchQueue.global(qos: .userInitiated).async {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }

    /// Provides a selection changed haptic feedback without blocking the main thread
    static func selection() {
        DispatchQueue.global(qos: .userInitiated).async {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }

    /// Provides a success notification haptic feedback without blocking the main thread
    static func success() {
        DispatchQueue.global(qos: .userInitiated).async {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    /// Provides an error notification haptic feedback without blocking the main thread
    static func error() {
        DispatchQueue.global(qos: .userInitiated).async {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }

    /// Provides a warning notification haptic feedback without blocking the main thread
    static func warning() {
        DispatchQueue.global(qos: .userInitiated).async {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
}
