//
//  FBDataService.swift
//  bluepin
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
    
    var mainRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var usersRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_USERS)
    }
    
    var businessUserRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_USERS_BUSINESS)
    }
    
    var customerUserRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_USERS_CUSTOMER)
    }
    
    var businessFollowersRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_BUSINESS_FOLLOWERS)
    }
    
    var customerFollowersRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_CUSTOMER_FOLLOWERS)
    }
    
    var userChannelsRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_USER_CHANNELS)
    }
    
    var channelsRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_CHANNELS)
    }
    
    var channelIDSRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_CHANNEL_IDS)
    }
    
    var messagesRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_MESSAGES)
    }
    
    var userReservationsRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_USER_RESERVATIONS)
    }
    
    var reservationsRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_RESERVATIONS)
    }
    
    var notificationsRef: DatabaseReference {
        return mainRef.child(FIR_CHILD_NOTIFICATIONS)
    }
    
    //-----------------End Database References------------------//
    

    //-----------------Current User--------------------//

    var currentUser: User? {
        
        if let user = Auth.auth().currentUser {
            // User is signed in.
            return user
        } else {
            // No user is signed in.
            return nil
        }
        
    }
    
    //-----------------End Current User--------------------//
    

    
    //-----------------Storage References--------------------//

    
    var mainStorageRef: StorageReference {
        return Storage.storage().reference()
    }
    
    var profilePicsStorageRef: StorageReference {
        return mainStorageRef.child(FIR_STORAGE_CHILD_USER_PROFILE_PICS)
    }
   
    var messagesStorageRef: StorageReference {
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
    
    var _allReservationIDS: [String] = []
    
    var allReservationIDS: [String]{
        return _allReservationIDS
    }

    var _allReservations: [String: Reservation] = [String: Reservation]()

    var allReservations: [String: Reservation]{
        return _allReservations
    }
    
    //-------------Firebase Observer Handlers-----------//

    var reservationAddedHandler: FirebaseHandle!
    var reservationChangedHandler: FirebaseHandle!
    var reservationDeletedHandler: FirebaseHandle!
    

    //-------------End Firebase Observer Handlers-----------//

    
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
        
        onComplete?(nil, nil)

    }
    
    func updateUser(_ uid: String!, propertes: Dictionary<String, AnyObject>, onComplete: DataCompletion?) {
        
        mainRef.child(FIR_CHILD_USERS).child(uid).updateChildValues(propertes)
        onComplete?(nil, nil)
        
    }
    
    func resetPassword(_ email: String!, onComplete: DataCompletion?) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                onComplete?("An error occured... \(error)", nil)
            } else {
                onComplete?(nil, nil)
            }
        }
        
    }
    
    func resetEmail(_ email: String!, onComplete: DataCompletion?) {
        
        let user = Auth.auth().currentUser
        
        user?.updateEmail(to: email) { error in
            if let error = error {
                onComplete?(error.localizedDescription, nil)
            } else {
                onComplete?(nil, nil)
            }
        }
        
    }
    
    func uploadFile(_ filePath: StorageReference!, data: Data!, metadata: StorageMetadata!, onComplete: DataCompletion?){
       
        let uploadTask = filePath.putData(data, metadata: metadata);

        uploadTask.observe(.progress) { snapshot in
            if let progress = snapshot.progress {
                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                self._uploadProgress = percentComplete
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "uploadProgressFB"), object: nil))
            }
        }
        
        uploadTask.observe(.success) { snapshot in
            uploadTask.removeAllObservers()
            onComplete?(nil, snapshot.metadata)
        }
        
        uploadTask.observe(.failure) { snapshot in
            guard let storageError = snapshot.error else { return }
            guard StorageErrorCode(rawValue: storageError._code) != nil else { return }
            uploadTask.removeAllObservers()
            onComplete?("There was an upload error. Check your connection.", nil)
        }
    }
    
    
    //Load Businesses
    func retriveAllBusinesses(onComplete: DataCompletion?) {
        
        _ = businessUserRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            if let businessDict = snapshot.value as? [String : AnyObject]{
                
                self._allBusinesses.removeAll()
                
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
                
        _ = businessFollowersRef.child(businessID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
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
                        self.businessFollowersRef.child(businessID).child(customerID).setValue(ServerValue.timestamp())
                        self.customerFollowersRef.child(customerID).child(businessID).setValue(ServerValue.timestamp())
                        onComplete?(nil, true as AnyObject?)
                    }
                    
                    self._allBusinessesFollowed.removeAll()

                }else{
                    self.businessFollowersRef.child(businessID).child(customerID).setValue(ServerValue.timestamp())
                    self.customerFollowersRef.child(customerID).child(businessID).setValue(ServerValue.timestamp())
                    onComplete?(nil, true as AnyObject?)
                }
            }else{
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
                        
                    }
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
    
    //Reservations
    
    func convertReservationIDToModel(_ reservationID: String, onComplete: DataCompletion?){
        
        let reservation = Reservation()
        reservation.castReservation(reservationID) { (errMsg) in
            if errMsg == nil{
                
                if reservation.status == INACTIVE_STATUS{
                
                    onComplete?("Delete Reservation", reservation.status as AnyObject?)

                }else{
                
                    self._allReservations[reservationID] = reservation
                    
                    let currentDate = NSDate()
                    
                    let scheduledTimeString = reservation.scheduledTime
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
                    
                    if let scheduledDate = dateFormatter.date(from: scheduledTimeString){
                    
                        if scheduledDate < currentDate as Date && reservation.status != INACTIVE_STATUS{
                            self.updateReservationForUser(reservation.uuid, status: INACTIVE_STATUS, businessID: reservation.businessID, customerID: reservation.leaderID)
                        }
                    }
                    
                    onComplete?(nil, reservation.status as AnyObject?)

                }
                
            }
        }
        
    }
    
    func observeReservationsAddedForUser(_ uuid: String!){
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reservationRetrieved"), object: nil))
        
        self.reservationAddedHandler = self.userReservationsRef.child(uuid).queryOrderedByValue().queryLimited(toLast: 25).observe(DataEventType.childAdded, with: { (snapshot) in
            
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

        self.reservationChangedHandler = self.userReservationsRef.child(uuid).queryLimited(toLast: 25).observe(DataEventType.childChanged, with: { (snapshot) in

            if snapshot.value != nil{
                
                let reservationID = snapshot.key
                self.convertReservationIDToModel(reservationID, onComplete: { (errMsg, data) in
                    if errMsg == nil{
                        
                        if data as? String == INACTIVE_STATUS{
                            self._allReservationIDS = self._allReservationIDS.filter { $0 != reservationID }
                            self._allReservations.removeValue(forKey: reservationID)
                        }

                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reservationRetrieved"), object: nil))
                    }
                })
                
            }
        })
        
    }

    func observeReservationsDeletedForUser(_ uuid: String!){
        
        self.reservationDeletedHandler = self.userReservationsRef.child(uuid).queryLimited(toLast: 25).observe(DataEventType.childRemoved, with: { (snapshot) in
            if snapshot.value != nil{
                
                let reservationID = snapshot.key
               
                self._allReservationIDS = self._allReservationIDS.filter { $0 != reservationID }
                self._allReservations.removeValue(forKey: reservationID)
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reservationRetrieved"), object: nil))
                
            }
        })
        
    }
    
    func removeReservationForUser(_ reservationID: String!, businessID: String!, customerID: String!, businessName: String!){
        
        self.reservationsRef.child(reservationID).removeValue()
        self.userReservationsRef.child(businessID).child(reservationID).removeValue()
        self.userReservationsRef.child(customerID).child(reservationID).removeValue()
        
        let notification = FBDataService.instance.notificationsRef.childByAutoId()
        
        let notificationRequest: Dictionary<String, AnyObject> = [REQUEST_ID: notification.key as AnyObject, REQUEST_SENDER_ID: businessID as AnyObject, REQUEST_RECIPIENT_ID: customerID as AnyObject, REQUEST_MESSAGE: DELETED_RESERVATION_NOTIF as AnyObject, REQUEST_SENDER_NAME: businessName as AnyObject]

        notification.setValue(notificationRequest)

    }

    func updateReservationForUser(_ reservationID: String!, status: String!, businessID: String!, customerID: String!){
        
         let selecteReservation = self.allReservations[reservationID]
        
         let reservation: Dictionary<String, AnyObject> = [RESERVATION_STATUS: status as AnyObject]
         self.reservationsRef.child(reservationID).updateChildValues(reservation)
        
        let interval = Date(timeIntervalSince1970: (selecteReservation?.appointmentTimeInterval)!)
        let newInterval = Date(timeInterval: 0.001, since: interval)
        let time = Double(newInterval.timeIntervalSince1970)
        
        self.userReservationsRef.child(businessID).child(reservationID).setValue(time)
        self.userReservationsRef.child(customerID).child(reservationID).setValue(time)
        
    }
    
    //End Reservations

    func removeObservers(uuid: String!){
    
        self.userReservationsRef.child(uuid).removeAllObservers()
        self.userChannelsRef.child(uuid).removeAllObservers()
        
        self.reservationAddedHandler = nil;
        self.reservationChangedHandler = nil;
        self.reservationDeletedHandler = nil;
        
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
    
    func clearAllReservations(){
        self._allReservationIDS.removeAll()
        self._allReservations.removeAll()
    }
    
}
