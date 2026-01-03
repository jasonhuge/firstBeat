//
//  HomeFeatureTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 12/19/25.
//

import Testing
import ComposableArchitecture
@testable import FirstBeat

@MainActor
struct HomeFeatureTests {

    @Test func initialStateReturnsAllCards() {
        let state = HomeFeature.State()

        #expect(state.cards.count == 2)
        #expect(state.cards == HomeCard.allCases)
    }

    @Test func homeCardComputedProperties() {
        let warmUpsCard = HomeCard.warmUps
        #expect(warmUpsCard.title == "Warm-ups")
        #expect(warmUpsCard.description == "Browse and explore improv exercises to energize your group")
        #expect(warmUpsCard.icon == "figure.walk")

        let practiceCard = HomeCard.practice
        #expect(practiceCard.title == "Practice")
        #expect(practiceCard.description == "Start a guided improv practice session")
        #expect(practiceCard.icon == "theatermasks")
    }

    @Test func cardSelectedWarmUpsSendsDelegateAction() async {
        let store = TestStore(
            initialState: HomeFeature.State()
        ) {
            HomeFeature()
        }

        await store.send(.cardSelected(.warmUps))
        await store.receive(.delegate(.navigateToWarmUps))
    }

    @Test func cardSelectedPracticeSendsDelegateAction() async {
        let store = TestStore(
            initialState: HomeFeature.State()
        ) {
            HomeFeature()
        }

        await store.send(.cardSelected(.practice))
        await store.receive(.delegate(.navigateToPractice))
    }
}
