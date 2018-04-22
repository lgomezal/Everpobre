//
//  NoteViewController.swift
//  Everpobre
//
//  Created by luis gomez alonso on 7/4/18.
//  Copyright © 2018 luis gomez alonso. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var imagesArray: [PhotoContainer] = []
    
    let dateLabel = UILabel()
    let dateText = UILabel()
    let expirationDate = UILabel()
    let expirationText = UILabel()
    let titleTextField = UITextField()
    let noteTextView = UITextView()
    
    let imageView = UIImageView()
    
    var topImgConstraint: NSLayoutConstraint!
    var bottomImgConstraint: NSLayoutConstraint!
    var leftImgConstraint: NSLayoutConstraint!
    var rightImgConstraint: NSLayoutConstraint!
    
    var relativePoint: CGPoint!
    
    var note: Note?
    
    override func loadView() {
        
        let backView = UIView()
        backView.backgroundColor = .white
        
        // Configure label
        dateLabel.text = ""
        backView.addSubview(dateLabel)
        dateText.text = "Start:"
        backView.addSubview(dateText)
        
        // Configure Expiration label
        expirationDate.text = ""
        backView.addSubview(expirationDate)
        expirationText.text = "End:"
        backView.addSubview(expirationText)
        
        
        // Configure textField
        titleTextField.placeholder = "Title note"
        backView.addSubview(titleTextField)
        
        // Configure noteTextView
        noteTextView.text = ""
        
        backView.addSubview(noteTextView)
        
        // Configure imageView
        backView.addSubview(imageView)
        
        
        // MARK: Autolayout.
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateText.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        expirationDate.translatesAutoresizingMaskIntoConstraints = false
        expirationText.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDict = ["dateText":dateText,"dateLabel":dateLabel,"noteTextView":noteTextView,"titleTextField":titleTextField,"expirationDate":expirationDate,"expirationText":expirationText]
        
        // Horizontals
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-10-[dateText]-10-[dateLabel]-10-[expirationText]-10-[expirationDate]-10-|", options: [], metrics: nil, views: viewDict)
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-10-[titleTextField]-10-|", options: [], metrics: nil, views: viewDict))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-10-[noteTextView]-10-|", options: [], metrics: nil, views: viewDict))
        
        // Verticals
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[dateText]-10-[titleTextField]-10-[noteTextView]-10-|", options: [], metrics: nil, views: viewDict))
        
        constraints.append(NSLayoutConstraint(item: dateText, attribute: .top, relatedBy: .equal, toItem: backView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 10))
        
        constraints.append(NSLayoutConstraint(item: titleTextField, attribute: .lastBaseline, relatedBy: .equal, toItem: dateText, attribute: .lastBaseline, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: dateLabel, attribute: .lastBaseline, relatedBy: .equal, toItem: dateText, attribute: .lastBaseline, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: expirationText, attribute: .lastBaseline, relatedBy: .equal, toItem: dateLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: expirationDate, attribute: .lastBaseline, relatedBy: .equal, toItem: expirationText, attribute: .lastBaseline, multiplier: 1, constant: 0))
        
        // Img View Constraint.
        
        topImgConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: noteTextView, attribute: .top, multiplier: 1, constant: 75)
        
        bottomImgConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: noteTextView, attribute: .bottom, multiplier: 1, constant: -20)
        
        leftImgConstraint = NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: noteTextView, attribute: .left, multiplier: 1, constant: 20)
        
        rightImgConstraint = NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal, toItem: noteTextView, attribute: .right, multiplier: 1, constant: -20)
        
        var imgConstraints = [NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 75)]
        
        imgConstraints.append(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 100))
        
        imgConstraints.append(contentsOf: [topImgConstraint,bottomImgConstraint,leftImgConstraint,rightImgConstraint])
        
        
        backView.addConstraints(constraints)
        backView.addConstraints(imgConstraints)
        
        NSLayoutConstraint.deactivate([bottomImgConstraint,rightImgConstraint])
        
        
        
        self.view = backView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        noteTextView.delegate = self
        
        // MARK: Navigation Controller
        navigationController?.isToolbarHidden = false
        
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(catchPhoto))
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let mapBarButton = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(addLocation))
        
        self.setToolbarItems([photoBarButton,flexible,mapBarButton], animated: false)
        
        // MARK: Gestures
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        
        view.addGestureRecognizer(swipeGesture)
        
        imageView.isUserInteractionEnabled = true
        
        let moveViewGesture = UILongPressGestureRecognizer(target: self, action: #selector(userMoveImage))
        
        imageView.addGestureRecognizer(moveViewGesture)
        
        // MARK: About Note
        
        if self.note != nil {
            
            syncModelView()
        }
        
    }
    
    @objc func userMoveImage(longPressGesture:UILongPressGestureRecognizer)
    {
        switch longPressGesture.state {
        case .began:
            closeKeyboard()
            relativePoint = longPressGesture.location(in: longPressGesture.view)
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            })
            
        case .changed:
            let location = longPressGesture.location(in: noteTextView)
            
            leftImgConstraint.constant = location.x - relativePoint.x
            topImgConstraint.constant = location.y - relativePoint.y
            
        case .ended, .cancelled:
            
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            })
            
        default:
            break
        }
        
    }
    
    
    @objc func moveImage(tapGesture:UITapGestureRecognizer)
    {
        
        if topImgConstraint.isActive
        {
            if leftImgConstraint.isActive
            {
                leftImgConstraint.isActive = false
                rightImgConstraint.isActive = true
            }
            else
            {
                topImgConstraint.isActive = false
                bottomImgConstraint.isActive = true
            }
        }
        else
        {
            if leftImgConstraint.isActive
            {
                bottomImgConstraint.isActive = false
                topImgConstraint.isActive = true
            }
            else
            {
                rightImgConstraint.isActive = false
                leftImgConstraint.isActive = true
            }
        }
        
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
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
    }
    
    
    override func viewDidLayoutSubviews()
    {
        var rect = view.convert(imageView.frame, to: noteTextView)
        rect = rect.insetBy(dx: -15, dy: -15)
        
        let paths = UIBezierPath(rect: rect)
        noteTextView.textContainer.exclusionPaths = [paths]
    }
    
    func syncModelView() {
        titleTextField.text = note?.title
        noteTextView.text = note?.text
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let creationDate = note?.createDate
        let expiratDate = note?.expirationDate
        expirationDate.text = formatter.string(from: (expiratDate)!)
        dateLabel.text = formatter.string(from: (creationDate)!)
        imagesArray = note?.photo.allObjects as! [PhotoContainer]
        for photo in imagesArray {
            let nsdata = photo.imageData
            let image = UIImage(data: nsdata! as Data)
            imageView.image = image
        }
    }
    
    
    // MARK: Toolbar Buttons actions
    
    @objc func catchPhoto()
    {
        let actionSheetAlert = UIAlertController(title: NSLocalizedString("Add photo", comment: "Add photo"), message: nil, preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let useCamera = UIAlertAction(title: "Camera", style: .default) { (alertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let usePhotoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (alertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        actionSheetAlert.addAction(useCamera)
        actionSheetAlert.addAction(usePhotoLibrary)
        actionSheetAlert.addAction(cancel)
        
        
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc func addLocation()
    {
        let mapViewController = MapViewController()
        
        navigationController?.pushViewController(mapViewController, animated: true)
        
    }
    
    // MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
        
        let context = Container.mainContainer.viewContext
        
        _ = PhotoContainer(image: image, note: note!, inContext: context)
        
        try! note?.managedObjectContext?.save()
        
    }
    
    // MARK: - TextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        note?.title = textField.text!
        
        try! note?.managedObjectContext?.save()
    }
    
    // MARK: - TextView Delegate
    func textViewDidEndEditing(_ textView: UITextView)
    {
        note?.text = textView.text
        
        try! note?.managedObjectContext?.save()
    }
}

extension NoteViewController: NotesTableViewControllerDelegate {
    func notesTableViewController(_ vc: NotesTableViewController, didSelectNote note: Note) {
        self.note = note
        syncModelView()
    }
    
}
