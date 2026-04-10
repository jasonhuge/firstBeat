//
//  FormatService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/2/26.
//

import Dependencies
import Foundation

struct FormatService {
    var fetchFormats: () async throws -> [FormatType]
}

// MARK: - DependencyKey

extension FormatService: DependencyKey {
    static var liveValue: FormatService {
        Self {
            async let dataTask = RemoteConfigService.load(FormatsDataRequest())
            async let translationsTask = RemoteConfigService.load(FormatsTranslationRequest())

            let (data, translations) = try await (dataTask, translationsTask)

            return data.compactMap { formatData in
                guard let translation = translations[formatData.id] else { return nil }
                return FormatType.merge(data: formatData, translation: translation)
            }
        }
    }

    #if DEBUG
    static var testValue: FormatService {
        Self {
            [FormatType.mock]
        }
    }

    static var previewValue: FormatService {
        Self {
            [FormatType.mock]
        }
    }
    #endif
}

// MARK: - DependencyValues

extension DependencyValues {
    var formatService: FormatService {
        get { self[FormatService.self] }
        set { self[FormatService.self] = newValue }
    }
}
