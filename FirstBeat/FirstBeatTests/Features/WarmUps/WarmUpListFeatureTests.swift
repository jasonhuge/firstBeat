//
//  WarmUpListFeatureTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 12/19/25.
//

import Foundation
import Testing
import ComposableArchitecture
@testable import FirstBeat

@MainActor
struct WarmUpListFeatureTests {

    @Test func initialState() {
        let state = WarmUpListFeature.State()

        #expect(state.warmUps.isEmpty)
        #expect(state.selectedCategory == nil)
        #expect(state.favoriteWarmUpNames.isEmpty)
        #expect(state.filteredWarmUps.isEmpty)
        #expect(state.favorites.isEmpty)
    }

    @Test func onAppearLoadsWarmUps() async {
        let mockWarmUps = [
            WarmUp(
                id: UUID(),
                name: "Test Warm-up",
                category: .physical,
                description: "Test description",
                howToPlay: "Test instructions",
                variations: [],
                tips: []
            )
        ]

        let store = TestStore(
            initialState: WarmUpListFeature.State()
        ) {
            WarmUpListFeature()
        } withDependencies: {
            $0.warmUpService.fetchWarmUps = { mockWarmUps }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }
        await store.receive(.warmUpsLoaded(mockWarmUps)) {
            $0.warmUps = mockWarmUps
            $0.isLoading = false
        }
        await store.receive(.favoritesLoaded([])) {
            $0.favoriteWarmUpNames = []
        }
    }

    @Test func categorySelectedFiltersWarmUps() async {
        let physicalWarmUp = WarmUp(
            id: UUID(),
            name: "Physical Warm-up",
            category: .physical,
            description: "Test",
            howToPlay: "Test",
            variations: [],
            tips: []
        )

        let vocalWarmUp = WarmUp(
            id: UUID(),
            name: "Vocal Warm-up",
            category: .vocal,
            description: "Test",
            howToPlay: "Test",
            variations: [],
            tips: []
        )

        let store = TestStore(
            initialState: WarmUpListFeature.State(
                warmUps: [physicalWarmUp, vocalWarmUp]
            )
        ) {
            WarmUpListFeature()
        }

        await store.send(.categorySelected(.physical)) {
            $0.selectedCategory = .physical
        }

        #expect(store.state.filteredWarmUps.count == 1)
        #expect(store.state.filteredWarmUps.first?.category == .physical)
    }

    @Test func categorySelectedToNilShowsAllWarmUps() async {
        let physicalWarmUp = WarmUp(
            id: UUID(),
            name: "Physical Warm-up",
            category: .physical,
            description: "Test",
            howToPlay: "Test",
            variations: [],
            tips: []
        )

        let vocalWarmUp = WarmUp(
            id: UUID(),
            name: "Vocal Warm-up",
            category: .vocal,
            description: "Test",
            howToPlay: "Test",
            variations: [],
            tips: []
        )

        let store = TestStore(
            initialState: WarmUpListFeature.State(
                warmUps: [physicalWarmUp, vocalWarmUp],
                selectedCategory: .physical
            )
        ) {
            WarmUpListFeature()
        }

        await store.send(.categorySelected(nil)) {
            $0.selectedCategory = nil
        }

        #expect(store.state.filteredWarmUps.count == 2)
    }

    @Test func warmUpSelected() async {
        let warmUp = WarmUp(
            id: UUID(),
            name: "Test Warm-up",
            category: .physical,
            description: "Test",
            howToPlay: "Test",
            variations: [],
            tips: []
        )

        let store = TestStore(
            initialState: WarmUpListFeature.State()
        ) {
            WarmUpListFeature()
        }

        await store.send(.warmUpSelected(warmUp))
    }

    @Test func toggleFavoriteTogglesFavoriteStatus() async {
        let warmUpName = "Zip Zap Zop"

        let store = TestStore(
            initialState: WarmUpListFeature.State()
        ) {
            WarmUpListFeature()
        }

        // Mark as favorite
        await store.send(.toggleFavorite(warmUpName)) {
            $0.favoriteWarmUpNames.insert(warmUpName)
        }

        #expect(store.state.favoriteWarmUpNames.contains(warmUpName))

        // Unmark as favorite
        await store.send(.toggleFavorite(warmUpName)) {
            $0.favoriteWarmUpNames.remove(warmUpName)
        }

        #expect(!store.state.favoriteWarmUpNames.contains(warmUpName))
    }
}
