//
//  WarmUpListFeature.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/1/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WarmUpListFeature {
    @ObservableState
    struct State: Equatable {
        var warmUps: [WarmUp] = []
        var selectedCategory: WarmUpCategory? = nil
        var completedWarmUps: Set<UUID> = []

        var filteredWarmUps: [WarmUp] {
            guard let category = selectedCategory else { return warmUps }
            return warmUps.filter { $0.category == category }
        }
    }

    enum Action: Equatable {
        case onAppear
        case categorySelected(WarmUpCategory?)
        case warmUpSelected(WarmUp)
        case toggleCompleted(UUID)
        case warmUpsLoaded([WarmUp])
    }

    @Dependency(\.warmUpService) var service

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let warmUps = await service.fetchWarmUps()
                    await send(.warmUpsLoaded(warmUps))
                }

            case .warmUpsLoaded(let warmUps):
                state.warmUps = warmUps
                return .none

            case .categorySelected(let category):
                state.selectedCategory = category
                return .none

            case .warmUpSelected:
                return .none  // Handled by parent navigation

            case .toggleCompleted(let id):
                if state.completedWarmUps.contains(id) {
                    state.completedWarmUps.remove(id)
                } else {
                    state.completedWarmUps.insert(id)
                }
                return .none
            }
        }
    }
}
