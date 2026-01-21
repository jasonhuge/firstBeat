//
//  WarmUpService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/1/26.
//

import Dependencies
import Foundation

struct WarmUpService {
    var fetchWarmUps: () async throws -> [WarmUp]
}

// MARK: - DependencyKey

extension WarmUpService: DependencyKey {
    static var liveValue: WarmUpService {
        Self {
            async let dataTask = RemoteConfigService.load(WarmUpsDataRequest())
            async let translationsTask = RemoteConfigService.load(WarmUpsTranslationRequest())

            let (data, translations) = try await (dataTask, translationsTask)

            return data.compactMap { warmUpData in
                guard let translation = translations[warmUpData.id] else { return nil }
                return WarmUp.merge(data: warmUpData, translation: translation)
            }
        }
    }

    static var testValue: WarmUpService {
        Self {
            [WarmUp(
                name: "Test Warm-up",
                category: .physical,
                description: "A test warm-up",
                howToPlay: "Test instructions"
            )]
        }
    }

    static var previewValue: WarmUpService {
        Self {
            [WarmUp(
                name: "Preview Warm-up",
                category: .physical,
                description: "A preview warm-up",
                howToPlay: "Preview instructions"
            )]
        }
    }
}

// MARK: - DependencyValues

extension DependencyValues {
    var warmUpService: WarmUpService {
        get { self[WarmUpService.self] }
        set { self[WarmUpService.self] = newValue }
    }
}
