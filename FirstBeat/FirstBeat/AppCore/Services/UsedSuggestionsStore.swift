//
//  UsedSuggestionsStore.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/11/26.
//

import Foundation
import SwiftData

actor UsedSuggestionsStore {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    private static let aiCategoryId = "ai"

    init() {
        do {
            let schema = Schema([UsedSuggestion.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            self.modelContainer = try ModelContainer(for: schema, configurations: config)
            self.modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to create UsedSuggestionsStore: \(error)")
        }
    }

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
