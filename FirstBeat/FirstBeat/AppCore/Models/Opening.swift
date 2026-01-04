//
//  Opening.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/2/26.
//

import Foundation

struct Opening: Equatable, Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let playerCount: String?
    let setupTime: String?
}

#if DEBUG
extension Opening {
    static var mock: Self {
        Self(
            id: "documentary",
            name: "Documentary",
            description: "Performed in the style of a documentary, this opening uses talking heads, narration, and reenactments to build a fictional world around the suggestion.",
            playerCount: "Ensemble",
            setupTime: "3-5 minutes"
        )
    }

    static var invocation: Self {
        Self(
            id: "invocation",
            name: "Invocation",
            description: "Performers organically call out words, phrases, or ideas inspired by a suggestion.",
            playerCount: "Ensemble",
            setupTime: "2-3 minutes"
        )
    }

    static var organicOpening: Self {
        Self(
            id: "organic_opening",
            name: "Organic Opening",
            description: "Improvisers move and speak freely in response to a suggestion.",
            playerCount: "Ensemble",
            setupTime: "3-5 minutes"
        )
    }
}
#endif
