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
    
    //Implement this so user's can also access and see the poem from which their quotes came from. 
    @Published var favoritedQuotesPoem: [QuotePoemsEntity] = []

    
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
    }
    
    
    //Fetching Favorite Poems
    
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
    
    func addFavoritePoem(id: UUID, title: String, author: String, lines: [String], linecount: String) {
        let newEntity = PoemEntity(context: container.viewContext)
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
    
    //Fetching Favorite Quotes
    
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
    
    func addQuote(id: UUID, title: String, author: String, quote: String, lines: [String], linecount: String) {
        
        let quotesPoemEntity = QuotePoemsEntity(context: container.viewContext)
        quotesPoemEntity.id = id
        quotesPoemEntity.title = title
        quotesPoemEntity.author = author
        quotesPoemEntity.lines = lines
        
        
        let newEntity = QuoteEntity(context: container.viewContext)
        newEntity.id = id
        newEntity.title = title
        newEntity.author = author
        newEntity.quote = quote
        
        saveData()
    }
    
    
    //Saving and Deleting from Core Data
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchFavoritedPoems()
            fetchQuotes()
            fetchQuotePoems()
            
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
}
