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

    var body: some View {
        GeometryReader { geo in
            let isLandscape = Self.isLandscape(size: geo.size)

            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    ZStack {
                        if !store.showTimerUI {
                            GeometryReader { scrollGeo in
                                ScrollView {
                                    VStack {
                                        Spacer(minLength: 0)
                                        SessionSummaryCard(
                                            suggestion: store.title,
                                            format: store.format,
                                            opening: store.opening,
                                            duration: store.duration
                                        )
                                        Spacer(minLength: 0)
                                    }
                                    .padding(.horizontal)
                                    .frame(minHeight: scrollGeo.size.height)
                                }
                            }
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

                    Spacer()

                    if !isLandscape && store.currentSegmentIndex < store.format.segments.count {
                        playPauseButton
                            .padding(.bottom, Constants.playButtonBottomPadding)
                    } else if !isLandscape {
                        Spacer()
                            .frame(height: Constants.placeholderSpacerHeight)
                    }
                }
            }
            .navigationTitle(store.title ?? "\(store.format.title) Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isLandscape && store.currentSegmentIndex < store.format.segments.count {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        toolbarPlayPauseButton
                    }
                }
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
            else if store.currentSegmentIndex < store.format.segments.count {
                VStack(spacing: Constants.segmentSpacing) {
                    Text(store.format.segments[store.currentSegmentIndex].title)
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
                .onChange(of: store.currentSegmentIndex) { _, _ in
                    playSegmentChime()
                }
            }

            // Complete
            else {
                ZStack {
                    Text("\(store.format.name) complete!")
                        .font(.title)
                        .foregroundColor(AppTheme.successColor)
                        .padding(.vertical, Constants.completePaddingVertical)

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
    let suggestion: String?
    let format: FormatType
    let opening: Opening
    let duration: Int

    @State private var showFormatInfo = false
    @State private var showOpeningInfo = false

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.cardSpacing) {

            // Suggestion
            if let suggestion = suggestion, !suggestion.isEmpty {
                Text("Suggestion: \(suggestion)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.label))
                    .multilineTextAlignment(.leading)
            } else {
                Text("Free Practice")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.label))
                    .multilineTextAlignment(.leading)
            }

            Divider()

            // Metadata - Vertical Stack
            VStack(alignment: .leading, spacing: Constants.metadataSpacing) {
                MetadataRow(
                    icon: "theatermasks",
                    text: format.title,
                    showInfo: true,
                    onInfoTap: { showFormatInfo = true }
                )
                MetadataRow(
                    icon: "star.circle",
                    text: opening.name,
                    showInfo: true,
                    onInfoTap: { showOpeningInfo = true }
                )
                MetadataRow(
                    icon: "clock",
                    text: "\(duration) min",
                    showInfo: false
                )
            }

            Divider()

            // Segment breakdown
            VStack(alignment: .leading, spacing: Constants.segmentBreakdownSpacing) {
                Text("Segments")
                    .font(.subheadline)
                    .fontWeight(.medium)

                ForEach(format.segments) { segment in
                    HStack {
                        Text(segment.title)
                            .foregroundColor(Color(.label))
                        Spacer()
                        Text(segment.stringDuration(duration))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    .font(.footnote)
                }
            }
        }
        .padding(Constants.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(Constants.cardShadowOpacity), radius: Constants.cardShadowRadius, y: Constants.cardShadowY)
        )
        .sheet(isPresented: $showFormatInfo) {
            InfoSheet(
                title: format.title,
                description: format.description,
                icon: "theatermasks"
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showOpeningInfo) {
            InfoSheet(
                title: opening.name,
                description: opening.description,
                icon: "star.circle"
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Metadata Row Component
private struct MetadataRow: View {
    let icon: String
    let text: String
    let showInfo: Bool
    var onInfoTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Constants.spacing) {
            Label {
                Text(text)
                    .font(.subheadline)
            } icon: {
                Image(systemName: icon)
                    .frame(width: SessionSummaryCard.Constants.iconWidth)
            }
            .foregroundColor(Color(.secondaryLabel))

            if showInfo {
                Button(action: {
                    onInfoTap?()
                }) {
                    Image(systemName: "info.circle")
                        .font(.subheadline)
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
        }
    }

    enum Constants {
        static let spacing: CGFloat = 8
    }
}

// MARK: - Info Sheet
private struct InfoSheet: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    let description: String
    let icon: String

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.contentSpacing) {
                    HStack {
                        Image(systemName: icon)
                            .font(.largeTitle)
                            .foregroundColor(AppTheme.practiceColor)

                        Text(title)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .padding(.bottom, Constants.titleBottomPadding)

                    Text(description)
                        .font(.body)
                        .foregroundColor(Color(.label))
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    enum Constants {
        static let contentSpacing: CGFloat = 16
        static let titleBottomPadding: CGFloat = 8
    }
}

// MARK: - Constants
extension SessionSummaryCard {
    enum Constants {
        static let cardSpacing: CGFloat = 16
        static let metadataSpacing: CGFloat = 12
        static let segmentBreakdownSpacing: CGFloat = 8
        static let cardPadding: CGFloat = 16
        static let cardCornerRadius: CGFloat = 20
        static let cardShadowOpacity: CGFloat = 0.10
        static let cardShadowRadius: CGFloat = 6
        static let cardShadowY: CGFloat = 3
        static let iconWidth: CGFloat = 20
    }
}


#Preview {
    NavigationView {
        SessionView(store: Store(
            initialState: SessionFeature.State(
                title: "A Happy Clam",
                format: .mock,
                opening: .mock,
                duration: 2
            ), reducer: {
                SessionFeature()
            }
        ))
    }
}
