//
//  SessionSetupFeatureTests.swift
//  FirstBeatTests
//
//  Created by Jason Hughes on 12/19/25.
//

import Testing
import ComposableArchitecture
@testable import FirstBeat

@MainActor
struct SessionSetupFeatureTests {

    @Test func initialStateWithSuggestion() {
        let state = SessionSetupFeature.State(suggestion: "Test suggestion")

        #expect(state.suggestion == "Test suggestion")
        #expect(state.selectedType == nil) // nil until formats are loaded
        #expect(state.totalDuration == 25)
        #expect(state.formats.isEmpty)
        #expect(state.openings.isEmpty)
    }

    @Test func initialStateWithoutSuggestion() {
        let state = SessionSetupFeature.State(suggestion: nil)

        #expect(state.suggestion == nil)
        #expect(state.selectedType == nil) // nil until formats are loaded
        #expect(state.totalDuration == 25)
        #expect(state.formats.isEmpty)
        #expect(state.openings.isEmpty)
    }

    @Test func onAppearLoadsFormatsAndOpenings() async {
        let mockFormats = [FormatType.mock]
        let mockOpenings = [Opening.invocation, Opening.organicOpening]

        let store = TestStore(
            initialState: SessionSetupFeature.State(suggestion: "Test")
        ) {
            SessionSetupFeature()
        } withDependencies: {
            $0.formatService.fetchFormats = { mockFormats }
            $0.openingService.fetchOpenings = { mockOpenings }
        }

        await store.send(.onAppear)
        await store.receive(.formatsLoaded(mockFormats)) {
            $0.formats = mockFormats
            $0.selectedType = mockFormats.first
        }
        await store.receive(.openingsLoaded(mockOpenings)) {
            $0.openings = mockOpenings
            $0.updateAvailableOpenings()
            // Auto-select preferred opening for Harold (invocation)
            $0.selectedOpening = Opening.invocation
        }
    }

    @Test func typeSelected() async {
        let mockFormat = FormatType.mock
        let mockOpenings = [Opening.invocation, Opening.organicOpening]

        let store = TestStore(
            initialState: SessionSetupFeature.State(
                suggestion: "Test",
                formats: [mockFormat],
                openings: mockOpenings
            )
        ) {
            SessionSetupFeature()
        }

        // Create a second format for selection
        let otherFormat = FormatType(
            id: "montage",
            title: "Montage",
            name: "Montage",
            description: "A montage format",
            segments: [FormatSegment(title: "Scene", portion: 1.0)],
            requiredOpeningId: nil,
            preferredOpeningId: "organic_opening",
            allowedOpeningIds: ["organic_opening", "invocation"]
        )

        await store.send(.typeSelected(otherFormat)) {
            $0.selectedType = otherFormat
            $0.updateAvailableOpenings()
            // Should select preferred opening (organic_opening)
            $0.selectedOpening = Opening.organicOpening
        }
    }

    @Test func durationChanged() async {
        let store = TestStore(
            initialState: SessionSetupFeature.State(suggestion: "Test")
        ) {
            SessionSetupFeature()
        }

        await store.send(.durationChanged(30)) {
            $0.totalDuration = 30
        }
    }

    @Test func startSelectedSendsNextActionWithSuggestion() async {
        let mockFormat = FormatType.mock
        let mockOpening = Opening.mock

        let store = TestStore(
            initialState: SessionSetupFeature.State(
                suggestion: "Test",
                formats: [mockFormat],
                selectedType: mockFormat,
                totalDuration: 30,
                openings: [mockOpening],
                selectedOpening: mockOpening
            )
        ) {
            SessionSetupFeature()
        }

        await store.send(.startSelected)
        await store.receive(.delegate(.next("Test", mockFormat, mockOpening, 30)))
    }

    @Test func startSelectedSendsNextActionWithoutSuggestion() async {
        let mockFormat = FormatType.mock
        let mockOpening = Opening.mock

        let store = TestStore(
            initialState: SessionSetupFeature.State(
                suggestion: nil,
                formats: [mockFormat],
                selectedType: mockFormat,
                totalDuration: 25,
                openings: [mockOpening],
                selectedOpening: mockOpening
            )
        ) {
            SessionSetupFeature()
        }

        await store.send(.startSelected)
        await store.receive(.delegate(.next(nil, mockFormat, mockOpening, 25)))
    }

    @Test func openingSelected() async {
        let mockFormat = FormatType.mock
        let mockOpening = Opening.mock

        let store = TestStore(
            initialState: SessionSetupFeature.State(
                suggestion: "Test",
                formats: [mockFormat],
                selectedType: mockFormat,
                openings: [mockOpening]
            )
        ) {
            SessionSetupFeature()
        }

        await store.send(.openingSelected(mockOpening)) {
            $0.selectedOpening = mockOpening
        }
    }
}
