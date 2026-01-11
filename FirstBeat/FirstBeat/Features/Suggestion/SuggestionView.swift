//
//  SuggestionView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import SwiftUI
import ComposableArchitecture

struct SuggestionView: View {
    @Bindable var store: StoreOf<SuggestionFeature>
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    if store.conversations.isEmpty {
                        makeIdleContent()
                    } else {
                        makeConversations(proxy: proxy)
                    }
                }
            }
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
        .navigationTitle("AI Suggestions")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func makeIdleContent() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.primary.opacity(0.7))

            Text("AI Suggestions")
                .font(.title2)
                .bold()

            Text("Ask for an improv suggestion powered by Apple Intelligence.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
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
                .background(AppTheme.practiceColor)
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
                                    .foregroundColor(Color(.label))
                                Spacer()
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.secondarySystemBackground))
                                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                            )
                        } else {
                            Button {
                                store.send(.suggestionSelected(suggestion))
                                HapticFeedback.medium()
                            } label: {
                                HStack {
                                    Text(suggestion)
                                        .foregroundColor(Color(.label))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(.secondaryLabel))
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.secondarySystemBackground))
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
                HapticFeedback.medium()
            } label: {
                Image(systemName: "arrow.up")
                    .foregroundColor(.white)
                    .padding(14)
                    .background(AppTheme.practiceColor)
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

#if DEBUG
#Preview {
    NavigationStack {
        SuggestionView(
            store: Store(initialState: SuggestionFeature.State()) {
                SuggestionFeature()
            }
        )
    }
}
#endif
