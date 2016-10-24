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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
    override func viewDidLoad() {
        self.navigationItem.title = "New Business"
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
       applySmartScrolling(textField)
       
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: -64), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func applySmartScrolling(_ textField: UITextField){
    
        let device = Device()
        let groupOfAllowedDevices: [Device] = [.iPhone4s, .iPhone5, .iPhone5c, .iPhone5s, .simulator(.iPhone5), .simulator(.iPhone4s)]
        
        if device.isPhone {
            
            if device.isOneOf(groupOfAllowedDevices) {
                
                if textField == passwordTextField || textField == businessTypeTextField {
                    scrollView.setContentOffset(CGPoint(x: 0, y: 80), animated: true)
                }else if textField == businessNameTextField{
                    scrollView.setContentOffset(CGPoint(x: 0, y: 50), animated: true)
                }else{
                    scrollView.setContentOffset(CGPoint(x: 0, y: -64), animated: true)
                }
                
            }
        }
    }
    
    @IBAction func signUpBtnPressed(_ sender: AnyObject) {
        
        if let businessName = businessNameTextField.text, let businessType = businessTypeTextField.text, let email = emailTextField.text, let password = passwordTextField.text  {
            
            passwordTextField.text = ""
            
            let user = NewUser(email: email, password: password, userType: USER_CUSTOMER_TYPE)
            user.businessName = businessName
            user.businessType = businessType
            
            signUpUser(user)
            
        }else{
            Messages.showAlertDialog("Error", msgAlert: "One or More Fields are Empty")
        }
        
    }
    
    func userProperties(_ uuid: String!, name: String!, businessType: String!, email: String!, deviceToken: String!) -> Dictionary<String, AnyObject>  {
        
        let profile: Dictionary<String, AnyObject> = [UUID: uuid as AnyObject, EMAIL: email as AnyObject, BUSINESS_NAME: name as AnyObject, BUSINESS_TYPE: businessType as AnyObject, USER_TYPE: USER_BUSINESS_TYPE as AnyObject, DEVICE_TOKEN: deviceToken as AnyObject]
        
        return profile
        
    }
    
    func signUpUser(_ userObj: NewUser?){
        
        if let user = userObj{
            
            AuthService.instance.signUp(user.email, password: user.password, onComplete: { (errMsg, data) in
                
                user.password = ""
                
                guard errMsg == nil else {
                    Messages.showAlertDialog("Authentication Error", msgAlert: errMsg)
                    return
                }
                
                let firUser = data as? FIRUser
                
                let properties = self.userProperties(firUser?.uid, name: user.businessName, businessType: user.businessType, email: user.email, deviceToken: self.appDelegate.deviceTokenString)
                
                FBDataService.instance.saveUser(firUser?.uid, isCustomer: false, propertes: properties, onComplete: { (errMsg, data) in
                    
                    if errMsg == nil {
                        self.view.hideToastActivity()
                        self.performSegue(withIdentifier: "businessSignUp", sender: nil)
                    }
                    
                })
                
            })
            
        }
        
    }
    
    @IBAction func termsBtnPressed(_ sender: AnyObject) {
        Hotline.sharedInstance().showFAQs(self)
    }
    
    
}















