//
//  NoteViewController.swift
//  Everpobre
//
//  Created by luis gomez alonso on 7/4/18.
//  Copyright © 2018 luis gomez alonso. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class NoteViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, SelectInMapDelegate {
    
    var placemark: CLPlacemark?
    var userAddress: String?
    
    let dateLabel = UILabel()
    let expirationDate = UITextField()
    let titleTextField = UITextField()
    let topLine = UIView()
    let noteTextView = UITextView()
    
    let locationLabel = UILabel()
    var bottomConstraint:NSLayoutConstraint!
    
    var note: Note!
    var pictures: [PhotoContainer] = []
    var imageViews: [UIImageView] = []
    
    
    let dateFormatter = { () -> DateFormatter in
        let dateF = DateFormatter()
        dateF.dateStyle = .short  // Usar este tipo nos garantiza la localización.
        dateF.timeStyle = .none
        return dateF
    }()
    
    var relativePoint = CGPoint.zero
    
    override func loadView() {
        
        let backView = UIView()
        backView.backgroundColor = .white
        
        backView.addSubview(dateLabel)
        backView.addSubview(expirationDate)
        expirationDate.textAlignment = .center
        
        backView.addSubview(titleTextField)
        titleTextField.delegate = self
        
        backView.addSubview(locationLabel)
        
        backView.addSubview(noteTextView)
        noteTextView.delegate = self
        
        // titles labels:
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("Title", comment: "title note label")
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        backView.addSubview(titleLabel)
        
        let expirationTitleLabel = UILabel()
        expirationTitleLabel.text = NSLocalizedString("Expiration", comment: "Expiration note label")
        expirationTitleLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        
        backView.addSubview(expirationTitleLabel)
        
        let createTitleLabel = UILabel()
        createTitleLabel.text = NSLocalizedString("Created", comment: "Created note label")
        createTitleLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        backView.addSubview(createTitleLabel)
        
        
        
        
        // MARK: Autolayout.
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        expirationDate.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        expirationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        createTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let viewDict = ["dateLabel":dateLabel,"noteTextView":noteTextView,"titleTextField":titleTextField,"expirationDate":expirationDate,"locationLabel":locationLabel,"titleLabel":titleLabel,"expirationTitleLabel":expirationTitleLabel,"createTitleLabel":createTitleLabel]
        
        // Horizontals
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-10-[titleTextField]-10-[expirationDate]-10-[dateLabel]-10-|", options: [], metrics: nil, views: viewDict)
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-10-[noteTextView]-10-|", options: [], metrics: nil, views: viewDict))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-10-[locationLabel]-10-|", options: [], metrics: nil, views: viewDict))
        
        constraints.append(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: titleTextField, attribute: .left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: expirationTitleLabel, attribute: .centerX, relatedBy: .equal, toItem: expirationDate, attribute: .centerX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: createTitleLabel, attribute: .right, relatedBy: .equal, toItem: dateLabel, attribute: .right, multiplier: 1, constant: 0))
        
        
        // Verticals
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[dateLabel]-4-[createTitleLabel]-[locationLabel]-[noteTextView]", options: [], metrics: nil, views: viewDict))
        
        constraints.append(NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: backView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 10))
        bottomConstraint = NSLayoutConstraint(item: noteTextView, attribute: .bottom, relatedBy: .equal, toItem: backView.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -10)
        constraints.append(bottomConstraint)
        
        
        
        constraints.append(NSLayoutConstraint(item: titleTextField, attribute: .lastBaseline, relatedBy: .equal, toItem: dateLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: expirationDate, attribute: .lastBaseline, relatedBy: .equal, toItem: dateLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: titleLabel, attribute: .lastBaseline, relatedBy: .equal, toItem: createTitleLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: expirationTitleLabel, attribute: .lastBaseline, relatedBy: .equal, toItem: createTitleLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        
        backView.addConstraints(constraints)
        
        // MARK. Top line
        noteTextView.addSubview(topLine)
        
        topLine.translatesAutoresizingMaskIntoConstraints = false
        var lineContraints = NSLayoutConstraint.constraints(withVisualFormat: "|-0-[line]-0-|", options: [], metrics: nil, views: ["line":topLine])
        lineContraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[line(1)]", options: [], metrics: nil, views: ["line":topLine]))
        
        noteTextView.addConstraints(lineContraints)
        
        
        self.view = backView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.text = note.title
        noteTextView.text = note.text
        dateLabel.text = dateFormatter.string(from: note.createDate)
        expirationDate.text = dateFormatter.string(from: note.expirationDate)
        
        locationLabel.text = note.address
        
        pictures = note.photo.sortedArray(using: [NSSortDescriptor(key: "tag", ascending: true)]) as! [PhotoContainer]
        
        for picture  in pictures {
            pictures.append(picture)
            addNewImage(UIImage(data: picture.imageData! as Data)!, tag: Int(picture.tag), relativeX: picture.x , relativeY: picture.y)
        }
        
        // MARK: Views
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        expirationDate.inputView = datePicker
        
        // MARK: Toolbar
        
        navigationController?.isToolbarHidden = false
        
        let photoBarButton = UIBarButtonItem(title: NSLocalizedString("Add image", comment: "ToolbarButton"), style: .plain, target: self, action: #selector(catchPhoto))
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let mapBarButton = UIBarButtonItem(title: NSLocalizedString("Add Location", comment: "ToolbarButton"), style: .plain, target: self, action: #selector(addLocation))
        
        self.setToolbarItems([photoBarButton,flexible,mapBarButton], animated: false)
        
        // MARK: Gestures
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        
        view.addGestureRecognizer(swipeGesture)
        
        setupViewsWithKeyboards()
    }
    
    @objc func closeKeyboard()
    {
        
        if noteTextView.isFirstResponder
        {
            noteTextView.resignFirstResponder()
        }
        else if titleTextField.isFirstResponder
        {
            titleTextField.resignFirstResponder()
        }
        else if expirationDate.isFirstResponder
        {
            expirationDate.resignFirstResponder()
        }
    }
    
    // MARK: TextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        let newText = textField.text ?? ""
        if newText.count > 0
        {
            let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
            privateMOC.perform {
                let privateNote = privateMOC.object(with: self.note.objectID) as! Note
                privateNote.title = newText
                try! privateMOC.save()
            }
        }
    }
    
    // MARK: Date Picker
    @objc func dateChanged(_ datePicker:UIDatePicker)
    {
        expirationDate.text = dateFormatter.string(from: datePicker.date)
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        privateMOC.perform {
            let privateNote = privateMOC.object(with: self.note.objectID) as! Note
            privateNote.expirationDate = datePicker.date.addingTimeInterval(NSTimeIntervalSince1970)
            try! privateMOC.save()
        }
    }
    
    // MARK: TextView Delegate
    func textViewDidEndEditing(_ textView: UITextView)
    {
        let newText = textView.text ?? ""
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        privateMOC.perform {
            let privateNote = privateMOC.object(with: self.note.objectID) as! Note
            privateNote.text = newText
            try! privateMOC.save()
        }
        
    }
    
    // MARK: Toolbar Buttons actions
    
    @objc func catchPhoto(_ barButton:UIBarButtonItem)
    {
        let actionSheetAlert = UIAlertController(title: NSLocalizedString("Add image", comment: "Action Sheet title"), message: nil, preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let useCamera = UIAlertAction(title: NSLocalizedString("Camera", comment: "Action Sheet Value"), style: .default) { (alertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let usePhotoLibrary = UIAlertAction(title: NSLocalizedString("Photo Library", comment: "Action Sheet Value"), style: .default) { (alertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
        
        actionSheetAlert.addAction(useCamera)
        actionSheetAlert.addAction(usePhotoLibrary)
        actionSheetAlert.addAction(cancel)
        
        let popOverCont = actionSheetAlert.popoverPresentationController
        popOverCont?.barButtonItem = barButton
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc func addLocation(_ barButton:UIBarButtonItem)
    {
        let selectAddress = SelectInMapViewController()
        selectAddress.delegate = self
        let navController = UINavigationController(rootViewController: selectAddress)
        navController.modalPresentationStyle = UIModalPresentationStyle.popover
        let popOverCont = navController.popoverPresentationController
        popOverCont?.barButtonItem = barButton
        
        present(navController, animated: true, completion: nil)
        
    }
    
    // MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let currentImages = note.photo.count
        let tag = currentImages + 1
        
        let xRelative = Double(tag*10) / Double(UIScreen.main.bounds.width)
        let yRelative = Double(tag*10) / Double(UIScreen.main.bounds.height)
        
        let backMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        backMOC.perform {
            
            let picture = NSEntityDescription.insertNewObject(forEntityName: "PhotoContainer", into: backMOC) as! PhotoContainer
            
            picture.x = xRelative
            picture.y = yRelative
            picture.rotation = 0
            picture.scale = 1
            picture.tag = Int64(tag)
            picture.imageData = UIImagePNGRepresentation(image)! as NSData
            
            picture.note = (backMOC.object(with: self.note.objectID) as! Note)
            
            try! backMOC.save()
            
            DispatchQueue.main.async {
                self.pictures.append(DataManager.sharedManager.persistentContainer.viewContext.object(with: picture.objectID) as! PhotoContainer)
                self.addNewImage(image, tag: tag, relativeX: xRelative, relativeY: yRelative)
                picker.dismiss(animated: true, completion: nil)
            }
        }
        
        
    }
    
    // MARK: Select In Map Delegate
    func address(_ address: String, lat: Double, lon: Double) {
        locationLabel.text = address
        let backMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        backMOC.perform {
            
            let backNote = (backMOC.object(with: self.note.objectID) as! Note)
            
            backNote.address = address
            backNote.lat = lat
            backNote.lon = lon
            
            try! backMOC.save()
        }
        
    }
    
    // MARK: Manage Keyboard
    func setupViewsWithKeyboards()  {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(notification:Notification)
    {
        let info = notification.userInfo
        let kbSize = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        UIView.animate(withDuration: 0.1) {
            self.bottomConstraint.constant = -(kbSize.height)
        }
        
    }
    
    @objc func keyboardWillHide(notification:Notification)
    {
        UIView.animate(withDuration: 0.1) {
            self.bottomConstraint.constant = -10
        }
    }
    
}
