//
//  AIAvailabilityService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/11/26.
//

import Foundation
import Dependencies
import FoundationModels

enum SuggestionBackend: Equatable {
    case appleIntelligence
    case randomSuggestions
}

struct AIAvailabilityService {
    var checkAvailability: () async -> SuggestionBackend
}

extension AIAvailabilityService: DependencyKey {
    static var liveValue: AIAvailabilityService {
        Self {
            // Check if Apple Intelligence is available
            switch SystemLanguageModel.default.availability {
            case .available:
                return .appleIntelligence
            case .unavailable:
                return .randomSuggestions
            @unknown default:
                return .randomSuggestions
            }
        }
    }

    static var testValue: AIAvailabilityService {
        Self {
            .randomSuggestions
        }
    }

    static var previewValue: AIAvailabilityService {
        Self {
            .appleIntelligence
        }
    }
}

extension DependencyValues {
    var aiAvailabilityService: AIAvailabilityService {
        get { self[AIAvailabilityService.self] }
        set { self[AIAvailabilityService.self] = newValue }
    }
}
