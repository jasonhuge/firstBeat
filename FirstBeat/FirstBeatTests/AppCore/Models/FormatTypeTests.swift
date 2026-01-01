//
//  FormatTypeTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 12/19/25.
//

import Testing
@testable import FirstBeat

struct FormatTypeTests {

    @Test func haroldHasCorrectSegments() {
        let harold = FormatType.harold

        #expect(harold.title == "Harold")
        #expect(harold.segments.count == 5)
        #expect(harold.segments[0].title == "Opening")
        #expect(harold.segments[1].title == "1st Beat")
        #expect(harold.segments[2].title == "2nd Beat")
        #expect(harold.segments[3].title == "3rd Beat")
        #expect(harold.segments[4].title == "Closer")
    }

    @Test func montageHasCorrectSegments() {
        let montage = FormatType.montage

        #expect(montage.title == "Montage")
        #expect(montage.segments.count == 3)
        #expect(montage.segments[0].title == "Opening")
        #expect(montage.segments[1].title == "Montage")
        #expect(montage.segments[2].title == "Callback")
    }

    @Test func segmentDurationCalculation() {
        let harold = FormatType.harold
        let duration = 25 // minutes

        // Opening is 20% of 25 minutes = 5 minutes = 300 seconds
        let openingDuration = harold.segments[0].duration(from: duration)
        #expect(openingDuration == 300.0)

        // 1st Beat is 20% of 25 minutes = 5 minutes = 300 seconds
        let firstBeatDuration = harold.segments[1].duration(from: duration)
        #expect(firstBeatDuration == 300.0)
    }

    @Test func formatTypeIsIdentifiable() {
        let harold = FormatType.harold
        let montage = FormatType.montage

        #expect(harold.id != montage.id)
    }

    @Test func allCasesContainsBothFormats() {
        let allCases = FormatType.allCases

        #expect(allCases.count == 2)
        #expect(allCases.contains(.harold))
        #expect(allCases.contains(.montage))
    }
}
