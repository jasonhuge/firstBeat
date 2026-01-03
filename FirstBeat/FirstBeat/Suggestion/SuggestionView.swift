//
//  SuggestionView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import SwiftUI
import ComposableArchitecture
import UIKit

struct SuggestionView: View {
    @Bindable
    var store: StoreOf<SuggestionFeature>

    @FocusState
    private var isTextFieldFocused: Bool

    @State
    private var impactGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        VStack(spacing: 0) {
            makeContent()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            store.send(.deleteAll)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.primary)
                        }
                    }
                }

            makeFooter()
        }
        .navigationTitle("AI Suggestion")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            impactGenerator.prepare()
        }
    }
}

// MARK: - Constants

extension SuggestionView {
    enum Constants {
        static let idleIconSize: CGFloat = 50
        static let idleIconOpacity: CGFloat = 0.7
        static let idleSpacing: CGFloat = 12

        static let conversationSpacing: CGFloat = 24
        static let responseSpacing: CGFloat = 16
        static let scrollAnimationDuration: CGFloat = 0.4

        static let promptPadding: CGFloat = 12
        static let promptCornerRadius: CGFloat = 16

        static let aiResponseSpacing: CGFloat = 12
        static let aiResponsePadding: CGFloat = 12
        static let aiResponseBackgroundOpacity: CGFloat = 0.1
        static let aiResponseCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 16
        static let cardShadowOpacity: CGFloat = 0.08
        static let cardShadowRadius: CGFloat = 4
        static let cardShadowY: CGFloat = 2

        static let footerHorizontalPadding: CGFloat = 16
        static let footerVerticalPadding: CGFloat = 12
        static let footerSpacing: CGFloat = 12
        static let textFieldPaddingTop: CGFloat = 12
        static let textFieldPaddingLeading: CGFloat = 16
        static let textFieldPaddingBottom: CGFloat = 12
        static let textFieldPaddingTrailing: CGFloat = 16
        static let textFieldCornerRadius: CGFloat = 30
        static let textFieldBackgroundOpacity: CGFloat = 0.1
        static let buttonPadding: CGFloat = 14
        static let buttonShadowRadius: CGFloat = 2
        static let buttonDisabledOpacity: CGFloat = 0.5
        static let footerBackgroundOpacity: CGFloat = 0.95
        static let footerShadowOpacity: CGFloat = 0.08
        static let footerShadowRadius: CGFloat = 8
        static let footerShadowY: CGFloat = -4
    }
}

// MARK: - Components

extension SuggestionView {
    @ViewBuilder
    private func makeIdleContent() -> some View {
        VStack(spacing: Constants.idleSpacing) {
            Image(systemName: "sparkles")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.idleIconSize, height: Constants.idleIconSize)
                .foregroundColor(.primary.opacity(Constants.idleIconOpacity))

            Text("Get a Suggestion")
                .font(.title2)
                .bold()

            Text("Ask for an improv suggestion to inspire your practice.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }

    @ViewBuilder
    private func makeContent() -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                if store.conversations.isEmpty {
                    makeIdleContent()
                        .transition(.opacity)
                } else {
                    makeConversations(proxy: proxy)
                }
            }
        }
    }

    @ViewBuilder
    private func makeConversations(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: Constants.conversationSpacing) {
            ForEach(store.conversations) { conversation in
                VStack(spacing: Constants.responseSpacing) {
                    makePrompt(conversation.prompt)
                    makeAIResponse(conversation.contentArray)
                }
                .id(conversation.id)
            }
        }
        .padding()
        .onChange(of: store.conversations.count, initial: false) { _, _ in
            guard let lastID = store.conversations.last?.id else { return }
            withAnimation(.easeOut(duration: Constants.scrollAnimationDuration)) {
                proxy.scrollTo(lastID, anchor: .bottom)
            }
        }
    }

    @ViewBuilder
    private func makePrompt(_ text: String) -> some View {
        HStack {
            Spacer()
            Text("Can we get a suggestion of **\(text)**?")
                .foregroundColor(.white)
                .padding(Constants.promptPadding)
                .background(AppTheme.practiceColor)
                .cornerRadius(Constants.promptCornerRadius)
        }
    }

    @ViewBuilder
    private func makeAIResponse(_ content: [String]) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Constants.aiResponseSpacing) {
                if content.isEmpty {
                    ThinkingView()
                } else {
                    ForEach(content, id: \.self) { suggestion in
                        if suggestion.contains("Error") {
                            HStack {
                                Text(suggestion)
                                    .foregroundColor(Color(.label))
                                Spacer()
                            }
                            .padding(Constants.cardPadding)
                            .background(
                                RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                                    .fill(Color(.secondarySystemBackground))
                                    .shadow(color: .black.opacity(Constants.cardShadowOpacity), radius: Constants.cardShadowRadius, y: Constants.cardShadowY)
                            )
                        } else {
                            Button {
                                // Send action first, then haptic feedback
                                store.send(.suggestionSelected(suggestion))
                                impactGenerator.impactOccurred()
                            } label: {
                                HStack {
                                    Text(suggestion)
                                        .foregroundColor(Color(.label))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(.secondaryLabel))
                                }
                                .padding(Constants.cardPadding)
                                .background(
                                    RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                                        .fill(Color(.secondarySystemBackground))
                                        .shadow(color: .black.opacity(Constants.cardShadowOpacity), radius: Constants.cardShadowRadius, y: Constants.cardShadowY)
                                )
                            }
                        }
                    }
                }
            }
            .padding(Constants.aiResponsePadding)
            .background(Color.gray.opacity(Constants.aiResponseBackgroundOpacity))
            .cornerRadius(Constants.aiResponseCornerRadius)

            Spacer()
        }
    }

    @ViewBuilder
    private func makeFooter() -> some View {
        HStack(spacing: Constants.footerSpacing) {
            TextField(
                "Can we get a suggestion of ...",
                text: $store.textInput
            )
            .textInputAutocapitalization(.sentences)
            .disableAutocorrection(false)
            .padding(EdgeInsets(
                top: Constants.textFieldPaddingTop,
                leading: Constants.textFieldPaddingLeading,
                bottom: Constants.textFieldPaddingBottom,
                trailing: Constants.textFieldPaddingTrailing
            ))
            .background(Color.gray.opacity(Constants.textFieldBackgroundOpacity))
            .cornerRadius(Constants.textFieldCornerRadius)
            .focused($isTextFieldFocused)

            Button {
                isTextFieldFocused = false
                store.send(.sendSuggestionTapped)
                impactGenerator.impactOccurred()
            } label: {
                Image(systemName: "arrow.up")
                    .foregroundColor(.white)
                    .padding(Constants.buttonPadding)
                    .background(AppTheme.practiceColor)
                    .clipShape(Circle())
                    .shadow(radius: Constants.buttonShadowRadius)
                    .opacity(store.textInput.isEmpty ? Constants.buttonDisabledOpacity : 1.0)
            }
            .disabled(store.textInput.isEmpty)
        }
        .padding(.horizontal, Constants.footerHorizontalPadding)
        .padding(.vertical, Constants.footerVerticalPadding)
        .background(Color(.systemBackground).opacity(Constants.footerBackgroundOpacity))
        .compositingGroup()
        .shadow(color: .black.opacity(Constants.footerShadowOpacity), radius: Constants.footerShadowRadius, y: Constants.footerShadowY)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        SuggestionView(
            store: Store(initialState: SuggestionFeature.State()) {
                SuggestionFeature()
            }
        )
    }
}
