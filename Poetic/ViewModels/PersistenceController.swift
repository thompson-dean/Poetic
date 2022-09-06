//
//  PersistenceController.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/14.
//

import Foundation
import CoreData

class PersistenceController: ObservableObject {
    
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    @Published var favoritedPoems: [PoemEntity] = []
    @Published var quotes: [QuoteEntity] = []
    @Published var favoritedQuotesPoem: [QuotePoemsEntity] = []
    @Published var viewedPoems: [ViewedPoemEntity] = []

    @Published var poemsFilter = true
    @Published var quotesFilter = true
    
    init() {
        container = NSPersistentContainer(name: "Poetic")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError(error.localizedDescription)
            }
        }
        fetchFavoritedPoems()
        fetchQuotes()
        fetchQuotePoems()
        fetchViewedPoems()
    }
    
    
    //Fetching Entities
    func fetchFavoritedPoems() {
        let request = NSFetchRequest<PoemEntity>(entityName: "PoemEntity")
        let sortDescriptor = NSSortDescriptor(key: poemsFilter ? "title" : "author", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            favoritedPoems = try container.viewContext.fetch(request)
        } catch {
            print("Error fetching. \(error.localizedDescription)")
        }
    }
    
    func fetchQuotes() {
        let request = NSFetchRequest<QuoteEntity>(entityName: "QuoteEntity")
        let sortDescriptor = NSSortDescriptor(key: quotesFilter ? "quote" : "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            quotes = try container.viewContext.fetch(request)
        } catch {
            print("Error fetching. \(error.localizedDescription)")
        }
    }
    
    func fetchQuotePoems() {
        let request = NSFetchRequest<QuotePoemsEntity>(entityName: "QuotePoemsEntity")
        
        do {
            favoritedQuotesPoem = try container.viewContext.fetch(request)
        } catch {
            print("Error fetching. \(error.localizedDescription)")
        }
    }
    
    func fetchViewedPoems() {
        let request = NSFetchRequest<ViewedPoemEntity>(entityName: "ViewedPoemEntity")
        
        do {
            viewedPoems = try container.viewContext.fetch(request)
        } catch {
            print("Error fetching. \(error.localizedDescription)")
        }
    }
    
    // Adding
    func addFavoritePoem(id: UUID, title: String, author: String, lines: [String], linecount: String) {
        guard let description = NSEntityDescription.entity(forEntityName: "PoemEntity", in: container.viewContext) else { return }
        let newEntity = PoemEntity(entity: description, insertInto: container.viewContext)
        newEntity.id = id
        newEntity.title = title
        newEntity.author = author
        newEntity.lines = lines
        newEntity.linecount = linecount
        
        if favoritedPoems.contains(where: { $0.title == newEntity.title }) {
            container.viewContext.delete(newEntity)
            saveData()
        } else {
            saveData()
        }
    }
    
    func addQuote(id: UUID, title: String, author: String, quote: String, lines: [String], linecount: String) {
        guard let description = NSEntityDescription.entity(forEntityName: "QuotePoemsEntity", in: container.viewContext) else { return }
        let quotesPoemEntity = QuotePoemsEntity(entity: description, insertInto: container.viewContext)
        quotesPoemEntity.id = id
        quotesPoemEntity.title = title
        quotesPoemEntity.author = author
        quotesPoemEntity.lines = lines
        
        
        guard let descriptionQuote = NSEntityDescription.entity(forEntityName: "QuoteEntity", in: container.viewContext) else { return }
        let newEntity = QuoteEntity(entity: descriptionQuote, insertInto: container.viewContext)
        newEntity.id = id
        newEntity.title = title
        newEntity.author = author
        newEntity.quote = quote
        
        saveData()
    }
    
    func addViewedPoem(id: UUID, title: String, author: String, lines: [String]) {
        guard let description = NSEntityDescription.entity(forEntityName: "ViewedPoemEntity", in: container.viewContext) else { return }
        let viewedPoemEntity = ViewedPoemEntity(entity: description, insertInto: container.viewContext)
        viewedPoemEntity.id = id
        viewedPoemEntity.title = title
        viewedPoemEntity.author = author
        viewedPoemEntity.lines = lines
        
        saveData()
    }
    
    
    //Saving and Deleting from Core Data
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchFavoritedPoems()
            fetchQuotes()
            fetchQuotePoems()
            fetchViewedPoems()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteFavoritedPoemFromTappingStar(entity poem: PoemEntity) {
        container.viewContext.delete(poem)
        saveData()
    }
    
    func deleteFavoritedPoem(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let entity = favoritedPoems[index]
        container.viewContext.delete(entity)
        saveData()
    }
    
    func deleteQuotes(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let entity = quotes[index]
        container.viewContext.delete(entity)
        saveData()
    }
    
    func removeQuoteFromQuotes(entity quote: QuoteEntity) {
        container.viewContext.delete(quote)
        saveData()
    }
    
    func deleteQuotePoem(entity quotePoem: QuotePoemsEntity) {
        container.viewContext.delete(quotePoem)
        saveData()
    }
    
    func deleteViewedPoem(entity viewedPoem: ViewedPoemEntity) {
        container.viewContext.delete(viewedPoem)
        saveData()
    }
}
