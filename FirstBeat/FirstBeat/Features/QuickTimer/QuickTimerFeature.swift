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
        var suggestion: String?
        var duration: Int = 20

        init(suggestion: String? = nil, duration: Int = 20) {
            self.suggestion = suggestion
            self.duration = duration
        }
    }

    enum Action: Equatable {
        case durationChanged(Int)
        case startTapped

        case delegate(Delegate)

        enum Delegate: Equatable {
            case start(suggestion: String?, duration: Int)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .durationChanged(let duration):
                state.duration = duration
                return .none

            case .startTapped:
                return .send(.delegate(.start(suggestion: state.suggestion, duration: state.duration)))

            case .delegate:
                return .none
            }
        }
    }
}
