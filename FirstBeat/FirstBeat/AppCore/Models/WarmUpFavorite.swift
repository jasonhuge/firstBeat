//
//  WarmUpFavorite.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/4/26.
//

import Foundation
import SwiftData

/// Represents a favorited warm-up stored persistently
///
/// IMPORTANT: Uses warmUp.name as the unique identifier because UUID is regenerated
/// on every JSON decode (see WarmUp.init(from:))
@Model
final class WarmUpFavorite {
    /// Unique identifier (warmUp.name)
    @Attribute(.unique) var name: String

    /// When the favorite was added
    var addedAt: Date

    init(name: String, addedAt: Date = Date()) {
        self.name = name
        self.addedAt = addedAt
    }
}
