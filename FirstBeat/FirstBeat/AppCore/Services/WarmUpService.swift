//
//  WarmUpService.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/1/26.
//

import Dependencies
import Foundation

struct WarmUpService {
    var fetchWarmUps: () -> [WarmUp]
}

// MARK: - DependencyKey

extension WarmUpService: DependencyKey {
    static var liveValue: WarmUpService {
        Self {
            JSONLoader.load([WarmUp].self, filename: "warmups") ?? []
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
