//
//  BusinessViewMessages.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class BusinessViewMessagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
    
    @IBOutlet weak var tableView: UITableView!
    
    var channel: MessageItem!
    
    override func viewDidLoad() {
        self.tabBarController?.navigationItem.hidesBackButton = true
        let titleView = UIImageView(image: UIImage(named: "Nav_Img"))
        self.tabBarController?.navigationItem.titleView = titleView
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(BusinessViewMessagesVC.onNewReservationBtnPressed))

        self.tabBarController?.navigationItem.rightBarButtonItem = button

        tableView.delegate = self
        tableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BusinessViewMessagesVC.onUniqueChannelsRetrived), name: "uniqueChannelsRetrieved", object: nil)
        
        showActivityIndicator()
        
        DataService.instance.subscribeToInboundChannel()
        
    }
    
    func onNewReservationBtnPressed(){
        
        performSegueWithIdentifier("NewReservationFromTab", sender: nil)
        
        print("pressed VC")
    
    }

    func onUniqueChannelsRetrived(){
        
        activityIndicator.stopAnimating()
        
        tableView.reloadData()
    }
    
    
    //Spinning indicator when loading request
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    
    //Setup Tableview
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let channel = DataService.instance.allUniqueChannels[indexPath.row]
        
        print(channel)
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("BusinessChannelsCell") as? BusinessMessageChannelsCell{
            
            cell.configureCell(channel)
            
            return cell
        }else {
            
            let cell = BusinessMessageChannelsCell()
            cell.configureCell(channel)
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataService.instance.allUniqueChannels.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true) //So tableview row doesn't stay highlighted
        
        channel = DataService.instance.allUniqueChannels[indexPath.row]
        performSegueWithIdentifier("ViewMessageThreadFromBusiness", sender: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
    if segue.identifier != "NewReservationFromTab" {
        
            let navVc = segue.destinationViewController as! UINavigationController
            let messageVC = navVc.viewControllers.first as! ViewMessageThreadVC
            
            let currentUser = appDelegate.backendless.userService.currentUser
            let user = User()
            user.populateUserData(currentUser)
            
            messageVC.mainChannelName = channel.channelName
            messageVC.currentUserID = user.userObjectID
            
            if user.userObjectID == channel.uuid{ //Current User was last sender
                
                messageVC.senderId =  channel.uuid // 3 Recipient is uuid
                messageVC.senderDisplayName = channel.senderDisplayName // 4
                messageVC.otherUserName = channel.recipientDisplayName
                messageVC.otherUserID = channel.recipientID
                messageVC.otherUserProfilePictureLocation = channel.recipientProfilePictureLocation
                
            }else{ // Current User was not last sender in convo
                
                messageVC.senderId =  channel.recipientID // 3 Recipient is currentuser
                messageVC.senderDisplayName = channel.recipientDisplayName // 4
                messageVC.otherUserName = channel.senderDisplayName
                messageVC.otherUserID = channel.uuid
                messageVC.otherUserProfilePictureLocation = channel.senderProfilePictureLocation
                
            }
            
            print("\(channel.channelName) later on")
            print("\(currentUser.objectId)")
       
        }
        
    }
    
}
