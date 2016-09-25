//
//  ViewBusinessLocationVC.swift
//  Bizmi
//
//  Created by Alex on 8/10/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import MapKit

class ViewBusinessLocationVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var regionRadius: CLLocationDistance = 100
    
    var location: GeoPoint?
    
    var loc: CLLocation!
    
    var newDistance: CLLocationDistance!
    
    var businessName: String!
    
    var address: String!
    
    var isCentered: Bool = false
    
    override func viewDidLoad() {
        map.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            if location?.latitude != 0 && location?.longitude != 0{
                
                map.showsUserLocation = true
                
                loc = CLLocation(latitude: Double(location!.latitude), longitude: Double(location!.longitude) )
                
                createAnnotationForLocation(loc)
    
            }
            
        }else {
            
            locationManager.requestWhenInUseAuthorization()
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    
        centerMapOnLocation(2)
        isCentered = true
        
    }
    
    func centerMapOnLocation(_ scaleFactor: Double) {
        
        if !isCentered {
    
            let userLoc = map.userLocation
            
            newDistance = CLLocation(latitude: userLoc.coordinate.latitude, longitude: userLoc.coordinate.longitude).distance(from: CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))

            let region = MKCoordinateRegionMakeWithDistance(userLoc.coordinate,scaleFactor * newDistance, scaleFactor * newDistance)
            let adjustRegion = map.regionThatFits(region)
            map.setRegion(adjustRegion, animated:true)
            
        }
    }
    
    func openMapForPlace() {
    
        let coordinates = CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, newDistance, newDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(businessName): \(address)"
        mapItem.openInMaps(launchOptions: options)
        
    }
    
    func createAnnotationForLocation(_ location: CLLocation){

        let business = BusinessAnnotation(coordinate: location.coordinate, title: "\(businessName)", subtitle: "")
        business.coordinate = location.coordinate
        map.addAnnotation(business)
    
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let annotationIdentifier = "BusinessPin"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "Marker_Large")
        }
        
        return annotationView
    }
    
    @IBAction func getDirectionsBtnPressed(_ sender: AnyObject) {
        openMapForPlace()
    }
    
    
    @IBAction func cancelBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
