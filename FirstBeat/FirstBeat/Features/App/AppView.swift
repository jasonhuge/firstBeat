//
//  AppView.swift
//  FirstBeat
//
//  Created by Jason Hughes on 12/19/25.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Bindable
    var store: StoreOf<AppFeature>

    var body: some View {
        NavigationStackStore(
            store.scope(state: \.path, action: \.path)
        ) {
            HomeView(
                store: store.scope(
                    state: \.home,
                    action: \.home
                )
            )
        } destination: { store in
            switch store.state {
            case .practiceEntry:
                if let store = store.scope(state: \.practiceEntry, action: \.practiceEntry) {
                    PracticeEntryView(store: store)
                }
            case .suggestion:
                if let store = store.scope(state: \.suggestion, action: \.suggestion) {
                    SuggestionView(store: store)
                }
            case .randomSuggestion:
                if let store = store.scope(state: \.randomSuggestion, action: \.randomSuggestion) {
                    RandomSuggestionView(store: store)
                }
            case .practiceSetup:
                if let store = store.scope(state: \.practiceSetup, action: \.practiceSetup) {
                    SessionSetupView(store: store)
                }
            case .practiceSession:
                if let store = store.scope(state: \.practiceSession, action: \.practiceSession) {
                    SessionView(store: store)
                }
            case .warmUpList:
                if let store = store.scope(state: \.warmUpList, action: \.warmUpList) {
                    WarmUpListView(store: store)
                }
            case .warmUpDetail:
                if let store = store.scope(state: \.warmUpDetail, action: \.warmUpDetail) {
                    WarmUpDetailView(store: store)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}

