////
////  DataService.swift
////  Bizmi
////
////  Created by Alex on 7/28/16.
////  Copyright © 2016 Alex. All rights reserved.
////
//
//import Foundation
//import UIKit
//import JSQMessagesViewController
//fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l < r
//  case (nil, _?):
//    return true
//  default:
//    return false
//  }
//}
//
//
//class DataService: NSObject{
//    
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//    let serialQueue: DispatchQueue = DispatchQueue(label: "pageHistoryQueue", attributes: [])
//
//    fileprivate static let _instance = DataService()
//
//    static var instance: DataService {
//        return _instance
//    }
//    
//    fileprivate var _allUsers = [User]()
//    
//    var allUsers: [User] {
//        
//        return _allUsers
//        
//    }
//    
//    fileprivate var _allBusinesses = [User]()
//    
//    var allBusinesses: [User] {
//        
//        return _allBusinesses
//        
//    }
//    
//    fileprivate var _allFollowers = [User]()
//    
//    var allFollowers: [User] {
//        
//        return _allFollowers
//        
//    }
//    
//    func currentUser() -> User{
//        
//        let user = User()
//        user.populateUserData(appDelegate.backendless.userService.currentUser)
//        
//        return user
//    }
//    
//    fileprivate var _allCustomerReservations: [Reservation] = []
//    
//    var allCustomerReservations: [Reservation] {
//        
//        return _allCustomerReservations
//    
//    }
//    
//    fileprivate var _allBusinessReservations: [Reservation] = []
//    
//    var allBusinessReservations: [Reservation] {
//        
//        return _allBusinessReservations
//    
//    }
//    
//    fileprivate var _allInboundMessageItems: [MessageItem] = [] //From Pubnub
//    
//    fileprivate var _allUniqueChannelNames: [String] = []
//    
//    fileprivate var _allUniqueChannels: [MessageItem] = [] //Queried from _allInboundMessageItems
//    
//    var allUniqueChannels: [MessageItem] {
//        
//        return _allUniqueChannels
//        
//    }
//    
//    var allUniqueChannelNames: [String] {
//        
//        return _allUniqueChannelNames
//        
//    }
//    
//    var allInboundMessageItems: [MessageItem] {
//    
//        return _allInboundMessageItems
//        
//    }
//    
//    fileprivate var _newPubNubMessage: MessageItem!
//    
//    var newPubNubMessage: MessageItem {
//        
//        get {
//            return _newPubNubMessage
//        }
//        
//        set(newMessage){
//            _newPubNubMessage = newMessage
//        }
//    }
//    
//    fileprivate var _allMessageItemsInChat: [MessageItem] = []
//    fileprivate var _allJSQMessagesInChat: [JSQMessage] = []
//    
//    var allJSQMessagesInChat: [JSQMessage] {
//       
//        get {
//            return _allJSQMessagesInChat
//        }
//        
//    }
//    
//    fileprivate var _appointmentLeaderName: String?
//    
//    var appointmentLeaderName: String {
//        
//        get {
//            if let name = _appointmentLeaderName{
//                return name
//            }else{
//                return "Select Customer"
//            }
//            
//        }
//        
//        set(newLeader){
//            _appointmentLeaderName = newLeader
//        }
//    }
//    
//    fileprivate var _appointmentLeaderID: String?
//    
//    var appointmentLeaderID: String {
//        
//        get {
//            if let ID = _appointmentLeaderID{
//                return ID
//            }else{
//                return "Select Customer"
//            }
//        }
//        
//        set(newLeaderID){
//            _appointmentLeaderID = newLeaderID
//        }
//    }
//    
//    enum statusType: String {
//        case PENDING = "Pending"
//        case ACTIVE = "Active"
//        case INACTIVE = "Inactive"
//        case DECLINED = "Declined"
//    }
//
//    func appendMessageToAllJSQMessages(_ newMessage: MessageItem){
//        
//        let newJSQMessage = JSQMessage(senderId: newMessage.uuid, displayName: "", text: newMessage.message)
//        
//        _allJSQMessagesInChat.append(newJSQMessage!)
//        _allMessageItemsInChat.append(newMessage)
//        
//    }
//    
//    func loadAllUsers(){
//        
//        let dataStore = appDelegate.self.backendless.persistenceService.of(BackendlessUser.ofClass())
//        
//        dataStore.find(
//            { (users : BackendlessCollection!) -> () in
//
//                //Backendless pages data - getCurrentPage will load 100 users
//                //Eventually we will implement paging mechanism as user scrolls more data will be loaded.
//                let currentPage = users.getCurrentPage()
//                
//                for user in currentPage as! [BackendlessUser]{
//                    
//                    //Cast BackendlessUser object to Bizmi User object
//                    let userObj: User = User()
//                    userObj.populateUserData(user)
//
//                    self._allUsers.append(userObj)
//                }
//                
//                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "allUsersLoaded", object: nil))
//                
//            },
//            error: { (fault : Fault!) -> () in
//                print("Server reported an error (ASYNC): \(fault.description)")
//            }
//        )
//     
//    }
//    
//     /*
//     1. Load all Follower ID's from Follow table
//     2. Query Follower ID from Users table one-by-one until all followers have been loaded from Users table
//     3. Send Notificaton once all users have been addd to _allFollowers variable
//     */
//    
//    func loadAllFollowers(){
//        
//        let currentuser = appDelegate.backendless.userService.currentUser
//        
//        let dataStore = appDelegate.self.backendless.persistenceService.of(Follow.ofClass())
//        
//        let whereClause = "To = '\(currentuser.objectId)'"
//        let dataQuery = BackendlessDataQuery()
//        dataQuery.whereClause = whereClause
//        
//        dataStore.find(dataQuery,
//               response: { (follows : BackendlessCollection!) -> () in
//                
//                let currentFollowersPage = follows.getCurrentPage()
//                
//                print("\(currentFollowersPage.count) current followers page")
//                
//                if currentFollowersPage.count > 0 {
//                    
//                    for follow in currentFollowersPage as! [Follow]{
//                        
//                        print("\(follow.From) current page")
//
//                        if let followerID = follow.From{
//                            
//                            let dataStore = self.appDelegate.backendless.persistenceService.of(BackendlessUser.ofClass())
//                            
//                            let whereClause = "userType = 'Customer' AND userObjectID = '\(followerID)'"
//                            let dataQuery = BackendlessDataQuery()
//                            dataQuery.whereClause = whereClause
//                            
//                            dataStore.find(dataQuery,
//                                response: { (users : BackendlessCollection!) -> () in
//                                    
//                                    //Backendless pages data - getCurrentPage will load 100 users
//                                    //Eventually we will implement paging mechanism as user scrolls more data will be loaded.
//                                    let currentPage = users.getCurrentPage()
//                                    print("\(currentPage.count) current page")
//
//                                    for user in currentPage as! [BackendlessUser]{
//                                        
//                                        //Cast BackendlessUser object to Bizmi User object
//                                        let userObj: User = User()
//                                        userObj.populateUserData(user)
//                                        
//                                        self._allFollowers.append(userObj)
//                                        
//                                        print("\(userObj.fullName)")
//
//                                    }
//                                    
//                                    //Make sure all users have been loaded because it is asyncronous
//                                    
//                                    if self._allFollowers.count == currentFollowersPage.count {
//                                        
//                                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "allFollowersLoaded", object: nil))
//                                        
//                                    }
//                                    
//                                    
//                                },
//                                error: { (fault : Fault!) -> () in
//                                    print("Server reported an error (ASYNC): \(fault.description)")
//                                }
//                            )
//                            
//                        }
//                    }
//                   
//                    
//                }
//                
//            },
//           error: { (fault : Fault!) -> () in
//            print("Server reported an error (ASYNC): \(fault.description)")
//            }
//        )
//        
//    }
//    
//    //TODO add filter option as argument
//    
//    func loadAllBusinesses(){
//        
//        let dataStore = appDelegate.self.backendless.persistenceService.of(BackendlessUser.ofClass())
//        
//        let whereClause = "userType = 'Business'"
//        let dataQuery = BackendlessDataQuery()
//        dataQuery.whereClause = whereClause
//    
//        dataStore.find(dataQuery,
//            response: { (users : BackendlessCollection!) -> () in
//                
//                //Backendless pages data - getCurrentPage will load 100 users
//                //Eventually we will implement paging mechanism as user scrolls more data will be loaded.
//                let currentPage = users.getCurrentPage()
//                
//                for user in currentPage as! [BackendlessUser]{
//                    
//                    //Cast BackendlessUser object to Bizmi User object
//                    let userObj: User = User()
//                    userObj.populateUserData(user)
//                    
//                    self._allBusinesses.append(userObj)
//                }
//                
//                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "allBusinessesLoaded", object: nil))
//                
//                print("users loaded")
//                
//            },
//            error: { (fault : Fault!) -> () in
//                print("Server reported an error (ASYNC): \(fault.description)")
//            }
//        )
//        
//    }
//    
//    /*
//     There is an odd error: if the user enters an email that is taken, they get fault code 3018; but for some odd reason the next time they try to update their profile, the server returns the same error. There is a reference to the current users email, newEmail, that is called before the update is made and is used to refresh the user if they get fault code 3018.
//     */
//    
//    func updateUser(_ properties: [String: AnyObject]){
//        
//        let currentUser = self.appDelegate.backendless.userService.currentUser
//        
//        let newEmail = currentUser.email //email reference
//        
//        currentUser.updateProperties( properties )
//        self.appDelegate.backendless.userService.update(currentUser,
//            response: { ( updatedUser : BackendlessUser!) -> () in
//                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "userUpdated", object: nil))
//            },
//            error: { ( fault : Fault!) -> () in
//                if fault.faultCode == "3018" {
//                    print("Error \(currentUser.email)")
//                    //TODO: Call email proeprty again but with email that worked so error goes away
//
//                    let newProperties = ["email": newEmail]
//                    
//                    DataService.instance.updateUser(newProperties)  //refresh user
//                    
//                    Messages.showAlertDialog("Error", msgAlert: "That email address is already taken...")
//                }else{
//                    Messages.showAlertDialog("Error", msgAlert: "There was an error updating your profile. Please contact support@bizmiapp.com if the issue persists.")
//                }
//               
//        })
//
//    }
//
//    
//    func requestUserPasswordChange(_ email: String, uiVIew: UIView!) {
//        
//        appDelegate.backendless.userService.restorePassword(email,
//             response:{ ( result : AnyObject!) -> () in
//                Messages.showAlertDialog("Change Requested!", msgAlert: "Check your email for a password reset link...")
//            },
//             error: { ( fault : Fault!) -> () in
//                Messages.displayForgotPasswordErrorMessage(uiVIew, errorMsg: fault.faultCode)
//            }
//        )
//    }
//    
//    func logoutUser(){
//        
//        appDelegate.backendless.userService.logout(
//            { ( user : AnyObject!) -> () in
//                print("User logged out.")
//                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "userLoggedOut", object: nil))
//                
//                //Clear DataService Instance
//                self._allUsers.removeAll()
//                self._allBusinesses.removeAll()
//                self._allFollowers.removeAll()
//                self._allCustomerReservations.removeAll()
//                self._allBusinessReservations.removeAll()
//                self._allInboundMessageItems.removeAll()
//                self._allUniqueChannelNames.removeAll()
//                self._allUniqueChannels.removeAll()
//                self._allMessageItemsInChat.removeAll()
//                self._allJSQMessagesInChat.removeAll()
//                
//            },
//            error: { ( fault : Fault!) -> () in
//                print("Server reported an error: \(fault)")
//        })
//    
//    }
//
//    func uploadFile(_ filePath: String, content: Data, overwrite: Bool){
//        
//        appDelegate.backendless.fileService.upload(
//            filePath,
//            content: content,
//            overwrite: overwrite,
//            response: { ( uploadedFile : BackendlessFile!) -> () in
//                print("File has been uploaded. File URL is - \(uploadedFile.fileURL)")
//                
//                let fileDict: [String: AnyObject] = [ "uploadedFile": uploadedFile]
//                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "fileUploaded", object: fileDict))
//            },
//            error: { ( fault : Fault!) -> () in
//                print("Server reported an error: \(fault)")
//        })
//
//    }
//    
//    func subscribeToBusiness(_ From: String, To: String){
//    
//        let dataStore = appDelegate.self.backendless.persistenceService.of(Follow.ofClass())
//        
//        let whereClause = "From = '\(From)' AND To = '\(To)'"
//        let dataQuery = BackendlessDataQuery()
//        dataQuery.whereClause = whereClause
//        
//        dataStore.find(dataQuery,
//                       response: { (follows : BackendlessCollection!) -> () in
//                        
//                        let responseDict: [String: AnyObject]!
//
//                        
//                        if follows.getCurrentPage().count > 0 {
//                            
//                            let follow = follows.getCurrentPage()[0] as! Follow
//                            
//                            responseDict = ["response": "Removed"]
//                            
//                            // now delete the saved object - unsubscribe
//                            dataStore.remove(
//                                follow,
//                                response: { (result: AnyObject!) -> Void in
//                                     NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "subscribedToBusiness", object: responseDict))
//                                },
//                                error: { (fault: Fault!) -> Void in
//                                    print("Server reported an error (2): \(fault)")
//                            })
//                            
//                        }else{
//                            
//                            let follow = Follow()
//                            follow.From = From
//                            follow.To = To
//                            
//                            responseDict = ["response": "Subscribed"]
//
//                            
//                            var error: Fault?
//                            let result = self.appDelegate.backendless.data.save(follow, error: &error) as? Follow
//                            if error == nil {
//                                print("Follow has been saved: \(result?.To)")
//                                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "subscribedToBusiness", object: responseDict))
//
//                            }
//                            else {
//                                print("Server reported an error: \(error)")
//                            }
//                            
//                        }
//                        
//            },
//               error: { (fault : Fault!) -> () in
//                    print("Server reported an error (ASYNC): \(fault.description)")
//            }
//        )
//    }
//    
//    
//    func findCustomerSubscriptionStatus(_ From: String, To: String){
//        
//        let dataStore = appDelegate.self.backendless.persistenceService.of(Follow.ofClass())
//        
//        let whereClause = "From = '\(From)' AND To = '\(To)'"
//        let dataQuery = BackendlessDataQuery()
//        dataQuery.whereClause = whereClause
//        
//        dataStore.find(dataQuery,
//                       response: { (follows : BackendlessCollection!) -> () in
//                        
//                        let responseDict: [String: AnyObject]!
//
//                        if follows.getCurrentPage().count > 0 {
//                            
//                            let follow = follows.getCurrentPage()[0]
//                            
//                            let followDate = follow.created.description
//                            
//                            let convertedDate = self.convertDateToString(followDate)
//                            
//                            responseDict = ["response": "Subscribed", "date": convertedDate]
//                            
//                            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "subscriptionStatus", object: responseDict))
//                            
//                        }else{
//                            
//                            responseDict = ["response": "Not Subscribed", "date": "nil"]
//
//                            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "subscriptionStatus", object: responseDict))
//                            
//                        }
//                        
//            },
//               error: { (fault : Fault!) -> () in
//                    print("Server reported an error (ASYNC): \(fault.description)")
//            }
//        )
//    }
//    
//    func convertDateToString(_ followDate: String) -> String {
//    
//        
//        let followDateSubstring = followDate[followDate.characters.index(followDate.startIndex, offsetBy: 0)...followDate.characters.index(followDate.startIndex, offsetBy: 10)]
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale.current
//        
//        let dateStringFormatter = DateFormatter()
//        dateStringFormatter.dateFormat = "yyyy-MM-dd"
//        let date: Date = dateStringFormatter.date(from: followDateSubstring)!
//        
//        
//        dateFormatter.dateStyle = DateFormatter.Style.medium
//        let convertedDate = dateFormatter.string(from: date)
//        
//        return convertedDate
//    
//    }
//    
//    func findCustomerReservations(_ customerID: String!, status: String){
//        
//        let dataStore = appDelegate.self.backendless.persistenceService.of(Reservation.ofClass())
//        
//        let whereClause = "PartyLeaderID = '\(customerID)' AND Status = '\(status)'"
//        let dataQuery = BackendlessDataQuery()
//        dataQuery.whereClause = whereClause
//        
//        dataStore.find(dataQuery,
//                       response: { (reservations : BackendlessCollection!) -> () in
//                        
//                        let currentPage = reservations.getCurrentPage()
//                     
//                        for reservation in currentPage as! [Reservation]{
//                            self._allCustomerReservations.append(reservation)
//                        }
//                    
//                        if status == statusType.PENDING.rawValue{
//                            self.findCustomerReservations(customerID, status: statusType.ACTIVE.rawValue)
//                        }else if status == statusType.ACTIVE.rawValue{
//                            self.findCustomerReservations(customerID, status: statusType.INACTIVE.rawValue)
//                        }else if status == statusType.INACTIVE.rawValue{
//                            self.findCustomerReservations(customerID, status: statusType.DECLINED.rawValue)
//                        }else if status == statusType.DECLINED.rawValue{
//                            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "findCustomerReservations", object: nil))
//                            
//                            print("reservations loaded")
//                        }
//                        
//
//            },
//               error: { (fault : Fault!) -> () in
//                print("Server reported an error (ASYNC): \(fault.description)")
//            }
//        )
//
//    }
//    
//    func clearCustomerReservation(){
//        self._allCustomerReservations.removeAll()
//    }
//
//    func clearBusinessReservation(){
//        self._allBusinessReservations.removeAll()
//    }
//    
//    func findBusinessReservations(_ businessID: String!){
//        
//        self._allBusinessReservations.removeAll()
//        
//        let dataStore = appDelegate.self.backendless.persistenceService.of(Reservation.ofClass())
//        
//        let whereClause = "BusinessID = '\(businessID)'"
//        let dataQuery = BackendlessDataQuery()
//        dataQuery.whereClause = whereClause
//        
//        dataStore.find(dataQuery,
//                       response: { (reservations : BackendlessCollection!) -> () in
//                        
//                        let currentPage = reservations.getCurrentPage()
//                        
//                        for reservation in currentPage as! [Reservation]{
//                            self._allBusinessReservations.append(reservation)
//                        }
//                        
//                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "findBusinessReservations", object: nil))
//                        
//                        print("reservations loaded")
//                        
//            },
//           error: { (fault : Fault!) -> () in
//            print("Server reported an error (ASYNC): \(fault.description)")
//            }
//        )
//        
//    }
//    
//    func updateReservation(_ reservation: Reservation, status: String){
//     
//        let dataStore = Backendless.sharedInstance().data.of(Reservation.ofClass())
//        
//        // update object asynchronously
//        reservation.Status = status
//        dataStore.save(
//            reservation,
//            response: { (result: AnyObject!) -> Void in
//                let reservation = result as! Reservation
//                
//                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "updateCustomerReservation", object: nil))
//                
//                print("Reservation Updated: \(reservation.objectId)")
//
//            },
//            error: { (fault: Fault!) -> Void in
//                print("Server reported an error (2): \(fault)")
//        })
//        
//    }
//    
//    func removeReservation(_ reservation: Reservation){
//        
//        let dataStore = Backendless.sharedInstance().data.of(Reservation.ofClass())
//        
//        dataStore.remove(
//            reservation,
//            response: { (result: AnyObject!) -> Void in
//                NotificationCenter.defaultCenter().postNotification(Notification(name: "removeReservation", object: nil))
//            },
//            error: { (fault: Fault!) -> Void in
//                print("Server reported an error (2): \(fault)")
//        })
//
//        
//    }
//
//    func subscribeToInboundChannel(){
//    
//        let currentUser = self.appDelegate.backendless.userService.currentUser
//        
//        appDelegate.client.subscribeToChannels([currentUser.objectId], withPresence: false)
//
//        getInboundChannelHistory(currentUser.objectId)
//        
//        print(currentUser.objectId)
//
//        
//    }
//    
//    func getInboundChannelHistory(_ channelName: String){
//        serialQueue.async { [unowned self] () -> Void in
//            self._allInboundMessageItems = self.pageHistory(channelName)
//            self._allUniqueChannels = self.findUniqueChannels(self._allInboundMessageItems)
//            print(self._allInboundMessageItems)
//            self.sendUniqueChannelsRetrievedNotification()
//        }
//    
//    }
//
//    func findUniqueChannels(_ allMessageItems: [MessageItem]) -> [MessageItem]{
//        
//        var uniqueMessages = [MessageItem]()
//        
//        for message in allMessageItems.reversed() { //Because we want the latest messages to show up in inbound box not the first
//            
//            if !_allUniqueChannelNames.contains(message.channelName){
//            
//                uniqueMessages.append(message)
//                _allUniqueChannelNames.append(message.channelName)
//                
//            }
//        }
//        
//        return uniqueMessages //Each Unique Message represents a channel
//    }
//    
//    
//    func sendUniqueChannelsRetrievedNotification(){
//        
//        //Update UI on main thread
//        DispatchQueue.main.async(execute: { () -> Void in
//            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "uniqueChannelsRetrieved"), object: nil))
//        })
//        
//    }
//    
//    
//    func getAllMessagesInChat(_ channelName: String){
//    
//        serialQueue.async { [unowned self] () -> Void in
//            self._allMessageItemsInChat = self.pageHistory(channelName)
//            self._allJSQMessagesInChat = self.updateMessages(self._allMessageItemsInChat)
//            self.sendChatMessagesRecievedNotification()
//        }
//        
//    }
//    
//    func updateMessages(_ allMessageItems: [MessageItem]) -> [JSQMessage]{
//        
//        var updatedMessagesList = [JSQMessage]()
//        
//        for message in allMessageItems {
//            
//            let newJSQMessage = JSQMessage(senderId: message.uuid, displayName: "", text: message.message)
//            
//            updatedMessagesList.append(newJSQMessage!)
//            
//        }
//        
//        return updatedMessagesList
//    }
//    
//    func sendChatMessagesRecievedNotification(){
//        
//        //Update UI on main thread
//        DispatchQueue.main.async(execute: { () -> Void in
//            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "chatMessagesRecieved"), object: nil))
//        })
//        
//    }
//    
//    //Page history of specified channel using semaphore and return array with history task items
//    func pageHistory(_ channelName: String) -> [MessageItem] {
//        
//        var uuidArray: [MessageItem] = []
//        var shouldStop: Bool = false
//        var isPaging: Bool = false
//        var startTimeToken: NSNumber = 0
//        let itemLimit: Int = 100
//        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
//        
//        self.appDelegate.client.history(forChannel: channelName, start: nil, end: nil, limit: 100, reverse: true, includeTimeToken: true, withCompletion: { (result, status) in
//            
//            //Check status isnt nil
//            
//            for message in (result?.data.messages)! {
//                if let resultMessage = message["message"] {
//                    uuidArray.append((MessageItem(uuid: resultMessage!["uuid"] as! String, message: resultMessage!["message"] as! String, channelName: resultMessage!["channelName"] as! String, senderDisplayName: resultMessage!["senderDisplayName"] as! String, recipientID : resultMessage!["recipientID"] as! String, recipientProfilePictureLocation: resultMessage!["recipientProfilePictureLocation"] as! String, recipientDisplayName: resultMessage!["recipientDisplayName"] as! String, senderProfilePictureLocation: resultMessage!["senderProfilePictureLocation"] as! String)))
//                }
//            }
//            
//            if let endTime = result?.data.end {
//                startTimeToken = endTime
//            }
//            
//            if result?.data.messages.count == itemLimit {
//                isPaging = true
//            }
//            semaphore.signal()
//        })
//        
//        semaphore.wait(timeout: DispatchTime.distantFuture)
//        
//        while isPaging && !shouldStop {
//            self.appDelegate.client.history(forChannel: channelName, start: startTimeToken, end: nil, limit: 100, reverse: true, includeTimeToken: true, withCompletion: { (result, status) in
//                for message in (result?.data.messages)! {
//                    if let resultMessage = message["message"] {
//                   
//                         uuidArray.append((MessageItem(uuid: resultMessage!["uuid"] as! String, message: resultMessage!["message"] as! String, channelName: resultMessage!["channelName"] as! String, senderDisplayName: resultMessage!["senderDisplayName"] as! String, recipientID : resultMessage!["recipientID"] as! String, recipientProfilePictureLocation: resultMessage!["recipientProfilePictureLocation"] as! String, recipientDisplayName: resultMessage!["recipientDisplayName"] as! String, senderProfilePictureLocation: resultMessage!["senderProfilePictureLocation"] as! String)))
//                        
//                    }
//                }
//                
//                if let endTime = result?.data.end {
//                    startTimeToken = endTime
//                }
//                
//                if result?.data.messages.count < itemLimit {
//                    shouldStop = true
//                }
//                semaphore.signal()
//            })
//            semaphore.wait(timeout: DispatchTime.distantFuture)
//        }
//        return uuidArray
//    }
//    
//    func clearAllMessagesInChat() {
//        
//        _allJSQMessagesInChat.removeAll()
//        _allMessageItemsInChat.removeAll()
//        
//    }
//    
//    func clearAllChannels() {
//        _allUniqueChannelNames.removeAll()
//        _allUniqueChannels.removeAll()
//        _allInboundMessageItems.removeAll()
//    }
//    
//    func clearAllFollowers() {
//        _allFollowers.removeAll()
//    }
//    
//    func clearAllBusinesses() {
//        _allBusinesses.removeAll()
//    }
//}
//
//
//
//
//
//
//
