//
//  SessionSetupFeatureTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 12/19/25.
//

import Testing
import ComposableArchitecture
@testable import FirstBeat

struct SessionSetupFeatureTests {

    @Test func initialStateWithSuggestion() {
        let state = SessionSetupFeature.State(suggestion: "Test suggestion")

        #expect(state.suggestion == "Test suggestion")
        #expect(state.selectedType == .harold)
        #expect(state.totalDuration == 25)
    }

    @Test func initialStateWithoutSuggestion() {
        let state = SessionSetupFeature.State(suggestion: nil)

        #expect(state.suggestion == nil)
        #expect(state.selectedType == .harold)
        #expect(state.totalDuration == 25)
    }

    @Test func typeSelected() async {
        let store = TestStore(
            initialState: SessionSetupFeature.State(suggestion: "Test")
        ) {
            SessionSetupFeature()
        }

        await store.send(.typeSelected(.montage)) {
            $0.selectedType = .montage
        }
    }

    @Test func durationChanged() async {
        let store = TestStore(
            initialState: SessionSetupFeature.State(suggestion: "Test")
        ) {
            SessionSetupFeature()
        }

        await store.send(.durationChanged(30)) {
            $0.totalDuration = 30
        }
    }

    @Test func startSelectedSendsNextActionWithSuggestion() async {
        let store = TestStore(
            initialState: SessionSetupFeature.State(
                suggestion: "Test",
                selectedType: .montage,
                totalDuration: 30
            )
        ) {
            SessionSetupFeature()
        }

        await store.send(.startSelected)
        await store.receive(.next("Test", .montage, 30))
    }

    @Test func startSelectedSendsNextActionWithoutSuggestion() async {
        let store = TestStore(
            initialState: SessionSetupFeature.State(
                suggestion: nil,
                selectedType: .harold,
                totalDuration: 25
            )
        ) {
            SessionSetupFeature()
        }

        await store.send(.startSelected)
        await store.receive(.next(nil, .harold, 25))
    }
}
