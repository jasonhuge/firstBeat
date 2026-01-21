//
//  SuggestionService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import FoundationModels
import Dependencies
import Foundation

enum SuggestionServiceError: Error {
    case noSuggestionsAvailable
}

struct SuggestionService {
    var fetchSuggestions: (String, Set<String>) async -> AsyncStream<String>  // input, usedSuggestions
}

// MARK: - DependencyKey

extension SuggestionService: DependencyKey {

    static var liveValue: SuggestionService {
        Self { input, usedSuggestions in
            AsyncStream { continuation in
                Task {
                    await runSuggestionStream(
                        input: input,
                        usedSuggestions: usedSuggestions,
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
    usedSuggestions: Set<String>,
    continuation: AsyncStream<String>.Continuation
) async {

    var seenSuggestions = usedSuggestions
    var session = LanguageModelSession(instructions: SuggestionService.sessionInstructions())
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
                session = LanguageModelSession(instructions: SuggestionService.sessionInstructions())
                continue
            }

            // Choose a neutral fallback input
            if let fallbackInput = SuggestionService
                .randomFallbackInputs()
                .randomElement() {

                currentInput = fallbackInput
                session = LanguageModelSession(instructions: SuggestionService.sessionInstructions())
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

// MARK: - Session Instructions

extension SuggestionService {

    /// Creates session instructions with the user's preferred language
    static func sessionInstructions() -> String {
        let languageName = currentLanguageName()

        return """
        You are an improv comedy suggestion generator.
        Generate short, fun audience suggestions (1-2 words each).
        Always respond in \(languageName).
        """
    }

    /// Returns the user's preferred language name
    private static func currentLanguageName() -> String {
        let locale = Locale.current
        guard let languageCode = locale.language.languageCode else {
            return "English"
        }

        // Get the localized name of the language in English for the model
        return Locale(identifier: "en").localizedString(forLanguageCode: languageCode.identifier) ?? "English"
    }
}

// MARK: - Prompt Construction

extension SuggestionService {

    static func makePrompt(
        with input: String,
        excluding seenSuggestions: Set<String>
    ) -> String {

        var prompt = """
        Improv comedy prompt: "\(input)"

        Give 3 short audience suggestions (1-2 words each).

        Example format:
        1. Dentist
        2. Hawaii
        3. Grandma
        """

        if !seenSuggestions.isEmpty {
            let seenList = seenSuggestions.joined(separator: ", ")
            prompt += """


        Already used: \(seenList)
        """
        }

        prompt += """


        Your suggestions:
        """

        return prompt
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
