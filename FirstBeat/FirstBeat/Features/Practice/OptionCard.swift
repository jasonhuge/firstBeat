//
//  OptionCard.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/2/26.
//

import SwiftUI

struct OptionCardModel: Equatable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct OptionCard: View {
    let model: OptionCardModel
    let action: () -> Void

    @State private var hapticGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        Button(action: {
            hapticGenerator.impactOccurred()
            action()
        }) {
            HStack(spacing: Constants.contentSpacing) {
                Image(systemName: model.icon)
                    .font(.system(size: Constants.iconSize))
                    .foregroundColor(model.color)
                    .frame(width: Constants.iconFrameSize, height: Constants.iconFrameSize)
                    .background(
                        Circle()
                            .fill(model.color.opacity(Constants.iconBackgroundOpacity))
                    )

                VStack(alignment: .leading, spacing: Constants.textSpacing) {
                    Text(model.title)
                        .font(.headline)
                        .foregroundColor(Color(.label))

                    Text(model.subtitle)
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(Constants.shadowOpacity), radius: Constants.shadowRadius, y: Constants.shadowY)
            )
        }
        .onAppear {
            hapticGenerator.prepare()
        }
    }
}

// MARK: - Constants

extension OptionCard {
    enum Constants {
        static let contentSpacing: CGFloat = 16
        static let iconSize: CGFloat = 32
        static let iconFrameSize: CGFloat = 60
        static let iconBackgroundOpacity: CGFloat = 0.15
        static let textSpacing: CGFloat = 4
        static let cornerRadius: CGFloat = 16
        static let shadowOpacity: CGFloat = 0.08
        static let shadowRadius: CGFloat = 4
        static let shadowY: CGFloat = 2
    }
}

#Preview {
    OptionCard(model:
        .init(
            id: "getAiSuggestion",
            title: "Get AI Suggestion",
            subtitle: "Let AI inspire your practice",
            icon: "brain.head.profile",
            color: AppTheme.practiceColor
        )
    ) {

    }
}
