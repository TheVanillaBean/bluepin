//
//  FBDataService.swift
//  Bizmi
//
//  Created by Alex on 9/18/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import JSQMessagesViewController

typealias DataCompletion = (_ errMsg: String?, _ data: AnyObject?) -> Void

class FBDataService {
    
    fileprivate static let _instance = FBDataService()
    
    //-----------------Database References------------------//
    
    static var instance: FBDataService {
        return _instance
    }
    
    var mainRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var usersRef: FIRDatabaseReference {
        return mainRef.child(FIR_CHILD_USERS)
    }
    
    var businessUserRef: FIRDatabaseReference {
        return mainRef.child(FIR_CHILD_USERS_BUSINESS)
    }
    
    var customerUserRef: FIRDatabaseReference {
        return mainRef.child(FIR_CHILD_USERS_CUSTOMER)
    }
    
    var businessFollowersRef: FIRDatabaseReference {
        return mainRef.child(FIR_CHILD_BUSINESS_FOLLOWERS)
    }
    
    var customerFollowersRef: FIRDatabaseReference {
        return mainRef.child(FIR_CHILD_CUSTOMER_FOLLOWERS)
    }
    
    var userChannelsRef: FIRDatabaseReference {
        return mainRef.child(FIR_CHILD_USER_CHANNELS)
    }
    
    var channelsRef: FIRDatabaseReference {
        return mainRef.child(FIR_CHILD_CHANNELS)
    }
    
    var messagesRef: FIRDatabaseReference {
        return mainRef.child(FIR_CHILD_MESSAGES)
    }
    
    var userReservationsRef: FIRDatabaseReference {
        return mainRef.child(FIR_CHILD_USER_RESERVATIONS)
    }
    
    var reservationsRef: FIRDatabaseReference {
        return mainRef.child(FIR_CHILD_RESERVATIONS)
    }
    
    //-----------------Database References------------------//
    

    //-----------------Current User--------------------//

    var currentUser: FIRUser? {
        
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            return user
        } else {
            // No user is signed in.
            return nil
        }
        
    }
    
    //-----------------End Current User--------------------//
    

    
    //-----------------Storage Refrences--------------------//

    
    var mainStorageRef: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    
    var profilePicsStorageRef: FIRStorageReference {
        return mainStorageRef.child(FIR_STORAGE_CHILD_USER_PROFILE_PICS)
    }
   
    var messagesStorageRef: FIRStorageReference {
        return mainStorageRef.child(FIR_STORAGE_CHILD_MESSAGES)
    }
    
    //-----------------End Storage Refrences--------------------//

    //Used When Uploading Files
    
    var _uploadProgress: Double?
    
    var uploadProgress: Double{
        if let progress = _uploadProgress{
            return progress
        }else{
            return 0.0
        }
    }
    
    
    var _allBusinesses: [String] = []
    
    var allBusinesses: [String]{
        return _allBusinesses
    }
    
    var _allFollowers: [String] = []
    
    var allFollowers: [String]{
        return _allFollowers
    }
    
    var _allFollowersTime: [Double] = []
    
    var allFollowersTime: [Double]{
        return _allFollowersTime
    }
    
    var _allBusinessesFollowed: [String] = []
    
    var allBusinessesFollowed: [String]{
        return _allBusinessesFollowed
    }
    
    var _allChannelNames: [String] = []
    
    var allChannelNames: [String]{
        return _allChannelNames
    }
    
    var _allLastMessages: [Message] = []
    
    var allLastMessages: [Message]{
        return _allLastMessages
    }
    
    var _allMessageIDSInChat: [String] = []
    
    var allMessageIDSInChat: [String]{
        return _allMessageIDSInChat
    }
    
    var _allMessagesInChat: [Message] = []
    
    var allMessagesInChat: [Message]{
        return _allMessagesInChat
    }
    
    var _allJSQMessagesInChat: [JSQMessage] = []
    
    var allJSQMessagesInChat: [JSQMessage]{
        return _allJSQMessagesInChat
    }
    
    var _newJSQMessage: JSQMessage?
    
    var newJSQMessage: JSQMessage{
        return _newJSQMessage!
    }
    
    var _allReservationIDS: [String] = []
    
    var _allReservations: [Reservation] = []
    
    var allReservations: [Reservation]{
        return _allReservations
    }
    
    //-------------Firebase Observer Handlers-----------//
    
    var channelAddedHandler: FirebaseHandle!
    var channelChangedHandler: FirebaseHandle!

    var reservationAddedHandler: FirebaseHandle!
    var reservationChangedHandler: FirebaseHandle!

    //-------------End Firebase Observer Handlers-----------//

    
    var dataChanged: Bool = false
    
    //For Reservations
    var appointmentLeaderID: String = "Select Customer"
    var appointmentLeaderName: String!

    func saveUser(_ uid: String!, isCustomer: Bool?, propertes: Dictionary<String, AnyObject>, onComplete: DataCompletion?) {
        
        usersRef.child(uid).setValue(propertes)
        
        if isCustomer!{
            customerUserRef.child(uid).setValue(true)
        }else{
            businessUserRef.child(uid).setValue(true)
        }
        
        print("iscustomer done")
        
        onComplete?(nil, nil)

    }
    
    func updateUser(_ uid: String!, propertes: Dictionary<String, AnyObject>, onComplete: DataCompletion?) {
        
        mainRef.child(FIR_CHILD_USERS).child(uid).updateChildValues(propertes)
        onComplete?(nil, nil)
        
    }
    
    func resetPassword(_ email: String!, onComplete: DataCompletion?) {
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                // An error happened.
                onComplete?("An error occured... \(error)", nil)

            } else {
                // Password reset email sent.
                onComplete?(nil, nil)
            }
        }
        
    }
  
    
    func uploadFile(_ filePath: FIRStorageReference!, data: Data!, metadata: FIRStorageMetadata!, onComplete: DataCompletion?){
       
        let uploadTask = filePath.put(data, metadata: metadata);

        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            if let progress = snapshot.progress {
                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                self._uploadProgress = percentComplete
                print(percentComplete)
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "uploadProgressFB"), object: nil))
            }
        }
        
        uploadTask.observe(.success) { snapshot in
            print("success upload -------")
            uploadTask.removeAllObservers()
        
            onComplete?(nil, snapshot.metadata)
            
        }
        
        // Errors only occur in the "Failure" case
        uploadTask.observe(.failure) { snapshot in
            guard let storageError = snapshot.error else { return }
            guard let errorCode = FIRStorageErrorCode(rawValue: storageError._code) else { return }
            uploadTask.removeAllObservers()
            
            print("\(errorCode) -- upload error")
            onComplete?("There was an upload error. Check your connection.", nil)
        
        }
    }
    
    
    //Load Businesses
    func retriveAllBusinesses(onComplete: DataCompletion?) {
       
        _ = businessUserRef.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let businessDict = snapshot.value as! [String : AnyObject]

            for businessObj in businessDict{
                let business = businessObj.key
                self._allBusinesses.append(business)
                onComplete?(nil, nil)
            }
            
        
        })
    }
    
    //Load Followers
    func retriveAllFollowers(businessID: String, onComplete: DataCompletion?) {
        
        _ = businessFollowersRef.child(businessID).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            
            let followersDict = snapshot.value as! [String : AnyObject]
            
            for followObj in followersDict{
                
                let customerID = followObj.key
                self._allFollowers.append(customerID)
                self._allFollowersTime.append(followObj.value as! Double)
                onComplete?(nil, nil)
            }
            
            
        })
    }
    
    //Subscribe To Business
    func subscribeToBusiness(businessID: String, customerID: String, onComplete: DataCompletion?) {
        
        retrieveAllBusinessesFollowed(customerID: customerID) { (errMsg, data) in
            if errMsg == nil {
                if self.allBusinessesFollowed.count > 0{
                    
                    if self.isSubscribed(businessID: businessID){
                        self.businessFollowersRef.child(businessID).child(customerID).removeValue()
                        self.customerFollowersRef.child(customerID).child(businessID).removeValue()
                        onComplete?(nil, false as AnyObject?)
                    }else{
                        self.businessFollowersRef.child(businessID).child(customerID).setValue(FIRServerValue.timestamp())
                        self.customerFollowersRef.child(customerID).child(businessID).setValue(FIRServerValue.timestamp())
                        onComplete?(nil, true as AnyObject?)
                    }
                    
                    self._allBusinessesFollowed.removeAll()

                }else{
                    self.businessFollowersRef.child(businessID).child(customerID).setValue(FIRServerValue.timestamp())
                    self.customerFollowersRef.child(customerID).child(businessID).setValue(FIRServerValue.timestamp())
                    onComplete?(nil, true as AnyObject?)
                }
            }else{
                print("error subscribing")
            }
        }
    }
    
    //Retrieve All Subscriptions
    func retrieveAllBusinessesFollowed(customerID: String, onComplete: DataCompletion?) {
        
        self._allBusinessesFollowed.removeAll()
        
        _ = customerFollowersRef.child(customerID).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value != nil{
                
                if let followsDict = snapshot.value as? [String : AnyObject]{
                
                    for followObj in followsDict{
                        
                        let businessID = followObj.key
                        self._allBusinessesFollowed.append(businessID)
                    }
                    
                    onComplete?(nil, nil)

                }else{
                    onComplete?(nil, nil)
                }
            }else{
                onComplete?(nil, nil)
            }
        })
    }
    
    //Retieve Specific Subscriptions Status
    func retrieveSubscriptionStatus(customerID: String, businessID: String, onComplete: DataCompletion?) {
        
        if allBusinessesFollowed.count > 0{
            
            if self.isSubscribed(businessID: businessID){
                onComplete?(nil, true as AnyObject?)
            }else{
                onComplete?(nil, false as AnyObject?)
            }
            
        }else{
        
            retrieveAllBusinessesFollowed(customerID: customerID) { (errMsg, data) in
                if errMsg == nil {
                    if self.allBusinessesFollowed.count > 0{
                        
                        if self.isSubscribed(businessID: businessID){
                            onComplete?(nil, true as AnyObject?)
                        }else{
                            onComplete?(nil, false as AnyObject?)
                        }
                        
                    }else{
                        print("all businesses 0 when retirving status")
                    }
                }else{
                    print("error retriving status")
                }
            }
            
        }
    }
    
    func isSubscribed(businessID: String!) -> Bool{
        
        for business in self.allBusinessesFollowed{
            if business == businessID{
                return true
            }
        }
        
       return false

    }
    
    //--------Messaging Retrieve Channels
    
    func retriveAllChannels(userID: String, onComplete: DataCompletion?){
       
        _ = userChannelsRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value != nil{
                
                if let channelsDic = snapshot.value as? [String : AnyObject]{
                    
                    for channelNameObj in channelsDic{
                        
                        let channelName = channelNameObj.key
                        self._allChannelNames.append(channelName)
                    }
                   // print("channel name")
                    //print(self.allChannelNames)
                    self.retrieveAllLastMessages(iterator: 0, onComplete: { (errMsg, data) in
                        print("inside channel")
                        if errMsg == nil{
                            onComplete?(nil, nil)
                        }else{
                            onComplete?(errMsg, nil)
                        }
                    })
                    
                }else{
                    onComplete?("No Channels for User", nil)
                }
            }else{
                onComplete?("No Channels for User", nil)
            }
        })
    }
    
    func retrieveAllLastMessages(iterator: Int, onComplete: DataCompletion?){
        
        if iterator < allChannelNames.count{
            
            let channelName = allChannelNames[iterator]
            
            _ = channelsRef.child(channelName).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.value != nil{
                    
                    if let messagesDict = snapshot.value as? [String : AnyObject]{
                        
                        if let messageID = messagesDict.keys.first{
                        
                            let message = Message()
                            message.castMessage(messageID, onComplete: { (errMsg) in
                                if errMsg == nil{
                                    self._allLastMessages.append(message)
                                    print(iterator)
                                    self.retrieveAllLastMessages(iterator: iterator + 1, onComplete: nil)
                                }
                            })
                        }
                        
                    }else{
                        onComplete?("No Messages for User", nil)
                    }
                }else{
                    onComplete?("No Messages for User", nil)
                }
            })
        }else{
            print("\(self.allChannelNames.count) ----oncomplete")
            onComplete?(nil, nil)
        }
    }
    
   //End Channels Retirveing
    
    
    
    func retrieveAllJSQMessagesInChat(channelName: String){
        
        _allJSQMessagesInChat.removeAll()
        _allMessagesInChat.removeAll()
        _allMessageIDSInChat.removeAll()
        
        _ = channelsRef.child(channelName).queryOrderedByValue().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value != nil{
                
                if let messagesDict = snapshot.value as? [String : AnyObject]{
                    
                    for messageID in messagesDict{
                    
                        self._allMessageIDSInChat.append(messageID.key)
                    
                    }
                    
               // print(self.allMessageIDSInChat)
                    
                self.convertMessageIDSToMessageModel(iterator: 0)
    
                }else{
                    let notifDict: Dictionary<String, AnyObject?> = ["errMsg": "No Messages for User" as Optional<AnyObject>, "data": nil]
                    
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "chatMessagesRecieved"), object: notifDict))
                }
            }else{
                let notifDict: Dictionary<String, AnyObject?> = ["errMsg": "No Messages for User" as Optional<AnyObject>, "data": nil]
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "chatMessagesRecieved"), object: notifDict))
                
            }
        })
        
       
    }
    
    
    func convertMessageIDSToMessageModel(iterator: Int){
        
        print("\(allMessageIDSInChat.count)------size")
        
        if iterator < allMessageIDSInChat.count{
        
            let messageID = allMessageIDSInChat[iterator]
            
            let message = Message()
            message.castMessage(messageID, onComplete: { (errMsg) in
                if errMsg == nil{
                    self._allMessagesInChat.append(message)
                    print(iterator)
                    //print(message.messageData)
                    self.convertMessageIDSToMessageModel(iterator: iterator + 1)
                }else{
                    self.onMessagesConverted(errMsg: "Error finding messages...")
                }
            })
            
        }else{
            print("no error convert")
            self._allJSQMessagesInChat = self.convertMessageToJSQMessages()
            self.organizeMessages()
            self.onMessagesConverted(errMsg: nil)

        }
        
    }

    func convertMessageToJSQMessages() -> [JSQMessage]{
        
        var updatedMessagesList = [JSQMessage]()

        for message in allMessagesInChat {
            
            let messageDate = Date(timeIntervalSince1970: Double(message.timeStamp))
            
            let newJSQMessage =  JSQMessage(senderId: message.senderUID, senderDisplayName: "", date: messageDate, text: message.messageData)

            updatedMessagesList.append(newJSQMessage!)

        }
        
        return updatedMessagesList
        
    }
    
    func organizeMessages(){
        FBDataService.instance._allJSQMessagesInChat.sort { $0.date < $1.date }
    }
    
    func onMessagesConverted(errMsg: String?){
        if errMsg == nil{
            let notifDict: Dictionary<String, AnyObject?> = ["errMsg": nil, "data": nil]
            
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "chatMessagesRecieved"), object: notifDict))
            
            print("-no error convert messages --")
            //print(self.allJSQMessagesInChat)
        }else{
            let notifDict: Dictionary<String, AnyObject?> = ["errMsg": "there was an error" as Optional<AnyObject>, "data": nil]
            
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "chatMessagesRecieved"), object: notifDict))
        }
    }
    
    func convertLastMessageToMessageModel(channelName: String, onComplete: DataCompletion?){
        
        self._allChannelNames.append(channelName)
        
        _ = channelsRef.child(channelName).queryLimited(toLast: 1).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            if snapshot.value != nil{
                
                let messageID = snapshot.key
        
                let message = Message()
                message.castMessage(messageID, onComplete: { (errMsg) in
                    if errMsg == nil{
                        self._allLastMessages.append(message)
                        onComplete?(nil, nil)
                    }else{
                        print("error updaating list")
                    }
                })
            
            }else{
                onComplete?("No Messages for User", nil)
            }
        })
        
    }

    
    func convertMessageIDToMessageModel(messageID: String, onComplete: DataCompletion?){
        
        FBDataService.instance._allMessageIDSInChat.append(messageID)
        
        //Peraps you could just append the message to allIDS and then create a recursive function that will iterator over all the messages 
        //kinda like puting a hold to the cycle and slowing it down like a funle

        //print("new message -----\(messageID)")
        
        let message = Message()
        message.castMessage(messageID, onComplete: { (errMsg) in
            if errMsg == nil{
                FBDataService.instance._allMessagesInChat.append(message)
                FBDataService.instance._allJSQMessagesInChat.append(self.convertMessageToJSQMessage(message: message))
                //self.organizeMessages()
               // print("\(message.messageData) ----\(messageID)")
//                for message in FBDataService.instance._allJSQMessagesInChat{
//                    print(message.text)
//                }
                
                //self.organizeMessages()
                
               // NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "newChatMessageConverted"), object: nil))
                
                self._newJSQMessage = self.convertMessageToJSQMessage(message: message)
                
                onComplete?(nil, nil)
                
            }else{
                print("error updaating list")
            }
        })
        
    }
    
    func castMessageID(messageID: String, onComplete: DataCompletion?){
    
        let message = Message()
        message.castMessage(messageID, onComplete: { (errMsg) in
            if errMsg == nil{
                FBDataService.instance._allMessagesInChat.append(message)
                FBDataService.instance._allJSQMessagesInChat.append(self.convertMessageToJSQMessage(message: message))
                //self.organizeMessages()
                //print("\(message.messageData) ----\(messageID)")
                //                for message in FBDataService.instance._allJSQMessagesInChat{
                //                    print(message.text)
                //                }
                
                //self.organizeMessages()
                
                // NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "newChatMessageConverted"), object: nil))
                
                self._newJSQMessage = self.convertMessageToJSQMessage(message: message)
                
                onComplete?(nil, nil)
                
            }else{
                print("error updaating list")
            }
        })
        

        
    }
    
    func convertMessageToJSQMessage(message: Message) -> JSQMessage{
        
        let messageDate = Date(timeIntervalSince1970: Double(message.timeStamp))
        
        let newJSQMessage =  JSQMessage(senderId: message.senderUID, senderDisplayName: "", date: messageDate, text: message.messageData)
        return newJSQMessage!
        
    }
    
    
    func observeChannelsAddedForUser(_ uuid: String!){
    
        self.channelAddedHandler = self.userChannelsRef.child(uuid).observe(FIRDataEventType.childAdded, with: { (snapshot) in
            if snapshot.value != nil{
                
                let channelName = snapshot.key
                FBDataService.instance.convertLastMessageToMessageModel(channelName: channelName, onComplete: { (errMsg, data) in
                    print("loaded -------added")
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "channelRetrieved"), object: nil))
                })
            }
        })

    }
    
    
    func observeChannelsChangedForUser(_ uuid: String!){
        
        self.channelChangedHandler = self.userChannelsRef.child(uuid).observe(FIRDataEventType.childChanged, with: { (snapshot) in
            if snapshot.value != nil{
                
                if !self.dataChanged{
                    self.dataChanged = true
                    let channelName = snapshot.key
                    
                    self._allChannelNames = self._allChannelNames.filter { $0 != channelName }
                    self._allLastMessages = self._allLastMessages.filter { $0.channelName != channelName }

                    print("\(self.allChannelNames) ----------channelNames")
                    FBDataService.instance.convertLastMessageToMessageModel(channelName: channelName, onComplete: { (errMsg, data) in
                        print("loaded")
                        print(self._allChannelNames)
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "channelRetrieved"), object: nil))
                    })
                }else{
                    self.dataChanged = false
                }
            }
        })
        
    }
    
    func convertReservationIDToModel(_ reservationID: String, onComplete: DataCompletion?){
        
        self._allReservationIDS.append(reservationID)
        
        let reservation = Reservation()
        reservation.castReservation(reservationID) { (errMsg) in
            if errMsg == nil{
                self._allReservations.append(reservation)
                onComplete?(nil, nil)
            }else{
                print("error updaating list")
            }
        }
        
        
    }
    
    func observeReservationsAddedForUser(_ uuid: String!){
        
        self.reservationAddedHandler = self.userReservationsRef.child(uuid).observe(FIRDataEventType.childAdded, with: { (snapshot) in
            if snapshot.value != nil{
                
                let reservationID = snapshot.key
                self.convertReservationIDToModel(reservationID, onComplete: { (errMsg, data) in
                    if errMsg == nil{
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reservationRetrieved"), object: nil))
                    }
                })
               
            }
        })
        
    }
    
    
    
    
}
