//
//  FormatType.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import Foundation

struct FormatSegment: Equatable, Identifiable {
    let id = UUID()
    let title: String
    let portion: Double   // 0.0 → 1.0

    func duration(from totalDuration: Int) -> Double {
        let totalSeconds = totalDuration * 60
        return Double(totalSeconds) * portion
    }

    func stringDuration(_ time: Int) -> String {
        let seconds = Int(duration(from: time))
        let minutes = seconds / 60
        let remainder = seconds % 60
        return remainder == 0
            ? "\(minutes)m"
            : "\(minutes)m \(remainder)s"
    }
}

enum FormatType: Equatable, Identifiable, CaseIterable {
    case harold
    case montage

    var id: String { title }

    var title: String {
        switch self {
        case .harold: return "Harold"
        case .montage: return "Montage"
        }
    }

    var segments: [FormatSegment] {
        switch self {
        case .harold:
            [
                FormatSegment(title: "Intro", portion: 0.08),
                FormatSegment(title: "Beat 1", portion: 0.24),
                FormatSegment(title: "Group Game 1", portion: 0.08),
                FormatSegment(title: "Beat 2", portion: 0.24),
                FormatSegment(title: "Group Game 2", portion: 0.08),
                FormatSegment(title: "Beat 3 / Wrap-Up", portion: 0.28)
            ]

        case .montage:
            [
                FormatSegment(title: "Opening", portion: 0.30),
                FormatSegment(title: "Heightening", portion: 0.40),
                FormatSegment(title: "Tag Run", portion: 0.20),
                FormatSegment(title: "Wrap-Up", portion: 0.10)
            ]
        }
    }

    var name: String {
        return switch self {
        case .harold:
            "Harold"
        case .montage:
            "Montage"
        }
    }

    var description: String {
        switch self {
        case .harold:
            return "A classic long-form structure with repeated beats and group games."
        case .montage:
            return "A flexible format featuring multiple independent scenes."
        }
    }
}
