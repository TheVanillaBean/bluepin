//
//  ViewMessageThreadVC.swift
//  Bizmi
//
//  Created by Alex on 8/17/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import JSQMessagesViewController

class ViewMessageThreadVC: JSQMessagesViewController{

    var mainChannelName: String = ""
    var currentUserID: String = ""
    var otherUserName: String = ""
    var otherUserID: String = ""
    var otherUserProfilePictureLocation: String = ""

    var currentUser: NewUser!
    
    var iterator: Int  = 0
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var newMessageHandler: FirebaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = otherUserName
        setupBubbles()
        setUpBackButton()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewMessageThreadVC.onChatMessagesRecieved), name: NSNotification.Name(rawValue: "chatMessagesRecieved"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(ViewMessageThreadVC.onNewChatMessageConverted), name: NSNotification.Name(rawValue: "newChatMessageConverted"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        showActivityIndicator()
        
        self.observeNewMessages()
       // FBDataService.instance.retrieveAllJSQMessagesInChat(channelName: mainChannelName)
        
    }
    
    func onNewChatMessageConverted(){
        self.collectionView?.reloadData()
    }
    
    func onChatMessagesRecieved(notification: NSNotification){
        
        //self.organizeMessages()
        self.collectionView?.reloadData()
       // self.observeNewMessages()

       // self.observeNewMessages()
        
//        let dict = notification.object as! NSDictionary
//        
//        let errMsg = dict["errMsg"]
//        
//        if errMsg == nil{
//            self.collectionView?.reloadData()
//            self.observeNewMessages()
//        }else{
//            print("noooooo")
//        }
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
        return FBDataService.instance.allJSQMessagesInChat[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FBDataService.instance.allJSQMessagesInChat.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = FBDataService.instance.allJSQMessagesInChat[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = FBDataService.instance.allJSQMessagesInChat[(indexPath as NSIndexPath).item] // 1
        
        if message.senderId == senderId { // 1
            cell.textView!.textColor = UIColor.white // 2
        } else {
            cell.textView!.textColor = UIColor.black // 3
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {

        let message = Message(messageType: MESSAGE_TEXT_TYPE, messageData: text, senderUID: senderId, recipientUID: otherUserID, channelName: self.mainChannelName, senderName: senderDisplayName, recName: otherUserName)

        publishMessage(message)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
  
    }
    
    func publishMessage(_ messageItem: Message) {
     
        showActivityIndicator()
        
        let FBMessage = FBDataService.instance.messagesRef.childByAutoId()
        
        let message: Dictionary<String, AnyObject> = [MESSAGE_TYPE: messageItem.messageType as AnyObject, MESSAGE_LOCATION: FBMessage.key as AnyObject, MESSAGE_SENDERID: messageItem.senderUID as AnyObject, MESSAGE_RECIPIENTID: messageItem.recipientUID as AnyObject, MESSAGE_TIMESTAMP: FIRServerValue.timestamp() as AnyObject, MESSAGE_CHANNEL_NAME: messageItem.channelName as AnyObject, MESSAGE_SENDER_NAME: messageItem.senderDisplayName as AnyObject, MESSAGE_RECIPIENT_NAME: messageItem.recipientDisplayName as AnyObject]
        
        FBMessage.setValue(message)
    

        let messageStorageRef = FBDataService.instance.messagesStorageRef.child(FBMessage.key)
        let data = messageItem.messageData.data(using: .utf8)
        
        // Upload the file to the path "images/rivers.jpg"
        _ = messageStorageRef.put(data!, metadata: nil) { metadata, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                print("upload sussess")
                FBDataService.instance.channelsRef.child(self.mainChannelName).child(FBMessage.key).setValue(FIRServerValue.timestamp())
                FBDataService.instance.userChannelsRef.child(self.currentUser.uuid).child(self.mainChannelName).setValue(FIRServerValue.timestamp())
            }
        }

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
    fileprivate func setupBubbles() {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleImageFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImageView = bubbleImageFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
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
    override func viewWillDisappear(_ animated: Bool) {
       // FBDataService.instance.mainRef.removeObserver(withHandle: self.newMessageHandler)
        FBDataService.instance.mainRef.removeAllObservers()
        FBDataService.instance._allMessageIDSInChat.removeAll()
        FBDataService.instance._allMessagesInChat.removeAll()
        FBDataService.instance._allJSQMessagesInChat.removeAll()
    }
    
    func observeNewMessages(){
        print("observe message")
        newMessageHandler = FBDataService.instance.channelsRef.child(self.mainChannelName).queryLimited(toLast: 30).observe(FIRDataEventType.childAdded, with: { (snapshot) in
            
            //if currentchannnelname from singleton is equal to this channel name, then dont update code, if not then change name deleted jsqmessages and reload
            
            print("handler")
            print("incoming \(snapshot.key)")

            self.iterator = self.iterator + 1
            
            let firstGroup = DispatchGroup()
            
          //  if FBDataService.instance.allMessageIDSInChat.count < self.iterator{
            
                print("yep \(self.iterator)")
            
            firstGroup.enter()
            
             FBDataService.instance.convertMessageIDToMessageModel(messageID: snapshot.key, onComplete: { (errMsg, data) in
                FBDataService.instance.organizeMessages()
                firstGroup.leave()
             })
         
            
            firstGroup.notify(queue: DispatchQueue.main, execute: {
                print("All Done and Processed, so load data now")
                self.collectionView?.reloadData()
            })
            
          //  }
            
        })
    }


   
    
}
