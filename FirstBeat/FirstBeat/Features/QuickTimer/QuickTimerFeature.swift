//
//  QuickTimerFeature.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/11/26.
//

import ComposableArchitecture

@Reducer
struct QuickTimerFeature {
    @ObservableState
    struct State: Equatable {
        var duration: Int = 20
    }

    enum Action: Equatable {
        case durationChanged(Int)
        case startTapped

        case delegate(Delegate)

        enum Delegate: Equatable {
            case start(duration: Int)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .durationChanged(let duration):
                state.duration = duration
                return .none

            case .startTapped:
                return .send(.delegate(.start(duration: state.duration)))

            case .delegate:
                return .none
            }
        }
    }
}
