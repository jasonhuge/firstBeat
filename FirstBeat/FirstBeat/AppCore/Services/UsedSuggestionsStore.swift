//
//  UsedSuggestionsStore.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/11/26.
//

import Foundation
import SwiftData
import Dependencies

// MARK: - Live Store (SwiftData with ModelActor)

@ModelActor
actor UsedSuggestionsStore {
    private static let aiCategoryId = "ai"

    // MARK: - Random Suggestions

    func markUsed(suggestion: String, categoryId: String) {
        let used = UsedSuggestion(suggestion: suggestion, categoryId: categoryId)
        modelContext.insert(used)
        try? modelContext.save()
    }

    func getUsed(categoryId: String) -> Set<String> {
        let predicate = #Predicate<UsedSuggestion> { $0.categoryId == categoryId }
        let descriptor = FetchDescriptor(predicate: predicate)

        do {
            let results = try modelContext.fetch(descriptor)
            return Set(results.map { $0.suggestion })
        } catch {
            return []
        }
    }

    func shouldReset(categoryId: String, totalCount: Int) -> Bool {
        let used = getUsed(categoryId: categoryId)
        return used.count >= totalCount
    }

    func reset(categoryId: String) {
        let predicate = #Predicate<UsedSuggestion> { $0.categoryId == categoryId }
        let descriptor = FetchDescriptor(predicate: predicate)

        do {
            let results = try modelContext.fetch(descriptor)
            for item in results {
                modelContext.delete(item)
            }
            try modelContext.save()
        } catch {
            // Silently fail
        }
    }

    // MARK: - AI Suggestions

    func markAIUsed(suggestion: String) {
        markUsed(suggestion: suggestion, categoryId: Self.aiCategoryId)
    }

    func getAIUsed() -> Set<String> {
        getUsed(categoryId: Self.aiCategoryId)
    }

    func resetAI() {
        reset(categoryId: Self.aiCategoryId)
    }
}

// MARK: - DependencyKey

extension UsedSuggestionsStore: DependencyKey {
    private static let liveModelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: UsedSuggestion.self)
        } catch {
            fatalError("Failed to create UsedSuggestion model container: \(error.localizedDescription)")
        }
    }()

    private static let testModelContainer: ModelContainer = {
        do {
            return try ModelContainer(
                for: UsedSuggestion.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            fatalError("Failed to create test UsedSuggestion model container: \(error.localizedDescription)")
        }
    }()

    static var liveValue: UsedSuggestionsStore {
        UsedSuggestionsStore(modelContainer: liveModelContainer)
    }

    static var testValue: UsedSuggestionsStore {
        UsedSuggestionsStore(modelContainer: testModelContainer)
    }

    static var previewValue: UsedSuggestionsStore {
        UsedSuggestionsStore(modelContainer: testModelContainer)
    }
}

// MARK: - DependencyValues

extension DependencyValues {
    var usedSuggestionsStore: UsedSuggestionsStore {
        get { self[UsedSuggestionsStore.self] }
        set { self[UsedSuggestionsStore.self] = newValue }
    }
}
