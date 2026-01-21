//
//  AIAvailabilityService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/11/26.
//

import Foundation
import Dependencies
import FoundationModels

struct AIAvailabilityService: Sendable {
    var isAppleIntelligenceAvailable: @MainActor @Sendable () async -> Bool
}

extension AIAvailabilityService: DependencyKey {
    static var liveValue: AIAvailabilityService {
        Self {
            switch SystemLanguageModel.default.availability {
            case .available:
                return true
            case .unavailable:
                return false
            @unknown default:
                return false
            }
        }
    }

    static var testValue: AIAvailabilityService {
        Self { false }
    }

    static var previewValue: AIAvailabilityService {
        Self { true }
    }
}

extension DependencyValues {
    var aiAvailabilityService: AIAvailabilityService {
        get { self[AIAvailabilityService.self] }
        set { self[AIAvailabilityService.self] = newValue }
    }
}
