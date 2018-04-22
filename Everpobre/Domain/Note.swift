import Foundation
import CoreData

@objc(Note)
open class Note: _Note {
	
}

extension Note {
    convenience init(title: String,
                     text: String,
                     notebook: Notebook,
                     expirationDate: Date,
                     inContext: NSManagedObjectContext) {
        
        self.init(context: inContext)
        self.notebook = notebook
        self.title = title
        self.text = text
        self.createDate = Date()
        self.expirationDate = Date()
    }
    
    convenience init(title: String,
                     text: String,
                     photo: NSSet,
                     notebook: Notebook,
                     expirationDate: Date,
                     inContext: NSManagedObjectContext) {
        
        self.init(title: title, text: text, notebook: notebook, expirationDate: expirationDate, inContext: inContext)
        self.photo = photo
    }
}
