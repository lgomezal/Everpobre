//
//  NotebooksTableViewController.swift
//  Everpobre
//
//  Created by luis gomez alonso on 20/4/18.
//  Copyright © 2018 luis gomez alonso. All rights reserved.
//

import UIKit
import CoreData

protocol NotebooksTableViewControllerDelegate: class {
    func notebooksTableViewController(_ vc: NotebooksTableViewController, didSelectNotebook: Notebook, accion: Accion, notebookToDelete: Notebook?)
}

class NotebooksTableViewController: UITableViewController {
    
    var accion: Accion = .listNotebooks
    var notebooks : [Notebook] = []
    var notebook : Notebook!
    var notebookDelete: Notebook?
    var notebookDefault: String = "N"
    
    var delegate: NotebooksTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Título de la vista
        self.title = "Notebooks"
        
        //Recibimos la accion para ver que mostrar en el viewcontroller
        switch accion {
        case .listNotebooks:
            // Creo el botón derecho de añadir notebook
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNotebook))
            // Creo el botón izquierdo para volver con notebook
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(defaultNewNotebook))
        case .changeOneNote:
            break
        case .changeAllNotes:
            break
        case .addNewNoteNotebook:
            break
        case .deleteAllNotes:
            break
        }
        
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (notebooks.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        }
        
        cell?.textLabel?.text = notebooks[indexPath.row].name
        
        if accion == .listNotebooks {
            if notebooks[indexPath.row].isDefault == "S" {
                cell?.accessoryType = .checkmark
                notebook = notebooks[indexPath.row]
            } else {
                cell?.accessoryType = .none
            }
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch accion {
        case .changeOneNote:
            notebook = notebooks[indexPath.row] as Notebook
            // Avisamos al delegado
            delegate?.notebooksTableViewController(self, didSelectNotebook: notebook, accion: accion, notebookToDelete: nil)
            dismiss(animated: true, completion: nil)
        case .listNotebooks:
            notebook = notebooks[indexPath.row] as Notebook
            notebooks[indexPath.row].isDefault = "S"
            for index in 0..<notebooks.count {
                if notebooks[index] == notebooks[indexPath.row] {
                    notebooks[indexPath.row].isDefault = "S"
                } else {
                    let indexpath = IndexPath(row: index, section: 0)
                    notebooks[indexpath.row].isDefault = "N"
                }
            }
            tableView.reloadData()
        case .addNewNoteNotebook:
            notebook = notebooks[indexPath.row] as Notebook
            // Avisamos al delegado
            delegate?.notebooksTableViewController(self, didSelectNotebook: notebook, accion: accion, notebookToDelete: nil)
            dismiss(animated: true, completion: nil)
        case .changeAllNotes:
            let notebook = notebooks[indexPath.row]
            if notebook == notebookDelete {
                let alert = UIAlertController(title: "Delete Notebook", message: "Can not be assigned to the notebook to be deleted, select another", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                // Avisamos al delegado
                delegate?.notebooksTableViewController(self, didSelectNotebook: notebook, accion: accion, notebookToDelete: notebookDelete)
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        notebook = notebooks[indexPath.row] as Notebook
        if notebook.isDefault == "N" {
        
            let editName = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
                self.createOrEditedNotebook(notebook: self.notebook, isNew: false)
            }
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                self.notebookDelete = self.notebook
                self.deleteNotebookNotes()
            }
            return [delete, editName]
        } else {
            return []
        }
    }
    
    @objc func addNewNotebook()  {
        createOrEditedNotebook(notebook: nil, isNew: true)
    }
    
    func createOrEditedNotebook(notebook:Notebook?, isNew:Bool)
    {
        var title = NSLocalizedString("New Notebook", comment: "")
        if isNew == false {
            title = NSLocalizedString("Change Notebook Name", comment: "")
        }
        let actionAlertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        actionAlertController.addTextField { (textField) in
            if isNew {
                textField.placeholder = NSLocalizedString("Enter name", comment: "")
            }
            else {
                textField.text = notebook?.name
            }
        }
        var actionTitle = NSLocalizedString("Change", comment: "")
        if isNew {
            actionTitle = NSLocalizedString("Create", comment: "")
        }
        
        actionAlertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (alert) in
            if let text = actionAlertController.textFields![0].text
            {
                if !text.isEmpty
                {
                    let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
                    
                    if isNew {
                        privateMOC.perform {
                            let notebook = Notebook(name: text, inContext: privateMOC, isDefault: "N")
                            
                            try! privateMOC.save()
                            
                            DispatchQueue.main.async {
                                self.notebooks.append(DataManager.sharedManager.persistentContainer.viewContext.object(with: notebook.objectID) as! Notebook)
                                self.tableView.reloadData()
                            }
                            
                        }
                    }
                    else {
                        
                        privateMOC.perform {
                            let backNotebook = privateMOC.object(with: (notebook?.objectID)!) as! Notebook
                            backNotebook.name = text
                            try! privateMOC.save()
                            
                            DispatchQueue.main.async {
                                
                                self.tableView.reloadData()
                            }
                        }
                        
                    }
                    
                }
            }
        }))
        
        actionAlertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        self.present(actionAlertController, animated: true, completion: nil)
    }
    
    @objc func defaultNewNotebook()  {
        
        // Avisamos al delegado
        delegate?.notebooksTableViewController(self, didSelectNotebook: notebook, accion: accion, notebookToDelete: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func deleteNotebookNotes() {
        
        let alert = UIAlertController(title: "Delete Notebook", message: "If notebook has notes, what do you want to do with them?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [] (_) in
            self.accion = .deleteAllNotes
            // Avisamos al delegado
            self.delegate?.notebooksTableViewController(self, didSelectNotebook: self.notebook, accion: self.accion, notebookToDelete: self.notebook )
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Assign to other Notebook", style: .default, handler: { [] (_) in
            self.accion = .changeAllNotes
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
