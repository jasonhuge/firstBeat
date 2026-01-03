//
//  WarmUp.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/1/26.
//

import Foundation

struct WarmUp: Equatable, Identifiable, Codable {
    let id: UUID
    let name: String
    let category: WarmUpCategory
    let description: String
    let howToPlay: String
    let variations: [String]
    let tips: [String]

    init(
        id: UUID = UUID(),
        name: String,
        category: WarmUpCategory,
        description: String,
        howToPlay: String,
        variations: [String] = [],
        tips: [String] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.howToPlay = howToPlay
        self.variations = variations
        self.tips = tips
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Generate new UUID on decode
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.category = try container.decode(WarmUpCategory.self, forKey: .category)
        self.description = try container.decode(String.self, forKey: .description)
        self.howToPlay = try container.decode(String.self, forKey: .howToPlay)
        self.variations = try container.decodeIfPresent([String].self, forKey: .variations) ?? []
        self.tips = try container.decodeIfPresent([String].self, forKey: .tips) ?? []
    }
}

enum WarmUpCategory: String, CaseIterable, Identifiable, Codable {
    case physical = "Physical"
    case vocal = "Vocal"
    case mental = "Mental"
    case group = "Group"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .physical:
            return "figure.walk"
        case .vocal:
            return "waveform"
        case .mental:
            return "brain.head.profile"
        case .group:
            return "person.3.fill"
        }
    }
}
