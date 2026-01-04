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

    var body: some View {
        VStack(spacing: 0) {

            if store.isLoading {
                LoadingView()
            } else {
                ScrollView {
                    VStack(spacing: Constants.contentSpacing) {

                        SuggestionCard(
                            suggestion: store.suggestion
                        )

                        if let selectedType = store.selectedType {
                            FormatTypePills(
                                formats: store.formats,
                                selected: selectedType
                            ) {
                                store.send(.typeSelected($0))
                            }
                        }

                        if !store.availableOpenings.isEmpty {
                            OpeningSection(
                                openings: store.availableOpenings,
                                selected: store.selectedOpening
                            ) {
                                store.send(.openingSelected($0))
                            }
                        }

                        DurationSection(
                            totalDuration: store.totalDuration
                        ) {
                            store.send(.durationChanged($0))
                        }
                    }
                    .padding(.top, Constants.contentTopPadding)
                }

                StartButton {
                    store.send(.startSelected)
                    HapticFeedback.medium()
                }
            }
        }
        .navigationTitle("Set the Show")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - Constants

extension SessionSetupView {
    enum Constants {
        static let contentSpacing: CGFloat = 32
        static let contentTopPadding: CGFloat = 24
    }
}

// MARK: - Suggestion Card

struct SuggestionCard: View {
    let suggestion: String?

    var body: some View {
        if let suggestion = suggestion, !suggestion.isEmpty {
            VStack(alignment: .leading, spacing: Constants.spacing) {

                Text("Suggestion")
                    .font(.headline)

                Text(suggestion)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.label))
                    .padding(Constants.textPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .fill(Color(.secondarySystemBackground))
                            .shadow(color: .black.opacity(Constants.shadowOpacity), radius: Constants.shadowRadius, y: Constants.shadowY)
                    )
            }
            .padding(.horizontal, Constants.horizontalPadding)
        }
    }
}

// MARK: - Constants

extension SuggestionCard {
    enum Constants {
        static let spacing: CGFloat = 12
        static let textPadding: CGFloat = 12
        static let cornerRadius: CGFloat = 16
        static let shadowOpacity: CGFloat = 0.08
        static let shadowRadius: CGFloat = 4
        static let shadowY: CGFloat = 2
        static let horizontalPadding: CGFloat = 16
    }
}

// MARK: - Flow Layout Helper

struct FlowLayout: Layout {
    var spacing: CGFloat = 12

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var size: CGSize = .zero
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)

                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, subviewSize.height)
                currentX += subviewSize.width + spacing
                size.width = max(size.width, currentX - spacing)
            }

            size.height = currentY + lineHeight
            self.size = size
            self.positions = positions
        }
    }
}

// MARK: - Practice Type Pills

struct FormatTypePills: View {
    let formats: [FormatType]
    let selected: FormatType
    let onSelect: (FormatType) -> Void

    @State private var showingInfo: FormatType?

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.vStackSpacing) {

            Text("Format")
                .font(.headline)
                .padding(.horizontal, Constants.horizontalPadding)

            FlowLayout(spacing: Constants.flowSpacing) {
                ForEach(formats) { format in
                    FormatPillButton(
                        format: format,
                        isSelected: selected.id == format.id,
                        onSelect: { onSelect(format) },
                        onInfo: { showingInfo = format }
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Constants.horizontalPadding)
        }
        .sheet(item: $showingInfo) { format in
            FormatInfoSheet(format: format)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Constants

extension FormatTypePills {
    enum Constants {
        static let vStackSpacing: CGFloat = 12
        static let flowSpacing: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
    }
}

// MARK: - Format Pill Button

struct FormatPillButton: View {
    let format: FormatType
    let isSelected: Bool
    let onSelect: () -> Void
    let onInfo: () -> Void

    var body: some View {
        HStack(spacing: Constants.spacing) {
            Button(action: onSelect) {
                Text(format.title)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }

            Button(action: {
                HapticFeedback.light()
                onInfo()
            }) {
                Image(systemName: "info.circle")
                    .font(.system(size: Constants.iconSize))
            }
        }
        .padding(.vertical, Constants.verticalPadding)
        .padding(.horizontal, Constants.horizontalPadding)
        .background(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(isSelected ? AppTheme.practiceColor : Color(.systemGray5))
        )
        .foregroundColor(isSelected ? .white : .primary)
        .animation(.easeInOut(duration: Constants.animationDuration), value: isSelected)
    }
}

// MARK: - Constants

extension FormatPillButton {
    enum Constants {
        static let spacing: CGFloat = 6
        static let iconSize: CGFloat = 14
        static let verticalPadding: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 16
        static let animationDuration: CGFloat = 0.2
    }
}

// MARK: - Format Info Sheet

struct FormatInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    let format: FormatType

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.contentSpacing) {
                    HStack {
                        Image(systemName: "theatermasks")
                            .font(.largeTitle)
                            .foregroundColor(AppTheme.practiceColor)

                        Text(format.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .padding(.bottom, Constants.titleBottomPadding)

                    Text(format.description)
                        .font(.body)
                        .foregroundColor(Color(.label))

                    Divider()

                    VStack(alignment: .leading, spacing: Constants.segmentSpacing) {
                        Text("Segments")
                            .font(.headline)

                        ForEach(format.segments) { segment in
                            HStack {
                                Text(segment.title)
                                    .foregroundColor(Color(.label))
                                Spacer()
                                Text("\(Int(segment.portion * 100))%")
                                    .foregroundColor(Color(.secondaryLabel))
                            }
                            .font(.subheadline)
                        }
                    }
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
}

// MARK: - Constants

extension FormatInfoSheet {
    enum Constants {
        static let contentSpacing: CGFloat = 16
        static let titleBottomPadding: CGFloat = 8
        static let segmentSpacing: CGFloat = 8
    }
}

// MARK: - Duration Section

struct DurationSection: View {
    let totalDuration: Int
    let onChange: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.spacing) {

            Text("How long are we playing?")
                .font(.headline)
                .padding(.horizontal, Constants.horizontalPadding)

            DurationCard(
                totalDuration: totalDuration,
                onChange: onChange
            )
        }
    }
}

// MARK: - Constants

extension DurationSection {
    enum Constants {
        static let spacing: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
    }
}

// MARK: - Duration Card (Animated Label + Haptics)

import AudioToolbox

struct DurationCard: View {
    let totalDuration: Int
    let onChange: (Int) -> Void

    @State private var lastValue: Int = 0
    @State private var animateTick: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.outerSpacing) {

            VStack(alignment: .leading, spacing: Constants.innerSpacing) {

                Text("\(totalDuration) minutes")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.label))
                    .scaleEffect(animateTick ? Constants.animateScale : 1.0)
                    .opacity(animateTick ? Constants.animateOpacity : 1.0)
                    .animation(.easeOut(duration: Constants.animationDuration), value: animateTick)

                Text(durationDescriptor)
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
            }

            Slider(
                value: Binding(
                    get: { Double(totalDuration) },
                    set: { newValue in
                        let intValue = Int(newValue)

                        if intValue != lastValue {
                            HapticFeedback.selection()
                            playTick()
                            lastValue = intValue
                            animateTick.toggle()
                        }

                        onChange(intValue)
                    }
                ),
                in: Constants.sliderMin...Constants.sliderMax,
                step: Constants.sliderStep
            )
        }
        .padding(Constants.cardPadding)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(Constants.shadowOpacity), radius: Constants.shadowRadius, y: Constants.shadowY)
        )
        .padding(.horizontal, Constants.horizontalPadding)
        .onAppear {
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

// MARK: - Constants

extension DurationCard {
    enum Constants {
        static let outerSpacing: CGFloat = 16
        static let innerSpacing: CGFloat = 4
        static let animateScale: CGFloat = 1.05
        static let animateOpacity: CGFloat = 0.85
        static let animationDuration: CGFloat = 0.15
        static let sliderMin: Double = 5
        static let sliderMax: Double = 60
        static let sliderStep: Double = 5
        static let cardPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 16
        static let shadowOpacity: CGFloat = 0.08
        static let shadowRadius: CGFloat = 4
        static let shadowY: CGFloat = 2
        static let horizontalPadding: CGFloat = 16
    }
}

// MARK: - Start Button

struct StartButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Let's Begin")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(Constants.buttonPadding)
                .background(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(AppTheme.practiceColor)
                )
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.vertical, Constants.verticalPadding)
    }
}

// MARK: - Constants

extension StartButton {
    enum Constants {
        static let buttonPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 16
    }
}

// MARK: - Opening Section

struct OpeningSection: View {
    let openings: [Opening]
    let selected: Opening?
    let onSelect: (Opening?) -> Void

    @State private var showingInfo: Opening?

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.spacing) {

            Text("Opening")
                .font(.headline)
                .padding(.horizontal, Constants.horizontalPadding)

            FlowLayout(spacing: Constants.flowSpacing) {
                ForEach(openings) { opening in
                    OpeningPill(
                        opening: opening,
                        isSelected: selected?.id == opening.id,
                        onSelect: { onSelect(opening) },
                        onInfo: { showingInfo = opening }
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Constants.horizontalPadding)
        }
        .sheet(item: $showingInfo) { opening in
            OpeningInfoSheet(opening: opening)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Constants

extension OpeningSection {
    enum Constants {
        static let spacing: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let flowSpacing: CGFloat = 12
    }
}

// MARK: - Opening Pill

struct OpeningPill: View {
    let opening: Opening
    let isSelected: Bool
    let onSelect: () -> Void
    let onInfo: () -> Void

    var body: some View {
        HStack(spacing: Constants.spacing) {
            Button(action: onSelect) {
                Text(opening.name)
                    .fontWeight(.semibold)
                    .font(.subheadline)
                    .lineLimit(1)
            }

            Button(action: {
                HapticFeedback.light()
                onInfo()
            }) {
                Image(systemName: "info.circle")
                    .font(.system(size: Constants.iconSize))
            }
        }
        .padding(.vertical, Constants.verticalPadding)
        .padding(.horizontal, Constants.horizontalPadding)
        .background(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(isSelected ? AppTheme.practiceColor : Color(.systemGray5))
        )
        .foregroundColor(isSelected ? .white : .primary)
        .animation(.easeInOut(duration: Constants.animationDuration), value: isSelected)
    }
}

// MARK: - Constants

extension OpeningPill {
    enum Constants {
        static let spacing: CGFloat = 6
        static let iconSize: CGFloat = 14
        static let verticalPadding: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 16
        static let animationDuration: CGFloat = 0.2
    }
}

// MARK: - Opening Info Sheet

struct OpeningInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    let opening: Opening

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.contentSpacing) {
                    HStack {
                        Image(systemName: "star.circle")
                            .font(.largeTitle)
                            .foregroundColor(AppTheme.practiceColor)

                        Text(opening.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .padding(.bottom, Constants.titleBottomPadding)

                    Text(opening.description)
                        .font(.body)
                        .foregroundColor(Color(.label))

                    if let playerCount = opening.playerCount {
                        Divider()

                        HStack {
                            Image(systemName: "person.2")
                                .foregroundColor(AppTheme.practiceColor)
                            Text(playerCount)
                                .font(.subheadline)
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    }

                    if let setupTime = opening.setupTime {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(AppTheme.practiceColor)
                            Text(setupTime)
                                .font(.subheadline)
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    }
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
}

// MARK: - Constants

extension OpeningInfoSheet {
    enum Constants {
        static let contentSpacing: CGFloat = 16
        static let titleBottomPadding: CGFloat = 8
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        VStack(spacing: Constants.spacing) {
            ProgressView()
                .scaleEffect(Constants.progressViewScale)
            Text("Loading formats...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Constants

extension LoadingView {
    enum Constants {
        static let spacing: CGFloat = 16
        static let progressViewScale: CGFloat = 1.5
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
