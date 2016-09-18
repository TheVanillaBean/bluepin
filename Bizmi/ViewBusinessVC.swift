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
        
        subscribeToNofications()
        
    }
    
    func subscribeToNofications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewBusinessVC.onSubscribedToBusiness), name: "subscribedToBusiness", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewBusinessVC.onSubscriptionStatusRetrieved), name: "subscriptionStatus", object: nil)
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
            
            let currentuser = appDelegate.backendless.userService.currentUser
            
            businessProfileImg.af_setImageWithURL(URL, placeholderImage: placeholderImage)
            businessNameLbl.text = business.businessName
            businessTypeLbl.text = business.businessType
            businessDescLbl.text = business.businessDesc
            aboutBusinessLbl.text = "About \(business.businessName)"
            phoneNumberBtn.setTitle("\(business.phoneNumber)", forState: .Normal)
            DataService.instance.findCustomerSubscriptionStatus(currentuser.objectId, To: business.userObjectID)
            
            location = business.businessLocation
            
            enableBtns()
            
            locationAuthStatus()
            
        }
    
    }
    
//Begin Map View Setup---------------------------------------------------

    
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

//---------------------------End MapView Setup
    
    @IBAction func onMessageBtnPressed(sender: AnyObject) {
        performSegueWithIdentifier("ViewMessageThread", sender: nil)
    }
    
    @IBAction func onSubscribeBtnPressed(sender: AnyObject) {
        
        let currentuser = appDelegate.backendless.userService.currentUser
 
        DataService.instance.subscribeToBusiness(currentuser.objectId, To: business.userObjectID)
        
        self.subscribeBtn.setTitle("Loading...", forState: .Normal)
        self.subscribeBtn.enabled = false
    }
    
    func onSubscribedToBusiness(notification: NSNotification){
    
        if let responseDict = notification.object as? [String:AnyObject] {
            if let response = responseDict["response"] as? String {
                
                self.subscribeBtn.enabled = true

                if response == "Subscribed" {
                    
                    self.subscribeBtn.setTitle("Unsubscribe from Business", forState: .Normal)
                    self.subscribeBtn.backgroundColor = ACCENT_COLOR
                    
                }else{
                    
                    self.subscribeBtn.setTitle("Subscribe to Business", forState: .Normal)
                    self.subscribeBtn.backgroundColor = DARK_PRIMARY_COLOR
                    
                }
                
            }
            
        }

    }
    
    
    func onSubscriptionStatusRetrieved(notification: NSNotification){
        
        if let responseDict = notification.object as? [String:AnyObject] {
            if let response = responseDict["response"] as? String {
                
                if response == "Subscribed" {
                    
                    self.subscribeBtn.setTitle("Unsubscribe from Business", forState: .Normal)
                    self.subscribeBtn.backgroundColor = ACCENT_COLOR
                    
                }else{
                    
                    self.subscribeBtn.setTitle("Subscribe to Business", forState: .Normal)
                    self.subscribeBtn.backgroundColor = DARK_PRIMARY_COLOR
                    
                }
                
            }
            
        }
        
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
        super.prepareForSegue(segue, sender: sender)

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
        
        
        if segue.identifier == "ViewMessageThread" {
            
            let navVc = segue.destinationViewController as! UINavigationController
            let messageVC = navVc.viewControllers.first as! ViewMessageThreadVC
        
            let currentUser = self.appDelegate.backendless.userService.currentUser
            let user = User()
            user.populateUserData(currentUser)
            
            
            //Check if Channel Already Exists
            
            var channelName: String = "\(user.userObjectID) - \(business.userObjectID)"
            
            let potentialChannelNameOne = channelName
            let potentialChannelNameTwo = "\(business.userObjectID) - \(user.userObjectID)"
            
            for channel in DataService.instance.allUniqueChannelNames {
                
                if channel == potentialChannelNameOne || channel == potentialChannelNameTwo{ //uuid is senderid of message
                    
                    //Channel already exists
                    
                    channelName = channel
    
                    break
                }
               
            }
            
            //Later on create function that checks if channel name of uniquechannelnames has the businessID in it
            
            //create two potentially chanel names - 1 where currentuser id is first and another where its second. if any of those exits, channel already exists then
        
            messageVC.mainChannelName = channelName
            messageVC.senderId =  user.userObjectID // 3
            messageVC.senderDisplayName = user.fullName // 4
            messageVC.currentUserID = user.userObjectID
            messageVC.otherUserName = business.businessName
            messageVC.otherUserID = business.userObjectID
            messageVC.otherUserProfilePictureLocation = business.userProfilePicLocation
            
        }
        
    }
    
}











