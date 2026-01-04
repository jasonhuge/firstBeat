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
        var favoriteWarmUpNames: Set<String> = []
        var isLoading: Bool = false

        var favorites: [WarmUp] {
            warmUps.filter { favoriteWarmUpNames.contains($0.name) }
        }

        var filteredWarmUps: [WarmUp] {
            guard let category = selectedCategory else { return warmUps }
            return warmUps.filter { $0.category == category }
        }
    }

    enum Action: Equatable {
        case onAppear
        case categorySelected(WarmUpCategory?)
        case warmUpSelected(WarmUp)
        case toggleFavorite(String)
        case warmUpsLoaded([WarmUp])
        case favoritesLoaded(Set<String>)
    }

    @Dependency(\.warmUpService) var service
    @Dependency(\.favoritesService) var favoritesService

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    async let warmUps = service.fetchWarmUps()
                    async let favorites = favoritesService.fetchAllFavorites()

                    await send(.warmUpsLoaded(warmUps))
                    await send(.favoritesLoaded(favorites))
                }

            case .warmUpsLoaded(let warmUps):
                state.warmUps = warmUps
                state.isLoading = false
                return .none

            case .favoritesLoaded(let favorites):
                state.favoriteWarmUpNames = favorites
                return .none

            case .categorySelected(let category):
                state.selectedCategory = category
                return .none

            case .warmUpSelected:
                return .none  // Handled by parent navigation

            case .toggleFavorite(let name):
                // Optimistic UI update
                let wasFavorite = state.favoriteWarmUpNames.contains(name)
                if wasFavorite {
                    state.favoriteWarmUpNames.remove(name)
                } else {
                    state.favoriteWarmUpNames.insert(name)
                }

                // Persist in background (fire-and-forget)
                return .run { _ in
                    if wasFavorite {
                        try? await favoritesService.removeFavorite(name)
                    } else {
                        try? await favoritesService.addFavorite(name)
                    }
                }
            }
        }
    }
}
