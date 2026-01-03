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
        // Empty - just presents options
        var options: [OptionCardModel] = [
            .init(
                id: "getAISuggestion",
                title: "Get AI Suggestion",
                subtitle: "Let AI inspire your practice",
                icon: "brain.head.profile",
                color: AppTheme.practiceColor
            ),
            .init(
                id: "startPractice",
                title: "Start Practice",
                subtitle: "Jump right into a session",
                icon: "play.circle.fill",
                color: .green
            )
        ]
    }

    enum Action: Equatable {
        case optionSelected(id: String)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case getAISuggestion
            case startPractice
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .optionSelected(let id):
                switch id {
                case "getAISuggestion":
                    return .send(.delegate(.getAISuggestion))
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
}
