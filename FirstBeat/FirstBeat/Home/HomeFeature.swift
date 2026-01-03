//
//  HomeFeature.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/1/26.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var cards: [HomeCard] = HomeCard.allCases
    }

    enum Action: Equatable {
        case cardSelected(HomeCard)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case navigateToWarmUps
            case navigateToPractice
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .cardSelected(let card):
                switch card {
                case .warmUps:
                    return .send(.delegate(.navigateToWarmUps))
                case .practice:
                    return .send(.delegate(.navigateToPractice))
                }

            case .delegate:
                return .none  // Parent handles navigation
            }
        }
    }
}
