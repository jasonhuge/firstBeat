//
//  SessionSetupFeature.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import ComposableArchitecture
import Dependencies

@Reducer
struct SessionSetupFeature {
    @ObservableState
    struct State: Equatable {
        var suggestion: String?
        var formats: [FormatType] = []
        var selectedType: FormatType?
        var totalDuration: Int = 25

        // Opening selection
        var openings: [Opening] = []
        var selectedOpening: Opening?
        var availableOpenings: [Opening] = []

        mutating func updateAvailableOpenings() {
            guard let selectedFormat = selectedType else {
                availableOpenings = []
                return
            }

            // Filter by allowed opening IDs if specified
            if let allowedIds = selectedFormat.allowedOpeningIds {
                availableOpenings = openings.filter { allowedIds.contains($0.id) }
            } else {
                // If no allowed IDs specified, show all openings
                availableOpenings = openings
            }
        }
    }

    @Dependency(\.formatService) var formatService
    @Dependency(\.openingService) var openingService

    enum Action: Equatable {
        case onAppear
        case formatsLoaded([FormatType])
        case openingsLoaded([Opening])
        case typeSelected(FormatType)
        case openingSelected(Opening?)
        case durationChanged(Int)
        case startSelected
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case next(String?, FormatType, Opening, Int)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    async let formats = formatService.fetchFormats()
                    async let openings = openingService.fetchOpenings()

                    await send(.formatsLoaded(formats))
                    await send(.openingsLoaded(openings))
                }

            case .formatsLoaded(let formats):
                state.formats = formats
                if let firstFormat = formats.first {
                    state.selectedType = firstFormat
                }
                return .none

            case .openingsLoaded(let openings):
                state.openings = openings
                state.updateAvailableOpenings()

                // Auto-select required opening, or preferred opening if no required
                if let selectedFormat = state.selectedType {
                    if let requiredId = selectedFormat.requiredOpeningId {
                        state.selectedOpening = state.openings.first { $0.id == requiredId }
                    } else if let preferredId = selectedFormat.preferredOpeningId {
                        state.selectedOpening = state.openings.first { $0.id == preferredId }
                    }
                }
                return .none

            case .typeSelected(let type):
                state.selectedType = type
                state.updateAvailableOpenings()

                // Auto-select required opening, preferred opening, or first available
                if let requiredId = type.requiredOpeningId {
                    state.selectedOpening = state.openings.first { $0.id == requiredId }
                } else if let preferredId = type.preferredOpeningId {
                    state.selectedOpening = state.openings.first { $0.id == preferredId }
                } else {
                    // If no preference, select first available opening
                    state.selectedOpening = state.availableOpenings.first
                }
                return .none

            case .openingSelected(let opening):
                state.selectedOpening = opening
                return .none

            case .durationChanged(let minutes):
                state.totalDuration = minutes
                return .none

            case .startSelected:
                guard let selectedType = state.selectedType else {
                    return .none
                }

                // Validate: opening is always required
                guard let selectedOpening = state.selectedOpening else {
                    return .none
                }

                return .send(.delegate(.next(
                    state.suggestion,
                    selectedType,
                    selectedOpening,
                    state.totalDuration
                )))

            case .delegate:
                return .none
            }
        }
    }
}
