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
            SuggestionView(
                store: store.scope(
                    state: \.suggestion,
                    action: \.suggestion
                )
            )
        } destination: { store in
            switch store.state {
            case .practiceSetup:
                if let store = store.scope(state: \.practiceSetup, action: \.practiceSetup) {
                    SessionSetupView(store: store)
                }
            case .practiceSession:
                if let store = store.scope(state: \.practiceSession, action: \.practiceSession) {
                    PracticeView(store: store)
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

