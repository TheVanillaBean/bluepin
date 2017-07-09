//
//  AuthService.swift
//  bluepin
//
//  Created by Alex on 9/18/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias AuthCompletion = (_ errMsg: String?, _ data: AnyObject?) -> Void

class AuthService {
    fileprivate static let _instance = AuthService()
    
    static var instance: AuthService {
        return _instance
    }
    
    func login(_ email: String, password: String, onComplete: AuthCompletion?) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                self.handleFirebaseError(error! as NSError, onComplete: onComplete)
            }else {
                onComplete?(nil, user)
            }
            
        })
    }
    
    func signUp(_ email: String, password: String, onComplete: AuthCompletion?){
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleFirebaseError(error! as NSError, onComplete: onComplete)
            } else {
                if user?.uid != nil {
                    
                    Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                        
                        if error != nil {
                            self.handleFirebaseError(error! as NSError, onComplete: onComplete)
                        } else {
                            onComplete?(nil, user)
                        }
                        
                    })
                    
                }
            }
        })
    }
   
    func handleFirebaseError(_ error: NSError, onComplete: AuthCompletion?) {
        print(error.debugDescription)
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch (errorCode) {
            case .invalidEmail:
                onComplete?("Invalid email address", nil)
                break
            case .wrongPassword:
                onComplete?("Invalid password", nil)
                break
            case .emailAlreadyInUse, .accountExistsWithDifferentCredential:
                onComplete?("Could not create account. Email already in use", nil)
                break
            case .userDisabled:
                onComplete?("Account Temporally Disabled. Contact Support to get issue resolved", nil)
            case .weakPassword:
                onComplete?("Weak Password. Password must be greater than six characters", nil)
            default:
                onComplete?("There was a problem authenticating. Try again.", nil)
            }
        }
    }
    
    
    
    
}
