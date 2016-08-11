//
//  ViewBusinessVC.swift
//  Bizmi
//
//  Created by Alex on 8/6/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import PhoneNumberKit

class ViewBusinessVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var businessProfileImg: UIImageView!
    
    @IBOutlet weak var businessNameLbl: UILabel!
    
    @IBOutlet weak var businessTypeLbl: UILabel!
    
    @IBOutlet weak var businessDescLbl: TTTAttributedLabel!
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var locationBtn: UIButton!
    
    @IBOutlet weak var phoneNumberBtn: ButtonBorderBlue!
    
    @IBOutlet weak var aboutBusinessLbl: UILabel!
  
    @IBOutlet weak var messageBtn: ButtonBorderBlue!
    
    @IBOutlet weak var websiteBtn: ButtonBorderBlue!
    
    @IBOutlet weak var hoursBtn: ButtonBorderBlue!
    
    @IBOutlet weak var subscribeBtn: UIButton!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var backendlessUser: BackendlessUser!
    
    let locationManager = CLLocationManager()
    
    var regionRadius: CLLocationDistance = 100
    
    var isCentered = false
    
    var location: GeoPoint?
    
    var business: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.setContentOffset(CGPointMake(0, 65), animated: true)
        map.delegate = self
        
        businessDescLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
        
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = true
        disableBtns()
        populateDataFields()
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.navigationBarHidden = false
    }

    func disableBtns(){
    
        phoneNumberBtn.enabled = false
        messageBtn.enabled = false
        websiteBtn.enabled = false
        hoursBtn.enabled = false
        subscribeBtn.enabled = false

    }
    
    func enableBtns(){
        
        phoneNumberBtn.enabled = true
        messageBtn.enabled = true
        websiteBtn.enabled = true
        hoursBtn.enabled = true
        subscribeBtn.enabled = true
        
    }

    func populateDataFields(){
    
        if let businessUser = backendlessUser{
        
            business = User()
            business.populateUserData(businessUser)
            
            self.navigationItem.title = "\(business.businessName)"

            
            let URL = NSURL(string: "\(business.userProfilePicLocation)")!
            let placeholderImage = UIImage(named: "Placeholder")!
            
            businessProfileImg.af_setImageWithURL(URL, placeholderImage: placeholderImage)
            businessNameLbl.text = business.businessName
            businessTypeLbl.text = business.businessType
            businessDescLbl.text = business.businessDesc
            aboutBusinessLbl.text = "About \(business.businessName)"
            phoneNumberBtn.setTitle("\(business.phoneNumber)", forState: .Normal)
            
            location = business.businessLocation
            
            enableBtns()
            
            locationAuthStatus()
            
        }
    
    }
    
    func locationAuthStatus() {
        
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            
            if !isCentered{ //Only needs to hapen once
                if location?.latitude != 0 && location?.longitude != 0{
                    
                    let loc = CLLocation(latitude: Double(location!.latitude), longitude: Double(location!.longitude) )
                    
                    print(loc)
                    
                    reverseGeoLocate(loc)

                    centerMapOnLocation(loc, scaleFactor: 3)
                    
                    createAnnotationForLocation(loc)
                    
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
    
    func createAnnotationForLocation(location: CLLocation){

        let businessAnnotation = BusinessAnnotation(coordinate: location.coordinate, title: "\(business.businessName)", subtitle: "\(business.businessType)")
        businessAnnotation.coordinate = location.coordinate
        map.addAnnotation(businessAnnotation)
    
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !annotation.isKindOfClass(MKUserLocation) else {
            return nil
        }
        
        let annotationIdentifier = "BusinessPin"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            annotationView = av
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "Marker_Large")
        }
        
        return annotationView
    }
    
    func reverseGeoLocate(location: CLLocation){
 
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if let marks = placemarks where marks.count > 0 {
                
                let pm = marks[0] as CLPlacemark
                
                    if let street = pm.name,locality = pm.locality, state = pm.administrativeArea, zip = pm.postalCode{
                        self.locationBtn.setTitle("\(street), \(locality), \(state) \(zip)", forState: .Normal)
                    }
        
            }else {
                print("there was an error no location")
            }
      
        })
    
    }

    
    @IBAction func onMessageBtnPressed(sender: AnyObject) {
    }
    
    @IBAction func onSubscribeBtnPressed(sender: AnyObject) {
        
        let currentuser = appDelegate.backendless.userService.currentUser
 
        let dataStore = appDelegate.self.backendless.persistenceService.of(Follow.ofClass())
        
        let whereClause = "From = '\(currentuser.objectId)' AND To = '\(business.userObjectID)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        dataStore.find(dataQuery,
                    response: { (follows : BackendlessCollection!) -> () in
                    
                if follows.getCurrentPage().count > 0 {
                    
                    let follow = follows.getCurrentPage()[0] as! Follow

                    // now delete the saved object
                    dataStore.remove(
                        follow,
                        response: { (result: AnyObject!) -> Void in
                            print("Follow has been deleted: \(result)")
                            self.subscribeBtn.setTitle("Subscribe to Business", forState: .Normal)
                            self.subscribeBtn.backgroundColor = DARK_PRIMARY_COLOR
                        },
                        error: { (fault: Fault!) -> Void in
                            print("Server reported an error (2): \(fault)")
                    })
                    
                }else{
                    
                    let follow = Follow()
                    follow.From = currentuser.objectId
                    follow.To = self.business.userObjectID
                    
                    var error: Fault?
                    let result = self.appDelegate.backendless.data.save(follow, error: &error) as? Follow
                    if error == nil {
                        print("Follow has been saved: \(result?.To)")
                        self.subscribeBtn.setTitle("Unsubscribe from Business", forState: .Normal)
                        self.subscribeBtn.backgroundColor = ACCENT_COLOR
                    }
                    else {
                        print("Server reported an error: \(error)")
                    }
                    
                }
                       
            },
               error: { (fault : Fault!) -> () in
                print("Server reported an error (ASYNC): \(fault.description)")
            }
        )

        
        
      
        
    }
    
    @IBAction func cancelBtnPressed(sender: AnyObject) {
        //Dismiss VC
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func locationBtnPressed(sender: UIButton) {
        
        if let title = sender.titleLabel?.text {
            performSegueWithIdentifier("ViewBusinessLocation", sender: title)
        }
        
    }
    
    @IBAction func phoneNumberBtnPressed(sender: AnyObject) {
        
        let stringArray = business.phoneNumber.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let phoneNumber = stringArray.joinWithSeparator("")
        
        callNumber(phoneNumber)
        
    }
    
    @IBAction func businessWebsiteBtnPressed(sender: AnyObject) {
        performSegueWithIdentifier("ViewBusinessWebsite", sender: nil)
    }

    @IBAction func hoursBtnPressed(sender: AnyObject) {
        performSegueWithIdentifier("ViewBusinessHours", sender: nil)
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewBusinessLocation" {
            if let viewLocationVC = segue.destinationViewController as? ViewBusinessLocationVC{
                
                viewLocationVC.location = location
                
                if let address = sender as? String{
                    viewLocationVC.address = address
                    viewLocationVC.businessName = business.businessName
                }
                
            }
            
        }
        
        if segue.identifier == "ViewBusinessWebsite" {
            if let websiteVC = segue.destinationViewController as? ViewBusinessWebsiteVC{
                websiteVC.URL = business.businessWebsite
            }
            
        }
        
        if segue.identifier == "ViewBusinessHours" {
            if let hoursVC = segue.destinationViewController as? ViewBusinessHoursVC{
                hoursVC.hours = business.businessHours
            }
            
        }
        
    }
    
}












