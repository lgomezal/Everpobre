// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Notebook.swift instead.

import Foundation
import CoreData

public enum NotebookAttributes: String {
    case createDate = "createDate"
    case isDefault = "isDefault"
    case name = "name"
}

public enum NotebookRelationships: String {
    case notes = "notes"
}

open class _Notebook: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Notebook"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Notebook.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var createDate: Date

    @NSManaged open
    var isDefault: String

    @NSManaged open
    var name: String

    // MARK: - Relationships

    @NSManaged open
    var notes: NSSet

    open func notesSet() -> NSMutableSet {
        return self.notes.mutableCopy() as! NSMutableSet
    }

}

extension _Notebook {

    open func addNotes(_ objects: NSSet) {
        let mutable = self.notes.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.notes = mutable.copy() as! NSSet
    }

    open func removeNotes(_ objects: NSSet) {
        let mutable = self.notes.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.notes = mutable.copy() as! NSSet
    }

    open func addNotesObject(_ value: Note) {
        let mutable = self.notes.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.notes = mutable.copy() as! NSSet
    }

    open func removeNotesObject(_ value: Note) {
        let mutable = self.notes.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.notes = mutable.copy() as! NSSet
    }

}

