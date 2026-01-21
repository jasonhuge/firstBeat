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
        case .warmUps: return L10n.Home.warmUpsTitle
        case .practice: return L10n.Home.practiceTitle
        }
    }

    var description: String {
        switch self {
        case .warmUps: return L10n.Home.warmUpsDescription
        case .practice: return L10n.Home.practiceDescription
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
