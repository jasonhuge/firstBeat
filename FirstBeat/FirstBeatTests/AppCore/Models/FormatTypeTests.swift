//
//  FormatTypeTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 12/19/25.
//

import Testing
@testable import FirstBeat

struct FormatTypeTests {

    @Test func segmentDurationCalculation() {
        let segment = FormatSegment(title: "Test", portion: 0.2)
        let duration = 25 // minutes

        // 20% of 25 minutes = 5 minutes = 300 seconds
        let segmentDuration = segment.duration(from: duration)
        #expect(segmentDuration == 300.0)
    }

    @Test func segmentStringDuration() {
        let segment = FormatSegment(title: "Test", portion: 0.2)
        let duration = 25 // minutes

        // 20% of 25 minutes = 5 minutes
        let stringDuration = segment.stringDuration(duration)
        #expect(stringDuration == "5m")
    }

    @Test func segmentStringDurationWithSeconds() {
        let segment = FormatSegment(title: "Test", portion: 0.1)
        let duration = 25 // minutes

        // 10% of 25 minutes = 2.5 minutes = 2m 30s
        let stringDuration = segment.stringDuration(duration)
        #expect(stringDuration == "2m 30s")
    }

    @Test func formatTypeIsIdentifiable() {
        let format1 = FormatType(
            id: "test1",
            title: "Test 1",
            name: "Test 1",
            description: "Description",
            segments: []
        )
        let format2 = FormatType(
            id: "test2",
            title: "Test 2",
            name: "Test 2",
            description: "Description",
            segments: []
        )

        #expect(format1.id != format2.id)
    }

    @Test func formatTypeEquality() {
        let format1 = FormatType(
            id: "test",
            title: "Test",
            name: "Test",
            description: "Description",
            segments: [FormatSegment(title: "Segment", portion: 0.5)]
        )
        let format2 = FormatType(
            id: "test",
            title: "Test",
            name: "Test",
            description: "Description",
            segments: [FormatSegment(title: "Segment", portion: 0.5)]
        )

        #expect(format1 == format2)
    }
}
