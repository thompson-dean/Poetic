//
//  PoemEntity+CoreData.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/11.
//

import Foundation
import CoreData

@objc(PoemEntity)
final class PoemEntity: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var author: String
    @NSManaged var lines: [String]
    @NSManaged var isFavorite: Bool
    @NSManaged var favoritedAt: Date?
    @NSManaged var lastViewedAt: Date?
    @NSManaged var quotes: Set<QuoteEntity>

    override func awakeFromInsert() {
        super.awakeFromInsert()
        lines = []
    }

    var linecount: String {
        String(lines.count)
    }

    func asPoem() -> Poem {
        Poem(title: title, author: author, lines: lines, linecount: linecount)
    }
}

extension PoemEntity: Identifiable {}

extension PoemEntity {
    @nonobjc static func fetchRequest() -> NSFetchRequest<PoemEntity> {
        NSFetchRequest<PoemEntity>(entityName: "Poem")
    }
}
