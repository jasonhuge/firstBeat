//
//  FavoritesService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/4/26.
//

import Dependencies
import Foundation
import SwiftData

struct FavoritesService {
    var addFavorite: (String) async throws -> Void
    var removeFavorite: (String) async throws -> Void
    var isFavorite: (String) async -> Bool
    var fetchAllFavorites: () async -> Set<String>
}

// MARK: - DependencyKey

extension FavoritesService: DependencyKey {
    static var liveValue: FavoritesService {
        let store = LiveFavoritesStore.shared
        return Self(
            addFavorite: { name in try await store.addFavorite(name) },
            removeFavorite: { name in try await store.removeFavorite(name) },
            isFavorite: { name in await store.isFavorite(name) },
            fetchAllFavorites: { await store.fetchAllFavorites() }
        )
    }

    static var testValue: FavoritesService {
        let store = TestFavoritesStore()
        return Self(
            addFavorite: { name in await store.addFavorite(name) },
            removeFavorite: { name in await store.removeFavorite(name) },
            isFavorite: { name in await store.isFavorite(name) },
            fetchAllFavorites: { await store.fetchAllFavorites() }
        )
    }

    static var previewValue: FavoritesService {
        testValue
    }
}

// MARK: - DependencyValues

extension DependencyValues {
    var favoritesService: FavoritesService {
        get { self[FavoritesService.self] }
        set { self[FavoritesService.self] = newValue }
    }
}

// MARK: - Live Store (SwiftData)

@ModelActor
private actor LiveFavoritesStore {
    private static let modelContainer = try! ModelContainer(for: WarmUpFavorite.self)
    static let shared = LiveFavoritesStore(modelContainer: modelContainer)

    func addFavorite(_ name: String) throws {
        let favorite = WarmUpFavorite(name: name)
        modelContext.insert(favorite)
        try modelContext.save()
    }

    func removeFavorite(_ name: String) throws {
        let predicate = #Predicate<WarmUpFavorite> { $0.name == name }
        let descriptor = FetchDescriptor<WarmUpFavorite>(predicate: predicate)
        let favorites = try modelContext.fetch(descriptor)

        for favorite in favorites {
            modelContext.delete(favorite)
        }

        try modelContext.save()
    }

    func isFavorite(_ name: String) -> Bool {
        let predicate = #Predicate<WarmUpFavorite> { $0.name == name }
        let descriptor = FetchDescriptor<WarmUpFavorite>(predicate: predicate)
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        return count > 0
    }

    func fetchAllFavorites() -> Set<String> {
        let descriptor = FetchDescriptor<WarmUpFavorite>(
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )
        let favorites = (try? modelContext.fetch(descriptor)) ?? []
        return Set(favorites.map(\.name))
    }
}

// MARK: - Test Store (In-Memory)

private actor TestFavoritesStore {
    private var favorites: Set<String> = []

    func addFavorite(_ name: String) {
        favorites.insert(name)
    }

    func removeFavorite(_ name: String) {
        favorites.remove(name)
    }

    func isFavorite(_ name: String) -> Bool {
        favorites.contains(name)
    }

    func fetchAllFavorites() -> Set<String> {
        favorites
    }
}
