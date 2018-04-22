import Foundation
import CoreData

@objc(Notebook)
open class Notebook: _Notebook {
    
}

extension Notebook {
    convenience init(name: String,
                     inContext: NSManagedObjectContext,
                     isDefault: String) {
        
        self.init(context: inContext)
        self.name = name
        self.createDate = Date()
        self.isDefault = isDefault
    }
}
