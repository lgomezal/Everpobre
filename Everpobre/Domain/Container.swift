//
//  Container.swift
//  Everpobre
//
//  Created by luis gomez alonso on 29/3/18.
//  Copyright © 2018 luis gomez alonso. All rights reserved.
//

import CoreData
import UIKit

class DataManager: NSObject {
    
    static let sharedManager = DataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Everpobre")
        container.loadPersistentStores(completionHandler: { (storeDescription,error) in
            
            if let err = error {
                // Error to handle.
                print(err)
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        })
        return container
    }()
}


func deleteAllCoreData() {
    let context = DataManager.sharedManager.persistentContainer.viewContext
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook" )
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
        try context.execute(deleteRequest)
    } catch let error as NSError {
        debugPrint(error)
    }
    // Guardamos
    if context.hasChanges {
        do {
            try context.save()
        }catch{
            print("Problemas al salvar")
        }
    }
}






