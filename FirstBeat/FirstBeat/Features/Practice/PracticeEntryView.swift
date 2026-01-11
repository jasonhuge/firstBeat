//
//  PracticeEntryView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 1/1/26.
//

import SwiftUI
import ComposableArchitecture
import UIKit

struct PracticeEntryView: View {
    @Bindable var store: StoreOf<PracticeEntryFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.containerSpacing) {
                Text("How would you like to practice?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.top, Constants.titleTopPadding)

                if store.isCheckingAvailability {
                    ProgressView()
                        .padding(.top, 40)
                } else {
                    VStack(spacing: Constants.cardSpacing) {
                        ForEach(store.options) { model in
                            OptionCard(model: model) {
                                store.send(.optionSelected(id: model.id))
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
        .navigationTitle("Practice")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - Constants

extension PracticeEntryView {
    enum Constants {
        static let containerSpacing: CGFloat = 24
        static let titleTopPadding: CGFloat = 40
        static let cardSpacing: CGFloat = 16
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        PracticeEntryView(
            store: Store(initialState: PracticeEntryFeature.State()) {
                PracticeEntryFeature()
            }
        )
    }
}
