//
//  WarmUpDetailFeature.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/1/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WarmUpDetailFeature {
    @ObservableState
    struct State: Equatable {
        let warmUp: WarmUp
        var isCompleted: Bool = false
    }

    enum Action: Equatable {
        case toggleCompleted
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleCompleted:
                state.isCompleted.toggle()
                return .none
            }
        }
    }
}
