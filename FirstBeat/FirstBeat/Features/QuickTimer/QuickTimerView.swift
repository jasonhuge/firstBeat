//
//  QuickTimerView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/11/26.
//

import SwiftUI
import ComposableArchitecture
import AudioToolbox

struct QuickTimerView: View {
    @Bindable var store: StoreOf<QuickTimerFeature>

    @State private var lastValue: Int = 0
    @State private var animateTick: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    // Show suggestion if present
                    if let suggestion = store.suggestion {
                        Text("\"\(suggestion)\"")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                    }

                    Text("How long are we playing?")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)

                    // Duration card
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(store.duration) minutes")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.label))
                                .scaleEffect(animateTick ? 1.05 : 1.0)
                                .opacity(animateTick ? 0.85 : 1.0)
                                .animation(.easeOut(duration: 0.15), value: animateTick)

                            Text(store.duration.durationDescriptor)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Slider(
                            value: Binding(
                                get: { Double(store.duration) },
                                set: { newValue in
                                    let intValue = Int(newValue)
                                    if intValue != lastValue {
                                        HapticFeedback.selection()
                                        AudioServicesPlaySystemSound(1104)
                                        lastValue = intValue
                                        animateTick.toggle()
                                    }
                                    store.send(.durationChanged(intValue))
                                }
                            ),
                            in: 5...60,
                            step: 5
                        )
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    )
                    .padding(.horizontal, 16)
                }
                .padding(.top, 24)
            }

            // Start button
            Button {
                store.send(.startTapped)
                HapticFeedback.medium()
            } label: {
                Text("Start")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppTheme.practiceColor)
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .navigationTitle("Freeform")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            lastValue = store.duration
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    NavigationStack {
        QuickTimerView(
            store: Store(initialState: QuickTimerFeature.State()) {
                QuickTimerFeature()
            }
        )
    }
}
#endif
