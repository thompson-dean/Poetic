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
    
    func test_PersistenceController_addFavoritePoem_incrementsFavoritedPoems() {
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
    
    func test_PersistenceController_fetchFavoritedPoems_returnsCorrectTitle() {
        persistenceController.addFavoritePoem(id: UUID(), title: "Test Title", author: "Test Author", lines: ["Test line 1"], linecount: "1")
        
        XCTAssertEqual(persistenceController.favoritedPoems.first?.title, "Test Title")
        XCTAssertEqual(persistenceController.favoritedPoems.first?.author, "Test Author")
        XCTAssertEqual(persistenceController.favoritedPoems.first?.lines, ["Test line 1"])
        XCTAssertEqual(persistenceController.favoritedPoems.first?.linecount, "1")
    }

    func test_PersistenceController_addAndDeleteFavoritePoem_returnsEmptyFavoritedPoems() {
        let id = UUID()
        
        persistenceController.addFavoritePoem(id: id, title: "Test Title", author: "Test Author", lines: ["Test line 1"], linecount: "1")
        XCTAssertEqual(persistenceController.favoritedPoems.first?.title, "Test Title")
        
        guard let poem = persistenceController.favoritedPoems.first else { XCTFail("Failed to fetch poem"); return }
        persistenceController.deleteFavoritedPoemFromTappingStar(entity: poem)
        XCTAssertTrue(persistenceController.favoritedPoems.isEmpty)
    }
    
    func test_PersistenceController_addQuote_incrementsQuotes() {
        let id = UUID()
        let title = "Test Quote"
        let author = "Test Author"
        let quote = "This is a test quote."
        let lines = ["Line 1", "Line 2"]
        let linecount = "2"

        persistenceController.addQuote(id: id, title: title, author: author, quote: quote, lines: lines, linecount: linecount)

        XCTAssertEqual(persistenceController.quotes.count, 1)
        XCTAssertEqual(persistenceController.quotes.first?.id, id)
        XCTAssertEqual(persistenceController.quotes.first?.title, title)
        XCTAssertEqual(persistenceController.quotes.first?.author, author)
        XCTAssertEqual(persistenceController.quotes.first?.quote, quote)
    }

    func test_PersistenceController_addAndDeleteQuote_returnsEmptyQuotes() {
        let id = UUID()
        let title = "Test Quote"
        let author = "Test Author"
        let quote = "This is a test quote."
        let lines = ["Line 1", "Line 2"]
        let linecount = "2"

        persistenceController.addQuote(id: id, title: title, author: author, quote: quote, lines: lines, linecount: linecount)
        XCTAssertEqual(persistenceController.quotes.first?.quote, quote)
        
        guard let quoteEntity = persistenceController.quotes.first else { XCTFail("Failed to fetch quote"); return }
        persistenceController.removeQuoteFromQuotes(entity: quoteEntity)
        XCTAssertTrue(persistenceController.quotes.isEmpty)
    }

    func test_PersistenceController_addAndDeleteViewedPoem_returnsEmptyViewedPoems() {
        let id = UUID()
        let title = "Test Poem"
        let author = "Test Author"
        let lines = ["Line 1", "Line 2"]

        persistenceController.addViewedPoem(id: id, title: title, author: author, lines: lines)
        XCTAssertEqual(persistenceController.viewedPoems.first?.title, title)
        
        guard let poem = persistenceController.viewedPoems.first else { XCTFail("Failed to fetch poem"); return }
        persistenceController.deleteViewedPoem(entity: poem)
        XCTAssertTrue(persistenceController.viewedPoems.isEmpty)
    }

    func test_PersistenceController_convertDateToString_returnsCorrectFormat() {
        let testDate = Date(timeIntervalSince1970: 1626643200) // July 19, 2021
        let dateAsString = persistenceController.convertDateToString(date: testDate)
        print(dateAsString)
        XCTAssertEqual(dateAsString, "7/19/21")
    }
}
