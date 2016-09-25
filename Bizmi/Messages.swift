//
//  Errors.swift
//  Bizmi
//
//  Created by Alex on 7/26/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class Messages {
    
    static var view: UIView!
    static let screenSize: CGRect = UIScreen.main.bounds
    static let screenWidth = screenSize.width
    static let screenHeight = screenSize.height
    static let position = CGPoint(x: CGFloat(screenWidth/2), y: CGFloat( (screenHeight * 0.33 ) ))
        
    static func displayToastMessage(_ uiVIew: UIView!, msg: String?){
        
        view = uiVIew
        
        if let message = msg {
           self.view.makeToast(message, duration: 5.0, position: position)
        }
    }
    
    static func displaySignUpErrorMessage(_ uiVIew: UIView!, errorMsg: String?){
        
        view = uiVIew
        
        if let error = errorMsg {
            
            if error == "3013"{
                self.view.makeToast("Please enter a correct email...", duration: 5.0, position: position)
            }else if error == "3011"{
                self.view.makeToast("Please enter a correct password...", duration: 5.0, position: position)
            }else if error == "3012"{
                self.view.makeToast("One or more fields are empty...", duration: 5.0, position: position)
            }else if error == "3033"{
                self.view.makeToast("Email address already taken...", duration: 5.0, position: position)
            }else if error == "3040"{
                self.view.makeToast("Please enter a correct email...", duration: 5.0, position: position)
            }else {
                self.view.makeToast("There was an error signing up...", duration: 5.0, position: position)
            }
            
        }
        
    }
    
    static func displayLoginErrorMessage(_ uiVIew: UIView!, errorMsg: String?){
        
        view = uiVIew

        if let error = errorMsg {
            if error == "3000"{
                self.view.makeToast("Login is disabled for this account. Contact support for more information...", duration: 5.0, position: position)
            }else if error == "3002"{
                self.view.makeToast("Unable to log user in because user is already logged in on another account...", duration: 5.0, position: position)
            }else if error == "3003"{
                self.view.makeToast("Invalid email or password...", duration: 5.0, position: position)
            }else if error == "3006"{
                self.view.makeToast("Either email or password are empty...", duration: 5.0, position: position)
            }else if error == "3036"{
                self.view.makeToast("Account locked out due to too many failed logins...", duration: 5.0, position: position)
            }else if error == "3044"{
                self.view.makeToast("Multiple login limit for the same user account has been reached...", duration: 5.0, position: position)
            }else {
                self.view.makeToast("There was an error signing up...", duration: 5.0, position: position)
            }
            
        }
        
    }
    
    static func displayForgotPasswordErrorMessage(_ uiVIew: UIView!, errorMsg: String?){

        view = uiVIew
        
        if let error = errorMsg {
            
            if error == "3020"{
                self.view.makeToast("Unable to find user with that email...", duration: 5.0, position: position)
            }else {
                self.view.makeToast("There was an error signing up...", duration: 5.0, position: position)
            }
            
        }
        
    }

    
    static func showAlertDialog(_ titleAlert: String?, msgAlert: String?){
        
        if let title = titleAlert, let message = msgAlert {
        
            // Initialize Alert Controller
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            // Initialize Actions
            let okAction = UIAlertAction(title: "Okay", style: .default) { (action) -> Void in
            }
            
            // Add Actions
            alertController.addAction(okAction)
            
            // Present Alert Controller
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
       
    }
 
    
}
    
    
