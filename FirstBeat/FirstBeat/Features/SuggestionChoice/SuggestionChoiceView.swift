//
//  SuggestionChoiceView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/20/26.
//

import SwiftUI
import ComposableArchitecture

struct SuggestionChoiceView: View {
    @Bindable var store: StoreOf<SuggestionChoiceFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.containerSpacing) {
                // Suggestion display
                Text("\"\(store.suggestion)\"")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, Constants.titleTopPadding)

                // Question
                Text(L10n.PracticeEntry.howWouldYouLike)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top, Constants.questionTopPadding)

                // Option cards
                VStack(spacing: Constants.cardSpacing) {
                    ForEach(store.options) { model in
                        OptionCard(model: model) {
                            store.send(.optionSelected(id: model.id))
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationTitle(L10n.SuggestionChoice.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Constants

extension SuggestionChoiceView {
    enum Constants {
        static let containerSpacing: CGFloat = 24
        static let titleTopPadding: CGFloat = 32
        static let questionTopPadding: CGFloat = 16
        static let cardSpacing: CGFloat = 16
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        SuggestionChoiceView(
            store: Store(initialState: SuggestionChoiceFeature.State(suggestion: "A day at the beach")) {
                SuggestionChoiceFeature()
            }
        )
    }
}
