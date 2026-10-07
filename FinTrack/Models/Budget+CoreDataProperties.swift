//
//  Budget+CoreDataProperties.swift
//  FinTrack
//
//  Created by Carmen on 06/10/2026.
//
//

public import Foundation
public import CoreData


public typealias BudgetCoreDataPropertiesSet = NSSet

extension Budget {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Budget> {
        return NSFetchRequest<Budget>(entityName: "Budget")
    }

    @NSManaged nonisolated public var id: UUID?
    @NSManaged nonisolated public var amount: Double
    @NSManaged nonisolated public var month: Date?
    @NSManaged nonisolated public var category: Category?

}

extension Budget : Identifiable {

}
