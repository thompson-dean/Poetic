//
//  PoemStore.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/11.
//

import Foundation
import CoreData

/// The single persistence facade the views observe.
/// All work happens synchronously on the view context — the dataset is one
/// person's favorites, quotes, and two weeks of reading history.
@MainActor
final class PoemStore: ObservableObject {
    enum FavoriteSort {
        case title, author
    }
    enum QuoteSort {
        case quote, title
    }

    @Published private(set) var favorites: [PoemEntity] = []
    @Published private(set) var quotes: [QuoteEntity] = []
    @Published private(set) var recents: [PoemEntity] = []

    @Published var favoriteSort: FavoriteSort = .title {
        didSet { refreshFavorites() }
    }
    @Published var quoteSort: QuoteSort = .quote {
        didSet { refreshQuotes() }
    }

    private let stack: PersistenceStack
    private var context: NSManagedObjectContext { stack.viewContext }

    init(stack: PersistenceStack) {
        self.stack = stack
        refresh()
        pruneRecents(olderThan: 14)
    }

    // MARK: - Favorites

    func isFavorited(_ poem: Poem) -> Bool {
        favorites.contains { $0.title == poem.title && $0.author == poem.author }
    }

    func toggleFavorite(_ poem: Poem) {
        let entity = fetchOrCreatePoem(for: poem)
        entity.isFavorite.toggle()
        entity.favoritedAt = entity.isFavorite ? Date() : nil
        saveAndRefresh()
    }

    func deleteFavorites(at offsets: IndexSet) {
        for index in offsets where favorites.indices.contains(index) {
            favorites[index].isFavorite = false
            favorites[index].favoritedAt = nil
        }
        saveAndRefresh()
    }

    // MARK: - Quotes

    /// Comparison is trimmed-on-both-sides: quotes migrated from v1 are stored
    /// raw, new quotes are stored trimmed, and both must highlight and dedupe.
    func hasQuote(_ line: String, in poem: Poem) -> Bool {
        let needle = line.trimmingCharacters(in: .whitespacesAndNewlines)
        return quotes.contains {
            $0.poem.title == poem.title && $0.poem.author == poem.author
                && $0.quote.trimmingCharacters(in: .whitespacesAndNewlines) == needle
        }
    }

    func addQuote(_ line: String, to poem: Poem) {
        let text = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !hasQuote(line, in: poem) else { return }
        let entity = fetchOrCreatePoem(for: poem)
        let quote = QuoteEntity(context: context)
        quote.quote = text
        quote.poem = entity
        saveAndRefresh()
    }

    func deleteQuotes(at offsets: IndexSet) {
        for index in offsets where quotes.indices.contains(index) {
            context.delete(quotes[index])
        }
        saveAndRefresh()
    }

    // MARK: - Recents

    func markViewed(_ poem: Poem) {
        let entity = fetchOrCreatePoem(for: poem)
        entity.lastViewedAt = Date()
        saveAndRefresh()
    }

    func pruneRecents(olderThan days: Int) {
        guard let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) else { return }
        let request = PoemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "lastViewedAt < %@", cutoff as NSDate)
        do {
            for poem in try context.fetch(request) {
                poem.lastViewedAt = nil
            }
        } catch {
            print("Error pruning recents. \(error.localizedDescription)")
        }
        saveAndRefresh()
    }

    // MARK: - Internals

    private func fetchOrCreatePoem(for poem: Poem) -> PoemEntity {
        let request = PoemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@ AND author == %@", poem.title, poem.author)
        request.fetchLimit = 1
        if let existing = (try? context.fetch(request))?.first {
            if existing.lines.isEmpty && !poem.lines.isEmpty {
                existing.lines = poem.lines
            }
            return existing
        }
        let entity = PoemEntity(context: context)
        entity.title = poem.title
        entity.author = poem.author
        entity.lines = poem.lines
        return entity
    }

    /// A poem row exists while it is favorited, quoted, or recently viewed.
    private func gcUnusedPoems() {
        let request = PoemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == NO AND lastViewedAt == nil AND quotes.@count == 0")
        guard let unused = try? context.fetch(request) else { return }
        unused.forEach(context.delete)
    }

    private func saveAndRefresh() {
        gcUnusedPoems()
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving. \(error.localizedDescription)")
                context.rollback()
            }
        }
        refresh()
    }

    private func refresh() {
        refreshFavorites()
        refreshQuotes()
        refreshRecents()
    }

    private func refreshFavorites() {
        let request = PoemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        let key = favoriteSort == .title ? "title" : "author"
        request.sortDescriptors = [NSSortDescriptor(key: key, ascending: true)]
        favorites = (try? context.fetch(request)) ?? []
    }

    private func refreshQuotes() {
        let request = QuoteEntity.fetchRequest()
        let key = quoteSort == .quote ? "quote" : "poem.title"
        request.sortDescriptors = [NSSortDescriptor(key: key, ascending: true)]
        quotes = (try? context.fetch(request)) ?? []
    }

    private func refreshRecents() {
        let request = PoemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "lastViewedAt != nil")
        request.sortDescriptors = [NSSortDescriptor(key: "lastViewedAt", ascending: false)]
        recents = (try? context.fetch(request)) ?? []
    }
}
