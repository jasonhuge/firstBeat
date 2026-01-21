//
//  RandomSuggestionService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/11/26.
//

import Foundation
import Dependencies

struct RandomSuggestionService {
    var fetchCategories: () async throws -> [SuggestionCategory]
    var getRandomSuggestions: (SuggestionCategory, Int, Set<String>) -> [String]  // category, count, exclusions
}

extension RandomSuggestionService: DependencyKey {
    static var liveValue: RandomSuggestionService {
        Self {
            async let dataTask = RemoteConfigService.load(SuggestionsDataRequest())
            async let translationsTask = RemoteConfigService.load(SuggestionsTranslationRequest())

            let (dataResponse, translations) = try await (dataTask, translationsTask)

            return dataResponse.categories.compactMap { categoryData in
                guard let translation = translations[categoryData.id] else { return nil }
                return SuggestionCategory.merge(data: categoryData, translation: translation)
            }
        } getRandomSuggestions: { category, count, exclusions in
            let available = category.suggestions.filter { !exclusions.contains($0) }
            guard !available.isEmpty else { return [] }

            let shuffled = available.shuffled()
            return Array(shuffled.prefix(min(count, shuffled.count)))
        }
    }
}

#if DEBUG
extension RandomSuggestionService {
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
#endif

extension DependencyValues {
    var randomSuggestionService: RandomSuggestionService {
        get { self[RandomSuggestionService.self] }
        set { self[RandomSuggestionService.self] = newValue }
    }
}
