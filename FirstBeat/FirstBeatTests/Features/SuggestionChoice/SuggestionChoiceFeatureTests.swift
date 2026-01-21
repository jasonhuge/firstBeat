//
//  SuggestionChoiceFeatureTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 1/20/26.
//

import Testing
import ComposableArchitecture
@testable import FirstBeat

@MainActor
struct SuggestionChoiceFeatureTests {

    @Test func initialState() {
        let suggestion = "A day at the beach"
        let state = SuggestionChoiceFeature.State(suggestion: suggestion)

        #expect(state.suggestion == suggestion)
        #expect(state.options.count == 2)
        #expect(state.options[0].id == "chooseFormat")
        #expect(state.options[1].id == "openPractice")
    }

    @Test func chooseFormatOptionSendsDelegate() async {
        let suggestion = "A day at the beach"
        let store = TestStore(
            initialState: SuggestionChoiceFeature.State(suggestion: suggestion)
        ) {
            SuggestionChoiceFeature()
        }

        await store.send(.optionSelected(id: "chooseFormat"))
        await store.receive(.delegate(.chooseFormat(suggestion)))
    }

    @Test func openPracticeOptionSendsDelegate() async {
        let suggestion = "A day at the beach"
        let store = TestStore(
            initialState: SuggestionChoiceFeature.State(suggestion: suggestion)
        ) {
            SuggestionChoiceFeature()
        }

        await store.send(.optionSelected(id: "openPractice"))
        await store.receive(.delegate(.openPractice(suggestion)))
    }

    @Test func unknownOptionDoesNothing() async {
        let store = TestStore(
            initialState: SuggestionChoiceFeature.State(suggestion: "Test")
        ) {
            SuggestionChoiceFeature()
        }

        await store.send(.optionSelected(id: "unknownId"))
        // No delegate action should be received
    }
}
