//
//  DataService.swift
//  Bizmi
//
//  Created by Alex on 7/28/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation
import UIKit

class DataService {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    private static let _instance = DataService()

    static var instance: DataService {
        return _instance
    }
    
    private var _allUsers = [User]()
    
    var allUsers: [User] {
        
        return _allUsers
        
    }
    
    private var _allBusinesses = [User]()
    
    var allBusinesses: [User] {
        
        return _allBusinesses
        
    }
    
    private var _allFollowers = [User]()
    
    var allFollowers: [User] {
        
        return _allFollowers
        
    }
    
    func loadAllUsers(){
        
        let dataStore = appDelegate.self.backendless.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore.find(
            { (users : BackendlessCollection!) -> () in

                //Backendless pages data - getCurrentPage will load 100 users
                //Eventually we will implement paging mechanism as user scrolls more data will be loaded.
                let currentPage = users.getCurrentPage()
                
                for user in currentPage as! [BackendlessUser]{
                    
                    //Cast BackendlessUser object to Bizmi User object
                    let userObj: User = User()
                    userObj.populateUserData(user)

                    self._allUsers.append(userObj)
                }
                
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "allUsersLoaded", object: nil))
                
            },
            error: { (fault : Fault!) -> () in
                print("Server reported an error (ASYNC): \(fault.description)")
            }
        )
     
    }
    
     /*
     1. Load all Follower ID's from Follow table
     2. Query Follower ID from Users table one-by-one until all followers have been loaded from Users table
     3. Send Notificaton once all users have been addd to _allFollowers variable
     */
    
    func loadAllFollowers(){
        
        let currentuser = appDelegate.backendless.userService.currentUser
        
        let dataStore = appDelegate.self.backendless.persistenceService.of(Follow.ofClass())
        
        let whereClause = "To = '\(currentuser.objectId)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        dataStore.find(dataQuery,
               response: { (follows : BackendlessCollection!) -> () in
                
                let currentFollowersPage = follows.getCurrentPage()
                
                print("\(currentFollowersPage.count) current followers page")
                
                if currentFollowersPage.count > 0 {
                    
                    for follow in currentFollowersPage as! [Follow]{
                        
                        print("\(follow.From) current page")

                        if let followerID = follow.From{
                            
                            let dataStore = self.appDelegate.backendless.persistenceService.of(BackendlessUser.ofClass())
                            
                            let whereClause = "userType = 'Customer' AND userObjectID = '\(followerID)'"
                            let dataQuery = BackendlessDataQuery()
                            dataQuery.whereClause = whereClause
                            
                            dataStore.find(dataQuery,
                                response: { (users : BackendlessCollection!) -> () in
                                    
                                    //Backendless pages data - getCurrentPage will load 100 users
                                    //Eventually we will implement paging mechanism as user scrolls more data will be loaded.
                                    let currentPage = users.getCurrentPage()
                                    print("\(currentPage.count) current page")

                                    for user in currentPage as! [BackendlessUser]{
                                        
                                        //Cast BackendlessUser object to Bizmi User object
                                        let userObj: User = User()
                                        userObj.populateUserData(user)
                                        
                                        self._allFollowers.append(userObj)
                                        
                                        print("\(userObj.fullName)")

                                    }
                                    
                                    //Make sure all users have been loaded because it is asyncronous
                                    
                                    if self._allFollowers.count == currentFollowersPage.count {
                                        
                                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "allFollowersLoaded", object: nil))
                                        
                                    }
                                    
                                    
                                },
                                error: { (fault : Fault!) -> () in
                                    print("Server reported an error (ASYNC): \(fault.description)")
                                }
                            )
                            
                        }
                    }
                   
                    
                }
                
            },
           error: { (fault : Fault!) -> () in
            print("Server reported an error (ASYNC): \(fault.description)")
            }
        )

        
    }
    
    
    
    
    //TODO add filter option as argument
    
    func loadAllBusinesses(){
        
        let dataStore = appDelegate.self.backendless.persistenceService.of(BackendlessUser.ofClass())
        
        let whereClause = "userType = 'Business'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
    
        dataStore.find(dataQuery,
            response: { (users : BackendlessCollection!) -> () in
                
                //Backendless pages data - getCurrentPage will load 100 users
                //Eventually we will implement paging mechanism as user scrolls more data will be loaded.
                let currentPage = users.getCurrentPage()
                
                for user in currentPage as! [BackendlessUser]{
                    
                    //Cast BackendlessUser object to Bizmi User object
                    let userObj: User = User()
                    userObj.populateUserData(user)
                    
                    self._allBusinesses.append(userObj)
                }
                
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "allBusinessesLoaded", object: nil))
                
                print("users loaded")
                
            },
            error: { (fault : Fault!) -> () in
                print("Server reported an error (ASYNC): \(fault.description)")
            }
        )
        
    }
    
    /*
     There is an odd error: if the user enters an email that is taken, they get fault code 3018; but for some odd reason the next time they try to update their profile, the server returns the same error. There is a reference to the current users email, newEmail, that is called before the update is made and is used to refresh the user if they get fault code 3018.
     */
    
    func updateUser(properties: [String: AnyObject]){
        
        let currentUser = self.appDelegate.backendless.userService.currentUser
        
        let newEmail = currentUser.email //email reference
        
        currentUser.updateProperties( properties )
        self.appDelegate.backendless.userService.update(currentUser,
            response: { ( updatedUser : BackendlessUser!) -> () in
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "userUpdated", object: nil))
            },
            error: { ( fault : Fault!) -> () in
                if fault.faultCode == "3018" {
                    print("Error \(currentUser.email)")
                    //TODO: Call email proeprty again but with email that worked so error goes away

                    let newProperties = ["email": newEmail]
                    
                    DataService.instance.updateUser(newProperties)  //refresh user
                    
                    Messages.showAlertDialog("Error", msgAlert: "That email address is already taken...")
                }else{
                    Messages.showAlertDialog("Error", msgAlert: "There was an error updating your profile. Please contact support@bizmiapp.com if the issue persists.")
                }
               
        })

    }

    
    func requestUserPasswordChange(email: String, uiVIew: UIView!) {
        
        appDelegate.backendless.userService.restorePassword(email,
             response:{ ( result : AnyObject!) -> () in
                Messages.showAlertDialog("Change Requested!", msgAlert: "Check your email for a password reset link...")
            },
             error: { ( fault : Fault!) -> () in
                Messages.displayForgotPasswordErrorMessage(uiVIew, errorMsg: fault.faultCode)
            }
        )
    }
    
    func logoutUser(){
        
        appDelegate.backendless.userService.logout(
            { ( user : AnyObject!) -> () in
                print("User logged out.")
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "userLoggedOut", object: nil))
            },
            error: { ( fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
        })
    
    }

    func uploadFile(filePath: String, content: NSData, overwrite: Bool){
        
        appDelegate.backendless.fileService.upload(
            filePath,
            content: content,
            overwrite: overwrite,
            response: { ( uploadedFile : BackendlessFile!) -> () in
                print("File has been uploaded. File URL is - \(uploadedFile.fileURL)")
                
                let fileDict: [String: AnyObject] = [ "uploadedFile": uploadedFile]
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "fileUploaded", object: fileDict))
            },
            error: { ( fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
        })

    }

    
}







