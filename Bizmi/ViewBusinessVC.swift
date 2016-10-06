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
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

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
    
    var castedBusiness: NewUser!
    
    var businessID: String!
    
    var currentUser: NewUser!
    
    let locationManager = CLLocationManager()
    
    var regionRadius: CLLocationDistance = 100
    
    var isCentered = false
    
    var location: CLLocation!
    
    var geoFire: GeoFire!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 65), animated: true)
        map.delegate = self
        
        businessDescLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        disableBtns()
        
        
        //Casting
        let castedUser = NewUser()
        castedUser.castUser(businessID) { (errMsg) in
            
            let castedCurrentUser = NewUser()
            castedCurrentUser.castUser((FBDataService.instance.currentUser?.uid)!) { (errMsg) in
                
                self.currentUser = castedCurrentUser
                self.castedBusiness = castedUser
                self.populateDataFields()
                
            }
            
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
    }

    func disableBtns(){
    
        phoneNumberBtn.isEnabled = false
        messageBtn.isEnabled = false
        websiteBtn.isEnabled = false
        hoursBtn.isEnabled = false
        subscribeBtn.isEnabled = false

    }
    
    func enableBtns(){
        
        phoneNumberBtn.isEnabled = true
        messageBtn.isEnabled = true
        websiteBtn.isEnabled = true
        hoursBtn.isEnabled = true
        subscribeBtn.isEnabled = true
        
    }

    func populateDataFields(){
        
        self.navigationItem.title = "\(castedBusiness.businessName)"
        
        loadProfilePic()
        
        businessNameLbl.text = castedBusiness.businessName
        businessTypeLbl.text = castedBusiness.businessType
        businessDescLbl.text = castedBusiness.businessDesc
        aboutBusinessLbl.text = "About \(castedBusiness.businessName)"
        phoneNumberBtn.setTitle("\(castedBusiness.phoneNumber)", for: UIControlState())
        
        FBDataService.instance.retrieveSubscriptionStatus(customerID: (FBDataService.instance.currentUser?.uid)!, businessID: castedBusiness.uuid) { (errMsg, data) in
            
            if errMsg == nil {
                
                let response = data as? Bool
                
                if response == true {

                    self.subscribeBtn.setTitle("Unsubscribe from Business", for: UIControlState())
                    self.subscribeBtn.backgroundColor = ACCENT_COLOR

                }else{

                    self.subscribeBtn.setTitle("Subscribe to Business", for: UIControlState())
                    self.subscribeBtn.backgroundColor = DARK_PRIMARY_COLOR
                    
                }

            }
        }
        
        enableBtns()
        
        self.geoFire = GeoFire(firebaseRef: FBDataService.instance.usersRef.child(castedBusiness.uuid))
        
        self.geoFire.getLocationForKey(BUSINESS_LOCATION, withCallback: { (loc, error) in
            if (error != nil) {
                print("Error VC")
            }else if (loc != nil) {
                self.location = loc
                print("Alex: llllll\(loc)")
                self.locationAuthStatus()
            } else {
                print("no loc VC")
                self.location = CLLocation(latitude: 0, longitude: 0)
                self.locationAuthStatus()
            }
        })
        
        
    }
    
    func loadProfilePic(){
        
        if castedBusiness.userProfilePicLocation != "" {
            
            let ref = FIRStorage.storage().reference(forURL: castedBusiness.userProfilePicLocation)
            ref.data(withMaxSize: 20 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("Unable to download image from Firebase storage")
                    print(error)
                    let placeholderImage = UIImage(named: "Placeholder")!
                    self.businessProfileImg.image = placeholderImage
                } else {
                    print("Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.businessProfileImg.image = img
                        }
                    }
                }
            })
            
            print(castedBusiness.userProfilePicLocation)
        }
    }
    
    
//Begin Map View Setup---------------------------------------------------

    
    func locationAuthStatus() {
        
        if location != nil{
            
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                if !isCentered{ //Only needs to hapen once
                    if location!.coordinate.latitude != 0 && location!.coordinate.longitude != 0{
                        
                        let loc = CLLocation(latitude: Double(location!.coordinate.latitude), longitude: Double(location!.coordinate.longitude) )
                        
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
    }
    
    func centerMapOnLocation(_ location: CLLocation, scaleFactor: Double) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * scaleFactor, regionRadius * scaleFactor)
        map.setRegion(coordinateRegion, animated: true)
        isCentered = true
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if !isCentered && (location!.coordinate.latitude == 0 && location!.coordinate.longitude == 0){ //Only needs to hapen once
            if let loc = userLocation.location {
                centerMapOnLocation(loc, scaleFactor: 10)
            }
        }
    }
    
    func createAnnotationForLocation(_ location: CLLocation){

        let businessAnnotation = BusinessAnnotation(coordinate: location.coordinate, title: "\(castedBusiness.businessName)", subtitle: "\(castedBusiness.businessType)")
        businessAnnotation.coordinate = location.coordinate
        map.addAnnotation(businessAnnotation)

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
    
    func reverseGeoLocate(_ location: CLLocation){
 
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if let marks = placemarks , marks.count > 0 {
                
                let pm = marks[0] as CLPlacemark
                
                    if let street = pm.name,let locality = pm.locality, let state = pm.administrativeArea, let zip = pm.postalCode{
                        self.locationBtn.setTitle("\(street), \(locality), \(state) \(zip)", for: UIControlState())
                    }
        
            }else {
                print("there was an error no location")
            }
      
        })
    
    }

//---------------------------End MapView Setup
    
    @IBAction func onMessageBtnPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "ViewMessageThread", sender: nil)
    }
    
    @IBAction func onSubscribeBtnPressed(_ sender: AnyObject) {
        
        self.subscribeBtn.setTitle("Loading...", for: UIControlState())
        self.subscribeBtn.isEnabled = false
        
        FBDataService.instance.subscribeToBusiness(businessID: castedBusiness.uuid, customerID: (FBDataService.instance.currentUser?.uid)!) { (errMsg, data) in
            
            if errMsg == nil {
                
                let response = data as? Bool
                
                if response == true {
                    
                    self.subscribeBtn.setTitle("Unsubscribe from Business", for: UIControlState())
                    self.subscribeBtn.backgroundColor = ACCENT_COLOR
                    
                }else{
                    
                    self.subscribeBtn.setTitle("Subscribe to Business", for: UIControlState())
                    self.subscribeBtn.backgroundColor = DARK_PRIMARY_COLOR
                    
                }
                
            }else{
                print("errMsg nil subscribed pressed")
            }

            self.subscribeBtn.isEnabled = true
            
        }
        
      
    }

    
    @IBAction func cancelBtnPressed(_ sender: AnyObject) {
        //Dismiss VC
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func locationBtnPressed(_ sender: UIButton) {
        
        if let title = sender.titleLabel?.text {
            performSegue(withIdentifier: "ViewBusinessLocation", sender: title)
        }
        
    }
    
    @IBAction func phoneNumberBtnPressed(_ sender: AnyObject) {
        
        let stringArray = castedBusiness.phoneNumber.components(
            separatedBy: CharacterSet.decimalDigits.inverted)
        let phoneNumber = stringArray.joined(separator: "")
        
        callNumber(phoneNumber)
        
    }
    
    @IBAction func businessWebsiteBtnPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "ViewBusinessWebsite", sender: nil)
    }

    @IBAction func hoursBtnPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "ViewBusinessHours", sender: nil)
    }
    
    fileprivate func callNumber(_ phoneNumber:String) {
        if let phoneCallURL:URL = URL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "ViewBusinessLocation" {
            if let viewLocationVC = segue.destination as? ViewBusinessLocationVC{
               
               viewLocationVC.location = self.location
               
               if let address = sender as? String{
                    viewLocationVC.address = address
                    viewLocationVC.businessName = castedBusiness.businessName
                }
                
            }
        
        }
        
        if segue.identifier == "ViewBusinessWebsite" {
            if let websiteVC = segue.destination as? ViewBusinessWebsiteVC{
                websiteVC.URL = castedBusiness.businessWebsite
                print(castedBusiness.businessWebsite)
            }
    
        }
        
        if segue.identifier == "ViewBusinessHours" {
            if let hoursVC = segue.destination as? ViewBusinessHoursVC{
                hoursVC.hours = castedBusiness.businessHours
            }
    
        }
        
        
        if segue.identifier == "ViewMessageThread" {
            
            let navVc = segue.destination as! UINavigationController
            let messageVC = navVc.viewControllers.first as! ViewMessageThreadVC

            //Check if Channel Already Exists
            
            let currentUserUID = self.currentUser.uuid
        
            var channelName: String!
            
            let potentialChannelNameOne = "\(currentUserUID)-\(castedBusiness.uuid)"
            let potentialChannelNameTwo = "\(castedBusiness.uuid) - \(currentUserUID)"
            
            channelName = potentialChannelNameOne
            print("\(channelName!) ---channelname")

            for channelNameObj in FBDataService.instance.allChannelNames {
                
                if channelNameObj == potentialChannelNameOne || channelNameObj == potentialChannelNameTwo{
                    
                    //Channel already exists
                    
                    channelName = channelNameObj
                    print("\(channelName) --------")

                    break
                }
               
            }
            
            //Later on create function that checks if channel name of uniquechannelnames has the businessID in it
            
            //create two potentially chanel names - 1 where currentuser id is first and another where its second. if any of those exits, channel already exists then
        
            messageVC.currentUser = self.currentUser
            messageVC.mainChannelName = channelName!
            messageVC.senderId =  currentUserUID // 3
            messageVC.senderDisplayName = self.currentUser.fullName // 4
            messageVC.currentUserID = currentUserUID
            messageVC.otherUserName = self.castedBusiness.businessName
            messageVC.otherUserID = self.castedBusiness.uuid
            messageVC.otherUserProfilePictureLocation = self.castedBusiness.userProfilePicLocation
    
        }
        
    }
    
}











