//
//  ThinkingView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import SwiftUI

struct ThinkingView: View {
    @State private var bounce = false

    var body: some View {
        HStack(spacing: Constants.dotSpacing) {
            ForEach(0..<Constants.dotCount, id: \.self) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: Constants.dotSize, height: Constants.dotSize)
                    .offset(y: bounce ? -Constants.bounceOffset : Constants.bounceOffset)
                    .animation(
                        Self.animation.delay(Double(index) * Constants.animationDelay),
                        value: bounce
                    )
            }
        }
        .onAppear {
            bounce.toggle()
        }
    }
}

// MARK: - Constants

extension ThinkingView {
    enum Constants {
        static let dotCount: Int = 3
        static let dotSpacing: CGFloat = 6
        static let dotSize: CGFloat = 8
        static let bounceOffset: CGFloat = 5
        static let animationDuration: CGFloat = 0.4
        static let animationDelay: CGFloat = 0.15
    }

    static var animation: Animation {
        .easeInOut(duration: Constants.animationDuration).repeatForever(autoreverses: true)
    }
}
