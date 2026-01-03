//
//  OpeningService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/2/26.
//

import Foundation
import Dependencies

struct OpeningService {
    var fetchOpenings: () -> [Opening]
}

extension OpeningService: DependencyKey {
    static var liveValue: OpeningService {
        Self {
            JSONLoader.load([Opening].self, filename: "openings") ?? []
        }
    }
}

extension DependencyValues {
    var openingService: OpeningService {
        get { self[OpeningService.self] }
        set { self[OpeningService.self] = newValue }
    }
}
