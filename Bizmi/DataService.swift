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
    
    static let instance = DataService()
    
    private var _allUsers = [User]()
    
    var allUsers: [User] {
        
        return _allUsers
        
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

    
}







