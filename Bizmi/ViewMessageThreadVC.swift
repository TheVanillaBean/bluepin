//
//  ViewMessageThreadVC.swift
//  Bizmi
//
//  Created by Alex on 8/17/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import PubNub
import JSQMessagesViewController

class ViewMessageThreadVC: JSQMessagesViewController, PNObjectEventListener {

    var mainChannelName: String = ""
    var currentUserID: String = ""
    var otherUserName: String = ""
    var otherUserID: String = ""
    var otherUserProfilePictureLocation: String = ""
    var currentUser: BackendlessUser!
    var user = User()

    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = otherUserName
        appDelegate.client.addListener(self)
        
        appDelegate.client.subscribeToChannels([currentUserID], withPresence: false)
        
        setupBubbles()
        
        setUpBackButton()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        currentUser = appDelegate.backendless.userService.currentUser
        user.populateUserData(currentUser)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewMessageThreadVC.onChatMessagesRetrived), name: "chatMessagesRecieved", object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewMessageThreadVC.onNewChatMessageRecieved), name: "newPubNubMessageRecieved", object: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        
        showActivityIndicator()
        
        DataService.instance.clearAllMessagesInChat()
        DataService.instance.getAllMessagesInChat(mainChannelName)
    }
    
    func setUpBackButton(){
        
        self.navigationController? .setNavigationBarHidden(false, animated:true)
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.addTarget(self, action: #selector(ViewMessageThreadVC.popToRoot(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        backButton.setTitle("Back", forState: UIControlState.Normal)
        backButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        backButton.sizeToFit()
        let backButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backButtonItem
        
    }
    
    func popToRoot(sender:UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onChatMessagesRetrived(){

        self.reloadMessagesView()
        
    }
    
    func onNewChatMessageRecieved(){
        
        activityIndicator.stopAnimating()
        
        let newMessage = DataService.instance.newPubNubMessage
        
        if newMessage.channelName == self.mainChannelName{
    
            print("\(DataService.instance.newPubNubMessage) new message chat view controller")
            
            DataService.instance.appendMessageToAllJSQMessages(newMessage)
            
            if newMessage.uuid != currentUserID{
                self.finishReceivingMessage()
                print("\(DataService.instance.newPubNubMessage) new message if--------------------")

            }else {
                self.finishSendingMessage()
                print("\(DataService.instance.newPubNubMessage) new message else-------------------")

            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return DataService.instance.allJSQMessagesInChat[indexPath.item]

    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataService.instance.allJSQMessagesInChat.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = DataService.instance.allJSQMessagesInChat[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = DataService.instance.allJSQMessagesInChat[indexPath.item] // 1
        
        if message.senderId == senderId { // 1
            cell.textView!.textColor = UIColor.whiteColor() // 2
        } else {
            cell.textView!.textColor = UIColor.blackColor() // 3
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {

        let message = MessageItem(uuid: senderId, message: text, channelName: self.mainChannelName, senderDisplayName: senderDisplayName, recipientID: otherUserID, recipientProfilePictureLocation: otherUserProfilePictureLocation, recipientDisplayName: otherUserName, senderProfilePictureLocation: user.userProfilePicLocation)
        publishMessage(message)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
  
    }
    
    func publishMessage(messageItem: MessageItem) {
        
        let message : [String : AnyObject] = ["uuid" : messageItem.uuid, "message" : messageItem.message, "channelName" : messageItem.channelName, "senderDisplayName" : messageItem.senderDisplayName, "recipientID" : messageItem.recipientID, "recipientProfilePictureLocation" : messageItem.recipientProfilePictureLocation, "recipientDisplayName" : messageItem.recipientDisplayName, "senderProfilePictureLocation" : messageItem.senderProfilePictureLocation]
        appDelegate.client.publish(message, toChannel: mainChannelName, withCompletion: nil)
        appDelegate.client.publish(message, toChannel: currentUserID, withCompletion: nil)
        appDelegate.client.publish(message, toChannel: otherUserID, withCompletion: nil)
        showActivityIndicator()

    }
    
    //Spinning indicator when loading request
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func reloadMessagesView() {
        //Update UI on main thread
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicator.stopAnimating()
            self.collectionView?.reloadData()
        })
    }
    
    private func setupBubbles() {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleImageFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        if user.userType == "Business"{
            DataService.instance.appointmentLeaderName = otherUserName
            DataService.instance.appointmentLeaderID = otherUserID
            performSegueWithIdentifier("NewReservationFromMessageThread", sender: nil)
        }else{
            Messages.displayToastMessage(self.view, msg: "We are currently working on implementing a photo upload feature. There will be an update in a few weeks :)")
        }

    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "NewReservationFromMessageThread" {
//            DataService.instance.appointmentLeaderName = otherUserName
//            DataService.instance.appointmentLeaderID = otherUserID
//        }
//    }
    
  
    func client(client: PubNub, didReceiveMessage message: PNMessageResult) {
        print("Data Service new message \( message.data.message)")

        let newMessage = MessageItem(uuid: message.data.message!["uuid"] as! String, message: message.data.message!["message"] as! String, channelName: message.data.message!["channelName"] as! String, senderDisplayName: message.data.message!["senderDisplayName"] as! String, recipientID : message.data.message!["recipientID"] as! String, recipientProfilePictureLocation: message.data.message!["recipientProfilePictureLocation"] as! String, recipientDisplayName: message.data.message!["recipientDisplayName"] as! String, senderProfilePictureLocation: message.data.message!["senderProfilePictureLocation"] as! String)
        
            DataService.instance.newPubNubMessage = newMessage
            
            print("Data Service new message \( DataService.instance.newPubNubMessage)")
            
            onNewChatMessageRecieved()
        
    }
    
    
    
    
    
    // Handle subscription status change.
    func client(client: PubNub, didReceiveStatus status: PNStatus) {
        
        if status.operation == .SubscribeOperation {
            
            // Check whether received information about successful subscription or restore.
            if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
                
                let subscribeStatus: PNSubscribeStatus = status as! PNSubscribeStatus
                if subscribeStatus.category == .PNConnectedCategory {
                    
                    // This is expected for a subscribe, this means there is no error or issue whatsoever.
                    print("successfuly subscribed")
                }
                else {
                    
                    /**
                     This usually occurs if subscribe temporarily fails but reconnects. This means there was
                     an error but there is no longer any issue.
                     */
                    print("successful subscribed after there was errror")

                }
            }
                // Looks like some kind of issues happened while client tried to subscribe or disconnected from
                // network.
            else {
                
                let errorStatus: PNErrorStatus = status as! PNErrorStatus
                if errorStatus.category == .PNAccessDeniedCategory {
                    
                    /**
                     This means that PAM does allow this client to subscribe to this channel and channel group
                     configuration. This is another explicit error.
                     */
                    print("pam ")

                }
                else if errorStatus.category == .PNUnexpectedDisconnectCategory {
                    
                    /**
                     This is usually an issue with the internet connection, this is an error, handle
                     appropriately retry will be called automatically.
                     */
                    print("internet")

                }
                else {
                    
                    /**
                     More errors can be directly specified by creating explicit cases for other error categories
                     of `PNStatusCategory` such as `PNTimeoutCategory` or `PNMalformedFilterExpressionCategory` or
                     `PNDecryptionErrorCategory`
                     */
                    print("more errors")

                }
            }
        }
        else if status.operation == .UnsubscribeOperation {
            
            if status.category == .PNDisconnectedCategory {
                
                /**
                 This is the expected category for an unsubscribe. This means there was no error in
                 unsubscribing from everything.
                 */
            }
        }
        else if status.operation == .HeartbeatOperation {
            
            /**
             Heartbeat operations can in fact have errors, so it is important to check first for an error.
             For more information on how to configure heartbeat notifications through the status
             PNObjectEventListener callback, consult http://www.pubnub.com/docs/ios-objective-c/api-reference-sdk-v4#configuration_basic_usage
             */
            
            if !status.error { /* Heartbeat operation was successful. */ }
            else { /* There was an error with the heartbeat operation, handle here. */ }
        }
    }
    
}
