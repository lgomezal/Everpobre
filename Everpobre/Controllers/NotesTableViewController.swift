//
//  CoreDataTableViewController.swift
//  Everpobre
//
//  Created by luis gomez alonso on 5/4/18.
//  Copyright © 2018 luis gomez alonso. All rights reserved.
//

import UIKit
import CoreData

protocol NotesTableViewControllerDelegate: class {
    func notesTableViewController(_ vc: NotesTableViewController, didSelectNote: Note)
}

class NotesTableViewController: UITableViewController {
    
    var noteToChangeNB : Note?
    var noteChangeIndex : IndexPath?
    var notes: [Note] = []
   
    weak var delegate: NotesTableViewControllerDelegate?
    
    // MARK: - Properties
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Título de la vista
        self.title = "EverPobre"
        
        // Creo el botón derecho de añadir nota
        let rightButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addNewNoteNotebook))
        let rightButton2 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        
        navigationItem.rightBarButtonItems = [rightButton2, rightButton]
        
        // Creo el botón izquierdo de añadir notebook
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(notebookList))
        
        // Preparamos el request
        prepareFetch()
        // Preparamos el split
        prepareSplitDetail()
        
        
    }
    
}

// MARK: - Subclass responsability
extension NotesTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        }
        
        let note = fetchedResultsController?.object(at: indexPath) as! Note
        
        cell?.textLabel?.text = note.title
        
        return cell!
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let note = fetchedResultsController?.object(at: indexPath) as? Note
        
        // Avisamos al delegado
        delegate?.notesTableViewController(self, didSelectNote: note!)
        
    }
    
    @objc func addNewNote() {
        
        let context = Container.mainContainer.viewContext
        
        let noteBookReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        let results = try? context.fetch(noteBookReq)
        
        for data in results as! [NSManagedObject] {
            if data.value(forKey: "isDefault") as! String == "S" {
                let notebook = data as! Notebook
                let date = Calendar.current.date(byAdding: .month, value: 12, to: (Date()))
                _ = Note(title: "New Note", text: "", notebook: notebook, expirationDate: date!, inContext: context)
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
    }
    
    @objc func addNewNoteNotebook()  {
        
        let notebooksTableViewController = NotebooksTableViewController()
        notebooksTableViewController.delegate = self
        let navController = UINavigationController(rootViewController: notebooksTableViewController)
        notebooksTableViewController.accion = Accion.addNewNoteNotebook
        
        navController.modalPresentationStyle = .overCurrentContext
        
        present(navController, animated: true, completion: nil)

    }
    
    @objc func notebookList()  {
        
        let notebooksTableViewController = NotebooksTableViewController()
        notebooksTableViewController.delegate = self
        let navController = UINavigationController(rootViewController: notebooksTableViewController)
        notebooksTableViewController.accion = Accion.listNotebooks
        
        navController.modalPresentationStyle = .overCurrentContext
        
        present(navController, animated: true, completion: nil)
    }
    
}



// MARK: - Delegados
extension NotesTableViewController: NotesTableViewControllerDelegate {
    func notesTableViewController(_ vc: NotesTableViewController, didSelectNote note: Note) {
        
        let noteViewController = NoteViewController()
        noteViewController.note = note
        navigationController?.pushViewController(noteViewController, animated: true)
        
    }
}

// MARK: - Table Data Source
extension NotesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if let fc = fetchedResultsController {
            guard let sections = fc.sections else {
                return 1
            }
            return sections.count
        } else {
            return 0
        
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let fc = fetchedResultsController {
            guard let numberOfRows = fc.sections?[section].numberOfObjects else {
                return 0
            }
            return numberOfRows
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if let fc = fetchedResultsController {
            return fc.sections?[section].name
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        if let fc = fetchedResultsController {
            return fc.section(forSectionIndexTitle: title, at: index)
        } else {
            return 0
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        if let fc = fetchedResultsController {
            return fc.sectionIndexTitles
        } else {
            return nil
        }
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let returnedView = UIView()
//        returnedView.backgroundColor = UIColor.lightGray
//
//        return returnedView
//    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if (self.fetchedResultsController?.sections?[indexPath.section].numberOfObjects)! > 1 {
        
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                
                let context = Container.mainContainer.viewContext
                let note = self.fetchedResultsController?.object(at:indexPath)
                context.delete(note as! NSManagedObject)
                
                // Guardamos
                if context.hasChanges {
                    do {
                        try context.save()
                    }catch{
                        print("Problemas al salvar")
                    }
                }
            }
        
            let changeNotebook = UITableViewRowAction(style: .normal, title: "Change Notebook") { (action, indexPath) in
                let notebooksTableViewController = NotebooksTableViewController()
                notebooksTableViewController.delegate = self
                let navController = UINavigationController(rootViewController: notebooksTableViewController)
            
                // Guardamos la nota y el indexpath que quieren cambiar de notebook
                self.noteToChangeNB = self.fetchedResultsController?.object(at: indexPath) as? Note
                self.noteChangeIndex = indexPath
                
                notebooksTableViewController.accion = .changeOneNote
                
                navController.modalPresentationStyle = .overCurrentContext
            
                self.present(navController, animated: true, completion: nil)
                }
            changeNotebook.backgroundColor = UIColor.blue
        
            return [delete, changeNotebook]
        } else {
            return []
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
}


// MARK: - Fetches
extension NotesTableViewController {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \(e)")
            }
        }
    }
    
    func prepareFetch() {
        // Creo el FetchedResultsController
        let noteReq = Note.fetchRequest()
        noteReq.fetchBatchSize = 100
        //sortDescriptors
        noteReq.sortDescriptors =
            [NSSortDescriptor(key: "notebook.name", ascending: true)]
        
        //Predicates
        let valorS = "S"
        let predicateS = NSPredicate(format: "notebook.name == %@", valorS)
        noteReq.predicate = predicateS
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: noteReq, managedObjectContext: Container.mainContainer.viewContext, sectionNameKeyPath: "notebook.name", cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        let noteReqDefault = Note.fetchRequest()
        
        //sortDescriptors
        noteReqDefault.sortDescriptors =
            [NSSortDescriptor(key: "notebook.name", ascending: true),
             NSSortDescriptor(key: NoteAttributes.title.rawValue, ascending: true)]
        
        //Predicates
        let valorN = "N"
        let predicateN = NSPredicate(format: "notebook.isDefault == %@", valorN)
        noteReq.predicate = predicateN
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: noteReqDefault, managedObjectContext: Container.mainContainer.viewContext, sectionNameKeyPath: "notebook.name", cacheName: nil)
        
//        let frc = NSFetchedResultsController(fetchRequest: noteReq, managedObjectContext: Container.mainContainer.viewContext, sectionNameKeyPath: "notebook.name", cacheName: nil)
        
        //self.fetchedResultsController = frc
    }
}

extension NotesTableViewController {
    
    func prepareSplitDetail() {
        
        let noteVC = NoteViewController()
        // Asignamos delegados
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.delegate = noteVC
        } 
        let indexPath = IndexPath(row: 0, section: 0)
        noteVC.note = fetchedResultsController?.object(at: indexPath) as? Note
        splitViewController?.viewControllers[1] = noteVC
    }
}

// MARK: - Delegate fetch
extension NotesTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
}

// MARK: - Delegate NotebooksTableViewController
extension NotesTableViewController: NotebooksTableViewControllerDelegate {
    
    func notebooksTableViewController(_ vc: NotebooksTableViewController, didSelectNotebook: Notebook, accion: Accion, notebookToDelete: Notebook?) {
        
        switch accion {
        case .changeOneNote:
            let notebook = didSelectNotebook
            let noteToChange = fetchedResultsController?.object(at: noteChangeIndex!) as! Note
            noteToChange.notebook = notebook
            
            // Guardamos
            let context = Container.mainContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                }catch{
                    print("Problemas al salvar")
                }
            }
        case .listNotebooks:
            let notebookSelected = didSelectNotebook
            
            let context = Container.mainContainer.viewContext
            let noteBookReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
            let results = try? context.fetch(noteBookReq)
            
            for data in results as! [NSManagedObject] {
                let notebook = data as! Notebook
                if notebook == notebookSelected {
                    notebook.isDefault = "S"
                } else {
                    notebook.isDefault = "N"
                }
            }
            // Guardamos
            if context.hasChanges {
                do {
                    try context.save()
                }catch{
                    print("Problemas al salvar")
                }
            }
        case .addNewNoteNotebook:
            let notebookSelected = didSelectNotebook
            let context = Container.mainContainer.viewContext
            let date = Calendar.current.date(byAdding: .month, value: 12, to: (Date()))
            _ = Note(title: "Nota Añadida", text: "", notebook: notebookSelected, expirationDate: date!, inContext: context)
            // Guardamos
            if context.hasChanges {
                do {
                    try context.save()
                }catch{
                    print("Problemas al salvar")
                }
            }
        case .changeAllNotes:
            let notebookSelected = didSelectNotebook
            let notebookToDelete = notebookToDelete
            let context = Container.mainContainer.viewContext
            let noteBookReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
            let results = try? context.fetch(noteBookReq)
            
            for data in results as! [NSManagedObject] {
                let notebook = data as! Notebook
                if notebook == notebookToDelete {
                    notes = notebook.notes.allObjects as! [Note]
                    for note in notes {
                        note.notebook = notebookSelected
                    }
                    context.delete(notebookToDelete!)
                }
            }
            // Guardamos
            if context.hasChanges {
                do {
                    try context.save()
                }catch{
                    print("Problemas al salvar")
                }
            }
        case .deleteAllNotes:
            let notebookSelected = didSelectNotebook
            let context = Container.mainContainer.viewContext
            context.delete(notebookSelected)
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
}








