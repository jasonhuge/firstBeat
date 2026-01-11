//
//  SuggestionFeature.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct SuggestionFeature {
    @ObservableState
    struct State: Equatable {
        var textInput: String = ""
        var conversations: [Conversation] = []
        var isFetching: Bool = false
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case sendSuggestionTapped
        case conversationReceived(id: String, content: String)
        case deleteAll
        case suggestionSelected(String)
    }

    @Dependency(\.suggestionService)
    var suggestionService

    @Dependency(\.usedSuggestionsService)
    var usedSuggestionsService

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .sendSuggestionTapped:
                let input = state.textInput
                guard !input.isEmpty else { return .none }

                state.isFetching = true
                state.textInput = ""

                let conversation = Conversation(
                    prompt: input,
                    content: ""
                )

                withAnimation {
                    state.conversations.append(conversation)
                }

                return .run { send in
                    for try await content in await suggestionService.fetchSuggestions(input) {
                        await send(.conversationReceived(id: conversation.id, content: content))
                    }
                }

            case .conversationReceived(let id, let content):
                if let index = state.conversations.firstIndex(where: { $0.id == id }) {
                    withAnimation {
                        state.conversations[index].update(with: content)
                    }
                }
                state.isFetching = false
                return .none

            case .deleteAll:
                state.conversations = []
                state.isFetching = false
                return .none

            case .suggestionSelected(let suggestion):
                // Mark as used
                return .run { _ in
                    await usedSuggestionsService.markAIUsed(suggestion)
                }
            }
        }
    }
}
