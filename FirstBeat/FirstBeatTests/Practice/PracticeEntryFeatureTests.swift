//
//  PracticeEntryFeatureTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 12/19/25.
//

import Testing
import ComposableArchitecture
@testable import FirstBeat

@MainActor
struct PracticeEntryFeatureTests {

    @Test func initialState() {
        let state = PracticeEntryFeature.State()

        // Practice entry feature has no state, just verifying it can be initialized
        #expect(state != nil)
    }

    @Test func getAISuggestion() async {
        let store = TestStore(
            initialState: PracticeEntryFeature.State()
        ) {
            PracticeEntryFeature()
        }

        await store.send(.getAISuggestion)
    }

    @Test func startPractice() async {
        let store = TestStore(
            initialState: PracticeEntryFeature.State()
        ) {
            PracticeEntryFeature()
        }

        await store.send(.startPractice)
    }
}
