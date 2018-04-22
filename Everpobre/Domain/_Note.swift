// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Note.swift instead.

import Foundation
import CoreData

public enum NoteAttributes: String {
    case createDate = "createDate"
    case expirationDate = "expirationDate"
    case text = "text"
    case title = "title"
}

public enum NoteRelationships: String {
    case notebook = "notebook"
    case photo = "photo"
}

open class _Note: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Note"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Note.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var createDate: Date

    @NSManaged open
    var expirationDate: Date

    @NSManaged open
    var text: String?

    @NSManaged open
    var title: String

    // MARK: - Relationships

    @NSManaged open
    var notebook: Notebook?

    @NSManaged open
    var photo: NSSet

    open func photoSet() -> NSMutableSet {
        return self.photo.mutableCopy() as! NSMutableSet
    }

}

extension _Note {

    open func addPhoto(_ objects: NSSet) {
        let mutable = self.photo.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.photo = mutable.copy() as! NSSet
    }

    open func removePhoto(_ objects: NSSet) {
        let mutable = self.photo.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.photo = mutable.copy() as! NSSet
    }

    open func addPhotoObject(_ value: PhotoContainer) {
        let mutable = self.photo.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.photo = mutable.copy() as! NSSet
    }

    open func removePhotoObject(_ value: PhotoContainer) {
        let mutable = self.photo.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.photo = mutable.copy() as! NSSet
    }

}

