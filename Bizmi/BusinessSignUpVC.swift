//
//  BusinessSignUpVC.swift
//  Bizmi
//
//  Created by Alex on 7/20/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import DeviceKit

class BusinessSignUpVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var userIDTextField: MaterialTextField!
    
    @IBOutlet weak var businessNameTextField: MaterialTextField!
    
    @IBOutlet weak var businessTypeTextField: MaterialTextField!
    
    @IBOutlet weak var emailTextField: MaterialTextField!
    
    @IBOutlet weak var passwordTextField: MaterialTextField!
    
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
                
                if textField == passwordTextField || textField == emailTextField {
                    scrollView.setContentOffset(CGPointMake(0, 80), animated: true)
                }else if textField == businessTypeTextField{
                    scrollView.setContentOffset(CGPointMake(0, 50), animated: true)
                }else{
                    scrollView.setContentOffset(CGPointMake(0, -64), animated: true)
                }
                
            }
        }
    
    }
    
    @IBAction func signUpBtnPressed(sender: AnyObject) {
    }
    
}
