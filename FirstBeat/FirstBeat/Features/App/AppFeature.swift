//
//  AppFeature.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import ComposableArchitecture

@Reducer
struct AppFeature {

    // MARK: - State
    @ObservableState
    struct State {
        // Root feature
        var home = HomeFeature.State()

        // Stack-based navigation
        var path = StackState<Path.State>()
    }

    // MARK: - Action
    enum Action {
        case home(HomeFeature.Action)
        case path(StackAction<Path.State, Path.Action>)
    }

    // MARK: - Navigation Path
    @Reducer
    struct Path {

        @ObservableState
        enum State: Equatable {
            case practiceEntry(PracticeEntryFeature.State)
            case suggestion(SuggestionFeature.State)
            case practiceSetup(SessionSetupFeature.State)
            case practiceSession(SessionFeature.State)
            case warmUpList(WarmUpListFeature.State)
            case warmUpDetail(WarmUpDetailFeature.State)
        }

        enum Action: Equatable {
            case practiceEntry(PracticeEntryFeature.Action)
            case suggestion(SuggestionFeature.Action)
            case practiceSetup(SessionSetupFeature.Action)
            case practiceSession(SessionFeature.Action)
            case warmUpList(WarmUpListFeature.Action)
            case warmUpDetail(WarmUpDetailFeature.Action)
        }

        var body: some Reducer<State, Action> {
            Scope(state: \.practiceEntry, action: \.practiceEntry) {
                PracticeEntryFeature()
            }

            Scope(state: \.suggestion, action: \.suggestion) {
                SuggestionFeature()
            }

            Scope(state: \.practiceSetup, action: \.practiceSetup) {
                SessionSetupFeature()
            }

            Scope(state: \.practiceSession, action: \.practiceSession) {
                SessionFeature()
            }

            Scope(state: \.warmUpList, action: \.warmUpList) {
                WarmUpListFeature()
            }

            Scope(state: \.warmUpDetail, action: \.warmUpDetail) {
                WarmUpDetailFeature()
            }
        }
    }

    // MARK: - Reducer
    var body: some Reducer<State, Action> {

        // Root feature
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }

        Reduce { state, action in
            switch action {

            // MARK: Home → Navigation
            case .home(.delegate(.navigateToWarmUps)):
                state.path.append(.warmUpList(WarmUpListFeature.State()))
                return .none

            case .home(.delegate(.navigateToPractice)):
                state.path.append(.practiceEntry(PracticeEntryFeature.State()))
                return .none

            // MARK: Practice Entry → AI Suggestion
            case .path(.element(id: _, action: .practiceEntry(.delegate(.getAISuggestion)))):
                state.path.append(.suggestion(SuggestionFeature.State()))
                return .none

            // MARK: Practice Entry → Direct Setup (no suggestion)
            case .path(.element(id: _, action: .practiceEntry(.delegate(.startPractice)))):
                state.path.append(.practiceSetup(SessionSetupFeature.State(suggestion: nil)))
                return .none

            // MARK: Suggestion → Practice Setup (with suggestion)
            case .path(.element(id: _, action: .suggestion(.suggestionSelected(let suggestion)))):
                state.path.append(.practiceSetup(SessionSetupFeature.State(suggestion: suggestion)))
                return .none

            // MARK: Practice Setup → Practice Session
            case .path(.element(id: _, action: .practiceSetup(.delegate(.next(let suggestion, let format, let opening, let duration))))):
                state.path.append(.practiceSession(SessionFeature.State(
                    title: suggestion,
                    format: format,
                    opening: opening,
                    duration: duration
                )))
                return .none

            // MARK: Warm-up List → Warm-up Detail
            case .path(.element(id: let id, action: .warmUpList(.warmUpSelected(let warmUp)))):
                guard case .warmUpList(let warmUpListState) = state.path[id: id] else {
                    return .none
                }
                let isFavorite = warmUpListState.favoriteWarmUpNames.contains(warmUp.name)
                state.path.append(.warmUpDetail(WarmUpDetailFeature.State(
                    warmUp: warmUp,
                    isFavorite: isFavorite
                )))
                return .none

            // MARK: Warm-up Detail → Sync favorite state back to list
            case .path(.element(id: _, action: .warmUpDetail(.delegate(.favoriteToggled(let name, let isFavorite))))):
                // Find the warm-up list in the path to sync the favorite state
                for pathID in state.path.ids {
                    if case .warmUpList(var warmUpListState) = state.path[id: pathID] {
                        if isFavorite {
                            warmUpListState.favoriteWarmUpNames.insert(name)
                        } else {
                            warmUpListState.favoriteWarmUpNames.remove(name)
                        }
                        state.path[id: pathID] = .warmUpList(warmUpListState)
                    }
                }
                return .none

            // MARK: No-ops
            case .home, .path:
                return .none
            }
        }
        // Attach navigation reducers
        .forEach(\.path, action: \.path) { Path() }
    }
}
