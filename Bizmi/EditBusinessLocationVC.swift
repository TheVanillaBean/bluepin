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
    
    var location: GeoPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Adjust Location"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(donePressed))
   
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditBusinessLocationVC.onCurrentUserUpdated), name: "userUpdated", object: nil)
        
        map.delegate = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.Done
       
    }
    
    override func viewWillAppear(animated: Bool) {
        locationAuthStatus()
    }

    func onCurrentUserUpdated(){
        //Dismiss VC
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    func donePressed(){
    
        if let center = centerCoordinates {
            
            let mapLatitude = center.latitude
            let mapLongitude = center.longitude
            let geoPoint = GeoPoint.geoPoint(GEO_POINT(latitude: mapLatitude, longitude: mapLongitude)) as! GeoPoint
            
            let center = "Latitude: \(geoPoint.latitude) Longitude: \(geoPoint.longitude)"
            print(center)

            let properties = [
                "businessLocation" : geoPoint
            ]
            
            DataService.instance.updateUser(properties)
            
        }
    
    }
 
    func locationAuthStatus() {
    
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            
            if !isCentered{ //Only needs to hapen once
                if location?.latitude != 0 && location?.longitude != 0{
                    
                    let loc = CLLocation(latitude: Double(location!.latitude), longitude: Double(location!.longitude) )
                    
                    centerMapOnLocation(loc, scaleFactor: 1)
                }
            }
            
            map.showsUserLocation = true
            
        }else {
        
            locationManager.requestWhenInUseAuthorization()
            
        }
        
    }
    
    func centerMapOnLocation(location: CLLocation, scaleFactor: Double) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * scaleFactor, regionRadius * scaleFactor)
        map.setRegion(coordinateRegion, animated: true)
        isCentered = true
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        if !isCentered && (location?.latitude == 0 && location?.longitude == 0){ //Only needs to hapen once
            if let loc = userLocation.location {
                centerMapOnLocation(loc, scaleFactor: 10)
            }
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
       
        if isCentered{
            centerCoordinates = mapView.centerCoordinate
        }
      
    }
 
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
        
        if let address = searchBar.text{
            getPlacemarkFromAddress(address)
        }
    }
    
//    func createAnnotationForLocation(location: CLLocation){
//    
//        let business = BusinessAnnotation(coordinate: location.coordinate)
//        business.coordinate = map.centerCoordinate
//        map.addAnnotation(business)
//    
//    }
//    
//    func updateAnnotationToCenter(){
//        
//        // Add new annotation
//        let annotation = BusinessAnnotation()
//        annotation.coordinate = map.centerCoordinate
//        map.addAnnotation(annotation)
//
//    }
    
    func getPlacemarkFromAddress(address: String) {
    
        CLGeocoder().geocodeAddressString(address) { ( placemarks: [CLPlacemark]?, error: NSError?) in
            
            if let marks = placemarks where marks.count > 0{
                if let loc = marks[0].location {

                    self.centerMapOnLocation(loc, scaleFactor: 10)
                  //  self.createAnnotationForLocation(loc)
                
                }else{
                    Messages.displayToastMessage(self.view, msg: "Did not retrieve location...")
                }
            }else{
                Messages.displayToastMessage(self.view, msg: "Did not retrieve location...")
            }
            
            
        }
    
    }
    
}

















