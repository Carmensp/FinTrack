//
//  Category+CoreDataProperties.swift
//  FinTrack
//
//  Created by Carmen on 05/10/2026.
//
//

public import Foundation
public import CoreData


public typealias CategoryCoreDataPropertiesSet = NSSet

extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged nonisolated public var id: UUID?
    @NSManaged nonisolated public var name: String?
    @NSManaged nonisolated public var icon: String?
    @NSManaged nonisolated public var attribute: NSObject?

}

extension Category : Identifiable {

}
