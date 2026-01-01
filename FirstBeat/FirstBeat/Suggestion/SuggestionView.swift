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
                    ToolbarItem(placement: .title) {
                        Text("First Beat")
                            .font(.title2)
                            .bold()
                    }
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
        .onAppear {
            impactGenerator.prepare()
        }
    }
}

extension SuggestionView {
    @ViewBuilder
    private func makeIdleContent() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.primary.opacity(0.7))

            Text("Welcome!")
                .font(.title2)
                .bold()

            Text("Ask for an improv suggestion to begin your practice session.")
                .font(.body)
                .foregroundColor(.secondary)
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
        VStack(spacing: 24) {
            ForEach(store.conversations) { conversation in
                VStack(spacing: 16) {
                    makePrompt(conversation.prompt)
                    makeAIResponse(conversation.contentArray)
                }
                .id(conversation.id)
            }
        }
        .padding()
        .onChange(of: store.conversations.count, initial: false) { _, _ in
            guard let lastID = store.conversations.last?.id else { return }
            withAnimation(.easeOut(duration: 0.4)) {
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
                .padding(12)
                .background(Color.blue)
                .cornerRadius(16)
        }
    }

    @ViewBuilder
    private func makeAIResponse(_ content: [String]) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 12) {
                if content.isEmpty {
                    ThinkingView()
                } else {
                    ForEach(content, id: \.self) { suggestion in
                        if suggestion.contains("Error") {
                            HStack {
                                Text(suggestion)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                            )
                        } else {
                            Button {
                                // Send action first, then haptic feedback
                                store.send(.suggestionSelected(suggestion))
                                impactGenerator.impactOccurred()
                            } label: {
                                HStack {
                                    Text(suggestion)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                                )
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)

            Spacer()
        }
    }

    @ViewBuilder
    private func makeFooter() -> some View {
        HStack(spacing: 12) {
            TextField(
                "Can we get a suggestion of ...",
                text: $store.textInput
            )
            .textInputAutocapitalization(.sentences)
            .disableAutocorrection(false)
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .background(Color.gray.opacity(0.1))
            .cornerRadius(30)
            .focused($isTextFieldFocused)

            Button {
                isTextFieldFocused = false
                store.send(.sendSuggestionTapped)
                impactGenerator.impactOccurred()
            } label: {
                Image(systemName: "arrow.up")
                    .foregroundColor(.white)
                    .padding(14)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                    .opacity(store.textInput.isEmpty ? 0.5 : 1.0)
            }
            .disabled(store.textInput.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground).opacity(0.95))
        .compositingGroup()
        .shadow(color: .black.opacity(0.08), radius: 8, y: -4)
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
