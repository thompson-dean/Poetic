//
//  StoreMigratorTests.swift
//  PoeticTests
//
//  Created by Dean Thompson on 2026/08/11.
//

import XCTest
import CoreData
@testable import Poetic

final class StoreMigratorTests: XCTestCase {
    private var directory: URL!
    private var storeURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        storeURL = directory.appendingPathComponent("Poetic.sqlite")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: directory.path)
        try? FileManager.default.removeItem(at: directory)
        directory = nil
        storeURL = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func test_migration_dedupesPoemsAndBuildsRelationships() throws {
        let lines = ["  From fairest creatures we desire increase,", "That thereby beauty's rose might never die,"]
        let older = Date(timeIntervalSince1970: 1_000_000)
        let newer = Date(timeIntervalSince1970: 2_000_000)

        try makeV1Store { context in
            self.insert(context, "PoemEntity", [
                "title": "Sonnet 1", "author": "William Shakespeare",
                "lines": lines, "linecount": "Sonnet 1"  // v1 linecount corruption: title stored here
            ])
            self.insert(context, "ViewedPoemEntity", [
                "title": "Sonnet 1", "author": "William Shakespeare", "lines": lines, "date": older
            ])
            self.insert(context, "ViewedPoemEntity", [
                "title": "Sonnet 1", "author": "William Shakespeare", "lines": lines, "date": newer
            ])
            let quoteTexts = [
                "  From fairest creatures we desire increase,",
                "That thereby beauty's rose might never die,"
            ]
            for quote in quoteTexts {
                self.insert(context, "QuoteEntity", [
                    "title": "Sonnet 1", "author": "William Shakespeare", "quote": quote
                ])
                self.insert(context, "QuotePoemsEntity", [
                    "title": "Sonnet 1", "author": "William Shakespeare", "lines": lines
                ])
            }
        }

        try StoreMigrator.migrateIfNeeded(at: storeURL)

        let context = try openV2Context()
        let poems = try context.fetch(PoemEntity.fetchRequest())
        XCTAssertEqual(poems.count, 1)

        let poem = try XCTUnwrap(poems.first)
        XCTAssertTrue(poem.isFavorite)
        XCTAssertNil(poem.favoritedAt)
        XCTAssertEqual(poem.lastViewedAt, newer)
        XCTAssertEqual(poem.lines, lines)

        let quotes = try context.fetch(QuoteEntity.fetchRequest())
        XCTAssertEqual(quotes.count, 2)
        // Quote text migrates verbatim — leading whitespace preserved.
        XCTAssertTrue(quotes.contains { $0.quote == "  From fairest creatures we desire increase," })
        XCTAssertTrue(quotes.allSatisfy { $0.poem == poem })
    }

    func test_migration_orphanQuote_createsPlaceholderPoem() throws {
        try makeV1Store { context in
            self.insert(context, "QuoteEntity", [
                "title": "Ozymandias",
                "author": "Percy Bysshe Shelley",
                "quote": "Look on my Works, ye Mighty, and despair!"
            ])
        }

        try StoreMigrator.migrateIfNeeded(at: storeURL)

        let context = try openV2Context()
        let poems = try context.fetch(PoemEntity.fetchRequest())
        XCTAssertEqual(poems.count, 1)
        let poem = try XCTUnwrap(poems.first)
        XCTAssertEqual(poem.title, "Ozymandias")
        XCTAssertEqual(poem.lines, [])
        XCTAssertFalse(poem.isFavorite)

        let quotes = try context.fetch(QuoteEntity.fetchRequest())
        XCTAssertEqual(quotes.first?.poem, poem)
    }

    func test_migration_isIdempotent() throws {
        try makeV1Store { context in
            self.insert(context, "PoemEntity", [
                "title": "Sonnet 1", "author": "William Shakespeare", "lines": ["a", "b"]
            ])
        }

        try StoreMigrator.migrateIfNeeded(at: storeURL)
        try StoreMigrator.migrateIfNeeded(at: storeURL)

        let context = try openV2Context()
        XCTAssertEqual(try context.fetch(PoemEntity.fetchRequest()).count, 1)
    }

    func test_migration_freshInstall_createsNoFile() throws {
        try StoreMigrator.migrateIfNeeded(at: storeURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: storeURL.path))
    }

    func test_migration_emptyV1Store_yieldsValidEmptyV2Store() throws {
        try makeV1Store { _ in }

        try StoreMigrator.migrateIfNeeded(at: storeURL)

        let context = try openV2Context()
        XCTAssertEqual(try context.fetch(PoemEntity.fetchRequest()).count, 0)
        XCTAssertEqual(try context.fetch(QuoteEntity.fetchRequest()).count, 0)
    }

    func test_migration_fromPreV1Store_lightweightUpgradesThenMigrates() throws {
        // The original 2022 model had only PoemEntity/QuoteEntity with
        // non-optional attributes; shipped builds lightweight-migrated such
        // stores on launch. The migrator must handle them the same way.
        let ancientModel = try v1Model()
        ancientModel.entities.removeAll { ["QuotePoemsEntity", "ViewedPoemEntity"].contains($0.name ?? "") }
        for entity in ancientModel.entities {
            for property in entity.properties {
                property.isOptional = false
            }
        }

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: ancientModel)
        try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: nil
        )
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        insert(context, "PoemEntity", [
            "title": "Sonnet 1", "author": "William Shakespeare", "lines": ["a", "b"], "linecount": "2"
        ])
        insert(context, "QuoteEntity", [
            "title": "Sonnet 1", "author": "William Shakespeare", "quote": "a"
        ])
        try context.save()
        if let store = coordinator.persistentStores.first {
            try coordinator.remove(store)
        }

        try StoreMigrator.migrateIfNeeded(at: storeURL)

        let v2Context = try openV2Context()
        let poems = try v2Context.fetch(PoemEntity.fetchRequest())
        XCTAssertEqual(poems.count, 1)
        XCTAssertEqual(poems.first?.isFavorite, true)
        XCTAssertEqual(poems.first?.lines, ["a", "b"])
        let quotes = try v2Context.fetch(QuoteEntity.fetchRequest())
        XCTAssertEqual(quotes.first?.quote, "a")
        XCTAssertEqual(quotes.first?.poem, poems.first)
    }

    func test_migration_failure_leavesV1StoreIntact() throws {
        try makeV1Store { context in
            self.insert(context, "PoemEntity", [
                "title": "Sonnet 1", "author": "William Shakespeare", "lines": ["a"]
            ])
        }
        // Read-only directory: building the temp v2 store must fail.
        try FileManager.default.setAttributes([.posixPermissions: 0o555], ofItemAtPath: directory.path)

        XCTAssertThrowsError(try StoreMigrator.migrateIfNeeded(at: storeURL))

        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: directory.path)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: try v1Model())
        try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: [NSReadOnlyPersistentStoreOption: true]
        )
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        let count = try context.count(for: NSFetchRequest<NSManagedObject>(entityName: "PoemEntity"))
        XCTAssertEqual(count, 1)
    }

    // MARK: - v1 fixture

    private func v1Model() throws -> NSManagedObjectModel {
        let momdURL = try XCTUnwrap(Bundle.main.url(forResource: "Poetic", withExtension: "momd"))
        let model = try XCTUnwrap(NSManagedObjectModel(contentsOf: momdURL.appendingPathComponent("Poetic.mom")))
        // v1 rows must not instantiate the v2 subclasses. Class names are not
        // part of the version hash, so store compatibility is unaffected.
        model.entities.forEach { $0.managedObjectClassName = "NSManagedObject" }
        return model
    }

    private func makeV1Store(_ populate: (NSManagedObjectContext) -> Void) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: try v1Model())
        try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: nil
        )
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        populate(context)
        try context.save()
        if let store = coordinator.persistentStores.first {
            try coordinator.remove(store)
        }
    }

    private func insert(_ context: NSManagedObjectContext, _ entityName: String, _ values: [String: Any]) {
        let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        var values = values
        values["id"] = UUID()
        values.forEach { object.setValue($0.value, forKey: $0.key) }
    }

    // MARK: - v2 readback

    private func openV2Context() throws -> NSManagedObjectContext {
        let momdURL = try XCTUnwrap(Bundle.main.url(forResource: "Poetic", withExtension: "momd"))
        let model = try XCTUnwrap(NSManagedObjectModel(contentsOf: momdURL.appendingPathComponent("Poetic 2.mom")))
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: [NSReadOnlyPersistentStoreOption: true]
        )
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }
}
