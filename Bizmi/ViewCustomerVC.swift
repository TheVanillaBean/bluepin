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
    
    var currentUser: NewUser!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        
        //Casting
        let castedUser = NewUser()
        castedUser.castUser(customerID) { (errMsg) in
            self.castedCustomer = castedUser
            
            self.currentUser = NewUser()
            self.currentUser.castUser((FBDataService.instance.currentUser?.uid)!, onComplete: { (errMsg) in
                if errMsg == nil{
                    self.populateDataFields()
                }
            })
            
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
        //Work Here Next
    }
    
    func calculateAppointmentsMade() -> String{
        return "67"
    }
   
    
    @IBAction func cancelBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func messageCustomerBtnPressed(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "ViewMessageThreadFromViewCustomerVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVc = segue.destination as! UINavigationController
        let messageVC = navVc.viewControllers.first as! ViewMessageThreadVC
        
        //Check if Channel Already Exists
        
        let currentUserUID = self.currentUser.uuid
        
        var channelName: String!
        
        let potentialChannelNameOne = "\(currentUserUID)-\(castedCustomer.uuid)"
        let potentialChannelNameTwo = "\(castedCustomer.uuid)-\(currentUserUID)"
        
        print(potentialChannelNameTwo)
        channelName = potentialChannelNameOne
        
        for channelNameObj in FBDataService.instance.allChannelNames {
            
            if channelNameObj == potentialChannelNameOne || channelNameObj == potentialChannelNameTwo{
                
                //Channel already exists
                
                channelName = channelNameObj
                
                break
            }
            
        }
        
        //Later on create function that checks if channel name of uniquechannelnames has the businessID in it
        
        //create two potentially chanel names - 1 where currentuser id is first and another where its second. if any of those exits, channel already exists then
        
        messageVC.currentUser = self.currentUser
        messageVC.mainChannelName = channelName!
        messageVC.senderId = currentUserUID // 3
        messageVC.senderDisplayName = self.currentUser.businessName // 4
        messageVC.currentUserID = currentUserUID
        messageVC.otherUserName = self.castedCustomer.fullName
        messageVC.otherUserID = self.castedCustomer.uuid
        messageVC.otherUserProfilePictureLocation = self.castedCustomer.userProfilePicLocation
        
    }
    
}



























