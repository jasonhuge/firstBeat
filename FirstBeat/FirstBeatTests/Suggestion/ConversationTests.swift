//
//  ConversationTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 12/19/25.
//

import Testing
@testable import FirstBeat

struct ConversationTests {

    @Test func conversationInitialization() {
        let conversation = Conversation(prompt: "Test prompt", content: "Test content")

        #expect(conversation.prompt == "Test prompt")
        #expect(conversation.content == "Test content")
        #expect(!conversation.id.isEmpty)
    }

    @Test func emptyContentReturnsEmptyArray() {
        let conversation = Conversation(prompt: "Test", content: "")

        #expect(conversation.contentArray.isEmpty)
    }

    @Test func contentArrayParsesNumberedList() {
        let conversation = Conversation(
            prompt: "Test",
            content: "1. First suggestion\n2. Second suggestion\n3. Third suggestion"
        )

        #expect(conversation.contentArray.count == 3)
        #expect(conversation.contentArray[0] == "First suggestion")
        #expect(conversation.contentArray[1] == "Second suggestion")
        #expect(conversation.contentArray[2] == "Third suggestion")
    }

    @Test func contentArrayHandlesWhitespace() {
        let conversation = Conversation(
            prompt: "Test",
            content: "  1. First  \n  2. Second  "
        )

        #expect(conversation.contentArray[0] == "First")
        #expect(conversation.contentArray[1] == "Second")
    }

    @Test func updateContent() {
        var conversation = Conversation(prompt: "Test", content: "Original")
        conversation.update(with: "Updated")

        #expect(conversation.content == "Updated")
    }
}
