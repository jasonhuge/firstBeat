//
//  Sessionview.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import SwiftUI
import ComposableArchitecture
import ConfettiSwiftUI
import AudioToolbox
import UIKit

struct PracticeView: View {
    @Bindable var store: StoreOf<SessionFeature>

    @State private var showConfetti: Bool = false
    @State private var pulse: Bool = false
    @State private var impactGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                if isLandscape {
                    // Landscape layout: split horizontally
                    HStack(spacing: 24) {
                        VStack(spacing: 32) {
                            timerArea
                            if store.currentSegmentIndex < store.format.segments.count {
                                playPauseButton
                            }
                        }
                        .frame(width: geo.size.width * 0.55)

                        ScrollView {
                            SessionSummaryCard(
                                suggestion: store.title,
                                format: store.format,
                                duration: store.duration
                            )
                        }
                        .frame(width: geo.size.width * 0.4)
                    }
                    .padding(.horizontal)
                } else {
                    // Portrait layout
                    VStack(spacing: 32) {
                        ZStack {
                            if !store.showTimerUI {
                                SessionSummaryCard(
                                    suggestion: store.title,
                                    format: store.format,
                                    duration: store.duration
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                                .zIndex(store.showTimerUI ? 0 : 1)
                            }

                            if store.showTimerUI {
                                timerArea
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .move(edge: .bottom).combined(with: .opacity)
                                    ))
                                    .zIndex(store.showTimerUI ? 1 : 0)
                            }
                        }

                        if store.currentSegmentIndex < store.format.segments.count {
                            playPauseButton
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 0)
                }
            }
            .navigationTitle("\(store.format.title) Time")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                impactGenerator.prepare()
            }
            .onChange(of: store.timerRunning) { _, newValue in
                UIApplication.shared.isIdleTimerDisabled = newValue
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
}

// MARK: - Components
extension PracticeView {

    private var playPauseButton: some View {
        Button {
            // Haptic feedback for button press
            impactGenerator.impactOccurred()
            withAnimation {
                _ = store.send(.togglePlayPause)
            }
        } label: {
            ZStack {
                Circle()
                    .fill(store.timerRunning ? Color.blue : Color.green)
                    .frame(width: 80, height: 80)
                    .shadow(color: .black.opacity(0.16), radius: 8, y: 4)

                Image(systemName: store.timerRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            .scaleEffect(store.timerRunning ? 1.0 : 1.12)
            .animation(.spring(response: 0.4, dampingFraction: 0.7),
                       value: store.timerRunning)
        }
    }

    private var timerArea: some View {
        VStack(spacing: 24) {

            // Pre-show countdown
            if store.showPreshowCountdown {
                VStack(spacing: 8) {
                    Text("Get Ready")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("\(store.preshowCountdown)")
                        .font(.system(size: 72, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                        .shadow(color: .orange.opacity(0.25), radius: 8)
                }
                .onChange(of: store.preshowCountdown) { _, _ in
                    playTick()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        pulse.toggle()
                    }
                }
            }

            // Current segment timer
            else if store.currentSegmentIndex < store.format.segments.count {
                VStack(spacing: 16) {
                    Text(store.format.segments[store.currentSegmentIndex].title)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.blue.opacity(0.2)))
                        .foregroundColor(.blue)
                        .minimumScaleFactor(0.5)

                    Text(timeString(store.elapsedTime))
                        .font(.system(size: 92, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.gray.opacity(0.25))
                            Capsule()
                                .fill(Color.blue)
                                .frame(width: geo.size.width * progress())
                                .scaleEffect(pulse ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true),
                                           value: pulse)
                        }
                    }
                    .frame(height: 20)
                }
                .onChange(of: store.currentSegmentIndex) { _, _ in
                    playSegmentChime()
                }
            }

            // Complete
            else {
                ZStack {
                    Text("\(store.format.name) complete!")
                        .font(.title)
                        .foregroundColor(.green)
                        .padding(.vertical, 20)

                    ConfettiCannon(trigger: $showConfetti)
                }
            }
        }
    }

    private func progress() -> CGFloat {
        guard store.currentSegmentIndex < store.format.segments.count else { return 0 }
        let total = store.format.segments[store.currentSegmentIndex].duration(from: store.duration)
        return CGFloat(store.remainingTime) / CGFloat(total)
    }

    private func timeString(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", minutes, s)
    }

    // MARK: - Audio / Haptic
    private func playTick() {
        AudioServicesPlaySystemSound(1104) // Tick sound
    }

    private func playSegmentChime() {
        AudioServicesPlaySystemSound(1151) // Chime / short bell
    }
}

// MARK: - Practice Summary Card
struct SessionSummaryCard: View {
    let suggestion: String
    let format: FormatType
    let duration: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Suggestion
            Text("Suggestion: \(suggestion)")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)

            // Metadata row
            HStack(spacing: 16) {
                Label(format.title, systemImage: "theatermasks")
                Spacer()
                Label("\(duration) min", systemImage: "clock")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Divider()

            // Format description
            Text(format.description)
                .font(.body)

            // Segment breakdown
            VStack(alignment: .leading, spacing: 8) {
                ForEach(format.segments) { segment in
                    HStack {
                        Text(segment.title)
                        Spacer()
                        Text(segment.stringDuration(duration))
                            .foregroundStyle(.secondary)
                    }
                    .font(.footnote)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.10), radius: 6, y: 3)
        )
    }
}


#Preview {
    NavigationView {
        PracticeView(store: Store(
            initialState: SessionFeature.State(
                title: "A Happy Clam",
                format: .harold,
                duration: 2
            ), reducer: {
                SessionFeature()
            }
        ))
    }
}
