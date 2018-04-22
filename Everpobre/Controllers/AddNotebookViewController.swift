//
//  AddNotebookViewController.swift
//  Everpobre
//
//  Created by luis gomez alonso on 8/4/18.
//  Copyright © 2018 luis gomez alonso. All rights reserved.
//

import UIKit
import CoreData

protocol AddNotebookViewControllerDelegate {
    func didAddNotebook(notebook: Notebook)
}

class AddNotebookViewController: UIViewController, UITextFieldDelegate {
    
    var topImgConstraint: NSLayoutConstraint!
    var bottomImgConstraint: NSLayoutConstraint!
    var leftImgConstraint: NSLayoutConstraint!
    var rightImgConstraint: NSLayoutConstraint!
    
    var notebook: Notebook? {
        didSet {
            notebookTextField.text = notebook?.name
        }
    }
    
    var delegate: AddNotebookViewControllerDelegate?
    
    let notebookLabel: UILabel = {
        let label = UILabel()
        label.text = "Notebook Name:"
        label.translatesAutoresizingMaskIntoConstraints  = false
        return label
    }()
    let notebookTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.lightText
        textField.translatesAutoresizingMaskIntoConstraints  = false
        return textField
    }()
    let noteLabel: UILabel = {
        let label = UILabel()
        label.text = "Note Name:"
        label.translatesAutoresizingMaskIntoConstraints  = false
        return label
    }()
    let noteTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.lightText
        textField.translatesAutoresizingMaskIntoConstraints  = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewConstraints()
        
        notebookTextField.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pressCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(pressSave))
        
        // MARK: Gestures
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        
        view.addGestureRecognizer(swipeGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = notebook == nil ? "Create notebook" : "Edit notebook"
    }
    
    private func viewConstraints(){
    
        let backView = UIView()
        backView.backgroundColor = UIColor.white
        
        backView.addSubview(notebookLabel)
        backView.addSubview(notebookTextField)
        backView.addSubview(noteLabel)
        backView.addSubview(noteTextField)
        
        // MARK: Autolayout.
        
        let viewDict = ["notebookLabel":notebookLabel,"notebookTextField":notebookTextField,"noteLabel":noteLabel,"noteTextField":noteTextField]
        
        // Horizontals
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-5-[notebookLabel]-5-[notebookTextField(200)]", options: [], metrics: nil, views: viewDict)
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-5-[noteLabel]-5-[noteTextField(240)]", options: [], metrics: nil, views: viewDict))
        
        // Verticals
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[notebookLabel]", options: [], metrics: nil, views: viewDict))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[notebookTextField]", options: [], metrics: nil, views: viewDict))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-120-[noteLabel]", options: [], metrics: nil, views: viewDict))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-120-[noteTextField]", options: [], metrics: nil, views: viewDict))
        
        backView.addConstraints(constraints)
        
        self.view = backView
        
        
    }
    
    @objc func pressSave(){
        CreateNotebook()
    }
    
    private func CreateNotebook(){
        let context = Container.mainContainer.viewContext
        
        let notebook = Notebook(name: notebookTextField.text!, inContext: context, isDefault: "N")
        
        let date = Calendar.current.date(byAdding: .month, value: 12, to: (notebook.createDate))
        
        _ = Note(title: noteTextField.text!, text: "", notebook: notebook, expirationDate: date!, inContext: context)
        
        do{
            try context.save()
            
            dismiss(animated: true){
                self.delegate?.didAddNotebook(notebook: notebook)
            }
        } catch let saveErr {
            print("Failed to save notebook:", saveErr)
        }
    }
    
    @objc func pressCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func closeKeyboard()
    {
        notebookTextField.resignFirstResponder()
        noteTextField.resignFirstResponder()
    }
}
