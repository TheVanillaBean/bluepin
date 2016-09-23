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
import FirebaseAuth

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
            
            passwordTextField.text = ""
            
            let user = NewUser(email: email, password: password, userType: USER_CUSTOMER_TYPE)
            user.businessName = businessName
            user.businessType = businessType
            
            signUpUser(user)
            
        }else{
            Messages.showAlertDialog("Error", msgAlert: "One or More Fields are Empty")
        }
        
    }
    
    func userProperties(uuid: String!, name: String!, businessType: String!, email: String!) -> Dictionary<String, AnyObject>  {
        
        let profile: Dictionary<String, AnyObject> = [UUID: uuid, EMAIL: email, BUSINESS_NAME: name, BUSINESS_TYPE: businessType, USER_TYPE: USER_BUSINESS_TYPE]
        
        return profile
        
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
                
                let properties = self.userProperties(firUser?.uid, name: user.businessName, businessType: user.businessType, email: user.email)
                
                FBDataService.instance.saveUser(firUser?.uid, isCustomer: false, propertes: properties, onComplete: { (errMsg, data) in
                    
                    if errMsg == nil {
                        self.view.hideToastActivity()
                        //self.performSegueWithIdentifier("businessSignUp", sender: nil)
                    }
                    
                })
                
            })
            
        }
        
    }
    
}















