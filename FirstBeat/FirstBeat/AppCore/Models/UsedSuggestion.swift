//
//  UsedSuggestion.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/11/26.
//

import Foundation
import SwiftData

@Model
final class UsedSuggestion {
    var suggestion: String
    var categoryId: String  // "ai" for AI suggestions, category id for random
    var usedAt: Date

    init(suggestion: String, categoryId: String) {
        self.suggestion = suggestion
        self.categoryId = categoryId
        self.usedAt = Date()
    }
}
