//
//  FormatType.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import Foundation

struct FormatSegment: Identifiable, Codable {
    let id: UUID
    let title: String
    let portion: Double   // 0.0 → 1.0

    init(title: String, portion: Double) {
        self.id = UUID()
        self.title = title
        self.portion = portion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.portion = try container.decode(Double.self, forKey: .portion)
    }

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

    nonisolated static func == (lhs: FormatSegment, rhs: FormatSegment) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.portion == rhs.portion
    }
}

extension FormatSegment: Equatable {}

struct FormatType: Identifiable, Codable {
    let id: String
    let title: String
    let name: String
    let description: String
    let segments: [FormatSegment]
    let requiredOpeningId: String?
    let preferredOpeningId: String?
    let allowedOpeningIds: [String]?

    nonisolated static func == (lhs: FormatType, rhs: FormatType) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.segments == rhs.segments &&
        lhs.requiredOpeningId == rhs.requiredOpeningId &&
        lhs.preferredOpeningId == rhs.preferredOpeningId &&
        lhs.allowedOpeningIds == rhs.allowedOpeningIds
    }
}

extension FormatType: Equatable {}

#if DEBUG
extension FormatType {
    static var mock: Self {
        Self(
            id: "harold",
            title: "Harold",
            name: "Harold",
            description: "A classic long-form structure with repeated beats and group games.",
            segments: [
                FormatSegment(title: "Intro", portion: 0.08),
                FormatSegment(title: "Beat 1", portion: 0.24),
                FormatSegment(title: "Group Game 1", portion: 0.08),
                FormatSegment(title: "Beat 2", portion: 0.24),
                FormatSegment(title: "Group Game 2", portion: 0.08),
                FormatSegment(title: "Beat 3 / Wrap-Up", portion: 0.28)
            ],
            requiredOpeningId: nil,
            preferredOpeningId: "invocation",
            allowedOpeningIds: ["invocation", "organic_opening", "living_room"]
        )
    }
}

#endif
