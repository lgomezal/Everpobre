// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PhotoContainer.swift instead.

import Foundation
import CoreData

public enum PhotoContainerAttributes: String {
    case imageData = "imageData"
    case rotation = "rotation"
    case scale = "scale"
    case tag = "tag"
    case x = "x"
    case y = "y"
}

public enum PhotoContainerRelationships: String {
    case note = "note"
}

open class _PhotoContainer: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "PhotoContainer"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _PhotoContainer.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var imageData: NSData?

    @NSManaged open
    var rotation: Double

    @NSManaged open
    var scale: Double

    @NSManaged open
    var tag: Int64

    @NSManaged open
    var x: Double

    @NSManaged open
    var y: Double

    // MARK: - Relationships

    @NSManaged open
    var note: Note?

}

