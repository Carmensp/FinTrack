//
//  Account+CoreDataProperties.swift
//  FinTrack
//
//  Created by Carmen on 05/10/2026.
//
//

public import Foundation
public import CoreData


public typealias AccountCoreDataPropertiesSet = NSSet

extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged nonisolated public var id: UUID?
    @NSManaged nonisolated public var name: String?
    @NSManaged nonisolated public var balance: Double
    @NSManaged nonisolated public var icon: String?
    @NSManaged nonisolated public var transactions: NSSet?

}

// MARK: Generated accessors for transactions
extension Account {

    @objc(addTransactionsObject:)
    @NSManaged nonisolated public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged nonisolated public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged nonisolated public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged nonisolated public func removeFromTransactions(_ values: NSSet)

}

extension Account : Identifiable {

}
