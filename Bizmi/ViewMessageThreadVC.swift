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
    var otherUser: NewUser!
    
    var iterator: Int = 1
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var newMessageHandler: FirebaseHandle!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = otherUserName
        setupBubbles()
        setUpBackButton()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        self.showLoadEarlierMessagesHeader = true
        
        self.otherUser = NewUser()
        self.otherUser.castUser(self.otherUserID) { (errMsg) in
            if errMsg == nil{
                self.retrieveAllChatIDS(onComplete: { (errMsg, data) in
                    
                    if FBDataService.instance.allMessageIDSInChat.count > 0{
                        self.loadMessages(iteratorStart: self.iterator, loadMoreMessages: false)
                    }else{
                        self.showLoadEarlierMessagesHeader = false
                    }
                    
                    self.observeNewMessages()
                })
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        self.loadMessages(iteratorStart: self.iterator, loadMoreMessages: true)
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    func convertTopDateToString(jsqDate: Date) -> NSAttributedString{
        
        let fontAttribute = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 15.0)! ]

        let dateDouble: Double = Double(jsqDate.timeIntervalSince1970)
        
        let date = NSDate(timeIntervalSince1970: dateDouble/1000)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM d, h:mm a"
        let dateString = dateFormatter.string(from: date as Date)
        
        return NSAttributedString(string: dateString, attributes: fontAttribute)

    }
    
    func convertBottomDateToString(jsqDate: Date) -> NSAttributedString{
        
        let textAttribute = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 11.0)!, NSForegroundColorAttributeName: UIColor.black ]

        let dateDouble: Double = Double(jsqDate.timeIntervalSince1970)
        
        let date = NSDate(timeIntervalSince1970: dateDouble/1000)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateString = dateFormatter.string(from: date as Date)
        
        
        return NSAttributedString(string: dateString, attributes: textAttribute)
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if (indexPath.item % 4 == 0) {
            let message: JSQMessage = FBDataService.instance.allJSQMessagesInChat[(indexPath as NSIndexPath).item]
            return self.convertTopDateToString(jsqDate: message.date)
        }
        
        return nil;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
       
        if (indexPath.item % 4 == 0) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
        return 0.0;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if (indexPath.item % 1 == 0) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0;
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
       
        if (indexPath.item % 1 == 0) {
            let message: JSQMessage = FBDataService.instance.allJSQMessagesInChat[(indexPath as NSIndexPath).item]
            return self.convertBottomDateToString(jsqDate: message.date)
        }
        
        return nil;
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {

        let message = Message(messageType: MESSAGE_TEXT_TYPE, messageData: text, senderUID: senderId, recipientUID: otherUserID, channelName: self.mainChannelName)

        self.inputToolbar.contentView.textView.text = ""
        
        publishMessage(message)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
  
    }
    
    func publishMessage(_ messageItem: Message) {
     
        showActivityIndicator()
        
        let FBMessage = FBDataService.instance.messagesRef.childByAutoId()
        
        let message: Dictionary<String, AnyObject> = [MESSAGE_TYPE: messageItem.messageType as AnyObject, MESSAGE_LOCATION: FBMessage.key as AnyObject, MESSAGE_SENDERID: messageItem.senderUID as AnyObject, MESSAGE_RECIPIENTID: messageItem.recipientUID as AnyObject, MESSAGE_TIMESTAMP: FIRServerValue.timestamp() as AnyObject, MESSAGE_CHANNEL_NAME: messageItem.channelName as AnyObject]
        
        FBMessage.setValue(message)

        let messageStorageRef = FBDataService.instance.messagesStorageRef.child(FBMessage.key)
        let data = messageItem.messageData.data(using: .utf8)
        
        // Upload the file to the path "images/rivers.jpg"
        _ = messageStorageRef.put(data!, metadata: nil) { metadata, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                    FBDataService.instance.channelsRef.child(self.mainChannelName).child(FBMessage.key).setValue(FIRServerValue.timestamp())
                    FBDataService.instance.userChannelsRef.child(self.currentUser.uuid).child(self.mainChannelName).setValue(FIRServerValue.timestamp())
                    FBDataService.instance.userChannelsRef.child(self.otherUserID).child(self.mainChannelName).setValue(FIRServerValue.timestamp())

                    let notification = FBDataService.instance.notificationsRef.childByAutoId()
                
                    var notificationRequest: Dictionary<String, AnyObject>
                
                    if self.currentUser.userType == "Customer"{
                        
                        notificationRequest = [REQUEST_ID: notification.key as AnyObject, REQUEST_SENDER_ID: self.currentUser.uuid as AnyObject, REQUEST_RECIPIENT_ID: self.otherUserID as AnyObject, REQUEST_MESSAGE: MESSAGE_NOTIF as AnyObject, REQUEST_SENDER_NAME: self.currentUser.fullName as AnyObject]
                        
                    }else{
                        
                         notificationRequest = [REQUEST_ID: notification.key as AnyObject, REQUEST_SENDER_ID: self.currentUser.uuid as AnyObject, REQUEST_RECIPIENT_ID: self.otherUserID as AnyObject, REQUEST_MESSAGE: MESSAGE_NOTIF as AnyObject, REQUEST_SENDER_NAME: self.currentUser.businessName as AnyObject, "title": self.appDelegate.deviceTokenString as AnyObject]
                        
                    }
                
                    notification.setValue(notificationRequest)
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
    
    fileprivate func setupBubbles() {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleImageFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImageView = bubbleImageFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }

    override func didPressAccessoryButton(_ sender: UIButton!) {
        if currentUser.userType == "Business"{
            FBDataService.instance.appointmentLeaderName = otherUserName
            FBDataService.instance.appointmentLeaderID = otherUserID
            performSegue(withIdentifier: "NewReservationFromMessageThread", sender: nil)
        }else{
            Messages.displayToastMessage(self.view, msg: "We are currently working on implementing a photo upload feature. There will be an update in a few weeks :)")
        }

    }
    
  
    override func viewWillDisappear(_ animated: Bool) {
        FBDataService.instance.channelsRef.child(self.mainChannelName).removeObserver(withHandle: newMessageHandler)
        FBDataService.instance._allMessageIDSInChat.removeAll()
        FBDataService.instance._allMessagesInChat.removeAll()
        FBDataService.instance._allJSQMessagesInChat.removeAll()
    }

    func observeNewMessages(){
        
        let firstGroup = DispatchGroup()
        
        newMessageHandler = FBDataService.instance.channelsRef.child(self.mainChannelName).queryLimited(toLast: 20).observe(FIRDataEventType.childAdded, with: { (snapshot) in
            
            if !FBDataService.instance.allMessageIDSInChat.contains(snapshot.key){
                self.showActivityIndicator()
                
                firstGroup.enter()
                
                FBDataService.instance.convertMessageIDToMessageModel(messageID: snapshot.key, onComplete: { (errMsg, data) in
                    FBDataService.instance.organizeMessages()
                    firstGroup.leave()
                })
                
                firstGroup.notify(queue: DispatchQueue.main, execute: {
                    
                    let newMessage = FBDataService.instance.newJSQMessage
                    
                    if newMessage.senderId != self.currentUserID{
                        self.finishReceivingMessage()
                    }else {
                        self.finishSendingMessage()
                    }
                    
                    // self.collectionView?.reloadData()
                    self.activityIndicator.stopAnimating()
                })
            }
        })
    }
    
    
    func retrieveAllChatIDS(onComplete: DataCompletion?){
        
        _ = FBDataService.instance.channelsRef.child(self.mainChannelName).queryOrderedByValue().observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            
            
                for snap in snapshot.children.allObjects as! [FIRDataSnapshot]{
                    
                    FBDataService.instance._allMessageIDSInChat.append(snap.key)
                }
                
                onComplete?(nil, nil)

        
        })
    }
    
    func loadMessages(iteratorStart: Int, loadMoreMessages: Bool){
        
        let firstGroup = DispatchGroup()
                
        var iterator = iteratorStart
        
        var iteratorEnd = iterator + 4
        
        self.showLoadEarlierMessagesHeader = false
        
        while iterator <= (iteratorEnd){
            
            self.showActivityIndicator()
            
            firstGroup.enter()
            
            let messageID = FBDataService.instance.allMessageIDSInChat[ FBDataService.instance.allMessageIDSInChat.count - iterator ]
            iterator = iterator + 1
            self.iterator = self.iterator + 1
            
            if iterator >= FBDataService.instance.allMessageIDSInChat.count{
                iteratorEnd =  FBDataService.instance.allMessageIDSInChat.count - iteratorEnd
                
                if iteratorEnd < 1{
                    iteratorEnd = 0
                }
                
            }
            
            FBDataService.instance.convertMessageIDToMessageModel(messageID: messageID, onComplete: { (errMsg, data) in
                FBDataService.instance.organizeMessages()
                firstGroup.leave()
            })
            
            firstGroup.notify(queue: DispatchQueue.main, execute: {
                
                if loadMoreMessages{
                    
                    self.collectionView.reloadData()
                    
                }else{
                
                    let newMessage = FBDataService.instance.newJSQMessage
                    
                    if newMessage.senderId != self.currentUserID{
                        self.finishReceivingMessage()
                    }else {
                        self.finishSendingMessage()
                    }
                    
                }
                
                self.activityIndicator.stopAnimating()
                
                if FBDataService.instance.allMessageIDSInChat.count == FBDataService.instance.allJSQMessagesInChat.count{
                    
                    self.showLoadEarlierMessagesHeader = false
                    
                }else{
                    
                    self.showLoadEarlierMessagesHeader = true

                }
            })
            
        }
    }
    
}
