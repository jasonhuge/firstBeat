//
//  RandomSuggestionFeature.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/11/26.
//

import ComposableArchitecture

@Reducer
struct RandomSuggestionFeature {
    @ObservableState
    struct State: Equatable {
        var categories: [SuggestionCategory] = []
        var selectedCategory: SuggestionCategory? = nil
        var currentSuggestions: [String] = []
        var selectedSuggestion: String? = nil
        var usedSuggestions: Set<String> = []
        var isLoadingCategories: Bool = true
    }

    enum Action: Equatable {
        case onAppear
        case categoriesLoaded([SuggestionCategory])
        case categorySelected(SuggestionCategory)
        case usedSuggestionsLoaded(Set<String>)
        case refreshSuggestions
        case suggestionSelected(String)
    }

    @Dependency(\.randomSuggestionService)
    var randomSuggestionService

    @Dependency(\.usedSuggestionsService)
    var usedSuggestionsService

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.categories.isEmpty else { return .none }
                state.isLoadingCategories = true
                return .run { send in
                    let categories = await randomSuggestionService.fetchCategories()
                    await send(.categoriesLoaded(categories))
                }

            case .categoriesLoaded(let categories):
                state.categories = categories
                state.isLoadingCategories = false
                return .none

            case .categorySelected(let category):
                state.selectedCategory = category
                state.selectedSuggestion = nil
                return .run { send in
                    // Check if we need to reset first
                    let shouldReset = await usedSuggestionsService.shouldReset(
                        category.id,
                        category.suggestions.count
                    )
                    if shouldReset {
                        await usedSuggestionsService.reset(category.id)
                    }

                    let used = await usedSuggestionsService.getUsed(category.id)
                    await send(.usedSuggestionsLoaded(used))
                }

            case .usedSuggestionsLoaded(let used):
                state.usedSuggestions = used
                guard let category = state.selectedCategory else { return .none }
                state.currentSuggestions = randomSuggestionService.getRandomSuggestions(
                    category,
                    3,
                    used
                )
                return .none

            case .refreshSuggestions:
                guard let category = state.selectedCategory else { return .none }
                state.currentSuggestions = randomSuggestionService.getRandomSuggestions(
                    category,
                    3,
                    state.usedSuggestions
                )
                return .none

            case .suggestionSelected(let suggestion):
                state.selectedSuggestion = suggestion
                guard let category = state.selectedCategory else { return .none }

                // Mark as used
                return .run { _ in
                    await usedSuggestionsService.markUsed(suggestion, category.id)
                }
            }
        }
    }
}
