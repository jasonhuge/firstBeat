//
//  SuggestionChoiceFeature.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/20/26.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SuggestionChoiceFeature {
    @ObservableState
    struct State: Equatable {
        let suggestion: String
        var options: [OptionCardModel]

        init(suggestion: String) {
            self.suggestion = suggestion
            self.options = Self.buildOptions()
        }

        private static func buildOptions() -> [OptionCardModel] {
            [
                OptionCardModel(
                    id: "chooseFormat",
                    title: L10n.PracticeEntry.startPracticeTitle,
                    subtitle: L10n.PracticeEntry.startPracticeSubtitle,
                    icon: "list.bullet.rectangle",
                    color: .blue
                ),
                OptionCardModel(
                    id: "openPractice",
                    title: L10n.PracticeEntry.freeformTitle,
                    subtitle: L10n.PracticeEntry.freeformSubtitle,
                    icon: "timer",
                    color: .green
                )
            ]
        }
    }

    enum Action: Equatable {
        case optionSelected(id: String)
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case chooseFormat(String)
            case openPractice(String)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .optionSelected(let id):
                switch id {
                case "chooseFormat":
                    return .send(.delegate(.chooseFormat(state.suggestion)))
                case "openPractice":
                    return .send(.delegate(.openPractice(state.suggestion)))
                default:
                    return .none
                }

            case .delegate:
                return .none
            }
        }
    }
}
