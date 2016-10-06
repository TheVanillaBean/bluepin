//
//  ViewCustomerVC.swift
//  Bizmi
//
//  Created by Alex on 8/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import FirebaseStorage

class ViewCustomerVC: UIViewController {
    
    @IBOutlet weak var customerProfilePicImg: BorderImageView!
    
    @IBOutlet weak var customerNameLbl: UILabel!
    
    @IBOutlet weak var followingDateLbl: UILabel!
    
    @IBOutlet weak var messagesSentLbl: UILabel!
    
    @IBOutlet weak var appointmentsMadeLbl: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var castedCustomer: NewUser!
    
    var customerID: String!
    
    var followingDate: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        
        //Casting
        let castedUser = NewUser()
        castedUser.castUser(customerID) { (errMsg) in
            self.castedCustomer = castedUser
            self.populateDataFields()
            
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func populateDataFields(){
            
        self.navigationItem.title = "\(castedCustomer.fullName)"
        
        loadProfilePic()
        
        customerNameLbl.text = castedCustomer.fullName
        followingDateLbl.text = followingDate
        messagesSentLbl.text = calculateMessagesSent()
        appointmentsMadeLbl.text = calculateAppointmentsMade()
        
        
    }
    
    
    func loadProfilePic(){
        
        if castedCustomer.userProfilePicLocation != "" {
            
            let ref = FIRStorage.storage().reference(forURL: castedCustomer.userProfilePicLocation)
            ref.data(withMaxSize: 20 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("Unable to download image from Firebase storage")
                    print(error)
                    let placeholderImage = UIImage(named: "Placeholder")!
                    self.customerProfilePicImg.image = placeholderImage
                } else {
                    print("Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.customerProfilePicImg.image = img
                        }
                    }
                }
            })
            
            print(castedCustomer.userProfilePicLocation)
        }
    }
    
    func calculateMessagesSent() -> String{
        return "5309"
    }
    
    func calculateAppointmentsMade() -> String{
        return "67"
    }
   
    
    @IBAction func cancelBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func messageCustomerBtnPressed(_ sender: AnyObject) {
        
       // performSegue(withIdentifier: "ViewMessageThreadFromViewCustomerVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue.identifier == "ViewMessageThreadFromViewCustomerVC" {
//            
//            let navVc = segue.destination as! UINavigationController
//            let messageVC = navVc.viewControllers.first as! ViewMessageThreadVC
//            
//            let currentUser = self.appDelegate.backendless.userService.currentUser
//            let user = User()
//            user.populateUserData(currentUser)
//            
//            
//            //Check if Channel Already Exists
//            
//            var channelName: String = "\(user.userObjectID) - \(customer.userObjectID)"
//            
//            let potentialChannelNameOne = channelName
//            let potentialChannelNameTwo = "\(customer.userObjectID) - \(user.userObjectID)"
//            
//            for channel in DataService.instance.allUniqueChannelNames {
//                
//                if channel == potentialChannelNameOne || channel == potentialChannelNameTwo{ //uuid is senderid of message
//                    
//                    //Channel already exists
//                    
//                    channelName = channel
//                    
//                    break
//                }
//                
//            }
//            
//            //Later on create function that checks if channel name of uniquechannelnames has the businessID in it
//            
//            //create two potentially chanel names - 1 where currentuser id is first and another where its second. if any of those exits, channel already exists then
//            
//            messageVC.mainChannelName = channelName
//            messageVC.senderId =  user.userObjectID // 3
//            messageVC.senderDisplayName = user.businessName // 4
//            messageVC.currentUserID = user.userObjectID
//            messageVC.otherUserName = customer.fullName
//            messageVC.otherUserID = customer.userObjectID
//            messageVC.otherUserProfilePictureLocation = customer.userProfilePicLocation
//            
//        }
        
    }
    
}



























