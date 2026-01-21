//
//  RemoteDataModels.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/19/26.
//

import Foundation

// MARK: - Raw Data Models (from data/ folder)

/// Raw format data without translations
struct FormatData: Decodable {
    let id: String
    let preferredOpeningId: String?
    let requiredOpeningId: String?
    let allowedOpeningIds: [String]?
    let segmentPortions: [Double]
}

/// Raw opening data without translations
struct OpeningData: Decodable {
    let id: String
}

/// Raw warmup data without translations
struct WarmUpData: Decodable {
    let id: String
    let category: String
}

/// Raw suggestion category data without translations
struct SuggestionCategoryData: Decodable {
    let id: String
    let icon: String
}

struct SuggestionsDataResponse: Decodable {
    let categories: [SuggestionCategoryData]
}

// MARK: - Translation Models (from translations/{lang}/ folder)

/// Format translation content
struct FormatTranslation: Decodable {
    let title: String
    let description: String
    let segmentTitles: [String]
}

/// Opening translation content
struct OpeningTranslation: Decodable {
    let name: String
    let description: String
    let playerCount: String?
    let setupTime: String?
}

/// Warmup translation content
struct WarmUpTranslation: Decodable {
    let name: String
    let description: String
    let howToPlay: String
    let variations: [String]
    let tips: [String]
}

/// Suggestion category translation content
struct SuggestionCategoryTranslation: Decodable {
    let name: String
    let suggestions: [String]
}

// MARK: - Merge Functions

extension FormatType {
    /// Creates a FormatType by merging data with translation
    static func merge(data: FormatData, translation: FormatTranslation) -> FormatType {
        let segments = zip(translation.segmentTitles, data.segmentPortions).map { title, portion in
            FormatSegment(title: title, portion: portion)
        }

        return FormatType(
            id: data.id,
            title: translation.title,
            name: translation.title,
            description: translation.description,
            segments: segments,
            requiredOpeningId: data.requiredOpeningId,
            preferredOpeningId: data.preferredOpeningId,
            allowedOpeningIds: data.allowedOpeningIds
        )
    }
}

extension Opening {
    /// Creates an Opening by merging data with translation
    static func merge(data: OpeningData, translation: OpeningTranslation) -> Opening {
        Opening(
            id: data.id,
            name: translation.name,
            description: translation.description,
            playerCount: translation.playerCount,
            setupTime: translation.setupTime
        )
    }
}

extension WarmUp {
    /// Creates a WarmUp by merging data with translation
    static func merge(data: WarmUpData, translation: WarmUpTranslation) -> WarmUp {
        WarmUp(
            name: translation.name,
            category: WarmUpCategory(rawValue: data.category) ?? .group,
            description: translation.description,
            howToPlay: translation.howToPlay,
            variations: translation.variations,
            tips: translation.tips
        )
    }
}

extension SuggestionCategory {
    /// Creates a SuggestionCategory by merging data with translation
    static func merge(data: SuggestionCategoryData, translation: SuggestionCategoryTranslation) -> SuggestionCategory {
        SuggestionCategory(
            id: data.id,
            name: translation.name,
            icon: data.icon,
            suggestions: translation.suggestions
        )
    }
}
