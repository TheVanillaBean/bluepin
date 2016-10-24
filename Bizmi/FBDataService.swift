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
    
    var notificationsRef: FIRDatabaseReference {
        return mainRef.child(FIR_CHILD_NOTIFICATIONS)
    }
    
    //-----------------End Database References------------------//
    

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
    

    
    //-----------------Storage References--------------------//

    
    var mainStorageRef: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    
    var profilePicsStorageRef: FIRStorageReference {
        return mainStorageRef.child(FIR_STORAGE_CHILD_USER_PROFILE_PICS)
    }
   
    var messagesStorageRef: FIRStorageReference {
        return mainStorageRef.child(FIR_STORAGE_CHILD_MESSAGES)
    }
    
    //-----------------End Storage References--------------------//

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
    
    var _allLastMessages: [String: Message] = [String: Message]()
    
    var allLastMessages: [String: Message]{
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
    
    var allReservationIDS: [String]{
        return _allReservationIDS
    }

    var _allReservations: [String: Reservation] = [String: Reservation]()

    var allReservations: [String: Reservation]{
        return _allReservations
    }
    
    //-------------Firebase Observer Handlers-----------//
    
    var channelAddedHandler: FirebaseHandle!
    var channelChangedHandler: FirebaseHandle!

    var reservationAddedHandler: FirebaseHandle!
    var reservationChangedHandler: FirebaseHandle!
    var reservationDeletedHandler: FirebaseHandle!

    //-------------End Firebase Observer Handlers-----------//

    
    //For Reservations
    var appointmentLeaderID: String = "Select Customer"
    var appointmentLeaderName: String!
    var appointmentLeaderDeviceToken: String!

    func saveUser(_ uid: String!, isCustomer: Bool?, propertes: Dictionary<String, AnyObject>, onComplete: DataCompletion?) {
        
        usersRef.child(uid).setValue(propertes)
        
        if isCustomer!{
            customerUserRef.child(uid).setValue(true)
        }else{
            businessUserRef.child(uid).setValue(true)
        }
        
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
    
    func resetEmail(_ email: String!, onComplete: DataCompletion?) {
        
        let user = FIRAuth.auth()?.currentUser
        
        user?.updateEmail(email) { error in
            if let error = error {
                
                onComplete?(error.localizedDescription, nil)
                
            } else {
                onComplete?(nil, nil)
            }
        }
        
    }
    
    
    func handleFirebaseError(_ error: NSError, onComplete: DataCompletion?) {
        print(error.debugDescription)
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
            switch (errorCode) {
            case .errorCodeInvalidEmail:
                onComplete?("Invalid email address", nil)
                break
            case .errorCodeWrongPassword:
                onComplete?("Invalid password", nil)
                break
            case .errorCodeEmailAlreadyInUse, .errorCodeAccountExistsWithDifferentCredential:
                onComplete?("Could not create account. Email already in use", nil)
                break
            case .errorCodeUserDisabled:
                onComplete?("Account Temporally Disabled. Contact Support to get issue resolved", nil)
            case .errorCodeWeakPassword:
                onComplete?("Weak Password. Password must be greater than six characters", nil)
            default:
                onComplete?("There was a problem authenticating. Try again.", nil)
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
            uploadTask.removeAllObservers()
            onComplete?(nil, snapshot.metadata)
        }
        
        // Errors only occur in the "Failure" case
        uploadTask.observe(.failure) { snapshot in
            guard let storageError = snapshot.error else { return }
            guard FIRStorageErrorCode(rawValue: storageError._code) != nil else { return }
            uploadTask.removeAllObservers()
            onComplete?("There was an upload error. Check your connection.", nil)
        }
    }
    
    
    //Load Businesses
    func retriveAllBusinesses(onComplete: DataCompletion?) {
        
        self._allBusinesses.removeAll()
       
        _ = businessUserRef.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            
            if let businessDict = snapshot.value as? [String : AnyObject]{

                for businessObj in businessDict{
                    let business = businessObj.key
                    self._allBusinesses.append(business)
                    onComplete?(nil, nil)
                }
            
            }else{
                
                onComplete?("No businesses were retrieved...", nil)
            }
        })
    }
    
    //Load Followers
    func retriveAllFollowers(businessID: String, onComplete: DataCompletion?) {
        
        self._allFollowers.removeAll()
        self._allFollowersTime.removeAll()
        
        _ = businessFollowersRef.child(businessID).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            
            if let followersDict = snapshot.value as? [String : AnyObject]{
            
                for followObj in followersDict{
                    
                    let customerID = followObj.key
                    self._allFollowers.append(customerID)
                    self._allFollowersTime.append(followObj.value as! Double)
                    onComplete?(nil, nil)
                }
            
            }else{
                onComplete?("No followers were retrieved...", nil)
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

    func convertLastMessageToMessageModel(channelName: String, onComplete: DataCompletion?){
        
        _ = channelsRef.child(channelName).queryLimited(toLast: 1).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            if snapshot.value != nil{
                
                let messageID = snapshot.key
                
                let message = Message()
                message.castMessage(messageID, onComplete: { (errMsg) in
                    if errMsg == nil{
                        self._allLastMessages[channelName] = message
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
    
    
    func observeChannelsAddedForUser(_ uuid: String!){
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "channelRetrieved"), object: nil))
        
        self.channelAddedHandler = self.userChannelsRef.child(uuid).observe(FIRDataEventType.childAdded, with: { (snapshot) in
            
            if snapshot.value != nil{
                
                    let channelName = snapshot.key
                    self.convertLastMessageToMessageModel(channelName: channelName, onComplete: { (errMsg, data) in
                        self._allChannelNames.append(channelName)
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "channelRetrieved"), object: nil))
                    })
            }
        })
        
    }
    
    func observeChannelsChangedForUser(_ uuid: String!){
        
        self.channelChangedHandler = self.userChannelsRef.child(uuid).observe(FIRDataEventType.childChanged, with: { (snapshot) in
            if snapshot.value != nil{
                
                let channelName = snapshot.key
                self.convertLastMessageToMessageModel(channelName: channelName, onComplete: { (errMsg, data) in
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "channelRetrieved"), object: nil))
                })
              
            }
        })
        
    }

    
   //End Channels Retirveing
    
    
   //Messaging Conversation
    
    func organizeMessages(){
        FBDataService.instance._allJSQMessagesInChat.sort { $0.date < $1.date }
    }
    
    func convertMessageIDToMessageModel(messageID: String!, onComplete: DataCompletion?){
                
        let message = Message()
        message.castMessage(messageID, onComplete: { (errMsg) in
            if errMsg == nil{
                let convertedMessage = self.convertMessageToJSQMessage(message: message)
                FBDataService.instance._allMessagesInChat.append(message)
                FBDataService.instance._allJSQMessagesInChat.append(convertedMessage)
                self._newJSQMessage = convertedMessage
                onComplete?(nil, nil)
            }else{
                print("error updaating list")
            }
        })
        
    }
    
    func convertMessageToJSQMessage(message: Message) -> JSQMessage{
        
        let messageDate = Date(timeIntervalSince1970: Double(message.timeStampDouble))
        
        let newJSQMessage =  JSQMessage(senderId: message.senderUID, senderDisplayName: "", date: messageDate, text: message.messageData)
        return newJSQMessage!
        
    }
 
    
    //End Messaging Conversation
    
    //Reservations
    
    func convertReservationIDToModel(_ reservationID: String, onComplete: DataCompletion?){
        
        let reservation = Reservation()
        reservation.castReservation(reservationID) { (errMsg) in
            if errMsg == nil{
                self._allReservations[reservationID] = reservation
                
                let currentDate = NSDate()
                
                let scheduledTimeString = reservation.scheduledTime
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
                if let scheduledDate = dateFormatter.date(from: scheduledTimeString){
                
                    if scheduledDate < currentDate as Date{
                        self.updateReservationForUser(reservation.uuid, status: INACTIVE_STATUS, businessID: reservation.businessID, customerID: reservation.leaderID)
                    }
                }
                
                onComplete?(nil, nil)
            }else{
                print("error updaating list")
            }
        }
        
    }
    
    func observeReservationsAddedForUser(_ uuid: String!){
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reservationRetrieved"), object: nil))
        
        self.reservationAddedHandler = self.userReservationsRef.child(uuid).observe(FIRDataEventType.childAdded, with: { (snapshot) in
            
            if snapshot.value != nil{
                
                let reservationID = snapshot.key
                self.convertReservationIDToModel(reservationID, onComplete: { (errMsg, data) in
                    if errMsg == nil{
                        self._allReservationIDS.append(reservationID)
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reservationRetrieved"), object: nil))
                    }
                })
               
            }
        })
        
    }
    
    func observeReservationsChangedForUser(_ uuid: String!){
        
        self.reservationChangedHandler = self.userReservationsRef.child(uuid).observe(FIRDataEventType.childChanged, with: { (snapshot) in
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

    func observeReservationsDeletedForUser(_ uuid: String!){
        
        self.reservationDeletedHandler = self.userReservationsRef.child(uuid).observe(FIRDataEventType.childRemoved, with: { (snapshot) in
            if snapshot.value != nil{
                
                let reservationID = snapshot.key
               
                self._allReservationIDS = self._allReservationIDS.filter { $0 != reservationID }
                self._allReservations.removeValue(forKey: reservationID)
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reservationRetrieved"), object: nil))
                
                
            }
        })
        
    }
    
    func removeReservationForUser(_ reservationID: String!, businessID: String!, customerID: String!){
        
        self.reservationsRef.child(reservationID).removeValue()
        self.userReservationsRef.child(businessID).child(reservationID).removeValue()
        self.userReservationsRef.child(customerID).child(reservationID).removeValue()

    }

    func updateReservationForUser(_ reservationID: String!, status: String!, businessID: String!, customerID: String!){
        
         let reservation: Dictionary<String, AnyObject> = [RESERVATION_STATUS: status as AnyObject]
         self.reservationsRef.child(reservationID).updateChildValues(reservation)
        
        self.userReservationsRef.child(businessID).child(reservationID).setValue(FIRServerValue.timestamp())
        self.userReservationsRef.child(customerID).child(reservationID).setValue(FIRServerValue.timestamp())
        
    }
    
    //End Reservations

    func removeObservers(uuid: String!){
    
        self.userReservationsRef.child(uuid).removeAllObservers()
        self.userChannelsRef.child(uuid).removeAllObservers()
        
    }
    
    func clearCurrentSelectedUser(){
        self.appointmentLeaderID = "Select Customer"
        self.appointmentLeaderName = ""
    }
    
    func clearAllFollowers(){
        self._allFollowers.removeAll()
        self._allFollowersTime.removeAll()
    }
    
    func clearAllBusinesses(){
        self._allBusinesses.removeAll()
        self._allBusinessesFollowed.removeAll()
    }
    
    func clearAllChannels(){
        self._allChannelNames.removeAll()
        self._allLastMessages.removeAll()
    }
    
    func clearAllReservations(){
        self._allReservationIDS.removeAll()
        self._allReservations.removeAll()
    }
    
    func clearAllMessagesInChat(){
        self._allJSQMessagesInChat.removeAll()
        self._allMessagesInChat.removeAll()
        self._allMessageIDSInChat.removeAll()
    }
    
}
