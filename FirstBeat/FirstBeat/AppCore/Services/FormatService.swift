//
//  FormatService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/2/26.
//

import Dependencies
import Foundation

struct FormatService {
    var fetchFormats: () async -> [FormatType]
}

// MARK: - DependencyKey

extension FormatService: DependencyKey {
    static var liveValue: FormatService {
        Self {
            await RemoteConfigService.load(FormatsRequest()) ?? []
        }
    }

    static var testValue: FormatService {
        Self {
            JSONLoader.load([FormatType].self, filename: "formats") ?? []
        }
    }

    static var previewValue: FormatService {
        Self {
            JSONLoader.load([FormatType].self, filename: "formats") ?? []
        }
    }
}

// MARK: - DependencyValues

extension DependencyValues {
    var formatService: FormatService {
        get { self[FormatService.self] }
        set { self[FormatService.self] = newValue }
    }
}
