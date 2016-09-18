//
//  BusinessSignUpVC.swift
//  Bizmi
//
//  Created by Alex on 7/20/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import DeviceKit
import Toast_Swift

class BusinessSignUpVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailTextField: MaterialTextField!
    
    @IBOutlet weak var businessNameTextField: MaterialTextField!
    
    @IBOutlet weak var businessTypeTextField: MaterialTextField!
    
    @IBOutlet weak var passwordTextField: MaterialTextField!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
    override func viewDidLoad() {
        self.navigationItem.title = "New Business"
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
       applySmartScrolling(textField)
       
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // -64 because the height of the navigation bar and status bar equals 64 units -- This is the true (0,0)
        scrollView.setContentOffset(CGPointMake(0, -64), animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func applySmartScrolling(textField: UITextField){
    
        let device = Device()
        let groupOfAllowedDevices: [Device] = [.iPhone4s, .iPhone5, .iPhone5c, .iPhone5s, .Simulator(.iPhone5), .Simulator(.iPhone4s)]
        
        if device.isPhone {
            
            //Only apply smart scrolling to iphone 4 and iphone 5 because they are smaller
            if device.isOneOf(groupOfAllowedDevices) {
                
                if textField == passwordTextField || textField == businessTypeTextField {
                    scrollView.setContentOffset(CGPointMake(0, 80), animated: true)
                }else if textField == businessNameTextField{
                    scrollView.setContentOffset(CGPointMake(0, 50), animated: true)
                }else{
                    scrollView.setContentOffset(CGPointMake(0, -64), animated: true)
                }
                
            }
        }
    }
    
    @IBAction func signUpBtnPressed(sender: AnyObject) {
        
        if let businessName = businessNameTextField.text, businessType = businessTypeTextField.text, email = emailTextField.text, password = passwordTextField.text  {
        
            let user = User(email: email, password: password, userType: USER_BUSINESS_TYPE)
            user.businessName = businessName
            user.businessType = businessType
            
            appDelegate.backendless.userService.registering(user,
                response: { (registeredUser : BackendlessUser!) -> () in
                    
                    self.appDelegate.backendless.userService.setStayLoggedIn(true)
                    self.appDelegate.backendless.userService.login(
                        email, password: password,
                        response: { ( user : BackendlessUser!) -> () in

                            //Cast BackendlessUser object to Bizmi User object
                            let userObj: User = User()
                            userObj.populateUserData(user)
                            
                            let properties = [
                                "userObjectID" : user.objectId
                            ]
                            
                            self.appDelegate.backendless.userService.currentUser.updateProperties( properties )
                            self.appDelegate.backendless.userService.update(self.appDelegate.backendless.userService.currentUser,
                                response: { ( updatedUser : BackendlessUser!) -> () in
                                    self.view.hideToastActivity()
                                    
                                    self.performSegueWithIdentifier("businessSignUp", sender: nil)

                                },
                                
                                error: { ( fault : Fault!) -> () in
                                    print("Server reported an error (2): \(fault.message)")
                            })
                            

                            
                            
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
    
    
}















