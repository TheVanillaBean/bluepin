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
typealias DataCompletion = (_ errMsg: String?, _ data: AnyObject?) -> Void


class FBDataService {
    fileprivate static let _instance = FBDataService()
    
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
   
    var _uploadProgress: Double?
    
    var uploadProgress: Double{
        if let progress = _uploadProgress{
            return progress
        }else{
            return 0.0
        }
    }
    
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
            guard let errorCode = FIRStorageErrorCode(rawValue: storageError.code) else { return }
            uploadTask.removeAllObservers()
            
            print("\(errorCode) -- upload error")
            onComplete?("There was an upload error. Check your connection.", nil)
        
        }
    }
    
    
    
}
