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

struct SessionView: View {
    @Bindable var store: StoreOf<SessionFeature>

    @State private var showConfetti: Bool = false
    @State private var pulse: Bool = false
    @State private var showSessionInfo: Bool = false

    var body: some View {
        GeometryReader { geo in
            let isLandscape = Self.isLandscape(size: geo.size)

            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    timerArea

                    Spacer()

                    if !isLandscape && store.currentSegmentIndex < store.segments.count {
                        playPauseButton
                            .padding(.bottom, Constants.playButtonBottomPadding)
                    } else if !isLandscape {
                        Spacer()
                            .frame(height: Constants.placeholderSpacerHeight)
                    }
                }
            }
            .navigationTitle(store.sessionType.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if case .format = store.sessionType {
                        infoButton
                    }
                    if isLandscape && store.currentSegmentIndex < store.segments.count {
                        toolbarPlayPauseButton
                    }
                }
            }
            .sheet(isPresented: $showSessionInfo) {
                sessionInfoSheet
            }
            .onChange(of: store.timerRunning) { _, newValue in
                UIApplication.shared.isIdleTimerDisabled = newValue
            }
            .onChange(of: store.showConfetti) { _, newValue in
                if newValue {
                    showConfetti = true
                    playCompletionChime()
                }
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
}

// MARK: - Layout Calculations

extension SessionView {
    enum Constants {
        static let playButtonSize: CGFloat = 80
        static let playButtonIconSize: CGFloat = 32
        static let playButtonShadowOpacity: CGFloat = 0.16
        static let playButtonShadowRadius: CGFloat = 8
        static let playButtonShadowY: CGFloat = 4
        static let playButtonScaleRunning: CGFloat = 1.0
        static let playButtonScalePaused: CGFloat = 1.12
        static let playButtonAnimationResponse: CGFloat = 0.4
        static let playButtonAnimationDamping: CGFloat = 0.7
        static let playButtonBottomPadding: CGFloat = 40
        static let placeholderSpacerHeight: CGFloat = 80

        static let timerSpacing: CGFloat = 24
        static let preshowSpacing: CGFloat = 8
        static let preshowCountdownFontSize: CGFloat = 72
        static let preshowShadowOpacity: CGFloat = 0.25
        static let preshowShadowRadius: CGFloat = 8
        static let preshowAnimationDuration: CGFloat = 0.2

        static let segmentSpacing: CGFloat = 16
        static let segmentLabelHorizontalPadding: CGFloat = 20
        static let segmentLabelVerticalPadding: CGFloat = 12
        static let segmentLabelOpacity: CGFloat = 0.2
        static let segmentLabelMinimumScaleFactor: CGFloat = 0.5
        static let timerFontSize: CGFloat = 92

        static let progressBarOpacity: CGFloat = 0.25
        static let progressBarHeight: CGFloat = 20
        static let progressBarPulseScale: CGFloat = 1.05
        static let progressBarAnimationDuration: CGFloat = 0.4

        static let completePaddingVertical: CGFloat = 20
    }

    static func isLandscape(size: CGSize) -> Bool {
        size.width > size.height
    }

    static func playButtonScale(isRunning: Bool) -> CGFloat {
        isRunning ? Constants.playButtonScaleRunning : Constants.playButtonScalePaused
    }
}

// MARK: - Components
extension SessionView {

    private var playPauseButton: some View {
        Button {
            HapticFeedback.medium()
            withAnimation {
                _ = store.send(.togglePlayPause)
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: Constants.playButtonSize, height: Constants.playButtonSize)
                    .shadow(color: .black.opacity(Constants.playButtonShadowOpacity),
                           radius: Constants.playButtonShadowRadius,
                           y: Constants.playButtonShadowY)

                Image(systemName: store.timerRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: Constants.playButtonIconSize))
                    .foregroundColor(.white)
            }
            .scaleEffect(Self.playButtonScale(isRunning: store.timerRunning))
            .animation(.spring(response: Constants.playButtonAnimationResponse,
                             dampingFraction: Constants.playButtonAnimationDamping),
                       value: store.timerRunning)
        }
    }

    private var toolbarPlayPauseButton: some View {
        Button {
            HapticFeedback.medium()
            withAnimation {
                _ = store.send(.togglePlayPause)
            }
        } label: {
            Image(systemName: store.timerRunning ? "pause.circle.fill" : "play.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
        }
    }

    private var infoButton: some View {
        Button {
            showSessionInfo = true
        } label: {
            Image(systemName: "info.circle")
                .font(.title3)
                .foregroundColor(AppTheme.practiceColor)
        }
    }

    @ViewBuilder
    private var sessionInfoSheet: some View {
        if case .format(let title, let format, let opening, let duration) = store.sessionType {
            SessionInfoSheet(
                suggestion: title,
                format: format,
                opening: opening,
                duration: duration
            )
        }
    }

    private var timerArea: some View {
        VStack(spacing: Constants.timerSpacing) {

            // Pre-show countdown
            if store.showPreshowCountdown {
                VStack(spacing: Constants.preshowSpacing) {
                    Text("Get Ready")
                        .font(.title2)
                        .foregroundColor(AppTheme.warmUpColor)
                    Text("\(store.preshowCountdown)")
                        .font(.system(size: Constants.preshowCountdownFontSize, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.warmUpColor)
                        .shadow(color: AppTheme.warmUpColor.opacity(Constants.preshowShadowOpacity),
                               radius: Constants.preshowShadowRadius)
                }
                .onChange(of: store.preshowCountdown) { _, _ in
                    playTick()
                    withAnimation(.easeInOut(duration: Constants.preshowAnimationDuration)) {
                        pulse.toggle()
                    }
                }
            }

            // Current segment timer
            else if store.currentSegmentIndex < store.segments.count {
                VStack(spacing: Constants.segmentSpacing) {
                    Text(store.segments[store.currentSegmentIndex].title)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.horizontal, Constants.segmentLabelHorizontalPadding)
                        .padding(.vertical, Constants.segmentLabelVerticalPadding)
                        .background(Capsule().fill(AppTheme.practiceColor.opacity(Constants.segmentLabelOpacity)))
                        .foregroundColor(AppTheme.practiceColor)
                        .minimumScaleFactor(Constants.segmentLabelMinimumScaleFactor)

                    Text(timeString(store.elapsedTime))
                        .font(.system(size: Constants.timerFontSize, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.gray.opacity(Constants.progressBarOpacity))
                            Capsule()
                                .fill(AppTheme.practiceColor)
                                .frame(width: geo.size.width * progress())
                                .scaleEffect(pulse ? Constants.progressBarPulseScale : 1.0)
                                .animation(.easeInOut(duration: Constants.progressBarAnimationDuration).repeatForever(autoreverses: true),
                                           value: pulse)
                        }
                    }
                    .frame(height: Constants.progressBarHeight)
                }
                .padding()
                .onChange(of: store.currentSegmentIndex) { _, _ in
                    playSegmentChime()
                }
            }

            // Complete
            else {
                ZStack {
                    Text(store.sessionType.completionMessage)
                        .font(.title)
                        .foregroundColor(AppTheme.successColor)
                        .padding(.vertical, Constants.completePaddingVertical)

                    ConfettiCannon(trigger: $showConfetti)
                }
            }
        }
    }

    private func progress() -> CGFloat {
        guard store.currentSegmentIndex < store.segments.count else { return 0 }
        let total = store.segments[store.currentSegmentIndex].duration(from: store.duration)
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

    private func playCompletionChime() {
        HapticFeedback.success()
        AudioServicesPlaySystemSound(1025) // Triple ascending bell
    }
}

// MARK: - Session Info Sheet
struct SessionInfoSheet: View {
    @Environment(\.dismiss) var dismiss

    let suggestion: String?
    let format: FormatType
    let opening: Opening
    let duration: Int

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Suggestion
                    if let suggestion = suggestion, !suggestion.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Suggestion")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(suggestion)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }

                    // Format
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Format")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(format.title)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(format.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    // Opening
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Opening")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(opening.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(opening.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    // Duration
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Duration")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(duration) minutes")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }

                    // Segments
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Segments")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        ForEach(format.segments) { segment in
                            HStack {
                                Text(segment.title)
                                    .font(.body)
                                Spacer()
                                Text(segment.stringDuration(duration))
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}


#if DEBUG
#Preview {
    NavigationView {
        SessionView(store: Store(
            initialState: SessionFeature.State(
                sessionType: .format(
                    title: "A Happy Clam",
                    format: .mock,
                    opening: .mock,
                    duration: 2
                )
            ), reducer: {
                SessionFeature()
            }
        ))
    }
}
#endif
