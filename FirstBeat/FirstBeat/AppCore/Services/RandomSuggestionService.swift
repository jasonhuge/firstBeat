//
//  RandomSuggestionService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/11/26.
//

import Foundation
import Dependencies

struct RandomSuggestionService {
    var fetchCategories: () async -> [SuggestionCategory]
    var getRandomSuggestions: (SuggestionCategory, Int, Set<String>) -> [String]  // category, count, exclusions
}

extension RandomSuggestionService: DependencyKey {
    static var liveValue: RandomSuggestionService {
        Self {
            let response = await RemoteConfigService.load(SuggestionsRequest())
            return response?.categories ?? []
        } getRandomSuggestions: { category, count, exclusions in
            let available = category.suggestions.filter { !exclusions.contains($0) }
            guard !available.isEmpty else { return [] }

            let shuffled = available.shuffled()
            return Array(shuffled.prefix(min(count, shuffled.count)))
        }
    }

    static var testValue: RandomSuggestionService {
        Self {
            SuggestionCategory.mockCategories
        } getRandomSuggestions: { category, count, _ in
            Array(category.suggestions.prefix(count))
        }
    }

    static var previewValue: RandomSuggestionService {
        Self {
            SuggestionCategory.mockCategories
        } getRandomSuggestions: { category, count, _ in
            Array(category.suggestions.shuffled().prefix(count))
        }
    }
}

extension DependencyValues {
    var randomSuggestionService: RandomSuggestionService {
        get { self[RandomSuggestionService.self] }
        set { self[RandomSuggestionService.self] = newValue }
    }
}
