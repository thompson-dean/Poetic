//
//  QuoteEntity+CoreData.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/11.
//

import Foundation
import CoreData

@objc(QuoteEntity)
final class QuoteEntity: NSManagedObject {
    @NSManaged var quote: String
    @NSManaged var createdAt: Date
    @NSManaged var poem: PoemEntity

    override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = Date()
    }
}

extension QuoteEntity: Identifiable {}

extension QuoteEntity {
    @nonobjc static func fetchRequest() -> NSFetchRequest<QuoteEntity> {
        NSFetchRequest<QuoteEntity>(entityName: "Quote")
    }
}
