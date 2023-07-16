//
//  PersistenceControllerTests.swift
//  PoeticTests
//
//  Created by Dean Thompson on 2023/07/16.
//

import XCTest
import CoreData

@testable import Poetic

class PersistenceControllerTests: XCTestCase {
    var persistenceController: PersistenceController!
    var mockContainer: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        mockContainer = mockPersistantContainer()
        persistenceController = PersistenceController(container: mockContainer)
    }

    override func tearDown() {
        persistenceController = nil
        mockContainer = nil
        super.tearDown()
    }
    
    func mockPersistantContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Poetic")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            precondition(description.type == NSInMemoryStoreType)
            if let error = error {
                fatalError("Create an in-memory coordinator failed \(error)")
            }
        }
        return container
    }
    
    func testAddFavoritePoem() {
        let id = UUID()
        let title = "Test Poem"
        let author = "Test Author"
        let lines = ["Line 1", "Line 2"]
        let linecount = "2"

        persistenceController.addFavoritePoem(id: id, title: title, author: author, lines: lines, linecount: linecount)
        persistenceController.fetchFavoritedPoems()

        XCTAssertEqual(persistenceController.favoritedPoems.count, 1)
        XCTAssertEqual(persistenceController.favoritedPoems.first?.id, id)
        XCTAssertEqual(persistenceController.favoritedPoems.first?.title, title)
        XCTAssertEqual(persistenceController.favoritedPoems.first?.author, author)
        XCTAssertEqual(persistenceController.favoritedPoems.first?.lines, lines)
        XCTAssertEqual(persistenceController.favoritedPoems.first?.linecount, linecount)
    }
    
    func testFetchFavoritedPoems() {
        persistenceController.addFavoritePoem(id: UUID(), title: "Test Title", author: "Test Author", lines: ["Test line 1"], linecount: "1")
        
        XCTAssertEqual(persistenceController.favoritedPoems.first?.title, "Test Title")
    }

    func testAddAndDeleteFavoritePoem() {
        let id = UUID()
        
        persistenceController.addFavoritePoem(id: id, title: "Test Title", author: "Test Author", lines: ["Test line 1"], linecount: "1")
        XCTAssertEqual(persistenceController.favoritedPoems.first?.title, "Test Title")
        
        guard let poem = persistenceController.favoritedPoems.first else { XCTFail("Failed to fetch poem"); return }
        persistenceController.deleteFavoritedPoemFromTappingStar(entity: poem)
        XCTAssertTrue(persistenceController.favoritedPoems.isEmpty)
    }
}
