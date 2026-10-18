//
//  Transaction+CoreDataProperties.swift
//  FinTrack
//
//  Created by Carmen on 05/10/2026.
//
//

public import Foundation
public import CoreData


public typealias TransactionCoreDataPropertiesSet = NSSet

extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged nonisolated public var id: UUID?
    @NSManaged nonisolated public var amount: Double
    @NSManaged nonisolated public var date: Date?
    @NSManaged nonisolated public var note: String?
    @NSManaged nonisolated public var type: String?
    @NSManaged nonisolated public var account: Account?
    @NSManaged nonisolated public var category: Category?

}

extension Transaction : Identifiable {

}
