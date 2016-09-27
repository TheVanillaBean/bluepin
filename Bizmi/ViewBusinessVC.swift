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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
//    var backendlessUser: BackendlessUser!
    
    let locationManager = CLLocationManager()
    
    var regionRadius: CLLocationDistance = 100
    
    var isCentered = false
    
//    var location: GeoPoint?
    
//    var business: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 65), animated: true)
        map.delegate = self
        
        businessDescLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        
      //  subscribeToNofications()
        
    }
    
//    func subscribeToNofications(){
//        NotificationCenter.default.addObserver(self, selector: #selector(ViewBusinessVC.onSubscribedToBusiness), name: NSNotification.Name(rawValue: "subscribedToBusiness"), object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(ViewBusinessVC.onSubscriptionStatusRetrieved), name: NSNotification.Name(rawValue: "subscriptionStatus"), object: nil)
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
//        disableBtns()
//        populateDataFields()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
    }

//    func disableBtns(){
//    
//        phoneNumberBtn.isEnabled = false
//        messageBtn.isEnabled = false
//        websiteBtn.isEnabled = false
//        hoursBtn.isEnabled = false
//        subscribeBtn.isEnabled = false
//
//    }
//    
//    func enableBtns(){
//        
//        phoneNumberBtn.isEnabled = true
//        messageBtn.isEnabled = true
//        websiteBtn.isEnabled = true
//        hoursBtn.isEnabled = true
//        subscribeBtn.isEnabled = true
//        
//    }
//
//    func populateDataFields(){
//    
//        if let businessUser = backendlessUser{
//        
//            business = User()
//            business.populateUserData(businessUser)
//            
//            self.navigationItem.title = "\(business.businessName)"
//
//            let URL = Foundation.URL(string: "\(business.userProfilePicLocation)")!
//            let placeholderImage = UIImage(named: "Placeholder")!
//            
//            let currentuser = appDelegate.backendless.userService.currentUser
//            
//            businessProfileImg.af_setImageWithURL(URL, placeholderImage: placeholderImage)
//            businessNameLbl.text = business.businessName
//            businessTypeLbl.text = business.businessType
//            businessDescLbl.text = business.businessDesc
//            aboutBusinessLbl.text = "About \(business.businessName)"
//            phoneNumberBtn.setTitle("\(business.phoneNumber)", for: UIControlState())
//            DataService.instance.findCustomerSubscriptionStatus(currentuser.objectId, To: business.userObjectID)
//            
//            location = business.businessLocation
//            
//            enableBtns()
//            
//            locationAuthStatus()
//            
//        }
//    
//    }
    
//Begin Map View Setup---------------------------------------------------

    
//    func locationAuthStatus() {
//        
//        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
//            
//            if !isCentered{ //Only needs to hapen once
//                if location?.latitude != 0 && location?.longitude != 0{
//                    
//                    let loc = CLLocation(latitude: Double(location!.latitude), longitude: Double(location!.longitude) )
//                    
//                    print(loc)
//                    
//                    reverseGeoLocate(loc)
//
//                    centerMapOnLocation(loc, scaleFactor: 3)
//                    
//                    createAnnotationForLocation(loc)
//                    
//                }
//            }
//            
//            map.showsUserLocation = true
//            
//        }else {
//            
//            locationManager.requestWhenInUseAuthorization()
//            
//        }
//        
//    }
    
//    func centerMapOnLocation(_ location: CLLocation, scaleFactor: Double) {
//        
//        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * scaleFactor, regionRadius * scaleFactor)
//        map.setRegion(coordinateRegion, animated: true)
//        isCentered = true
//    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
//        if !isCentered && (location?.latitude == 0 && location?.longitude == 0){ //Only needs to hapen once
//            if let loc = userLocation.location {
//                centerMapOnLocation(loc, scaleFactor: 10)
//            }
//        }
    }
    
    func createAnnotationForLocation(_ location: CLLocation){

//        let businessAnnotation = BusinessAnnotation(coordinate: location.coordinate, title: "\(business.businessName)", subtitle: "\(business.businessType)")
//        businessAnnotation.coordinate = location.coordinate
//        map.addAnnotation(businessAnnotation)
//    
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        // Don't want to show a custom image if the annotation is the user's location.
//        guard !annotation.isKind(of: MKUserLocation.self) else {
//            return nil
//        }
//        
//        let annotationIdentifier = "BusinessPin"
//        
//        var annotationView: MKAnnotationView?
//        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
//            annotationView = dequeuedAnnotationView
//            annotationView?.annotation = annotation
//        }
//        else {
//            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
//            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            annotationView = av
//        }
//        
//        if let annotationView = annotationView {
//            // Configure your annotation view here
//            annotationView.canShowCallout = true
//            annotationView.image = UIImage(named: "Marker_Large")
//        }
//        
//        return annotationView
//    }
//    
//    func reverseGeoLocate(_ location: CLLocation){
// 
//        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
//            
//            if let marks = placemarks , marks.count > 0 {
//                
//                let pm = marks[0] as CLPlacemark
//                
//                    if let street = pm.name,let locality = pm.locality, let state = pm.administrativeArea, let zip = pm.postalCode{
//                        self.locationBtn.setTitle("\(street), \(locality), \(state) \(zip)", for: UIControlState())
//                    }
//        
//            }else {
//                print("there was an error no location")
//            }
//      
//        })
//    
//    }

//---------------------------End MapView Setup
    
    @IBAction func onMessageBtnPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "ViewMessageThread", sender: nil)
    }
    
    @IBAction func onSubscribeBtnPressed(_ sender: AnyObject) {
//        
//        let currentuser = appDelegate.backendless.userService.currentUser
// 
//        DataService.instance.subscribeToBusiness(currentuser.objectId, To: business.userObjectID)
//        
//        self.subscribeBtn.setTitle("Loading...", for: UIControlState())
//        self.subscribeBtn.isEnabled = false
    }
    
    func onSubscribedToBusiness(_ notification: Notification){
    
//        if let responseDict = notification.object as? [String:AnyObject] {
//            if let response = responseDict["response"] as? String {
//                
//                self.subscribeBtn.isEnabled = true
//
//                if response == "Subscribed" {
//                    
//                    self.subscribeBtn.setTitle("Unsubscribe from Business", for: UIControlState())
//                    self.subscribeBtn.backgroundColor = ACCENT_COLOR
//                    
//                }else{
//                    
//                    self.subscribeBtn.setTitle("Subscribe to Business", for: UIControlState())
//                    self.subscribeBtn.backgroundColor = DARK_PRIMARY_COLOR
//                    
//                }
//                
//            }
//            
//        }

    }
    
    
//    func onSubscriptionStatusRetrieved(_ notification: Notification){
//        
//        if let responseDict = notification.object as? [String:AnyObject] {
//            if let response = responseDict["response"] as? String {
//                
//                if response == "Subscribed" {
//                    
//                    self.subscribeBtn.setTitle("Unsubscribe from Business", for: UIControlState())
//                    self.subscribeBtn.backgroundColor = ACCENT_COLOR
//                    
//                }else{
//                    
//                    self.subscribeBtn.setTitle("Subscribe to Business", for: UIControlState())
//                    self.subscribeBtn.backgroundColor = DARK_PRIMARY_COLOR
//                    
//                }
//                
//            }
//            
//        }
//        
//    }
    
    @IBAction func cancelBtnPressed(_ sender: AnyObject) {
        //Dismiss VC
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func locationBtnPressed(_ sender: UIButton) {
        
//        if let title = sender.titleLabel?.text {
//            performSegue(withIdentifier: "ViewBusinessLocation", sender: title)
//        }
        
    }
    
    @IBAction func phoneNumberBtnPressed(_ sender: AnyObject) {
//        
//        let stringArray = business.phoneNumber.components(
//            separatedBy: CharacterSet.decimalDigits.inverted)
//        let phoneNumber = stringArray.joined(separator: "")
//        
//        callNumber(phoneNumber)
        
    }
    
    @IBAction func businessWebsiteBtnPressed(_ sender: AnyObject) {
//        performSegue(withIdentifier: "ViewBusinessWebsite", sender: nil)
    }

    @IBAction func hoursBtnPressed(_ sender: AnyObject) {
//        performSegue(withIdentifier: "ViewBusinessHours", sender: nil)
    }
    
    fileprivate func callNumber(_ phoneNumber:String) {
//        if let phoneCallURL:URL = URL(string: "tel://\(phoneNumber)") {
//            let application:UIApplication = UIApplication.shared
//            if (application.canOpenURL(phoneCallURL)) {
//                application.openURL(phoneCallURL);
//            }
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

////        if segue.identifier == "ViewBusinessLocation" {
////            if let viewLocationVC = segue.destination as? ViewBusinessLocationVC{
////                
////                viewLocationVC.location = location
////                
////                if let address = sender as? String{
////                    viewLocationVC.address = address
////                    viewLocationVC.businessName = business.businessName
////                }
////                
////            }
//        
////        }
//        
////        if segue.identifier == "ViewBusinessWebsite" {
////            if let websiteVC = segue.destination as? ViewBusinessWebsiteVC{
////                websiteVC.URL = business.businessWebsite
////            }
//    
////        }
//        
////        if segue.identifier == "ViewBusinessHours" {
////            if let hoursVC = segue.destination as? ViewBusinessHoursVC{
////                hoursVC.hours = business.businessHours
////            }
//    
//        }
//        
//        
//        if segue.identifier == "ViewMessageThread" {
//            
////            let navVc = segue.destination as! UINavigationController
////            let messageVC = navVc.viewControllers.first as! ViewMessageThreadVC
////        
////            let currentUser = self.appDelegate.backendless.userService.currentUser
////            let user = User()
////            user.populateUserData(currentUser)
////            
////            
////            //Check if Channel Already Exists
////            
////            var channelName: String = "\(user.userObjectID) - \(business.userObjectID)"
////            
////            let potentialChannelNameOne = channelName
////            let potentialChannelNameTwo = "\(business.userObjectID) - \(user.userObjectID)"
////            
////            for channel in DataService.instance.allUniqueChannelNames {
////                
////                if channel == potentialChannelNameOne || channel == potentialChannelNameTwo{ //uuid is senderid of message
////                    
////                    //Channel already exists
////                    
////                    channelName = channel
////    
////                    break
////                }
////               
////            }
////            
////            //Later on create function that checks if channel name of uniquechannelnames has the businessID in it
////            
////            //create two potentially chanel names - 1 where currentuser id is first and another where its second. if any of those exits, channel already exists then
////        
////            messageVC.mainChannelName = channelName
////            messageVC.senderId =  user.userObjectID // 3
////            messageVC.senderDisplayName = user.fullName // 4
////            messageVC.currentUserID = user.userObjectID
////            messageVC.otherUserName = business.businessName
////            messageVC.otherUserID = business.userObjectID
////            messageVC.otherUserProfilePictureLocation = business.userProfilePicLocation
//    
//        }
//        
    }
    
}











