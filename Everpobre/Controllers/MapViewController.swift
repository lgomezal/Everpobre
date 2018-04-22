//
//  MapViewController.swift
//  Everpobre
//
//  Created by luis gomez alonso on 22/4/18.
//  Copyright © 2018 luis gomez alonso. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts

class MapViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    let mapView = MKMapView()
    let textField = UITextField()
    
    override func loadView() {
        
        let backView = UIView()
        
        backView.addSubview(mapView)
        backView.addSubview(textField)
        textField.backgroundColor = UIColor.init(white: 1, alpha: 0.7)
        
        // MARK: Autolayout.
        mapView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let dictViews = ["mapView": mapView, "textField": textField]
        
        // Horizontals
        var constraint = NSLayoutConstraint.constraints(withVisualFormat: "|-0-[mapView]-0-|", options: [], metrics: nil, views: dictViews)
        
        constraint.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-20-[textField]-20-|", options: [], metrics: nil, views: dictViews))
        
        // Verticals
        
        constraint.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[mapView]-0-|", options: [], metrics: nil, views: dictViews))
        
        constraint.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[textField(40)]", options: [], metrics: nil, views: dictViews))
        
        constraint.append(NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: backView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 20))
        
        backView.addConstraints(constraint)
        
        self.view = backView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D.init(latitude: 40.416736, longitude: -3.703306), span: MKCoordinateSpan.init(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        mapView.setRegion(region, animated: false)
    }
    
    // MARK: MapView Delegates
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let centerCoord = mapView.centerCoordinate
        
        
        let location = CLLocation(latitude: centerCoord.latitude, longitude: centerCoord.longitude)
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarkArray, error) in
            
            if let places = placeMarkArray {
                
                if let place = places.first {
                    
                    DispatchQueue.main.async
                        {
                            if let postalAdd = place.postalAddress
                            {
                                self.textField.text =  "\(postalAdd.street) ,  \(postalAdd.city)"
                            }
                            
                    }
                }
                
                
            }
            
        }
        
        
    }
    
    // MARK: Text Field Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        mapView.isScrollEnabled = false
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text != nil && !textField.text!.isEmpty
        {
            
            mapView.isScrollEnabled = false
            
            let geocoder = CLGeocoder()
            let postalAddress = CNMutablePostalAddress()
            
            postalAddress.street = textField.text!
            // postalAddress.subAdministrativeArea
            // postalAddress.subLocality
            postalAddress.isoCountryCode = "ES"
            
            geocoder.geocodePostalAddress(postalAddress) { (placeMarkArray, error) in
                
                if placeMarkArray != nil && placeMarkArray!.count > 0
                {
                    let placemark = placeMarkArray?.first
                    
                    DispatchQueue.main.async
                        {
                            let region = MKCoordinateRegion(center:placemark!.location!.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.004, longitudeDelta: 0.004))
                            self.mapView.setRegion(region, animated: true)
                    }
                    
                    
                }
                
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    
}
