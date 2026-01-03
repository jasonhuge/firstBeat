//
//  SuggestionService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import FoundationModels
import Dependencies
import Foundation

enum SuggestionServiceError: Error{
    case noSuggestionsAvailable
}

struct SuggestionService {
    var fetchSuggestions: (String) async -> AsyncStream<String>
}

// MARK: - DependencyKey

extension SuggestionService: DependencyKey {

    static var liveValue: SuggestionService {
        Self { input in
            AsyncStream { continuation in
                Task {
                    await runSuggestionStream(
                        input: input,
                        continuation: continuation
                    )
                }
            }
        }
    }
}

// MARK: - Streaming Orchestration

private func runSuggestionStream(
    input: String,
    continuation: AsyncStream<String>.Continuation
) async {

    var seenSuggestions: Set<String> = []
    var session = LanguageModelSession()
    var currentInput = input

    while true {
        do {
            try await streamModelSuggestions(
                input: currentInput,
                session: session,
                seenSuggestions: &seenSuggestions,
                continuation: continuation
            )
            break

        } catch {
            if isTokenLimitError(error) {
                session = LanguageModelSession()
                continue
            }

            // Choose a neutral fallback input
            if let fallbackInput = SuggestionService
                .randomFallbackInputs()
                .randomElement() {

                currentInput = fallbackInput
                session = LanguageModelSession()
                continue
            }

            // Any other failure or repeated fallback → stop silently
            break
        }
    }

    continuation.finish()
}

// MARK: - Model Streaming

private func streamModelSuggestions(
    input: String,
    session: LanguageModelSession,
    seenSuggestions: inout Set<String>,
    continuation: AsyncStream<String>.Continuation
) async throws {

    let prompt = SuggestionService.makePrompt(
        with: input,
        excluding: seenSuggestions
    )

    let stream = session.streamResponse(to: prompt)

    for try await response in stream {
        let suggestion = response.content
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            !suggestion.isEmpty,
            !seenSuggestions.contains(suggestion)
        else { continue }

        if suggestion.contains("I'm sorry") {
            throw SuggestionServiceError.noSuggestionsAvailable
        } else {
            seenSuggestions.insert(suggestion)
            continuation.yield(suggestion)
        }
    }
}

// MARK: - Error Classification

private func isTokenLimitError(_ error: Error) -> Bool {
    error.localizedDescription.lowercased().contains("token")
}

private func isUnsafeContentError(_ error: Error) -> Bool {
    let message = error.localizedDescription.lowercased()
    return message.contains("unsafe")
        || message.contains("sexual")
        || message.contains("policy")
        || message.contains("content")
}

// MARK: - Prompt Construction

extension SuggestionService {

    static func makePrompt(
        with input: String,
        excluding seenSuggestions: Set<String>
    ) -> String {

        let seenList = seenSuggestions.joined(separator: ", ")

        return """
        You are an enthusiastic audience member at a live comedy improv show.

        The improvisers have asked for a suggestion based on this prompt:
        \"\(input)\"

        As an audience member, provide 3 suggestions in a numbered list.
        Keep each suggestion short and simple (1–3 words).

        Do not provide any of the following suggestions you have already given in this session:
        \(seenList)

        Do not try to be funny or witty.

        If the prompt involves an object, generate suggestions without mentioning the object itself or anything within its worldview. Absurd is allowed.
        """
    }
}

// MARK: - Fallback Inputs (NOT shown to user)

extension SuggestionService {

    /// Neutral prompts that can safely seed the LLM
    static func randomFallbackInputs() -> [String] {
        [
            "A misunderstanding",
            "An awkward pause",
            "A wrong assumption",
            "Overconfidence",
            "Bad timing",
            "Hidden motives",
            "Unexpected honesty",
            "A power imbalance",
            "A secret revealed",
            "Conflicting goals"
        ]
    }
}

// MARK: - DependencyValues

extension DependencyValues {
    var suggestionService: SuggestionService {
        get { self[SuggestionService.self] }
        set { self[SuggestionService.self] = newValue }
    }
}
