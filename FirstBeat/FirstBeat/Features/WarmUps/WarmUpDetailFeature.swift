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
        var isFavorite: Bool = false
    }

    enum Action: Equatable {
        case toggleFavorite
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case favoriteToggled(String, Bool)
        }
    }

    @Dependency(\.favoritesService) var favoritesService

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleFavorite:
                state.isFavorite.toggle()

                let warmUpName = state.warmUp.name
                let newValue = state.isFavorite

                return .run { send in
                    if newValue {
                        try? await favoritesService.addFavorite(warmUpName)
                    } else {
                        try? await favoritesService.removeFavorite(warmUpName)
                    }
                    await send(.delegate(.favoriteToggled(warmUpName, newValue)))
                }

            case .delegate:
                return .none
            }
        }
    }
}
