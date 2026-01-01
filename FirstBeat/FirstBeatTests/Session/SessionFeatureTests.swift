//
//  SessionFeatureTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 12/19/25.
//

import Testing
import ComposableArchitecture
@testable import FirstBeat

@MainActor
struct SessionFeatureTests {

    @Test func initialState() {
        let state = SessionFeature.State(
            title: "Test",
            format: .harold,
            duration: 25
        )

        #expect(state.title == "Test")
        #expect(state.format == .harold)
        #expect(state.duration == 25)
        #expect(state.currentSegmentIndex == 0)
        #expect(state.timerRunning == false)
        #expect(state.showPreshowCountdown == false)
    }

    @Test func togglePlayPauseStartsTimer() async {
        let clock = TestClock()

        let store = TestStore(
            initialState: SessionFeature.State(
                title: "Test",
                format: .harold,
                duration: 25
            )
        ) {
            SessionFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.togglePlayPause) {
            $0.showTimerUI = true
        }

        await store.receive(.startPreshowCountdown(resume: false)) {
            $0.timerRunning = true
            $0.showPreshowCountdown = true
            $0.preshowCountdown = 5
        }
    }

    @Test func togglePlayPausePausesRunningTimer() async {
        let clock = TestClock()

        let store = TestStore(
            initialState: SessionFeature.State(
                title: "Test",
                format: .harold,
                duration: 25,
                timerRunning: true,
                showTimerUI: true
            )
        ) {
            SessionFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.togglePlayPause) {
            $0.showTimerUI = false
        }

        await store.receive(.pause) {
            $0.timerRunning = false
        }
    }

    @Test func preshowCountdownTicksDown() async {
        let clock = TestClock()

        let store = TestStore(
            initialState: SessionFeature.State(
                title: "Test",
                format: .harold,
                duration: 25,
                timerRunning: true,
                showPreshowCountdown: true,
                preshowCountdown: 3
            )
        ) {
            SessionFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.tick) {
            $0.preshowCountdown = 2
        }

        await store.send(.tick) {
            $0.preshowCountdown = 1
        }

        await store.send(.tick) {
            $0.preshowCountdown = 0
        }
    }

    @Test func preshowCountdownTransitionsToSegmentTimer() async {
        let clock = TestClock()

        let store = TestStore(
            initialState: SessionFeature.State(
                title: "Test",
                format: .harold,
                duration: 25,
                timerRunning: true,
                showPreshowCountdown: true,
                preshowCountdown: 0
            )
        ) {
            SessionFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.tick) {
            $0.showPreshowCountdown = false
            $0.currentSegmentIndex = 0
            $0.elapsedTime = 0
            $0.remainingTime = FormatType.harold.segments[0].duration(from: 25)
        }

        await store.receive(.startSegmentTimer(resume: false)) {
            $0.timerRunning = true
        }
    }

    @Test func segmentTimerTicksDown() async {
        let store = TestStore(
            initialState: SessionFeature.State(
                title: "Test",
                format: .harold,
                duration: 25,
                timerRunning: true,
                remainingTime: 10
            )
        ) {
            SessionFeature()
        }

        await store.send(.tick) {
            $0.remainingTime = 9
            $0.segmentElapsedTime = 1
            $0.elapsedTime = 1
        }
    }

    @Test func segmentCompletionAdvancesToNextSegment() async {
        let clock = TestClock()

        let store = TestStore(
            initialState: SessionFeature.State(
                title: "Test",
                format: .harold,
                duration: 25,
                currentSegmentIndex: 0,
                timerRunning: true,
                remainingTime: 0
            )
        ) {
            SessionFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.tick) {
            $0.timerRunning = false
            $0.currentSegmentIndex = 1
            $0.segmentElapsedTime = 0
            $0.remainingTime = FormatType.harold.segments[1].duration(from: 25)
        }

        await store.receive(.startSegmentTimer(resume: false)) {
            $0.timerRunning = true
        }
    }

    @Test func finalSegmentCompletionShowsConfetti() async {
        let lastSegmentIndex = FormatType.harold.segments.count - 1

        let store = TestStore(
            initialState: SessionFeature.State(
                title: "Test",
                format: .harold,
                duration: 25,
                currentSegmentIndex: lastSegmentIndex,
                timerRunning: true,
                remainingTime: 0
            )
        ) {
            SessionFeature()
        }

        await store.send(.tick) {
            $0.timerRunning = false
            $0.currentSegmentIndex = lastSegmentIndex + 1
            $0.segmentElapsedTime = 0
            $0.showConfetti = true
        }
    }

    @Test func totalDurationText() {
        let state = SessionFeature.State(
            title: "Test",
            format: .harold,
            duration: 30
        )

        #expect(state.totalDurationText == "30 min")
    }
}
