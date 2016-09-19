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
typealias DataCompletion = (errMsg: String?, data: AnyObject?) -> Void


class FBDataService {
    private static let _instance = FBDataService()
    
    static var instance: FBDataService {
        return _instance
    }
    
    var mainRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var usersRef: FIRDatabaseReference {
        return mainRef.child(FIR_CHILD_USERS)
    }
    
    var currentUser: FIRUser? {
        
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            return user
        } else {
            // No user is signed in.
            return nil
        }
        
    }
    
    var mainStorageRef: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    
    var profilePicsStorageRef: FIRStorageReference {
        return mainStorageRef.child(FIR_STORAGE_CHILD_USER_PROFILE_PICS)
    }
   
    
    func saveUser(uid: String!, propertes: Dictionary<String, AnyObject>, onComplete: DataCompletion?) {
        
        mainRef.child(FIR_CHILD_USERS).child(uid).setValue(propertes)
        onComplete?(errMsg: nil, data: nil)

    }
    
    func updateUser(uid: String!, propertes: Dictionary<String, AnyObject>, onComplete: DataCompletion?) {
        
        mainRef.child(FIR_CHILD_USERS).child(uid).updateChildValues(propertes)
        onComplete?(errMsg: nil, data: nil)
        
    }
    
    
    
    
}