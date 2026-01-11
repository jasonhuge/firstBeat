//
//  SuggestionCategory.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/11/26.
//

import Foundation

struct SuggestionCategory: Equatable, Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let suggestions: [String]
}

struct SuggestionsResponse: Codable {
    let categories: [SuggestionCategory]
}

#if DEBUG
extension SuggestionCategory {
    static var mock: Self {
        Self(
            id: "locations",
            name: "Locations",
            icon: "mappin.and.ellipse",
            suggestions: ["Dentist's Office", "Space Station", "Submarine"]
        )
    }

    static var mockCategories: [SuggestionCategory] {
        [
            Self(id: "locations", name: "Locations", icon: "mappin.and.ellipse", suggestions: ["Dentist's Office", "Space Station"]),
            Self(id: "occupations", name: "Occupations", icon: "briefcase", suggestions: ["Astronaut", "Magician"]),
            Self(id: "relationships", name: "Relationships", icon: "person.2", suggestions: ["Siblings", "Rivals"])
        ]
    }
}
#endif
