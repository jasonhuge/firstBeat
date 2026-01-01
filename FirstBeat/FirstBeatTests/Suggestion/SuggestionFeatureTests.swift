//
//  SuggestionFeatureTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 12/19/25.
//

import Testing
import ComposableArchitecture
@testable import FirstBeat

@MainActor
struct SuggestionFeatureTests {

    @Test func initialState() {
        let store = TestStore(initialState: SuggestionFeature.State()) {
            SuggestionFeature()
        }

        #expect(store.state.textInput.isEmpty)
        #expect(store.state.conversations.isEmpty)
        #expect(store.state.isFetching == false)
    }

    @Test func sendSuggestionWithEmptyInputDoesNothing() async {
        let store = TestStore(initialState: SuggestionFeature.State()) {
            SuggestionFeature()
        }

        await store.send(.sendSuggestionTapped)

        #expect(store.state.textInput.isEmpty)
        #expect(store.state.conversations.isEmpty)
    }

    @Test func sendSuggestionClearsTextInputAndCreatesConversation() async {
        let store = TestStore(
            initialState: SuggestionFeature.State(textInput: "a funny scene")
        ) {
            SuggestionFeature()
        } withDependencies: {
            $0.suggestionService.fetchSuggestions = { _ in
                AsyncStream { continuation in
                    continuation.finish()
                }
            }
        }

        await store.send(.sendSuggestionTapped) {
            $0.textInput = ""
            $0.isFetching = true
            $0.conversations = [
                Conversation(prompt: "a funny scene", content: "")
            ]
        }
    }

    @Test func conversationReceivedUpdatesContent() async {
        let conversation = Conversation(prompt: "test", content: "")
        let store = TestStore(
            initialState: SuggestionFeature.State(
                conversations: [conversation]
            )
        ) {
            SuggestionFeature()
        }

        await store.send(.conversationReceived(id: conversation.id, content: "1. New suggestion")) {
            $0.conversations[0].content = "1. New suggestion"
            $0.isFetching = false
        }
    }

    @Test func deleteAllClearsConversations() async {
        let store = TestStore(
            initialState: SuggestionFeature.State(
                conversations: [
                    Conversation(prompt: "test1", content: "content1"),
                    Conversation(prompt: "test2", content: "content2")
                ],
                isFetching: true
            )
        ) {
            SuggestionFeature()
        }

        await store.send(.deleteAll) {
            $0.conversations = []
            $0.isFetching = false
        }
    }

    @Test func bindingUpdatesTextInput() async {
        let store = TestStore(initialState: SuggestionFeature.State()) {
            SuggestionFeature()
        }

        await store.send(.binding(.set(\.textInput, "new input"))) {
            $0.textInput = "new input"
        }
    }
}
