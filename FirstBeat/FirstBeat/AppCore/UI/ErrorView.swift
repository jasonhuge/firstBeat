//
//  ErrorView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/19/26.
//

import SwiftUI

struct ErrorView: View {
    let message: String?
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: Constants.contentSpacing) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: Constants.iconSize))
                .foregroundColor(.secondary)

            VStack(spacing: Constants.textSpacing) {
                Text(L10n.Error.unableToLoad)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(L10n.Error.checkConnection)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                if let message = message {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, Constants.errorMessageTopPadding)
                }
            }

            Button(action: {
                HapticFeedback.medium()
                onRetry()
            }) {
                Text(L10n.Button.tryAgain)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, Constants.buttonHorizontalPadding)
                    .padding(.vertical, Constants.buttonVerticalPadding)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                            .fill(Color.accentColor)
                    )
            }
            .padding(.top, Constants.buttonTopPadding)
        }
        .padding(Constants.contentPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Constants

extension ErrorView {
    enum Constants {
        static let contentSpacing: CGFloat = 16
        static let textSpacing: CGFloat = 8
        static let iconSize: CGFloat = 48
        static let errorMessageTopPadding: CGFloat = 4
        static let buttonHorizontalPadding: CGFloat = 24
        static let buttonVerticalPadding: CGFloat = 12
        static let buttonCornerRadius: CGFloat = 12
        static let buttonTopPadding: CGFloat = 8
        static let contentPadding: CGFloat = 32
    }
}

// MARK: - Preview

#Preview {
    ErrorView(
        message: "The operation couldn't be completed.",
        onRetry: {}
    )
}
