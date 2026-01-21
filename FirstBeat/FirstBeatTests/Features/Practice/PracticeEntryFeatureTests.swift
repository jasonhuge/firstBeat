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

        #expect(state.options.isEmpty)
        #expect(state.isAIAvailable == false)
        #expect(state.isCheckingAvailability == true)
    }

    @Test func onAppearChecksAIAvailability() async {
        let store = TestStore(
            initialState: PracticeEntryFeature.State()
        ) {
            PracticeEntryFeature()
        } withDependencies: {
            $0.aiAvailabilityService.isAppleIntelligenceAvailable = { true }
        }

        await store.send(.onAppear)

        await store.receive(.availabilityChecked(true)) {
            $0.isAIAvailable = true
            $0.isCheckingAvailability = false
            $0.options = PracticeEntryFeature.buildOptions(isAIAvailable: true)
        }
    }

    @Test func hasCorrectOptionsWhenAIAvailable() async {
        let store = TestStore(
            initialState: PracticeEntryFeature.State()
        ) {
            PracticeEntryFeature()
        } withDependencies: {
            $0.aiAvailabilityService.isAppleIntelligenceAvailable = { true }
        }

        await store.send(.onAppear)
        await store.receive(.availabilityChecked(true)) {
            $0.isAIAvailable = true
            $0.isCheckingAvailability = false
            $0.options = PracticeEntryFeature.buildOptions(isAIAvailable: true)
        }

        // When AI is available, we should have 4 options
        #expect(store.state.options.count == 4)
        #expect(store.state.options[0].id == "getAISuggestion")
        #expect(store.state.options[0].title == L10n.PracticeEntry.aiSuggestionTitle)
        #expect(store.state.options[1].id == "getRandomSuggestion")
        #expect(store.state.options[2].id == "startPractice")
        #expect(store.state.options[3].id == "quickTimer")
    }

    @Test func hasCorrectOptionsWhenAINotAvailable() async {
        let store = TestStore(
            initialState: PracticeEntryFeature.State()
        ) {
            PracticeEntryFeature()
        } withDependencies: {
            $0.aiAvailabilityService.isAppleIntelligenceAvailable = { false }
        }

        await store.send(.onAppear)
        await store.receive(.availabilityChecked(false)) {
            $0.isAIAvailable = false
            $0.isCheckingAvailability = false
            $0.options = PracticeEntryFeature.buildOptions(isAIAvailable: false)
        }

        // When AI is not available, we should have 3 options (no AI suggestion)
        #expect(store.state.options.count == 3)
        #expect(store.state.options[0].id == "getRandomSuggestion")
        #expect(store.state.options[1].id == "startPractice")
        #expect(store.state.options[2].id == "quickTimer")
    }

    @Test func getAISuggestionOptionSendsDelegate() async {
        var initialState = PracticeEntryFeature.State()
        initialState.isCheckingAvailability = false
        initialState.isAIAvailable = true
        initialState.options = PracticeEntryFeature.buildOptions(isAIAvailable: true)

        let store = TestStore(initialState: initialState) {
            PracticeEntryFeature()
        }

        await store.send(.optionSelected(id: "getAISuggestion"))
        await store.receive(.delegate(.getAISuggestion))
    }

    @Test func getRandomSuggestionOptionSendsDelegate() async {
        var initialState = PracticeEntryFeature.State()
        initialState.isCheckingAvailability = false
        initialState.options = PracticeEntryFeature.buildOptions(isAIAvailable: false)

        let store = TestStore(initialState: initialState) {
            PracticeEntryFeature()
        }

        await store.send(.optionSelected(id: "getRandomSuggestion"))
        await store.receive(.delegate(.getRandomSuggestion))
    }

    @Test func startPracticeOptionSendsDelegate() async {
        var initialState = PracticeEntryFeature.State()
        initialState.isCheckingAvailability = false
        initialState.options = PracticeEntryFeature.buildOptions(isAIAvailable: false)

        let store = TestStore(initialState: initialState) {
            PracticeEntryFeature()
        }

        await store.send(.optionSelected(id: "startPractice"))
        await store.receive(.delegate(.startPractice))
    }

    @Test func quickTimerOptionSendsDelegate() async {
        var initialState = PracticeEntryFeature.State()
        initialState.isCheckingAvailability = false
        initialState.options = PracticeEntryFeature.buildOptions(isAIAvailable: false)

        let store = TestStore(initialState: initialState) {
            PracticeEntryFeature()
        }

        await store.send(.optionSelected(id: "quickTimer"))
        await store.receive(.delegate(.quickTimer))
    }

    @Test func onAppearDoesNothingIfAlreadyChecked() async {
        var initialState = PracticeEntryFeature.State()
        initialState.isCheckingAvailability = false
        initialState.options = PracticeEntryFeature.buildOptions(isAIAvailable: false)

        let store = TestStore(initialState: initialState) {
            PracticeEntryFeature()
        }

        // Should not trigger any effects since already checked
        await store.send(.onAppear)
    }
}
