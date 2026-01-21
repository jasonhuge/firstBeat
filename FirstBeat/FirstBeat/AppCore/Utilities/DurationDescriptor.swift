//
//  DurationDescriptor.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/12/26.
//

import Foundation

extension Int {
    /// Returns a descriptive string for the duration in minutes
    var durationDescriptor: String {
        switch self {
        case 5...15:
            return L10n.Duration.shortSet
        case 20...35:
            return L10n.Duration.mediumSet
        default:
            return L10n.Duration.longSet
        }
    }
}
