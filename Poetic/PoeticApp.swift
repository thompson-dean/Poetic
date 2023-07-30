//
//  PoeticApp.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI
import BackgroundTasks

@main
struct PoeticApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var persistenceController = PersistenceController()
    @StateObject private var storeKitManager = StoreKitManager()
    
    var body: some Scene {
        WindowGroup {
            SplashView(storeKitManager: storeKitManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    let viewModel = PoemViewModel(apiService: APIService(), csvManager: CSVManager())
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Constants.updatePoemIdentifier,
            using: nil
        ) { task in
            self.viewModel.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        return true
    }
}
