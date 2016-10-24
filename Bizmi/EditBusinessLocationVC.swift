//
//  EditBusinessLocationVC.swift
//  Bizmi
//
//  Created by Alex on 8/7/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import MapKit

class EditBusinessLocationVC: UIViewController, MKMapViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let locationManager = CLLocationManager()
    
    var regionRadius: CLLocationDistance = 100
    
    var centerCoordinates: CLLocationCoordinate2D?
    
    var isCentered = false
    
    var geoFire: GeoFire!
    
    var uuid: String!
    
    var location: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Adjust Location"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
   
        self.geoFire = GeoFire(firebaseRef: FBDataService.instance.usersRef.child(uuid))
        
        map.delegate = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        geoFire.getLocationForKey(BUSINESS_LOCATION, withCallback: { (loc, error) in
                if (error != nil) {
                }else if (loc != nil) {
                    self.location = loc
                    self.locationAuthStatus()
                } else {
                    self.location = CLLocation(latitude: 0, longitude: 0)
                    self.locationAuthStatus()
                }
            })
    }


    func donePressed(){
    
        if let center = centerCoordinates {
            
            let mapLatitude = center.latitude
            let mapLongitude = center.longitude
            location = CLLocation(latitude: mapLatitude, longitude: mapLongitude)
            
            geoFire.setLocation(location, forKey: BUSINESS_LOCATION) { (error) in
                if (error != nil) {
                } else {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
    
    }
 
    func locationAuthStatus() {
    
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            if !isCentered{
                if location.coordinate.latitude != 0 && location?.coordinate.longitude != 0{
                    centerMapOnLocation(location, scaleFactor: 1)
                }
            }
            map.showsUserLocation = true
        }else {
            locationManager.requestWhenInUseAuthorization()
        }

    }
    
    func centerMapOnLocation(_ location: CLLocation, scaleFactor: Double) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * scaleFactor, regionRadius * scaleFactor)
        map.setRegion(coordinateRegion, animated: true)
        isCentered = true
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if !isCentered && (location.coordinate.latitude == 0 && location.coordinate.longitude == 0){
            if let loc = userLocation.location {
                centerMapOnLocation(loc, scaleFactor: 10)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
       
        if isCentered{
            centerCoordinates = mapView.centerCoordinate
        }
      
    }
 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
        if let address = searchBar.text{
            getPlacemarkFromAddress(address)
        }
    }
    
    func createAnnotationForLocation(location: CLLocation){
    
        let business = BusinessAnnotation(coordinate: location.coordinate)
        business.coordinate = map.centerCoordinate
        map.addAnnotation(business)
    
    }
    
    func updateAnnotationToCenter(){
        
        let annotation = BusinessAnnotation()
        annotation.coordinate = map.centerCoordinate
        map.addAnnotation(annotation)

    }
    
    func getPlacemarkFromAddress(_ address: String) {
    
        CLGeocoder().geocodeAddressString(address) { ( placemarks: [CLPlacemark]?, error: Error?) in
            
            if let marks = placemarks , marks.count > 0{
                if let loc = marks[0].location {
                    self.centerMapOnLocation(loc, scaleFactor: 10)
                }else{
                    Messages.displayToastMessage(self.view, msg: "Did not retrieve location...")
                }
            }else{
                Messages.displayToastMessage(self.view, msg: "Did not retrieve location...")
            }
            
            
        }
    }

}

















