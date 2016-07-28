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
    let applicationKey = "fb9c06d5-53e7-4d60-83d0-cb853587884a";
    
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
            
            verification =
                SMSVerification(applicationKey: applicationKey,
                                phoneNumber: phoneNumber)
            verification.initiate { (success:Bool, error: NSError?) -> Void in
                if (success){
                    self.performSegueWithIdentifier("verifyPhoneNumber", sender: user);
                } else {
                    Messages.displayToastMessage(self.view, msg: "There was an error starting the phone number verification process..." + (error?.description)!)
                }
            }
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "verifyPhoneNumber" {
            if let verifyVC = segue.destinationViewController as? VerifyPhoneNumberVC{
                if let user = sender as? User{
                    verifyVC.user = user
                    verifyVC.verification = self.verification
                }
            }
        }
        
    }

}














