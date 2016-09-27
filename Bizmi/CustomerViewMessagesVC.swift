//
//  CustomerMessages.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class CustomerViewMessagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    
    @IBOutlet weak var tableView: UITableView!
    
    var channel: MessageItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Subscribe To Channel with ID equaivalent to currentUserID
        //Get message History From Newest to Oldest of user B Messages
        
        //Create UniqueChannelMessages Array that holds Message Struct Items
        //Create allMessagesObject
        //Loop through all Messages from History and add Message to Array if it doesn’t exist in the array already
    
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        let titleView = UIImageView(image: UIImage(named: "Nav_Img"))
        self.tabBarController?.navigationItem.titleView = titleView
        
        tableView.delegate = self
        tableView.dataSource = self
        
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomerViewMessagesVC.onUniqueChannelsRetrived), name: "uniqueChannelsRetrieved", object: nil)
        
        showActivityIndicator()
        
       // DataService.instance.subscribeToInboundChannel()

    }
    
    
//    func onUniqueChannelsRetrived(){
//    
//        activityIndicator.stopAnimating()
//        
//        tableView.reloadData()
//    }
//   
    
    //Spinning indicator when loading request
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    
    //Setup Tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let channel = DataService.instance.allUniqueChannels[(indexPath as NSIndexPath).row]
//        
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerChannelsCell") as? CustomerMessageChannelsCell{
//            
//            cell.configureCell(channel)
//            
//            return cell
//        }else {
//            
//            let cell = CustomerMessageChannelsCell()
//            cell.configureCell(channel)
//            
//            return cell
//        }
        return CustomerMessageChannelsCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return DataService.instance.allUniqueChannels.count
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        tableView.deselectRow(at: indexPath, animated: true) //So tableview row doesn't stay highlighted
//        
//        channel = DataService.instance.allUniqueChannels[(indexPath as NSIndexPath).row]
//        performSegue(withIdentifier: "ViewMessageThreadFromCustomer", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        let navVc = segue.destination as! UINavigationController
//        let messageVC = navVc.viewControllers.first as! ViewMessageThreadVC
//
//        let currentUser = appDelegate.backendless.userService.currentUser
//        let user = User()
//        user.populateUserData(currentUser)
//        
//        messageVC.mainChannelName = channel.channelName
//        messageVC.currentUserID = user.userObjectID
//
//        
//        if user.userObjectID == channel.uuid{ //Current User was last sender
//          
//            messageVC.senderId =  channel.uuid // 3 Recipient is uuid
//            messageVC.senderDisplayName = channel.senderDisplayName // 4
//            messageVC.otherUserName = channel.recipientDisplayName
//            messageVC.otherUserID = channel.recipientID
//            messageVC.otherUserProfilePictureLocation = channel.recipientProfilePictureLocation
//            
//        }else{ // Current User was not last sender in convo
//     
//            messageVC.senderId =  channel.recipientID // 3 Recipient is currentuser
//            messageVC.senderDisplayName = channel.recipientDisplayName // 4
//            messageVC.otherUserName = channel.senderDisplayName
//            messageVC.otherUserID = channel.uuid
//            messageVC.otherUserProfilePictureLocation = channel.senderProfilePictureLocation
//            
//        }
//        
//        print("\(channel.channelName) later on")
//        print("\(currentUser.objectId)")
        

    }
}
