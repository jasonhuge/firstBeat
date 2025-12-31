//
//  Conversation.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import Foundation

struct Conversation: Identifiable, Equatable {
    let id: String = UUID().uuidString
    let prompt: String
    var content: String

    // Computed array of suggestions
    var contentArray: [String] {
        guard !content.isEmpty else { return [] }

        let lines = content
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        // Remove numbers and dots using regex (e.g., "1. this" → "this")
        let suggestions = lines.map { line in
            line.replacingOccurrences(of: "^\\d+\\.\\s*", with: "", options: .regularExpression)
        }

        return suggestions
    }

    // Updating content (mutating for structs)
    mutating func update(with newContent: String) {
        self.content = newContent
    }
}

