//
//  SessionFeature.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
@MainActor
struct SessionFeature {
    @ObservableState
    struct State: Equatable {
        var title: String
        var format: FormatType
        var duration: Int

        // UI
        var currentSegmentIndex = 0
        var segmentElapsedTime = 0
        var elapsedTime = 0
        var remainingTime = 0.0
        var timerRunning = false
        var showPreshowCountdown = false
        var preshowCountdown = 5
        var showTimerUI = false
        var showConfetti = false
    }

    enum Action: Equatable {
        case togglePlayPause
        case tick
        case startPreshowCountdown(resume: Bool)
        case startSegmentTimer(resume: Bool)
        case pause
    }

    @Dependency(\.continuousClock)
    var clock

    let timerId = "timer"

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .togglePlayPause:
               if state.timerRunning {
                   state.showTimerUI = false

                   return .run { send in
                       await send(.pause)
                   }
               } else {
                   state.showTimerUI = true

                   if state.showPreshowCountdown {
                       return .send(.startPreshowCountdown(resume: true))
                   } else if state.remainingTime > 0 {
                       return .send(.startSegmentTimer(resume: true))
                   } else if state.currentSegmentIndex == 0 &&
                               state.elapsedTime == 0 &&
                               state.remainingTime == 0 {
                       return .send(.startPreshowCountdown(resume: false))
                   } else {
                       return .send(.startSegmentTimer(resume: true))
                   }
               }
            case .startPreshowCountdown(let resume):
                state.timerRunning = true

                if !resume {
                    state.preshowCountdown = 5
                }

                state.showPreshowCountdown = true

                return .run { @MainActor send in
                    for await _ in clock.timer(interval: .seconds(1)) {
                        send(.tick)
                    }
                }
                .cancellable(id: timerId, cancelInFlight: true)
            case .startSegmentTimer(let resume):
                guard state.currentSegmentIndex < state.format.segments.count else { return .none }

                state.timerRunning = true

                if !resume && state.remainingTime == 0 {
                    state.remainingTime = state.format.segments[state.currentSegmentIndex].duration(from: state.duration)
                    state.elapsedTime = 0
                }

                return .run { @MainActor send in
                    for await _ in clock.timer(interval: .seconds(1)) {
                        send(.tick)
                    }
                }
                .cancellable(id: timerId, cancelInFlight: true)
            case .pause:
                state.timerRunning = false
                return .cancel(id: timerId)
            case .tick:
                if state.showPreshowCountdown {
                    if state.preshowCountdown > 0 {
                        state.preshowCountdown -= 1
                        return .none
                    } else {
                        // end the countdown
                        withAnimation {
                            state.showPreshowCountdown = false
                        }

                        state.currentSegmentIndex = max(0, state.currentSegmentIndex)
                        state.elapsedTime = 0
                        state.remainingTime = state.format.segments[state.currentSegmentIndex].duration(from: state.duration)
                        return .send(.startSegmentTimer(resume: false))
                    }
                }

                // segment active
                if state.remainingTime > 0 {
                    state.remainingTime -= 1
                    state.segmentElapsedTime += 1
                    state.elapsedTime += 1
                    return .none
                }

                // segment finished
                state.timerRunning = false
                state.currentSegmentIndex += 1
                state.segmentElapsedTime = 0 
                state.remainingTime = 0

                guard state.currentSegmentIndex < state.format.segments.count else {
                    state.showConfetti = true
                    return .cancel(id: timerId)
                }

                state.remainingTime = state.format.segments[state.currentSegmentIndex].duration(from: state.duration)

                return .send(.startSegmentTimer(resume: false))
            }
        }
    }
}

extension SessionFeature.State {
    var totalDurationText: String {
        "\(duration) min"
    }

    var segmentBreakdownText: String {
        format.segments
            .map { segment in
                let seconds = Int(segment.duration(from: duration))
                let minutes = seconds / 60
                let remainder = seconds % 60
                return "\(segment.title): \(minutes)m \(remainder)s"
            }
            .joined(separator: " • ")
    }
}
