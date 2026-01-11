//
//  RandomSuggestionView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/11/26.
//

import SwiftUI
import ComposableArchitecture

struct RandomSuggestionView: View {
    var store: StoreOf<RandomSuggestionFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                if store.isLoadingCategories {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                } else {
                    makeCategoriesSection()

                    if store.selectedCategory != nil {
                        makeSuggestionsSection()
                    }
                }
            }
            .padding(.top, 24)
        }
        .navigationTitle("Get a Suggestion")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.send(.onAppear)
        }
    }

    // MARK: - Categories Section

    @ViewBuilder
    private func makeCategoriesSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)
                .padding(.horizontal, 16)

            FlowLayout(spacing: 12) {
                ForEach(store.categories) { category in
                    makeCategoryPill(category)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func makeCategoryPill(_ category: SuggestionCategory) -> some View {
        let isSelected = store.selectedCategory?.id == category.id

        Button {
            store.send(.categorySelected(category))
            HapticFeedback.medium()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                Text(category.name)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppTheme.practiceColor : Color(.systemGray5))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Suggestions Section

    @ViewBuilder
    private func makeSuggestionsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Pick a Suggestion")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    store.send(.refreshSuggestions)
                    HapticFeedback.medium()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "shuffle")
                        Text("Shuffle")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.practiceColor)
                }
            }
            .padding(.horizontal, 20)

            VStack(spacing: 12) {
                ForEach(store.currentSuggestions, id: \.self) { suggestion in
                    makeSuggestionCard(suggestion)
                }
            }
            .padding(.horizontal, 20)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.easeOut(duration: 0.3), value: store.selectedCategory?.id)
    }

    @ViewBuilder
    private func makeSuggestionCard(_ suggestion: String) -> some View {
        let isSelected = store.selectedSuggestion == suggestion

        Button {
            store.send(.suggestionSelected(suggestion))
            HapticFeedback.medium()
        } label: {
            HStack {
                Text(suggestion)
                    .font(.body)
                    .foregroundColor(isSelected ? .white : Color(.label))
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: isSelected ? "checkmark" : "chevron.right")
                    .foregroundColor(isSelected ? .white : Color(.secondaryLabel))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppTheme.practiceColor : Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    NavigationStack {
        RandomSuggestionView(
            store: Store(initialState: RandomSuggestionFeature.State(
                categories: SuggestionCategory.mockCategories,
                isLoadingCategories: false
            )) {
                RandomSuggestionFeature()
            }
        )
    }
}

#Preview("With Selection") {
    NavigationStack {
        RandomSuggestionView(
            store: Store(initialState: RandomSuggestionFeature.State(
                categories: SuggestionCategory.mockCategories,
                selectedCategory: SuggestionCategory.mockCategories.first,
                currentSuggestions: ["Dentist's Office", "Outer Space", "Medieval Castle"],
                isLoadingCategories: false
            )) {
                RandomSuggestionFeature()
            }
        )
    }
}
#endif
