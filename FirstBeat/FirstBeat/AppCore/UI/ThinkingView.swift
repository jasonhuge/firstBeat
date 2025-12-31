//
//  ThinkingView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import SwiftUI

struct ThinkingView: View {
    @State private var bounce = false
    let dotCount = 3
    let animation = Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true)

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .offset(y: bounce ? -5 : 5)
                    .animation(
                        animation.delay(Double(index) * 0.15),
                        value: bounce
                    )
            }
        }
        .onAppear {
            bounce.toggle()
        }
    }
}
