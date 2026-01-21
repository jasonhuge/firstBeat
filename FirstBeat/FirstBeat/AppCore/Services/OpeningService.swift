//
//  OpeningService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/2/26.
//

import Foundation
import Dependencies

struct OpeningService {
    var fetchOpenings: () async throws -> [Opening]
}

extension OpeningService: DependencyKey {
    static var liveValue: OpeningService {
        Self {
            async let dataTask = RemoteConfigService.load(OpeningsDataRequest())
            async let translationsTask = RemoteConfigService.load(OpeningsTranslationRequest())

            let (data, translations) = try await (dataTask, translationsTask)

            return data.compactMap { openingData in
                guard let translation = translations[openingData.id] else { return nil }
                return Opening.merge(data: openingData, translation: translation)
            }
        }
    }

    static var testValue: OpeningService {
        Self {
            [Opening.mock]
        }
    }

    static var previewValue: OpeningService {
        Self {
            [Opening.mock]
        }
    }
}

extension DependencyValues {
    var openingService: OpeningService {
        get { self[OpeningService.self] }
        set { self[OpeningService.self] = newValue }
    }
}
