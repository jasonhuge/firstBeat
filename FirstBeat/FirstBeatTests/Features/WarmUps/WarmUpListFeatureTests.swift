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
        #expect(state.completedWarmUps.isEmpty)
        #expect(state.filteredWarmUps.isEmpty)
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

        await store.send(.onAppear)
        await store.receive(.warmUpsLoaded(mockWarmUps)) {
            $0.warmUps = mockWarmUps
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

    @Test func toggleCompletedTogglesCompletion() async {
        let warmUpId = UUID()

        let store = TestStore(
            initialState: WarmUpListFeature.State()
        ) {
            WarmUpListFeature()
        }

        // Mark as completed
        await store.send(.toggleCompleted(warmUpId)) {
            $0.completedWarmUps.insert(warmUpId)
        }

        #expect(store.state.completedWarmUps.contains(warmUpId))

        // Unmark as completed
        await store.send(.toggleCompleted(warmUpId)) {
            $0.completedWarmUps.remove(warmUpId)
        }

        #expect(!store.state.completedWarmUps.contains(warmUpId))
    }
}
