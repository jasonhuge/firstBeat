//
//  Localization.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/13/26.
//

import SwiftUI

enum L10n {

    // MARK: - Navigation Titles

    enum Nav {
        static let warmUps = String(localized: "Warm-ups")
        static let practice = String(localized: "Practice")
        static let freeform = String(localized: "Freeform")
        static let setTheShow = String(localized: "Set the Show")
        static let sessionDetails = String(localized: "Session Details")
        static let aiSuggestions = String(localized: "AI Suggestions")
        static let getASuggestion = String(localized: "Get a Suggestion")
    }

    // MARK: - Duration

    enum Duration {
        static let shortSet = String(localized: "Short set — quick and punchy")
        static let mediumSet = String(localized: "Medium set — find the game")
        static let longSet = String(localized: "Long set — let it breathe")
        static let howLong = String(localized: "How long are we playing?")
        static let duration = String(localized: "Duration")

        static func minutes(_ count: Int) -> String {
            String(localized: "\(count) minutes")
        }
    }

    // MARK: - Home Cards

    enum Home {
        static let warmUpsTitle = String(localized: "Warm-ups")
        static let warmUpsDescription = String(localized: "Browse and explore improv exercises to energize your group")
        static let practiceTitle = String(localized: "Practice")
        static let practiceDescription = String(localized: "Start a guided improv practice session")
    }

    // MARK: - Practice Entry

    enum PracticeEntry {
        static let howWouldYouLike = String(localized: "How would you like to practice?")
        static let aiSuggestionTitle = String(localized: "AI Suggestion")
        static let aiSuggestionSubtitle = String(localized: "Let AI inspire your practice")
        static let randomSuggestionTitle = String(localized: "Random Suggestion")
        static let randomSuggestionSubtitle = String(localized: "Pick from curated categories")
        static let startPracticeTitle = String(localized: "Start Practice")
        static let startPracticeSubtitle = String(localized: "Choose format and opening")
        static let freeformTitle = String(localized: "Freeform")
        static let freeformSubtitle = String(localized: "Practice without structure")
    }

    // MARK: - Session

    enum Session {
        static let practice = String(localized: "Practice")
        static let practiceComplete = String(localized: "Practice complete!")
        static let getReady = String(localized: "Get Ready")

        static func formatTime(_ format: String) -> String {
            String(localized: "\(format) Time")
        }

        static func formatComplete(_ format: String) -> String {
            String(localized: "\(format) complete!")
        }
    }

    // MARK: - Session Setup

    enum SessionSetup {
        static let suggestion = String(localized: "Suggestion")
        static let format = String(localized: "Format")
        static let opening = String(localized: "Opening")
        static let segments = String(localized: "Segments")
        static let loadingFormats = String(localized: "Loading formats...")
    }

    // MARK: - Warm-ups

    enum WarmUps {
        static let favorites = String(localized: "Favorites")
        static let allWarmUps = String(localized: "All Warm-ups")
        static let all = String(localized: "All")
        static let loading = String(localized: "Loading warm-ups...")
        static let about = String(localized: "About")
        static let howToPlay = String(localized: "How to Play")
        static let variations = String(localized: "Variations")
        static let tips = String(localized: "Tips")
    }

    // MARK: - AI Suggestions

    enum AISuggestions {
        static let title = String(localized: "AI Suggestions")
        static let description = String(localized: "Ask for an improv suggestion powered by Apple Intelligence.")
        static let placeholder = String(localized: "Can we get a suggestion of ...")

        static func prompt(_ text: String) -> String {
            String(localized: "Can we get a suggestion of **\(text)**?")
        }
    }

    // MARK: - Random Suggestions

    enum RandomSuggestions {
        static let category = String(localized: "Category")
        static let pickASuggestion = String(localized: "Pick a Suggestion")
        static let shuffle = String(localized: "Shuffle")
    }

    // MARK: - Suggestion Choice

    enum SuggestionChoice {
        static let title = String(localized: "Your Suggestion")
    }

    // MARK: - Buttons

    enum Button {
        static let done = String(localized: "Done")
        static let start = String(localized: "Start")
        static let letsBegin = String(localized: "Let's Begin")
        static let tryAgain = String(localized: "Try Again")
    }

    // MARK: - Errors

    enum Error {
        static let unableToLoad = String(localized: "Unable to Load")
        static let checkConnection = String(localized: "Please check your internet connection and try again.")
    }
}
