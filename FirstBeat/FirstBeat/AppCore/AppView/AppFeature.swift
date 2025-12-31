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
        var suggestion = SuggestionFeature.State()

        // Stack-based navigation
        var path = StackState<Path.State>()
    }

    // MARK: - Action
    enum Action {
        case suggestion(SuggestionFeature.Action)
        case path(StackAction<Path.State, Path.Action>)
    }

    // MARK: - Navigation Path
    @Reducer
    struct Path {

        @ObservableState
        enum State: Equatable {
            case practiceSetup(SessionSetupFeature.State)
            case practiceSession(SessionFeature.State)
        }

        enum Action: Equatable {
            case practiceSetup(SessionSetupFeature.Action)
            case practiceSession(SessionFeature.Action)
        }

        var body: some Reducer<State, Action> {
            Scope(state: \.practiceSetup, action: \.practiceSetup) {
                SessionSetupFeature()
            }

            Scope(state: \.practiceSession, action: \.practiceSession) {
                SessionFeature()
            }
        }
    }

    // MARK: - Reducer
    var body: some Reducer<State, Action> {

        // Root feature
        Scope(
            state: \.suggestion,
            action: \.suggestion
        ) {
            SuggestionFeature()
        }

        Reduce { state, action in
            switch action {

            // MARK: Suggestion → Practice Setup
            case .suggestion(.suggestionSelected(let suggestion)):
                state.path.append(
                    .practiceSetup(
                        SessionSetupFeature.State(
                            suggestion: suggestion
                        )
                    )
                )
                return .none
            // MARK: Practice Setup → Practice Session
            case .path(.element(
                id: _,
                action: .practiceSetup(.next(
                    let suggestion,
                    let format,
                    let duration
                )))
            ):
                state.path.append(
                    .practiceSession(
                        SessionFeature.State(
                            title: suggestion,
                            format: format,
                            duration: duration
                        )
                    )
                )
                return .none
            // MARK: No-ops
            case .suggestion, .path:
                return .none
            }
        }
        // Attach navigation reducers
        .forEach(\.path, action: \.path) { Path() }
    }
}
