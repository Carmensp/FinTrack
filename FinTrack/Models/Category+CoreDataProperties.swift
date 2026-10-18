//
//  Category+CoreDataProperties.swift
//  FinTrack
//
//  Created by Carmen on 13/10/2026.
//
//

public import Foundation
public import CoreData


public typealias CategoryCoreDataPropertiesSet = NSSet

extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged nonisolated public var icon: String?
    @NSManaged nonisolated public var id: UUID?
    @NSManaged nonisolated public var name: String?
    @NSManaged nonisolated public var budgets: NSSet?
    @NSManaged nonisolated public var transactions: NSSet?

}

// MARK: Generated accessors for budgets
extension Category {

    @objc(addBudgetsObject:)
    @NSManaged nonisolated public func addToBudgets(_ value: Budget)

    @objc(removeBudgetsObject:)
    @NSManaged nonisolated public func removeFromBudgets(_ value: Budget)

    @objc(addBudgets:)
    @NSManaged nonisolated public func addToBudgets(_ values: NSSet)

    @objc(removeBudgets:)
    @NSManaged nonisolated public func removeFromBudgets(_ values: NSSet)

}

// MARK: Generated accessors for transactions
extension Category {

    @objc(addTransactionsObject:)
    @NSManaged nonisolated public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged nonisolated public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged nonisolated public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged nonisolated public func removeFromTransactions(_ values: NSSet)

}

extension Category : Identifiable {

}
