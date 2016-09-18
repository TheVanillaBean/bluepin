//
//  ViewCustomerVC.swift
//  Bizmi
//
//  Created by Alex on 8/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class ViewCustomerVC: UIViewController {
    
    @IBOutlet weak var customerProfilePicImg: BorderImageView!
    
    @IBOutlet weak var customerNameLbl: UILabel!
    
    @IBOutlet weak var followingDateLbl: UILabel!
    
    @IBOutlet weak var messagesSentLbl: UILabel!
    
    @IBOutlet weak var appointmentsMadeLbl: UILabel!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var backendlessUser: BackendlessUser!
    
    var customer: User!
    
    var followingDate: String!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = true
        populateDataFields()
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.navigationBarHidden = false
    }
    
    func populateDataFields(){
        
        if let customerUser = backendlessUser{
            
            customer = User()
            customer.populateUserData(customerUser)
            
            self.navigationItem.title = "\(customer.fullName)"
            
            let URL = NSURL(string: "\(customer.userProfilePicLocation)")!
            let placeholderImage = UIImage(named: "Placeholder")!
            
            customerProfilePicImg.af_setImageWithURL(URL, placeholderImage: placeholderImage)
            customerNameLbl.text = customer.fullName
            followingDateLbl.text = followingDate
            messagesSentLbl.text = calculateMessagesSent()
            appointmentsMadeLbl.text = calculateAppointmentsMade()
            
        }
        
    }
    
    func calculateMessagesSent() -> String{
        return "5309"
    }
    
    func calculateAppointmentsMade() -> String{
        return "67"
    }
   
    
    @IBAction func cancelBtnPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func messageCustomerBtnPressed(sender: AnyObject) {
        
        performSegueWithIdentifier("ViewMessageThreadFromViewCustomerVC", sender: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ViewMessageThreadFromViewCustomerVC" {
            
            let navVc = segue.destinationViewController as! UINavigationController
            let messageVC = navVc.viewControllers.first as! ViewMessageThreadVC
            
            let currentUser = self.appDelegate.backendless.userService.currentUser
            let user = User()
            user.populateUserData(currentUser)
            
            
            //Check if Channel Already Exists
            
            var channelName: String = "\(user.userObjectID) - \(customer.userObjectID)"
            
            let potentialChannelNameOne = channelName
            let potentialChannelNameTwo = "\(customer.userObjectID) - \(user.userObjectID)"
            
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
            messageVC.senderDisplayName = user.businessName // 4
            messageVC.currentUserID = user.userObjectID
            messageVC.otherUserName = customer.fullName
            messageVC.otherUserID = customer.userObjectID
            messageVC.otherUserProfilePictureLocation = customer.userProfilePicLocation
            
        }
        
    }
    
}



























