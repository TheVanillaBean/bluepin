//
//  CustomerSignUpVC.swift
//  Bizmi
//
//  Created by Alex on 7/20/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import DeviceKit
import Toast_Swift
import PhoneNumberKit
import SendBirdSDK
import SinchVerification

class CustomerSignUpVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var emailTextField: MaterialTextField!
    
    @IBOutlet weak var fullNameTextField: MaterialTextField!
    
    @IBOutlet weak var phoneNumberTextField: PhoneNumberTextField!
    
    @IBOutlet weak var passwordTextField: MaterialTextField!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //Sinch Phone # Verification
    var verification: Verification!;
    
    override func viewDidLoad() {
       
        self.navigationItem.title = "New Customer"
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
                
                if textField == passwordTextField || textField == phoneNumberTextField {
                    scrollView.setContentOffset(CGPointMake(0, 40), animated: true)
                }else if textField == fullNameTextField{
                    scrollView.setContentOffset(CGPointMake(0, 30), animated: true)
                }else{
                    scrollView.setContentOffset(CGPointMake(0, -64), animated: true)
                }
                
            }
        }
        
    }

    
    @IBAction func signUpBtnPressed(sender: AnyObject) {
        
        if let customerName = fullNameTextField.text, phoneNumber = phoneNumberTextField.text, email = emailTextField.text, password = passwordTextField.text  {
            
            let user = User(email: email, password: password, userType: USER_CUSTOMER_TYPE)
            user.fullName = customerName
            user.phoneNumber = phoneNumber
            user.phoneNumberVerified = false;
            
            signUpUser(user)
            
        }
    }
    
    func initiateVerificationProcess(user: User!, phoneNumber: String){
    
        self.verification =
            SMSVerification(applicationKey: sinchApplicationKey,
                            phoneNumber: phoneNumber)
        self.verification.initiate { (success:Bool, error: NSError?) -> Void in
            if (success){
                self.performSegueWithIdentifier("verifyPhoneNumber", sender: user);
            } else {
                Messages.displayToastMessage(self.view, msg: "There was an error starting the phone number verification process..." + (error?.description)!)
            }
        }
        
    }
    
    func signUpUser(userObj: User?){
        
        if let user = userObj{
        
                appDelegate.backendless.userService.registering(user,
                response: { (registeredUser : BackendlessUser!) -> () in
                    
                        self.appDelegate.backendless.userService.setStayLoggedIn(true)
                        self.appDelegate.backendless.userService.login(
                            user.userEmail, password: user.userPassword,
                            response: { ( user : BackendlessUser!) -> () in
                                
                                //Cast BackendlessUser object to Bizmi User object
                                let userObj: User = User()
                                userObj.populateUserData(user)
                                
                                //Authenticate with Sendbird for messaging
                                SendBird.loginWithUserId(userObj.objectId, andUserName: userObj.fullName)
                                
                                self.view.hideToastActivity()
                                
                                self.initiateVerificationProcess(userObj, phoneNumber: userObj.phoneNumber)
                                                                
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "verifyPhoneNumber" {
            if let verifyVC = segue.destinationViewController as? VerifyPhoneNumberVC{
                verifyVC.verification = self.verification
            }
        }
        
    }

}














