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
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                self.handleFirebaseError(error! as NSError, onComplete: onComplete)
            }else {
                onComplete?(nil, user)
            }
            
        })
    }
    
    func signUp(_ email: String, password: String, onComplete: AuthCompletion?){
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleFirebaseError(error! as NSError, onComplete: onComplete)
            } else {
                if user?.uid != nil {
                    
                    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                        
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
    
    
    
    
}
