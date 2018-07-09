//
//  CoreDataTableViewController.swift
//  Everpobre
//
//  Created by luis gomez alonso on 5/4/18.
//  Copyright © 2018 luis gomez alonso. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var noteToChangeNB : Note?
    var noteChangeIndex : IndexPath?
    var notes: [Note] = []
    
    // MARK: - Properties
    var fetchedResultsController : NSFetchedResultsController<Notebook>!
    
    let defaultNoteSorts = [NSSortDescriptor(key: "title", ascending: true)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Título de la vista
        self.title = "EverPobre"
        
        // Creo el botón derecho de añadir nota
        let rightButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addNoteSelectinNotebbok))
        let rightButton2 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        
        navigationItem.rightBarButtonItems = [rightButton2, rightButton]
        
        // Creo el botón izquierdo de añadir notebook
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(manageNotebooks))
        
        // MARK: Fetch Request.
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        
        let sortByDefault = NSSortDescriptor(key: "isDefault", ascending: false)
        let sortByTitle = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortByDefault,sortByTitle]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        try! fetchedResultsController.performFetch()
        
        if fetchedResultsController.fetchedObjects?.count == 0
        {
            // Sólo la primera vez, cuando no hay default. Lo hacemos en el ViewContext porque es indispensable para la App.
            _ = Notebook(name: "My first Notebook", inContext: viewMOC, isDefault: "S")
            
            try! viewMOC.save()
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
        
        prepareSplitDetail()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (fetchedResultsController.fetchedObjects?.count)!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let notebook = fetchedResultsController.object(at: IndexPath(row: section, section: 0))
        return notebook.notes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        }
        let notebook = fetchedResultsController.object(at: IndexPath(row: indexPath.section, section: 0))
        let notes = notebook.notes.sortedArray(using: defaultNoteSorts) as! [Note]
        cell?.textLabel?.text = notes[indexPath.row].title
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notebook = fetchedResultsController.object(at: IndexPath(row: indexPath.section, section: 0))
        let notes = notebook.notes.sortedArray(using: defaultNoteSorts) as! [Note]
        let note = notes[indexPath.row]
        
        let noteVC = NoteViewController()
        noteVC.note = note
        
        let detailNavController = UINavigationController(rootViewController: noteVC)
        
        splitViewController?.showDetailViewController(detailNavController, sender: nil)
        
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let notebook = fetchedResultsController.object(at: IndexPath(row: section, section: 0))
        return notebook.name
    }
    
    // MARK: UIBarButtons Actions
    
    @objc func addNewNote()  {
        
        let defaultNotebook = fetchedResultsController.fetchedObjects!.first!
        addNewNoteToNotebook(defaultNotebook)
    }
    
    @objc func addNewNoteToNotebook(_ notebook:Notebook)  {
        
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        privateMOC.perform {
            
            let notebookPrivate = (privateMOC.object(with: notebook.objectID) as! Notebook)
            
            let date = Calendar.current.date(byAdding: .month, value: 12, to: (Date()))
            _ = Note(title: "New Note", text: "", notebook: notebookPrivate, expirationDate: date!, inContext: privateMOC)
            
            try! privateMOC.save()
        }
    }
    
    @objc func addNoteSelectinNotebbok(barButton:UIBarButtonItem)
    {
        let notebooksTableViewController = NotebooksTableViewController(style: .plain)
        notebooksTableViewController.notebooks = fetchedResultsController.fetchedObjects!
        notebooksTableViewController.delegate = self
        let navController = UINavigationController(rootViewController: notebooksTableViewController)
        notebooksTableViewController.accion = Accion.addNewNoteNotebook
        
        navController.modalPresentationStyle = .overCurrentContext
        
        present(navController, animated: true, completion: nil)
        
    }
    
    @objc func manageNotebooks(barButton:UIBarButtonItem)
    {
        let notebooksTableViewController = NotebooksTableViewController(style: .plain)
        notebooksTableViewController.notebooks = fetchedResultsController.fetchedObjects!
        notebooksTableViewController.delegate = self
        let navController = UINavigationController(rootViewController: notebooksTableViewController)
        notebooksTableViewController.accion = Accion.listNotebooks
        
        navController.modalPresentationStyle = .overCurrentContext
        
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: fetchedResultController Delegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

// MARK: - Table Data Source
extension NotesTableViewController {
  
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            let context = DataManager.sharedManager.persistentContainer.viewContext
            // Guardamos la nota que quieren borrar
            let notebook = self.fetchedResultsController.object(at: IndexPath(row: indexPath.section, section: 0))
            let notes = notebook.notes.sortedArray(using: self.defaultNoteSorts) as! [Note]
            let noteToDelete = notes[indexPath.row]
            
            context.delete(noteToDelete)
            
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
            notebooksTableViewController.notebooks = self.fetchedResultsController.fetchedObjects!
            notebooksTableViewController.delegate = self
            let navController = UINavigationController(rootViewController: notebooksTableViewController)
            
            // Guardamos la nota y el indexpath que quieren cambiar de notebook
            let notebook = self.fetchedResultsController.object(at: IndexPath(row: indexPath.section, section: 0))
            let notes = notebook.notes.sortedArray(using: self.defaultNoteSorts) as! [Note]
            
            self.noteToChangeNB = notes[indexPath.row]
            self.noteChangeIndex = indexPath
            
            notebooksTableViewController.accion = .changeOneNote
            
            navController.modalPresentationStyle = .overCurrentContext
            
            self.present(navController, animated: true, completion: nil)
        }
        changeNotebook.backgroundColor = UIColor.blue
        
        return [delete, changeNotebook]
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
}

extension NotesTableViewController {
    
    func prepareSplitDetail() {
        // Solamente si es iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            let noteVC = NoteViewController()
            // Asignamos delegados
            //self.delegate = noteVC as? NotesTableViewControllerDelegate
            // Ponemos la primera nota del primer notebook
            let notebook = self.fetchedResultsController.object(at: IndexPath(row: 0, section: 0))
            if let notes = notebook.notes.sortedArray(using: self.defaultNoteSorts) as? [Note] {
                let note = notes[0]
                noteVC.note = note
                let detailNavController = UINavigationController(rootViewController: noteVC)
                splitViewController?.showDetailViewController(detailNavController, sender: nil)
            }
        }
    }
}

// MARK: - Delegate NotebooksTableViewController
extension NotesTableViewController: NotebooksTableViewControllerDelegate {
    
    func notebooksTableViewController(_ vc: NotebooksTableViewController, didSelectNotebook: Notebook, accion: Accion, notebookToDelete: Notebook?) {
        
        switch accion {
        case .changeOneNote:
            let notebook = didSelectNotebook
            let noteToChange = self.noteToChangeNB
            
            noteToChange?.notebook = notebook
            
            // Guardamos
            let context = DataManager.sharedManager.persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                }catch{
                    print("Problemas al salvar")
                }
            }
        case .listNotebooks:
            let notebookSelected = didSelectNotebook
            
            let context = DataManager.sharedManager.persistentContainer.viewContext
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
            let context = DataManager.sharedManager.persistentContainer.viewContext
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
            let context = DataManager.sharedManager.persistentContainer.viewContext
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
            let context = DataManager.sharedManager.persistentContainer.viewContext
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




