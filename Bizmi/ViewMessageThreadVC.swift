//
//  ViewMessageThreadVC.swift
//  Bizmi
//
//  Created by Alex on 8/17/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
//import PubNub
import JSQMessagesViewController

class ViewMessageThreadVC: JSQMessagesViewController{

    var mainChannelName: String = ""
    var currentUserID: String = ""
    var otherUserName: String = ""
    var otherUserID: String = ""
    var otherUserProfilePictureLocation: String = ""
  //  var currentUser: BackendlessUser!
  //  var user = User()

    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = otherUserName
//        appDelegate.client.add(self)
//        
//        appDelegate.client.subscribe(toChannels: [currentUserID], withPresence: false)
        
//        setupBubbles()
        
//        setUpBackButton()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
//        currentUser = appDelegate.backendless.userService.currentUser
//        user.populateUserData(currentUser)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(ViewMessageThreadVC.onChatMessagesRetrived), name: NSNotification.Name(rawValue: "chatMessagesRecieved"), object: nil)
//        
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(ViewMessageThreadVC.onNewChatMessageRecieved), name: NSNotification.Name(rawValue: "newPubNubMessageRecieved"), object: nil)
//
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        showActivityIndicator()
        
//        DataService.instance.clearAllMessagesInChat()
//        DataService.instance.getAllMessagesInChat(mainChannelName)
    }
    
    func setUpBackButton(){
        
        self.navigationController? .setNavigationBarHidden(false, animated:true)
        let backButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(ViewMessageThreadVC.popToRoot(_:)), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState())
        backButton.setTitleColor(UIColor.white, for: UIControlState())
        backButton.sizeToFit()
        let backButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backButtonItem
        
    }
    
    func popToRoot(_ sender:UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }
    
    func onChatMessagesRetrived(){

//        self.reloadMessagesView()
        
    }
//    
//    func onNewChatMessageRecieved(){
//        
//        activityIndicator.stopAnimating()
//        
//        let newMessage = DataService.instance.newPubNubMessage
//        
//        if newMessage.channelName == self.mainChannelName{
//    
//            print("\(DataService.instance.newPubNubMessage) new message chat view controller")
//            
//            DataService.instance.appendMessageToAllJSQMessages(newMessage)
//            
//            if newMessage.uuid != currentUserID{
//                self.finishReceivingMessage()
//                print("\(DataService.instance.newPubNubMessage) new message if--------------------")
//
//            }else {
//                self.finishSendingMessage()
//                print("\(DataService.instance.newPubNubMessage) new message else-------------------")
//
//            }
//        }
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
       var _allJSQMessagesInChat: [JSQMessage] = []
        return _allJSQMessagesInChat[indexPath.item]
     //   return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     //   return DataService.instance.allJSQMessagesInChat.count
        return 0
    }
    
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
//        
////        let message = DataService.instance.allJSQMessagesInChat[indexPath.item] // 1
////        if message.senderId == senderId { // 2
////            return outgoingBubbleImageView
////        } else { // 3
////            return incomingBubbleImageView
////        }
//    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
//        
//        let message = DataService.instance.allJSQMessagesInChat[(indexPath as NSIndexPath).item] // 1
//        
//        if message.senderId == senderId { // 1
//            cell.textView!.textColor = UIColor.white // 2
//        } else {
//            cell.textView!.textColor = UIColor.black // 3
//        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {

//        let message = MessageItem(uuid: senderId, message: text, channelName: self.mainChannelName, senderDisplayName: senderDisplayName, recipientID: otherUserID, recipientProfilePictureLocation: otherUserProfilePictureLocation, recipientDisplayName: otherUserName, senderProfilePictureLocation: user.userProfilePicLocation)
//        publishMessage(message)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
  
    }
    
    func publishMessage(_ messageItem: MessageItem) {
        
//        let message : [String : AnyObject] = ["uuid" : messageItem.uuid as AnyObject, "message" : messageItem.message as AnyObject, "channelName" : messageItem.channelName as AnyObject, "senderDisplayName" : messageItem.senderDisplayName as AnyObject, "recipientID" : messageItem.recipientID as AnyObject, "recipientProfilePictureLocation" : messageItem.recipientProfilePictureLocation as AnyObject, "recipientDisplayName" : messageItem.recipientDisplayName as AnyObject, "senderProfilePictureLocation" : messageItem.senderProfilePictureLocation as AnyObject]
////        appDelegate.client.publish(message, toChannel: mainChannelName, withCompletion: nil)
////        appDelegate.client.publish(message, toChannel: currentUserID, withCompletion: nil)
////        appDelegate.client.publish(message, toChannel: otherUserID, withCompletion: nil)
//        showActivityIndicator()

    }
    
    //Spinning indicator when loading request
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
//    func reloadMessagesView() {
//        //Update UI on main thread
//        DispatchQueue.main.async(execute: { () -> Void in
//            self.activityIndicator.stopAnimating()
//            self.collectionView?.reloadData()
//        })
//    }
//    
//    fileprivate func setupBubbles() {
//        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
//        outgoingBubbleImageView = bubbleImageFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
//        incomingBubbleImageView = bubbleImageFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
//    }
//    
    override func didPressAccessoryButton(_ sender: UIButton!) {
//        if user.userType == "Business"{
//            DataService.instance.appointmentLeaderName = otherUserName
//            DataService.instance.appointmentLeaderID = otherUserID
//            performSegue(withIdentifier: "NewReservationFromMessageThread", sender: nil)
//        }else{
//            Messages.displayToastMessage(self.view, msg: "We are currently working on implementing a photo upload feature. There will be an update in a few weeks :)")
//        }

    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "NewReservationFromMessageThread" {
//            DataService.instance.appointmentLeaderName = otherUserName
//            DataService.instance.appointmentLeaderID = otherUserID
//        }
//    }
    
  
//    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
//        print("Data Service new message \( message.data.message)")
//
////        let newMessage = MessageItem(uuid: message.data.message!["uuid"] as! String, message: message.data.message!["message"] as! String, channelName: message.data.message!["channelName"] as! String, senderDisplayName: message.data.message!["senderDisplayName"] as! String, recipientID : message.data.message!["recipientID"] as! String, recipientProfilePictureLocation: message.data.message!["recipientProfilePictureLocation"] as! String, recipientDisplayName: message.data.message!["recipientDisplayName"] as! String, senderProfilePictureLocation: message.data.message!["senderProfilePictureLocation"] as! String)
////        
////            DataService.instance.newPubNubMessage = newMessage
//            
////            print("Data Service new message \( DataService.instance.newPubNubMessage)")
////            
////            onNewChatMessageRecieved()
//        
//    }
//    
    
    
    
//    
//    // Handle subscription status change.
//    func client(_ client: PubNub, didReceive status: PNStatus) {
//        
//        if status.operation == .subscribeOperation {
//            
//            // Check whether received information about successful subscription or restore.
//            if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
//                
//                let subscribeStatus: PNSubscribeStatus = status as! PNSubscribeStatus
//                if subscribeStatus.category == .PNConnectedCategory {
//                    
//                    // This is expected for a subscribe, this means there is no error or issue whatsoever.
//                    print("successfuly subscribed")
//                }
//                else {
//                    
//                    /**
//                     This usually occurs if subscribe temporarily fails but reconnects. This means there was
//                     an error but there is no longer any issue.
//                     */
//                    print("successful subscribed after there was errror")
//
//                }
//            }
//                // Looks like some kind of issues happened while client tried to subscribe or disconnected from
//                // network.
//            else {
//                
//                let errorStatus: PNErrorStatus = status as! PNErrorStatus
//                if errorStatus.category == .PNAccessDeniedCategory {
//                    
//                    /**
//                     This means that PAM does allow this client to subscribe to this channel and channel group
//                     configuration. This is another explicit error.
//                     */
//                    print("pam ")
//
//                }
//                else if errorStatus.category == .PNUnexpectedDisconnectCategory {
//                    
//                    /**
//                     This is usually an issue with the internet connection, this is an error, handle
//                     appropriately retry will be called automatically.
//                     */
//                    print("internet")
//
//                }
//                else {
//                    
//                    /**
//                     More errors can be directly specified by creating explicit cases for other error categories
//                     of `PNStatusCategory` such as `PNTimeoutCategory` or `PNMalformedFilterExpressionCategory` or
//                     `PNDecryptionErrorCategory`
//                     */
//                    print("more errors")
//
//                }
//            }
//        }
//        else if status.operation == .unsubscribeOperation {
//            
//            if status.category == .PNDisconnectedCategory {
//                
//                /**
//                 This is the expected category for an unsubscribe. This means there was no error in
//                 unsubscribing from everything.
//                 */
//            }
//        }
//        else if status.operation == .heartbeatOperation {
//            
//            /**
//             Heartbeat operations can in fact have errors, so it is important to check first for an error.
//             For more information on how to configure heartbeat notifications through the status
//             PNObjectEventListener callback, consult http://www.pubnub.com/docs/ios-objective-c/api-reference-sdk-v4#configuration_basic_usage
//             */
//            
//            if !status.isError { /* Heartbeat operation was successful. */ }
//            else { /* There was an error with the heartbeat operation, handle here. */ }
//        }
//    }
    
}
