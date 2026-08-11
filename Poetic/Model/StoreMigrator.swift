//
//  StoreMigrator.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/11.
//

import Foundation
import CoreData

enum StoreMigratorError: LocalizedError {
    case modelNotFound(String)
    case unrecognizedStoreVersion

    var errorDescription: String? {
        switch self {
        case .modelNotFound(let name):
            return "Could not load the \(name) data model from the app bundle."
        case .unrecognizedStoreVersion:
            return "The existing library is from an unrecognized version of Poetic."
        }
    }
}

/// One-shot programmatic migration from the 2020-era v1 schema
/// (PoemEntity / QuoteEntity / QuotePoemsEntity / ViewedPoemEntity, no relationships)
/// to the v2 schema (Poem unique on title+author, Quote with a to-one poem relationship).
///
/// The v1 file is opened read-only and only replaced once a complete v2 store
/// has been built next to it, so a failed migration always leaves the old store intact.
enum StoreMigrator {

    static func migrateIfNeeded(at storeURL: URL, bundle: Bundle = .main) throws {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return }

        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: storeURL,
            options: nil
        )

        let v2Model = try model(named: "Poetic 2", bundle: bundle)
        // The migrator's model copies must not claim the entity subclasses —
        // the app's own container claims them, and competing claims break
        // +entity resolution ("Multiple NSEntityDescriptions claim...").
        // All migration writes therefore go through KVC, not typed accessors.
        v2Model.entities.forEach { $0.managedObjectClassName = "NSManagedObject" }
        if v2Model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) {
            return
        }

        let v1Model = try model(named: "Poetic", bundle: bundle)
        // v1 entities must not instantiate the v2 subclasses, whose @NSManaged
        // surface no longer matches the v1 schema. (Class names are not part
        // of the version hash, so compatibility checks are unaffected.)
        v1Model.entities.forEach { $0.managedObjectClassName = "NSManagedObject" }

        if !v1Model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) {
            // The v1 schema changed over the years without model versioning;
            // shipped builds silently lightweight-migrated old stores on every
            // launch. A store from a dormant install predates the final v1
            // shape, so reproduce that upgrade before the custom migration.
            try upgradeInPlaceToV1(at: storeURL, model: v1Model)
        }

        let snapshot = try readV1Snapshot(at: storeURL, model: v1Model)

        let directory = storeURL.deletingLastPathComponent()
        let tempURL = directory.appendingPathComponent("Poetic.migration.sqlite")
        let backupURL = directory.appendingPathComponent("Poetic.v1backup.sqlite")

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: v2Model)
        try? coordinator.destroyPersistentStore(at: tempURL, ofType: NSSQLiteStoreType, options: nil)
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: tempURL, options: nil)

        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        try context.performAndWait {
            populate(context, with: snapshot)
            try context.save()
        }

        try coordinator.replacePersistentStore(
            at: backupURL,
            destinationOptions: nil,
            withPersistentStoreFrom: storeURL,
            sourceOptions: nil,
            ofType: NSSQLiteStoreType
        )
        try coordinator.replacePersistentStore(
            at: storeURL,
            destinationOptions: nil,
            withPersistentStoreFrom: tempURL,
            sourceOptions: nil,
            ofType: NSSQLiteStoreType
        )
        try? coordinator.destroyPersistentStore(at: tempURL, ofType: NSSQLiteStoreType, options: nil)
        removeStoreFiles(at: tempURL)
    }

    /// destroyPersistentStore truncates rather than unlinks — remove the husks.
    private static func removeStoreFiles(at url: URL) {
        for suffix in ["", "-shm", "-wal"] {
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
        }
    }

    // MARK: - Models

    private static func model(named name: String, bundle: Bundle) throws -> NSManagedObjectModel {
        guard let momdURL = bundle.url(forResource: "Poetic", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: momdURL.appendingPathComponent("\(name).mom")) else {
            throw StoreMigratorError.modelNotFound(name)
        }
        return model
    }

    // MARK: - Pre-v1 stores

    private static func upgradeInPlaceToV1(at storeURL: URL, model: NSManagedObjectModel) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: [
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true
                ]
            )
        } catch {
            throw StoreMigratorError.unrecognizedStoreVersion
        }
        if let store = coordinator.persistentStores.first {
            try coordinator.remove(store)
        }
    }

    // MARK: - Reading v1

    private struct PoemKey: Hashable {
        let title: String
        let author: String
    }

    private struct V1FavoriteRow {
        let key: PoemKey
        let lines: [String]
    }

    private struct V1ViewedRow {
        let key: PoemKey
        let lines: [String]
        let date: Date?
    }

    private struct V1QuotePoemRow {
        let key: PoemKey
        let lines: [String]
    }

    private struct V1QuoteRow {
        let key: PoemKey
        let text: String
    }

    private struct V1Snapshot {
        var favorites: [V1FavoriteRow] = []
        var viewed: [V1ViewedRow] = []
        var quotePoems: [V1QuotePoemRow] = []
        var quotes: [V1QuoteRow] = []
    }

    private static func readV1Snapshot(at storeURL: URL, model: NSManagedObjectModel) throws -> V1Snapshot {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: [NSReadOnlyPersistentStoreOption: true]
        )

        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        var snapshot = V1Snapshot()
        try context.performAndWait {
            func rows(_ entityName: String) throws -> [NSManagedObject] {
                let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
                request.returnsObjectsAsFaults = false
                return try context.fetch(request)
            }
            func key(of object: NSManagedObject) -> PoemKey {
                PoemKey(
                    title: object.value(forKey: "title") as? String ?? "",
                    author: object.value(forKey: "author") as? String ?? ""
                )
            }
            func lines(of object: NSManagedObject) -> [String] {
                object.value(forKey: "lines") as? [String] ?? []
            }

            snapshot.favorites = try rows("PoemEntity").map {
                .init(key: key(of: $0), lines: lines(of: $0))
            }
            snapshot.viewed = try rows("ViewedPoemEntity").map {
                .init(key: key(of: $0), lines: lines(of: $0), date: $0.value(forKey: "date") as? Date)
            }
            snapshot.quotePoems = try rows("QuotePoemsEntity").map {
                .init(key: key(of: $0), lines: lines(of: $0))
            }
            snapshot.quotes = try rows("QuoteEntity").compactMap {
                guard let text = $0.value(forKey: "quote") as? String, !text.isEmpty else { return nil }
                return .init(key: key(of: $0), text: text)
            }
        }

        if let store = coordinator.persistentStores.first {
            try coordinator.remove(store)
        }
        return snapshot
    }

    // MARK: - Populating v2

    // Writes use KVC because the migrator's v2 model deliberately does not
    // map the entity subclasses (see migrateIfNeeded). awakeFromInsert
    // defaults don't run here, so every non-optional value is set explicitly.
    private static func populate(_ context: NSManagedObjectContext, with snapshot: V1Snapshot) {
        var poems: [PoemKey: NSManagedObject] = [:]

        func upsertPoem(_ key: PoemKey, lines: [String]) -> NSManagedObject {
            if let existing = poems[key] {
                if (existing.value(forKey: "lines") as? [String] ?? []).isEmpty && !lines.isEmpty {
                    existing.setValue(lines, forKey: "lines")
                }
                return existing
            }
            let poem = insertPoem(key, lines: lines, into: context)
            poems[key] = poem
            return poem
        }

        // Pass A: favorites.
        for row in snapshot.favorites {
            let poem = upsertPoem(row.key, lines: row.lines)
            poem.setValue(true, forKey: "isFavorite")
        }

        // Pass B: recents. Multiple viewed rows for one poem collapse to the most recent date.
        for row in snapshot.viewed {
            let poem = upsertPoem(row.key, lines: row.lines)
            if let date = row.date {
                let existing = poem.value(forKey: "lastViewedAt") as? Date ?? .distantPast
                poem.setValue(max(existing, date), forKey: "lastViewedAt")
            }
        }

        // Pass C: the poems backing saved quotes (v1 stored one full copy per quote).
        for row in snapshot.quotePoems {
            _ = upsertPoem(row.key, lines: row.lines)
        }

        // Pass D: quotes.
        migrateQuotes(snapshot.quotes, into: context, poems: &poems)
    }

    private static func insertPoem(
        _ key: PoemKey,
        lines: [String],
        into context: NSManagedObjectContext
    ) -> NSManagedObject {
        let poem = NSEntityDescription.insertNewObject(forEntityName: "Poem", into: context)
        poem.setValue(key.title, forKey: "title")
        poem.setValue(key.author, forKey: "author")
        poem.setValue(lines, forKey: "lines")
        poem.setValue(false, forKey: "isFavorite")
        return poem
    }

    // Exact (title, author) match first, then title-only (all the v1 UI ever
    // required), then a placeholder poem so the quote survives.
    private static func migrateQuotes(
        _ rows: [V1QuoteRow],
        into context: NSManagedObjectContext,
        poems: inout [PoemKey: NSManagedObject]
    ) {
        struct QuoteKey: Hashable {
            let poem: ObjectIdentifier
            let text: String
        }
        var seenQuotes: Set<QuoteKey> = []
        let migrationDate = Date()

        for row in rows {
            let poem: NSManagedObject
            if let exact = poems[row.key] {
                poem = exact
            } else if let byTitle = poems.first(where: { $0.key.title == row.key.title })?.value {
                poem = byTitle
            } else {
                poem = insertPoem(row.key, lines: [], into: context)
                poems[row.key] = poem
            }
            let quoteKey = QuoteKey(poem: ObjectIdentifier(poem), text: row.text)
            guard seenQuotes.insert(quoteKey).inserted else { continue }

            let quote = NSEntityDescription.insertNewObject(forEntityName: "Quote", into: context)
            quote.setValue(row.text, forKey: "quote")
            quote.setValue(migrationDate, forKey: "createdAt")
            quote.setValue(poem, forKey: "poem")
        }
    }
}
