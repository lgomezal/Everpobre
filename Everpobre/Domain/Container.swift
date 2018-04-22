//
//  Container.swift
//  Everpobre
//
//  Created by luis gomez alonso on 29/3/18.
//  Copyright © 2018 luis gomez alonso. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct Container {
    
    static var mainContainer : NSPersistentContainer = {
        let c = NSPersistentContainer(name: "Everpobre")
        c.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error {
                // Loggear esto en crashlytics
                fatalError("Error al cargar la BD")
            }
        // Hace que cualquier hilo de background haga que se actualice el main
        c.viewContext.automaticallyMergesChangesFromParent = true
        })
        return c
    }()
    
}

func deleteAllCoreData() {
    let context = Container.mainContainer.viewContext
    
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

func insertDefaultNotebook() {
    
    let context = Container.mainContainer.viewContext
    
    let noteReq = Notebook.fetchRequest()
    let results = try? context.fetch(noteReq)
    
    if results?.count == 0 {
        let notebook = Notebook(name: "My first Notebook", inContext: context, isDefault: "S")
        
        let date = Calendar.current.date(byAdding: .month, value: 12, to: (notebook.createDate))
        
        _ = Note(title: "My first Note", text: "", notebook: notebook, expirationDate: date!, inContext: context)
        
        // Guardamos
        if context.hasChanges {
            do {
                try context.save()
            }catch{
                print("Problemas al salvar")
            }
        }
    }
}






