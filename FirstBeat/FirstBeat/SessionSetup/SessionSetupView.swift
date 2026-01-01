//
//  SessionSetupView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import SwiftUI
import ComposableArchitecture
import UIKit

struct SessionSetupView: View {
    @Bindable
    var store: StoreOf<SessionSetupFeature>

    @State
    private var impactGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        VStack(spacing: 0) {

            ScrollView {
                VStack(spacing: 32) {

                    SuggestionCard(
                        suggestion: store.suggestion
                    )

                    FormatTypePills(
                        formats: FormatType.allCases,
                        selected: store.selectedType
                    ) {
                        store.send(.typeSelected($0))
                    }

                    DurationSection(
                        totalDuration: store.totalDuration
                    ) {
                        store.send(.durationChanged($0))
                    }
                }
                .padding(.top, 24)
            }

            StartButton {
                store.send(.startSelected)
                impactGenerator.impactOccurred()
            }
        }
        .navigationTitle("Set the Show")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            impactGenerator.prepare()
        }
    }
}

// MARK: - Suggestion Card

struct SuggestionCard: View {
    let suggestion: String

    var body: some View {
        if !suggestion.isEmpty {
            VStack(alignment: .leading, spacing: 12) {

                Text("Suggestion")
                    .font(.headline)

                Text(suggestion)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Practice Type Pills

struct FormatTypePills: View {
    let formats: [FormatType]
    let selected: FormatType
    let onSelect: (FormatType) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Format")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(formats) { format in
                        Button {
                            onSelect(format)
                        } label: {
                            Text(format.title)
                                .fontWeight(.semibold)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            selected.id == format.id
                                            ? Color.blue
                                            : Color(.systemGray5)
                                        )
                                )
                                .foregroundStyle(
                                    selected.id == format.id
                                    ? Color.white
                                    : Color.primary
                                )
                        }
                        .animation(.easeInOut(duration: 0.2), value: selected.id)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Duration Section

struct DurationSection: View {
    let totalDuration: Int
    let onChange: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("How long are we playing?")
                .font(.headline)
                .padding(.horizontal)

            DurationCard(
                totalDuration: totalDuration,
                onChange: onChange
            )
        }
    }
}

// MARK: - Duration Card (Animated Label + Haptics)

import AudioToolbox

struct DurationCard: View {
    let totalDuration: Int
    let onChange: (Int) -> Void

    @State private var lastValue: Int = 0
    @State private var animateTick: Bool = false
    private let feedback = UISelectionFeedbackGenerator()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            VStack(alignment: .leading, spacing: 4) {

                Text("\(totalDuration) minutes")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .scaleEffect(animateTick ? 1.05 : 1.0)
                    .opacity(animateTick ? 0.85 : 1.0)
                    .animation(.easeOut(duration: 0.15), value: animateTick)

                Text(durationDescriptor)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: Binding(
                    get: { Double(totalDuration) },
                    set: { newValue in
                        let intValue = Int(newValue)

                        if intValue != lastValue {
                            feedback.selectionChanged()
                            playTick()
                            lastValue = intValue
                            animateTick.toggle()
                        }

                        onChange(intValue)
                    }
                ),
                in: 5...60,
                step: 5
            )
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
        .onAppear {
            feedback.prepare()
            lastValue = totalDuration
        }
    }

    private func playTick() {
        AudioServicesPlaySystemSound(1104)
    }

    private var durationDescriptor: String {
        switch totalDuration {
        case 5...15:
            return "Short set — quick and punchy"
        case 20...35:
            return "Medium set — find the game"
        default:
            return "Long set — let it breathe"
        }
    }
}


// MARK: - Start Button

struct StartButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Let’s Begin")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue)
                )
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SessionSetupView(
            store: Store(
                initialState: SessionSetupFeature.State(
                    suggestion: "A king salmon who refuses the call to adventure"
                ),
                reducer: {
                    SessionSetupFeature()
                }
            )
        )
    }
}
