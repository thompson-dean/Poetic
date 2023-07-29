//
//  PoeticApp.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

@main
struct PoeticApp: App {
    
    @StateObject private var persistenceController = PersistenceController()
    @StateObject private var storeKitManager = StoreKitManager()
    
    var body: some Scene {
        WindowGroup {
            SplashView(storeKitManager: storeKitManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
