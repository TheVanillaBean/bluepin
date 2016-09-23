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
import SinchVerification
import FirebaseAuth

class CustomerSignUpVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var emailTextField: MaterialTextField!
    
    @IBOutlet weak var fullNameTextField: MaterialTextField!
    
    @IBOutlet weak var phoneNumberTextField: PhoneNumberTextField!
    
    @IBOutlet weak var passwordTextField: MaterialTextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
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
    
    func toggleSubmit(enable: Bool){
        submitBtn.enabled = enable
    }
    
    @IBAction func signUpBtnPressed(sender: AnyObject) {
        
        toggleSubmit(false)
        
        if let customerName = fullNameTextField.text, phoneNumber = phoneNumberTextField.text, email = emailTextField.text, password = passwordTextField.text  {
            
            passwordTextField.text = ""

            let user = NewUser(email: email, password: password, userType: USER_CUSTOMER_TYPE)
            user.fullName = customerName
            user.phoneNumber = phoneNumber
            user.phoneNumberVerified = "false";
            
            signUpUser(user)
            
        }else{
            toggleSubmit(true)
            Messages.showAlertDialog("Error", msgAlert: "One or More Fields are Empty")
        }
    }
    
    func userProperties(uuid: String!, name: String!, number: String!, email: String!) -> Dictionary<String, AnyObject>  {
    
        let profile: Dictionary<String, AnyObject> = [UUID: uuid, EMAIL: email, FULL_NAME: name, PHONE_NUMBER: number, USER_TYPE: USER_CUSTOMER_TYPE, PHONE_NUMBER_VERIFIED: "true"]
    
        return profile
    
    }
    
    func initiateVerificationProcess(phoneNumber: String){
    
        self.verification =
            SMSVerification(applicationKey: sinchApplicationKey,
                            phoneNumber: phoneNumber)
        self.verification.initiate { (success:Bool, error: NSError?) -> Void in
            if (success){
                self.performSegueWithIdentifier("verifyPhoneNumber", sender: nil);
            } else {
                Messages.displayToastMessage(self.view, msg: "There was an error starting the phone number verification process..." + (error?.description)!)
            }
        }
        
    }
    
    func signUpUser(userObj: NewUser?){
        
        if let user = userObj{
       
            AuthService.instance.signUp(user.email, password: user.password, onComplete: { (errMsg, data) in

                user.password = ""
                
                guard errMsg == nil else {
                    Messages.showAlertDialog("Authentication Error", msgAlert: errMsg)
                    return
                }
                
                let firUser = data as? FIRUser
                
                let properties = self.userProperties(firUser?.uid, name: user.fullName, number: user.phoneNumber, email: user.email)
                
                FBDataService.instance.saveUser(firUser?.uid, isCustomer: true, propertes: properties, onComplete: { (errMsg, data) in
                    
                        self.toggleSubmit(true)

                        if errMsg == nil {
                            self.initiateVerificationProcess(user.phoneNumber)
                        }
                    
                })
                
            })
            
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














