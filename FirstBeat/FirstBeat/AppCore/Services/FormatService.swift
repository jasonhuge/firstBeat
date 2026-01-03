//
//  FormatService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/2/26.
//

import Dependencies
import Foundation

struct FormatService {
    var fetchFormats: () -> [FormatType]
}

// MARK: - DependencyKey

extension FormatService: DependencyKey {
    static var liveValue: FormatService {
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
