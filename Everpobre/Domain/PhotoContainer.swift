import Foundation
import CoreData
import UIKit

@objc(PhotoContainer)
open class PhotoContainer: _PhotoContainer {
    
    convenience init(image: UIImage,
                     note: Note,
                     inContext: NSManagedObjectContext) {
        self.init(context: inContext)
        self.image = image
        self.note = note
    }
    
}

extension PhotoContainer {
    var image : UIImage {
        
        get {
            // NSData -> UIImage
            let img = UIImage(data: self.imageData! as Data)
            return img!
        }
        
        set {
            // UIImage -> NSData
            let data = UIImageJPEGRepresentation(newValue, 1)
            self.imageData = data! as NSData
        }
    }
}
