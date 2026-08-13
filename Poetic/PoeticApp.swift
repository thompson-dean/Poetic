//
//  PoeticApp.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

@main
struct PoeticApp: App {
    private let stack: PersistenceStack
    @StateObject private var store: PoemStore
    @StateObject private var storeKitManager = StoreKitManager()

    init() {
        let stack = PersistenceStack()
        self.stack = stack
        _store = StateObject(
            wrappedValue: PoemStore(stack: stack, widgetSync: LiveWidgetFavoritesSync())
        )
    }

    var body: some Scene {
        WindowGroup {
            if let error = stack.loadError {
                ContentUnavailableView(
                    "Couldn't Load Your Library",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
            } else {
                ContentView(storeKitManager: storeKitManager)
                    .environmentObject(store)
            }
        }
    }
}
