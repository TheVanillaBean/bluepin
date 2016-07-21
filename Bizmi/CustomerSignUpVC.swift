//
//  CustomerSignUpVC.swift
//  Bizmi
//
//  Created by Alex on 7/20/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import DeviceKit

class CustomerSignUpVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var emailTextField: MaterialTextField!
    
    @IBOutlet weak var fullNameTextField: MaterialTextField!
    
    @IBOutlet weak var phoneNumberTextField: MaterialTextField!
    
    @IBOutlet weak var passwordTextField: MaterialTextField!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
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
            
            appDelegate.backendless.userService.registering(user,
                response: { (registeredUser : BackendlessUser!) -> () in
            
                  self.appDelegate.backendless.userService.setStayLoggedIn(true)
                  self.appDelegate.backendless.userService.login(
                  email, password: password,
                  response: { ( user : BackendlessUser!) -> () in
                    
                    //TODO:
                    //Segue to First VC in Business TabView
                    
                   },
                   error: { ( fault : Fault!) -> () in
                        print(fault.description + " Login")
                   }
                )
            
        },
        error: { ( fault : Fault!) -> () in
            print(fault.description + " Sign up")
            
        }
                
      )
        
    }
        
  }


}














