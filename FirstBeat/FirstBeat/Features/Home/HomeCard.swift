//
//  HomeCard.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/2/26.
//

import Foundation
import SwiftUI

enum HomeCard: String, CaseIterable, Equatable, Identifiable {
    case warmUps
    case practice

    var id: String { rawValue }

    var title: String {
        switch self {
        case .warmUps: return "Warm-ups"
        case .practice: return "Practice"
        }
    }

    var description: String {
        switch self {
        case .warmUps: return "Browse and explore improv exercises to energize your group"
        case .practice: return "Start a guided improv practice session"
        }
    }

    var icon: String {
        switch self {
        case .warmUps: return "figure.walk"
        case .practice: return "theatermasks"
        }
    }

    var color: Color {
        switch self {
        case .warmUps: return AppTheme.warmUpColor
        case .practice: return AppTheme.practiceColor
        }
    }
}
