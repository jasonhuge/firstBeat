//
//  WarmUpListView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/1/26.
//

import SwiftUI
import ComposableArchitecture
import UIKit

struct WarmUpListView: View {
    @Bindable var store: StoreOf<WarmUpListFeature>

    var body: some View {
        VStack(spacing: 0) {
            if store.isLoading {
                WarmUpLoadingView()
            } else {
                // Category filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Constants.categoryPillSpacing) {
                        CategoryPill(
                            category: nil,
                            isSelected: store.selectedCategory == nil
                        ) {
                            store.send(.categorySelected(nil))
                        }

                        ForEach(WarmUpCategory.allCases) { category in
                            CategoryPill(
                                category: category,
                                isSelected: store.selectedCategory == category
                            ) {
                                store.send(.categorySelected(category))
                            }
                        }
                    }
                    .padding(.horizontal, Constants.categoryScrollHorizontalPadding)
                    .padding(.vertical, Constants.categoryScrollVerticalPadding)
                }
                .background(Color(.systemBackground))

                // Warm-up list
                List {
                    // Favorites section
                    if !store.favorites.isEmpty {
                        Section {
                            ForEach(store.favorites) { warmUp in
                                WarmUpRow(
                                    warmUp: warmUp,
                                    isFavorite: true,
                                    onSelect: { store.send(.warmUpSelected(warmUp)) }
                                )
                            }
                        } header: {
                            SectionHeaderView(title: "Favorites")
                        }
                    }

                    // All warm-ups section
                    Section {
                        ForEach(store.filteredWarmUps) { warmUp in
                            WarmUpRow(
                                warmUp: warmUp,
                                isFavorite: store.favoriteWarmUpNames.contains(warmUp.name),
                                onSelect: { store.send(.warmUpSelected(warmUp)) }
                            )
                        }
                    } header: {
                        if !store.favorites.isEmpty {
                            SectionHeaderView(title: "All Warm-ups")
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Warm-ups")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - Constants

extension WarmUpListView {
    enum Constants {
        static let categoryPillSpacing: CGFloat = 12
        static let categoryScrollHorizontalPadding: CGFloat = 16
        static let categoryScrollVerticalPadding: CGFloat = 12
    }
}

// MARK: - Warm-Up Row

struct WarmUpRow: View {
    let warmUp: WarmUp
    let isFavorite: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Constants.rowSpacing) {
                // Category icon
                Image(systemName: warmUp.category.icon)
                    .font(.system(size: Constants.categoryIconSize))
                    .foregroundColor(AppTheme.warmUpColor)
                    .frame(width: Constants.categoryIconFrameWidth)

                VStack(alignment: .leading, spacing: Constants.textSpacing) {
                    Text(warmUp.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(warmUp.category.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppTheme.warmUpColor)
                        .font(.system(size: Constants.starIconSize))
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: Constants.chevronIconSize))
            }
            .padding(.vertical, Constants.rowVerticalPadding)
        }
    }
}

// MARK: - Constants

extension WarmUpRow {
    enum Constants {
        static let rowSpacing: CGFloat = 12
        static let categoryIconSize: CGFloat = 20
        static let categoryIconFrameWidth: CGFloat = 30
        static let textSpacing: CGFloat = 4
        static let starIconSize: CGFloat = 20
        static let chevronIconSize: CGFloat = 14
        static let rowVerticalPadding: CGFloat = 4
    }
}

// MARK: - Section Header

struct SectionHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
            .textCase(nil)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.verticalPadding)
            .background(Color(.systemBackground))
    }
}

extension SectionHeaderView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 8
    }
}

// MARK: - Category Pill

struct CategoryPill: View {
    let category: WarmUpCategory?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.spacing) {
                if let category = category {
                    Image(systemName: category.icon)
                        .font(.system(size: Constants.iconSize))
                    Text(category.rawValue)
                } else {
                    Text("All")
                }
            }
            .fontWeight(.semibold)
            .font(.subheadline)
            .padding(.vertical, Constants.verticalPadding)
            .padding(.horizontal, Constants.horizontalPadding)
            .background(
                Capsule()
                    .fill(isSelected ? AppTheme.warmUpColor : Color(.systemGray5))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// MARK: - Constants

extension CategoryPill {
    enum Constants {
        static let spacing: CGFloat = 6
        static let iconSize: CGFloat = 14
        static let verticalPadding: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
    }
}

// MARK: - Loading View

struct WarmUpLoadingView: View {
    var body: some View {
        VStack(spacing: Constants.spacing) {
            ProgressView()
                .scaleEffect(Constants.progressViewScale)
            Text("Loading warm-ups...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Constants

extension WarmUpLoadingView {
    enum Constants {
        static let spacing: CGFloat = 16
        static let progressViewScale: CGFloat = 1.5
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        WarmUpListView(
            store: Store(initialState: WarmUpListFeature.State()) {
                WarmUpListFeature()
            }
        )
    }
}
