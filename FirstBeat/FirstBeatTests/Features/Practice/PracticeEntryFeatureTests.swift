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

    @Test func getAISuggestionOptionSendsDelegate() async {
        let store = TestStore(
            initialState: PracticeEntryFeature.State()
        ) {
            PracticeEntryFeature()
        }

        await store.send(.optionSelected(id: "getAISuggestion"))
        await store.receive(.delegate(.getAISuggestion))
    }

    @Test func startPracticeOptionSendsDelegate() async {
        let store = TestStore(
            initialState: PracticeEntryFeature.State()
        ) {
            PracticeEntryFeature()
        }

        await store.send(.optionSelected(id: "startPractice"))
        await store.receive(.delegate(.startPractice))
    }

    @Test func hasCorrectOptions() {
        let state = PracticeEntryFeature.State()

        #expect(state.options.count == 2)
        #expect(state.options[0].id == "getAISuggestion")
        #expect(state.options[0].title == "Get AI Suggestion")
        #expect(state.options[1].id == "startPractice")
        #expect(state.options[1].title == "Start Practice")
    }
}
