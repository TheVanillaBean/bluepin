//
//  ViewMessageThreadVC.swift
//  bluepin
//
//  Created by Alex on 8/17/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import JSQMessagesViewController
import ImagePicker

class ViewMessageThreadVC: JSQMessagesViewController, ImagePickerDelegate{

    private let imageURLNotSetKey = "NOTSET"
    
    var channelRef: DatabaseReference?
    private lazy var messageRef: DatabaseReference = self.channelRef!.child(FIR_CHILD_MESSAGES)
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    private var messages: [JSQMessage] = []
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    private var messageIDS: [String] = []
    private var firstMessageID: String = "NONE"
    var showLoadMoreHeader: Bool = true

    var mainChannelName: String = ""

    var currentUser: NewUser!
    var recipientUser: NewUser!
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var recipientName: String {
        get {
            return recipientUser.userType == USER_CUSTOMER_TYPE ? recipientUser.fullName : recipientUser.businessName
        }
    }
    
    var senderName: String {
        get {
            return currentUser.userType == USER_CUSTOMER_TYPE ? currentUser.fullName : currentUser.businessName
        }
    }
    
    let imagePicker = ImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = recipientName
        setupBubbles()
        setUpBackButton()
        observeMessages()
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        var config = Configuration()
        config.doneButtonTitle = "Finish"
        config.noImagesTitle = "Sorry! There are no images here!"
        config.recordLocation = false
        config.allowMultiplePhotoSelection = false
        
        imagePicker.configuration = config
        imagePicker.delegate = self

    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
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

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if !message.isMediaMessage{
            if message.senderId == senderId {
                cell.textView!.textColor = UIColor.white
            } else {
                cell.textView!.textColor = UIColor.black
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        self.loadMoreMessages()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    func convertTopDateToString(jsqDate: Date) -> NSAttributedString{
        
        let fontAttribute = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 15.0)! ]

        let dateDouble: Double = Double(jsqDate.timeIntervalSince1970)
        
        let date = Date(timeIntervalSince1970: dateDouble/1000)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM d, h:mm a"
        let dateString = dateFormatter.string(from: date as Date)
        
        return NSAttributedString(string: dateString, attributes: fontAttribute)
    }
    
    func convertBottomDateToString(jsqDate: Date) -> NSAttributedString{
        
        let textAttribute = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 11.0)!, NSForegroundColorAttributeName: UIColor.black ]

        let dateDouble: Double = Double(jsqDate.timeIntervalSince1970)
        
        let date = Date(timeIntervalSince1970: dateDouble/1000)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateString = dateFormatter.string(from: date as Date)
        
        return NSAttributedString(string: dateString, attributes: textAttribute)
    }
    
    
    private func isSameDay(indexPath: Int) -> Bool {
 
        if let milliMessageDate = messages[indexPath].date, let prevMilliMessageDate = messages[indexPath - 1].date {
        
            let messageDate = Date(timeIntervalSince1970: Double(milliMessageDate.timeIntervalSince1970) / 1000)
            let prevDate = Date(timeIntervalSince1970: Double(prevMilliMessageDate.timeIntervalSince1970) / 1000)

            if (Calendar.current.isDate(messageDate, inSameDayAs: prevDate)) {
                return true
            }
            
        }
        
        return false;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if messageIDS[indexPath.item] == firstMessageID {return self.convertTopDateToString(jsqDate: messages[indexPath.item].date)}
        if indexPath.item == 0  {return nil}
        return !isSameDay(indexPath: indexPath.item) ? self.convertTopDateToString(jsqDate: messages[indexPath.item].date): nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return indexPath.item % 1 == 0 ? self.convertBottomDateToString(jsqDate: messages[indexPath.item].date) : nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if messageIDS[indexPath.item] == firstMessageID  {return kJSQMessagesCollectionViewCellLabelHeightDefault}
        if indexPath.item == 0 {return 0.0}
        return !isSameDay(indexPath: indexPath.item) ? kJSQMessagesCollectionViewCellLabelHeightDefault : 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return indexPath.item % 1 == 0 ? kJSQMessagesCollectionViewCellLabelHeightDefault : 0.0
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let FBMessage = messageRef.childByAutoId()
        
        let messageItem: Dictionary<String, AnyObject> = [
             MESSAGE_TYPE: MESSAGE_TEXT_TYPE as AnyObject,
             MESSAGE_TEXT: text! as AnyObject,
             MESSAGE_SENDERID: senderId as AnyObject,
             MESSAGE_RECIPIENTID: recipientUser.uuid as AnyObject,
             MESSAGE_TIMESTAMP: ServerValue.timestamp() as AnyObject,
             MESSAGE_CHANNEL_NAME: mainChannelName as AnyObject,
             MESSAGE_UID: FBMessage.key as AnyObject
        ]
        
        FBDataService.instance.channelIDSRef.child(currentUser.uuid).child(recipientUser.uuid).child(CHANNEL_ID).setValue(mainChannelName)
        FBDataService.instance.channelIDSRef.child(recipientUser.uuid).child(currentUser.uuid).child(CHANNEL_ID).setValue(mainChannelName)
        FBMessage.setValue(messageItem)
        
        FBDataService.instance.userChannelsRef.child(currentUser.uuid).child(mainChannelName).setValue(messageItem)
        FBDataService.instance.userChannelsRef.child(recipientUser.uuid).child(mainChannelName).setValue(messageItem)
        
        let notification = FBDataService.instance.notificationsRef.childByAutoId()
        
        var notificationRequest: Dictionary<String, AnyObject>
        
        notificationRequest = [REQUEST_ID: notification.key as AnyObject, REQUEST_SENDER_ID: self.currentUser.uuid as AnyObject, REQUEST_RECIPIENT_ID: self.recipientUser.uuid as AnyObject, REQUEST_MESSAGE: MESSAGE_NOTIF as AnyObject, REQUEST_SENDER_NAME: self.senderName as AnyObject]
        
        notification.setValue(notificationRequest)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
    }
    
    private func appendMessage(withId id: String, name: String, text: String, date: Date, key: String) {
        if let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text) {
            messages.append(message)
            messageIDS.append(key)
        }
    }
    
    private func addPhotoMessage(withId id: String, key: String, name: String, date: Date, mediaItem: JSQPhotoMediaItem) {
        
        if let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: mediaItem){
            messages.append(message)
            messageIDS.append(key)

            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    func showActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))

        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.startAnimating()
    }
    
    fileprivate func setupBubbles() {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleImageFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImageView = bubbleImageFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }

    override func didPressAccessoryButton(_ sender: UIButton!) {
        if currentUser.userType == USER_BUSINESS_TYPE{
            FBDataService.instance.appointmentLeaderName = recipientUser.fullName
            FBDataService.instance.appointmentLeaderID = recipientUser.uuid
            performSegue(withIdentifier: "NewReservationFromMessageThread", sender: nil)
        }else{
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func getSenderDisplayName(senderID: String) -> String{
        return senderID == currentUser.uuid ? senderName : recipientName
    }
    
    func getFirstMessage(){
        messageRef.queryLimited(toFirst: 1).queryOrderedByKey().observeSingleEvent(of: .childAdded, with: { (snapshot) in
            self.firstMessageID = snapshot.key
        })
    }

    private func observeMessages() {
        
        messageRef = channelRef!.child(FIR_CHILD_MESSAGES)
        
        getFirstMessage()
        
        newMessageRefHandle = messageRef.queryLimited(toLast:25).queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            
            self.showActivityIndicator()
            
            let messageData = snapshot.value as! [String : AnyObject]
            
            if let type = messageData[MESSAGE_TYPE] as! String!, let senderID = messageData[MESSAGE_SENDERID] as! String!, let stamp = messageData[MESSAGE_TIMESTAMP] as! Double!{
                
                if type == MESSAGE_TEXT_TYPE, let text = messageData[MESSAGE_TEXT] as! String!, text.characters.count > 0 {

                    let date = NSDate(timeIntervalSince1970: stamp)
                    self.appendMessage(withId: senderID, name: self.getSenderDisplayName(senderID: senderID), text: text, date: date as Date, key: snapshot.key)
                    
                    
                }else if type == MESSAGE_IMAGE_TYPE, let photoURL = messageData[MESSAGE_PHOTO_URL] as! String!{
                    
                    let date = NSDate(timeIntervalSince1970: stamp)
                    if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: senderID == self.senderId) {
                        self.addPhotoMessage(withId: senderID, key: snapshot.key, name: self.getSenderDisplayName(senderID: senderID), date: date as Date, mediaItem: mediaItem)
                        
                        print("fetching image before prefix")
                        
                        if photoURL.hasPrefix("gs://") {
                            print("has prefix")
                            self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                        }
                    }
                }
                
                if self.messages.count > 24 && snapshot.key != self.firstMessageID && self.showLoadMoreHeader{
                    self.showLoadEarlierMessagesHeader = true
                }
                
                if snapshot.key == self.firstMessageID{
                    self.showLoadEarlierMessagesHeader = false
                    self.showLoadMoreHeader = false
                }
                
                if self.firstMessageID == "NONE" || self.firstMessageID == snapshot.key{
                    self.inputToolbar.contentView.textView.text = ""
                    self.collectionView.reloadData()
                }else{
                    if senderID == self.currentUser.uuid{
                        self.finishSendingMessage(animated: true)
                    }else {
                        self.finishReceivingMessage(animated: true)
                    }
                }

                
            } else {
                print("Error! Could not decode message data")
            }
            
            self.activityIndicator.stopAnimating()

        })
        
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! [String : AnyObject]
            
            if let photoURL = messageData[MESSAGE_PHOTO_URL] as! String!, photoURL != self.imageURLNotSetKey {
                if let mediaItem = self.photoMessageMap[key] {
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
                }
            }
        })
        
    }
    
    private func loadMoreMessages() {
        
        let endingIndexKey = messageIDS.first
        
        messageRef.queryEnding(atValue: endingIndexKey).queryLimited(toLast: 16).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in

            self.showActivityIndicator()

            var previousMessages: [JSQMessage] = []
            var previousMessageIDS: [String] = []
            
            for child in snapshot.children {
                
                let childSnapshot = snapshot.childSnapshot(forPath: (child as AnyObject).key)

                let messageData = childSnapshot.value as! [String : AnyObject]
                
                if let type = messageData[MESSAGE_TYPE] as! String!, let senderID = messageData[MESSAGE_SENDERID] as! String!, let stamp = messageData[MESSAGE_TIMESTAMP] as! Double!, let text = messageData[MESSAGE_TEXT] as! String!, text.characters.count > 0 {
                    
                    if type == MESSAGE_TEXT_TYPE {
                        
                        let date = NSDate(timeIntervalSince1970: stamp)
                        if let message = JSQMessage(senderId: senderID, senderDisplayName: self.getSenderDisplayName(senderID: senderID), date: date as Date, text: text) {
                            previousMessages.append(message)
                            previousMessageIDS.append(childSnapshot.key)
                        }
                    }
                    
                } else {
                    print("Error! Could not decode message data")
                }
         
            }
            
            if previousMessageIDS.first == self.firstMessageID {
                self.showLoadEarlierMessagesHeader = false
                self.showLoadMoreHeader = false
            }
            
            self.messages.remove(at: 0)
            self.messageIDS.remove(at: 0)
            self.messages = Array([previousMessages, self.messages].joined())
            self.messageIDS = Array([previousMessageIDS, self.messageIDS].joined())
            self.activityIndicator.stopAnimating()
            self.collectionView.reloadData()
            
        })
        
    }
    
    func sendPhotoMessage() -> String? {
        
        let FBMessage = messageRef.childByAutoId()
        
        let messageItem: Dictionary<String, AnyObject> = [
            MESSAGE_TYPE: MESSAGE_IMAGE_TYPE as AnyObject,
            MESSAGE_PHOTO_URL: imageURLNotSetKey as AnyObject,
            MESSAGE_SENDERID: senderId as AnyObject,
            MESSAGE_RECIPIENTID: recipientUser.uuid as AnyObject,
            MESSAGE_TIMESTAMP: ServerValue.timestamp() as AnyObject,
            MESSAGE_CHANNEL_NAME: mainChannelName as AnyObject,
            MESSAGE_UID: FBMessage.key as AnyObject
        ]
        
        FBDataService.instance.channelIDSRef.child(currentUser.uuid).child(recipientUser.uuid).child(CHANNEL_ID).setValue(mainChannelName)
        FBDataService.instance.channelIDSRef.child(recipientUser.uuid).child(currentUser.uuid).child(CHANNEL_ID).setValue(mainChannelName)
        FBMessage.setValue(messageItem)
        
        FBDataService.instance.userChannelsRef.child(currentUser.uuid).child(mainChannelName).setValue(messageItem)
        FBDataService.instance.userChannelsRef.child(recipientUser.uuid).child(mainChannelName).setValue(messageItem)
        
        let notification = FBDataService.instance.notificationsRef.childByAutoId()
        
        var notificationRequest: Dictionary<String, AnyObject>
        
        notificationRequest = [REQUEST_ID: notification.key as AnyObject, REQUEST_SENDER_ID: self.currentUser.uuid as AnyObject, REQUEST_RECIPIENT_ID: self.recipientUser.uuid as AnyObject, REQUEST_MESSAGE: MESSAGE_NOTIF as AnyObject, REQUEST_SENDER_NAME: self.senderName as AnyObject]
        
        notification.setValue(notificationRequest)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        return FBMessage.key

    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues([MESSAGE_PHOTO_URL: url])
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        
        let storageRef = Storage.storage().reference(forURL: photoURL)
        storageRef.getData(maxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            storageRef.getMetadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
         
                if let imgData = data{
                    print("media item set")
                    mediaItem.image = UIImage.init(data: imgData)
                    self.collectionView.reloadData()
                }
        
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        if images.first != nil{
            
            if let key = sendPhotoMessage() {
          
                let image = images.first?.correctlyOrientedImage()

                let imageData: Data = UIImageJPEGRepresentation(image!, 0.5)!
                
                let filePath: StorageReference = FBDataService.instance.messagesStorageRef.child("\(key).jpg")
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                
                FBDataService.instance.uploadFile(filePath, data: imageData, metadata: metadata, onComplete: { (errMsg, data) in
                    if errMsg != nil {
                        Messages.showAlertDialog("Upload Issue", msgAlert: errMsg)
                    }else{
                        print(filePath.description + "url")
                        self.setImageURL(filePath.description, forPhotoMessageWithKey: key)
                    }
                })
                
            }
            
        
        }
        
    }

    
}