//
//  HomeView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/1/26.
//

import SwiftUI
import ComposableArchitecture
import UIKit

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    @State private var selectedCardID: HomeCard.ID?

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = Self.isLandscape(size: geometry.size)
            let cardWidth = Self.cardWidth(for: geometry.size, isLandscape: isLandscape)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Constants.cardSpacing) {
                        ForEach(store.cards) { card in
                            HomeCardView(
                                title: card.title,
                                description: card.description,
                                icon: card.icon,
                                color: card.color,
                                isLandscape: isLandscape
                            ) {
                                selectedCardID = card.id
                                store.send(.cardSelected(card))
                            }
                            .frame(width: cardWidth)
                            .id(card.id)
                        }
                    }
                    .padding(.horizontal, Constants.scrollViewHorizontalPadding)
                }
                .scrollTargetBehavior(.paging)
                .onChange(of: selectedCardID) { old, new in
                    guard let new else { return }
                    withAnimation(.spring()) {
                        proxy.scrollTo(new, anchor: .center)
                    }
                }
            }
        }
        .navigationTitle("First Beat")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Layout Calculations

extension HomeView {
    enum Constants {
        static let landscapeWidthMultiplier: CGFloat = 0.6
        static let landscapeMaxWidth: CGFloat = 500
        static let portraitPeekOffset: CGFloat = 60
        static let minimumCardWidth: CGFloat = 200
        static let cardSpacing: CGFloat = 16
        static let scrollViewHorizontalPadding: CGFloat = 20
    }

    static func isLandscape(size: CGSize) -> Bool {
        size.width > size.height
    }

    static func cardWidth(for size: CGSize, isLandscape: Bool) -> CGFloat {
        if isLandscape {
            return min(size.width * Constants.landscapeWidthMultiplier, Constants.landscapeMaxWidth)
        } else {
            return max(size.width - Constants.portraitPeekOffset, Constants.minimumCardWidth)
        }
    }
}

// MARK: - Home Card View

struct HomeCardView: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isLandscape: Bool
    let action: () -> Void

    @State private var hapticGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if !isLandscape {
                    Spacer()
                }

                Button(action: {
                    hapticGenerator.impactOccurred()
                    action()
                }) {
                    VStack(spacing: 0) {
                        // Icon section
                        VStack(spacing: Constants.iconSpacing) {
                            Spacer()

                            Image(systemName: icon)
                                .font(.system(size: Self.iconSize(isLandscape: isLandscape), weight: .light))
                                .foregroundColor(.white)

                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: Self.iconSectionHeight(isLandscape: isLandscape))
                        .background(color)

                        // Content section
                        VStack(alignment: .leading, spacing: Constants.contentSpacing) {
                            Text(title)
                                .font(isLandscape ? .title2 : .title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.label))

                            Text(description)
                                .font(isLandscape ? .subheadline : .body)
                                .foregroundColor(Color(.secondaryLabel))
                                .multilineTextAlignment(.leading)
                                .lineLimit(Self.descriptionLineLimit(isLandscape: isLandscape))
                        }
                        .padding(Self.contentPadding(isLandscape: isLandscape))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: Self.contentHeight(isLandscape: isLandscape))
                        .background(Color(.secondarySystemBackground))
                    }
                    .frame(height: Self.cardHeight(isLandscape: isLandscape))
                    .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                    .shadow(color: Color.black.opacity(Constants.shadowOpacity), radius: Constants.shadowRadius, y: Constants.shadowY)
                }
                .buttonStyle(.plain)

                if !isLandscape {
                    Spacer()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            hapticGenerator.prepare()
        }
    }
}

// MARK: - Layout Calculations

extension HomeCardView {
    enum Constants {
        static let cardHeightPortrait: CGFloat = 450
        static let cardHeightLandscape: CGFloat = 350
        static let iconSizePortrait: CGFloat = 72
        static let iconSizeLandscape: CGFloat = 56
        static let iconSectionHeightPortrait: CGFloat = 280
        static let iconSectionHeightLandscape: CGFloat = 200
        static let contentPaddingPortrait: CGFloat = 24
        static let contentPaddingLandscape: CGFloat = 20
        static let contentHeightPortrait: CGFloat = 170
        static let contentHeightLandscape: CGFloat = 150
        static let descriptionLineLimitPortrait: Int = 3
        static let descriptionLineLimitLandscape: Int = 2
        static let iconSpacing: CGFloat = 16
        static let contentSpacing: CGFloat = 12
        static let cornerRadius: CGFloat = 24
        static let shadowOpacity: CGFloat = 0.1
        static let shadowRadius: CGFloat = 12
        static let shadowY: CGFloat = 6
    }

    static func cardHeight(isLandscape: Bool) -> CGFloat {
        isLandscape ? Constants.cardHeightLandscape : Constants.cardHeightPortrait
    }

    static func iconSize(isLandscape: Bool) -> CGFloat {
        isLandscape ? Constants.iconSizeLandscape : Constants.iconSizePortrait
    }

    static func iconSectionHeight(isLandscape: Bool) -> CGFloat {
        isLandscape ? Constants.iconSectionHeightLandscape : Constants.iconSectionHeightPortrait
    }

    static func contentPadding(isLandscape: Bool) -> CGFloat {
        isLandscape ? Constants.contentPaddingLandscape : Constants.contentPaddingPortrait
    }

    static func contentHeight(isLandscape: Bool) -> CGFloat {
        isLandscape ? Constants.contentHeightLandscape : Constants.contentHeightPortrait
    }

    static func descriptionLineLimit(isLandscape: Bool) -> Int {
        isLandscape ? Constants.descriptionLineLimitLandscape : Constants.descriptionLineLimitPortrait
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        HomeView(
            store: Store(initialState: HomeFeature.State()) {
                HomeFeature()
            }
        )
    }
}
