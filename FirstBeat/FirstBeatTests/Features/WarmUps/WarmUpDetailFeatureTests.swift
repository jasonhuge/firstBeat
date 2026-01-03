//
//  WarmUpDetailFeatureTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 12/19/25.
//

import Foundation
import Testing
import ComposableArchitecture
@testable import FirstBeat

@MainActor
struct WarmUpDetailFeatureTests {

    @Test func initialState() {
        let warmUp = WarmUp(
            id: UUID(),
            name: "Test Warm-up",
            category: .physical,
            description: "Test description",
            howToPlay: "Test instructions",
            variations: ["Variation 1"],
            tips: ["Tip 1"]
        )

        let state = WarmUpDetailFeature.State(warmUp: warmUp)

        #expect(state.warmUp.name == "Test Warm-up")
        #expect(state.warmUp.category == .physical)
        #expect(state.isCompleted == false)
    }

    @Test func toggleCompletedMarksAsCompleted() async {
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
            initialState: WarmUpDetailFeature.State(warmUp: warmUp)
        ) {
            WarmUpDetailFeature()
        }

        await store.send(.toggleCompleted) {
            $0.isCompleted = true
        }
    }

    @Test func toggleCompletedUnmarksAsCompleted() async {
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
            initialState: WarmUpDetailFeature.State(
                warmUp: warmUp,
                isCompleted: true
            )
        ) {
            WarmUpDetailFeature()
        }

        await store.send(.toggleCompleted) {
            $0.isCompleted = false
        }
    }
}
