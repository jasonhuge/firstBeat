//
//  PracticeEntryFeature.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/1/26.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct PracticeEntryFeature {
    @ObservableState
    struct State: Equatable {
        var options: [OptionCardModel] = []
        var isAIAvailable: Bool = false
        var isCheckingAvailability: Bool = true
    }

    enum Action: Equatable {
        case onAppear
        case availabilityChecked(Bool)
        case optionSelected(id: String)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case getAISuggestion
            case getRandomSuggestion
            case startPractice
        }
    }

    @Dependency(\.aiAvailabilityService)
    var aiAvailabilityService

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.isCheckingAvailability else { return .none }
                return .run { send in
                    let backend = await aiAvailabilityService.checkAvailability()
                    await send(.availabilityChecked(backend == .appleIntelligence))
                }

            case .availabilityChecked(let isAIAvailable):
                state.isAIAvailable = isAIAvailable
                state.isCheckingAvailability = false
                state.options = Self.buildOptions(isAIAvailable: isAIAvailable)
                return .none

            case .optionSelected(let id):
                switch id {
                case "getAISuggestion":
                    return .send(.delegate(.getAISuggestion))
                case "getRandomSuggestion":
                    return .send(.delegate(.getRandomSuggestion))
                case "startPractice":
                    return .send(.delegate(.startPractice))
                default:
                    return .none
                }

            case .delegate:
                return .none
            }
        }
    }

    static func buildOptions(isAIAvailable: Bool) -> [OptionCardModel] {
        var options: [OptionCardModel] = []

        if isAIAvailable {
            options.append(.init(
                id: "getAISuggestion",
                title: "AI Suggestion",
                subtitle: "Let AI inspire your practice",
                icon: "sparkles",
                color: AppTheme.practiceColor
            ))
        }

        options.append(.init(
            id: "getRandomSuggestion",
            title: "Random Suggestion",
            subtitle: "Pick from curated categories",
            icon: "shuffle",
            color: .orange
        ))

        options.append(.init(
            id: "startPractice",
            title: "Start Practice",
            subtitle: "Jump right into a session",
            icon: "play.circle.fill",
            color: .green
        ))

        return options
    }
}
