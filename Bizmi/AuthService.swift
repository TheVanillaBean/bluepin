//
//  AuthService.swift
//  Bizmi
//
//  Created by Alex on 9/18/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias AuthCompletion = (errMsg: String?, data: AnyObject?) -> Void

class AuthService {
    private static let _instance = AuthService()
    
    static var instance: AuthService {
        return _instance
    }
    
    func login(email: String, password: String, onComplete: AuthCompletion?) {
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            
            if error != nil {
                self.handleFirebaseError(error!, onComplete: onComplete)
            }else {
                //Successfully logged in
                onComplete?(errMsg: nil, data: user)
            }
            
        })
    }
    
    func signUp(email: String, password: String, onComplete: AuthCompletion?){
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleFirebaseError(error!, onComplete: onComplete)
            } else {
                if user?.uid != nil {
                    
                    FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
                        
                        if error != nil {
                            self.handleFirebaseError(error!, onComplete: onComplete)
                        } else {
                            //Successfully logged in
                            onComplete?(errMsg: nil, data: user)
                        }
                        
                    })
                    
                }
            }
        })

    }
    
    func handleFirebaseError(error: NSError, onComplete: AuthCompletion?) {
        print(error.debugDescription)
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
            switch (errorCode) {
            case .ErrorCodeInvalidEmail:
                onComplete?(errMsg: "Invalid email address", data: nil)
                break
            case .ErrorCodeWrongPassword:
                onComplete?(errMsg: "Invalid password", data: nil)
                break
            case .ErrorCodeEmailAlreadyInUse, .ErrorCodeAccountExistsWithDifferentCredential:
                onComplete?(errMsg: "Could not create account. Email already in use", data: nil)
                break
            case .ErrorCodeUserDisabled:
                onComplete?(errMsg: "Account Temporally Disabled. Contact Support to get issue resolved", data: nil)
            case .ErrorCodeWeakPassword:
                onComplete?(errMsg: "Weak Password. Password must be greater than six characters", data: nil)
            default:
                onComplete?(errMsg: "There was a problem authenticating. Try again.", data: nil)
            }
        }
    }
    
    
    
    
}