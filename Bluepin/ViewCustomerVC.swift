//
//  ViewCustomerVC.swift
//  bluepin
//
//  Created by Alex on 8/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

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
    
    var allCustomerReservations: [String] = []
    var allResrvatinsMadeForCustomer: [String] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        
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
        checkIfFUserHasSentAnyMessages()
        calculateCustomerReservations()
        
    }
    
    
    func loadProfilePic(){
        
        if castedCustomer.userProfilePicLocation != "" {
            
            let ref = FIRStorage.storage().reference(forURL: castedCustomer.userProfilePicLocation)
            ref.data(withMaxSize: 20 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    let placeholderImage = UIImage(named: "Placeholder")!
                    self.customerProfilePicImg.image = placeholderImage
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.customerProfilePicImg.image = img
                        }
                    }
                }
            })
        }
    }
    
    func checkIfFUserHasSentAnyMessages(){

        let currentUserID = FBDataService.instance.currentUser?.uid
    
        _ = FBDataService.instance.userChannelsRef.child(currentUserID!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            
            for snap in snapshot.children.allObjects as! [FIRDataSnapshot]{
                
                if snap.key.contains(self.customerID){
                    self.calculateMessages(channelID: snap.key)
                }
            }
        
        })

    }
    
    func calculateMessages(channelID: String){
    
        _ = FBDataService.instance.channelsRef.child(channelID).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            
            self.messagesSentLbl.text = "\(snapshot.childrenCount)"
            
        })
    
    }
    
    func calculateCustomerReservations(){
        
        _ = FBDataService.instance.userReservationsRef.child(customerID).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            
            for snap in snapshot.children.allObjects as! [FIRDataSnapshot]{
              
                self.allCustomerReservations.append(snap.key)
            }
            
            self.calculateBusinessReservations()
            
        })
        
    }
    
    func calculateBusinessReservations(){
        
        let currentUserID = FBDataService.instance.currentUser?.uid
        
        _ = FBDataService.instance.userReservationsRef.child(currentUserID!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            
            for snap in snapshot.children.allObjects as! [FIRDataSnapshot]{
                
                if self.allCustomerReservations.contains(snap.key){
                    self.allResrvatinsMadeForCustomer.append(snap.key)
                }
            }
            
            self.appointmentsMadeLbl.text = "\(self.allResrvatinsMadeForCustomer.count)"
            
        })
    }
   
    
    @IBAction func cancelBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func messageCustomerBtnPressed(_ sender: AnyObject) {
        
        let currentUserUID = self.currentUser.uuid
        
        var channelName: String!
        
        _ = FBDataService.instance.channelIDSRef.child(currentUserUID).child(self.castedCustomer.uuid).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            
            if snapshot.exists(){
                let value = snapshot.value as? NSDictionary
                
                if let name = value?[CHANNEL_ID] as? String {
                    channelName = name
                }
                
                
            }else {
                let newChannelID = FBDataService.instance.userChannelsRef.child(currentUserUID).childByAutoId().key;
                FBDataService.instance.channelIDSRef.child(currentUserUID).child(self.castedCustomer.uuid).child(CHANNEL_ID).setValue(newChannelID)
                FBDataService.instance.channelIDSRef.child(self.castedCustomer.uuid).child(currentUserUID).child(CHANNEL_ID).setValue(newChannelID)
                channelName = newChannelID
                
            }
            
            self.performSegue(withIdentifier: "ViewMessageThreadFromViewCustomerVC", sender: channelName)
            
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ViewMessageThreadFromViewCustomerVC" {
            
            let navVc = segue.destination as! UINavigationController
            let messageVC = navVc.viewControllers.first as! ViewMessageThreadVC
            
            let currentUserUID = self.currentUser.uuid
            
            if let channelName = sender as? String{
                
                messageVC.currentUser = self.currentUser
                messageVC.mainChannelName = channelName
                messageVC.recipientUser = self.castedCustomer
                messageVC.channelRef = FBDataService.instance.channelsRef.child(channelName)
                messageVC.senderId =  currentUserUID
                messageVC.senderDisplayName = self.currentUser.businessName
                
            }
            
        }
        
    }
    
}



























