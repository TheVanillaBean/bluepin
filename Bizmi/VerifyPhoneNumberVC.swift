//
//  VerifyPhoneNumberVC.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import SendBirdSDK
import SinchVerification
import Toast_Swift

class VerifyPhoneNumberVC: UIViewController {

    @IBOutlet weak var verifyTextField: MaterialTextField!
    @IBOutlet weak var verifyBtn: UIButton!
    
    var user: User! =  User()
    var verification: Verification!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        
    }
    
    @IBAction func verifyBtnPressed(sender: AnyObject) {
        
        if let pinCode = verifyTextField.text {

            self.verifyBtn.enabled = false
            self.verifyTextField.text = ""
            
            verification.verify(pinCode,
                completion: { (success:Bool, error:NSError?) -> Void in
                    self.verifyBtn.enabled = true
                    if (success) {
                        Messages.displayToastMessage(self.view, msg: "Verification Successful!")
                        self.view.makeToastActivity(.Center)
                        self.signUpUser()
                    } else {
                        Messages.displayToastMessage(self.view, msg: "Verification Unsuccessful...")
                    }
            })
            
        }

                                                            
    }
    
    func signUpUser(){
        
        appDelegate.backendless.userService.registering(user,
          response: { (registeredUser : BackendlessUser!) -> () in
                                                            
              self.appDelegate.backendless.userService.setStayLoggedIn(true)
              self.appDelegate.backendless.userService.login(
              self.user.userEmail, password: self.user.userPassword,
              response: { ( user : BackendlessUser!) -> () in
                                                                    
                  //Cast BackendlessUser object to Bizmi User object
                  let userObj: User = User()
                  userObj.populateUserData(user)
                                                                        
                  //Authenticate with Sendbird for messagings
                  SendBird.loginWithUserId(userObj.objectId, andUserName: userObj.fullName)
                
                  self.view.hideToastActivity()

                  self.performSegueWithIdentifier("customerSignUp", sender: nil)
                                                                    
              },
              error: { ( fault : Fault!) -> () in
                Messages.displayLoginErrorMessage(self.view, errorMsg: fault.faultCode)
              }
            )
                                                            
            },
              error: { ( fault : Fault!) -> () in
                Messages.displaySignUpErrorMessage(self.view, errorMsg: fault.faultCode)
            }
            
        )
        
    }
    
}
