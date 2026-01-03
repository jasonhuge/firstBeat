//
//  WarmUpDetailView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/1/26.
//

import SwiftUI
import ComposableArchitecture
import UIKit

struct WarmUpDetailView: View {
    @Bindable var store: StoreOf<WarmUpDetailFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.contentSpacing) {
                // Category badge
                HStack(spacing: Constants.badgeSpacing) {
                    Image(systemName: store.warmUp.category.icon)
                    Text(store.warmUp.category.rawValue)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, Constants.badgeTopPadding)

                // Description
                SectionView(title: "About") {
                    Text(store.warmUp.description)
                }

                // How to Play
                SectionView(title: "How to Play") {
                    Text(store.warmUp.howToPlay)
                }

                // Variations
                if !store.warmUp.variations.isEmpty {
                    SectionView(title: "Variations") {
                        VStack(alignment: .leading, spacing: Constants.listItemSpacing) {
                            ForEach(store.warmUp.variations, id: \.self) { variation in
                                HStack(alignment: .top, spacing: Constants.listItemContentSpacing) {
                                    Text("•")
                                        .fontWeight(.bold)
                                    Text(variation)
                                }
                            }
                        }
                    }
                }

                // Tips
                if !store.warmUp.tips.isEmpty {
                    SectionView(title: "Tips") {
                        VStack(alignment: .leading, spacing: Constants.listItemSpacing) {
                            ForEach(store.warmUp.tips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: Constants.listItemContentSpacing) {
                                    Text("💡")
                                    Text(tip)
                                }
                            }
                        }
                    }
                }

                // Mark as done button
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.prepare()
                    generator.impactOccurred()
                    store.send(.toggleCompleted)
                } label: {
                    HStack {
                        Image(systemName: store.isCompleted ? "checkmark.circle.fill" : "circle")
                        Text(store.isCompleted ? "Completed" : "Mark as Done")
                    }
                    .font(.headline)
                    .foregroundColor(store.isCompleted ? .white : AppTheme.warmUpColor)
                    .frame(maxWidth: .infinity)
                    .padding(Constants.buttonPadding)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                            .fill(store.isCompleted ? AppTheme.successColor : AppTheme.warmUpColor.opacity(Constants.buttonBackgroundOpacity))
                    )
                }
                .padding(.top, Constants.buttonTopPadding)
            }
            .padding(Constants.containerPadding)
        }
        .navigationTitle(store.warmUp.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Constants

extension WarmUpDetailView {
    enum Constants {
        static let contentSpacing: CGFloat = 24
        static let badgeSpacing: CGFloat = 6
        static let badgeTopPadding: CGFloat = 8
        static let listItemSpacing: CGFloat = 8
        static let listItemContentSpacing: CGFloat = 8
        static let buttonPadding: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 16
        static let buttonBackgroundOpacity: CGFloat = 0.1
        static let buttonTopPadding: CGFloat = 8
        static let containerPadding: CGFloat = 16
    }
}

// MARK: - Section View

struct SectionView<Content: View>: View {
    let title: String
    let content: () -> Content

    private static var spacing: CGFloat { 8 }

    var body: some View {
        VStack(alignment: .leading, spacing: Self.spacing) {
            Text(title)
                .font(.headline)

            content()
                .font(.body)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        WarmUpDetailView(
            store: Store(
                initialState: WarmUpDetailFeature.State(
                    warmUp: WarmUp(
                        name: "Zip Zap Zop",
                        category: .physical,
                        description: "A classic improv game that builds energy, focus, and group connection.",
                        howToPlay: "Stand in a circle. One person points to another and says 'Zip'.",
                        variations: ["Add physical gestures", "Speed up the pace"],
                        tips: ["Maintain eye contact", "Use your whole body"]
                    )
                )
            ) {
                WarmUpDetailFeature()
            }
        )
    }
}
