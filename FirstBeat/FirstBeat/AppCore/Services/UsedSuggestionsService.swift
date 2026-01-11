//
//  UsedSuggestionsService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/11/26.
//

import Foundation
import Dependencies

struct UsedSuggestionsService {
    /// Mark a suggestion as used for a given category
    var markUsed: (String, String) async -> Void  // (suggestion, categoryId)

    /// Get all used suggestions for a category
    var getUsed: (String) async -> Set<String>  // categoryId -> suggestions

    /// Check if all suggestions in a category are used (for reset)
    var shouldReset: (String, Int) async -> Bool  // (categoryId, totalCount) -> should reset

    /// Reset used suggestions for a category
    var reset: (String) async -> Void  // categoryId

    /// Mark an AI suggestion as used (no category)
    var markAIUsed: (String) async -> Void

    /// Get all used AI suggestions
    var getAIUsed: () async -> Set<String>

    /// Reset AI suggestions
    var resetAI: () async -> Void
}

// MARK: - DependencyKey

extension UsedSuggestionsService: DependencyKey {
    static var liveValue: UsedSuggestionsService {
        let store = UsedSuggestionsStore()

        return Self(
            markUsed: { suggestion, categoryId in
                await store.markUsed(suggestion: suggestion, categoryId: categoryId)
            },
            getUsed: { categoryId in
                await store.getUsed(categoryId: categoryId)
            },
            shouldReset: { categoryId, totalCount in
                await store.shouldReset(categoryId: categoryId, totalCount: totalCount)
            },
            reset: { categoryId in
                await store.reset(categoryId: categoryId)
            },
            markAIUsed: { suggestion in
                await store.markAIUsed(suggestion: suggestion)
            },
            getAIUsed: {
                await store.getAIUsed()
            },
            resetAI: {
                await store.resetAI()
            }
        )
    }

    static var testValue: UsedSuggestionsService {
        Self(
            markUsed: { _, _ in },
            getUsed: { _ in [] },
            shouldReset: { _, _ in false },
            reset: { _ in },
            markAIUsed: { _ in },
            getAIUsed: { [] },
            resetAI: { }
        )
    }

    static var previewValue: UsedSuggestionsService {
        testValue
    }
}

// MARK: - DependencyValues

extension DependencyValues {
    var usedSuggestionsService: UsedSuggestionsService {
        get { self[UsedSuggestionsService.self] }
        set { self[UsedSuggestionsService.self] = newValue }
    }
}
