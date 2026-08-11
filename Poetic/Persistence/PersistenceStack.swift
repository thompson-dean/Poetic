//
//  PersistenceStack.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/11.
//

import Foundation
import CoreData

/// Owns the Core Data container. Runs the one-shot v1→v2 migration before the
/// store is loaded, loads synchronously, and exposes any failure as `loadError`
/// so the app can show it instead of silently starting with an empty library.
final class PersistenceStack {
    let container: NSPersistentContainer
    private(set) var loadError: NSError?

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: Constants.appName)

        if inMemory {
            let description = NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
            container.persistentStoreDescriptions = [description]
        } else {
            let storeURL = NSPersistentContainer.defaultDirectoryURL()
                .appendingPathComponent("\(Constants.appName).sqlite")
            do {
                try StoreMigrator.migrateIfNeeded(at: storeURL)
            } catch {
                // Never fall through to loadPersistentStores after a failed
                // migration — the container would attempt (and fail) an
                // inferred migration and mask the real error.
                loadError = error as NSError
            }
        }

        guard loadError == nil else { return }

        container.persistentStoreDescriptions.forEach { $0.shouldAddStoreAsynchronously = false }
        var storeError: NSError?
        container.loadPersistentStores { _, error in
            storeError = error as NSError?
        }
        loadError = storeError

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
