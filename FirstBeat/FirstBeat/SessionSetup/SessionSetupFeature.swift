//
//  SessionSetupFeature.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import ComposableArchitecture

@Reducer
struct SessionSetupFeature {
    @ObservableState
    struct State: Equatable {
        var suggestion: String
        var selectedType: FormatType = .harold
        var totaDuration: Int = 25
    }

    enum Action: Equatable {
        case typeSelected(FormatType)
        case durationChanged(Int)
        case startSelected
        case next(String, FormatType, Int)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .typeSelected(let type):
                state.selectedType = type
                return .none
            case .durationChanged(let minutes):
                state.totaDuration = minutes
                return .none
            case .startSelected:
                return .send(.next(
                    state.suggestion,
                    state.selectedType,
                    state.totaDuration
                ))
            case .next:
                return .none
            }
        }
    }
}
