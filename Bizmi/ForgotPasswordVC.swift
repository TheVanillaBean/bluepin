//
//  ForgotPasswordVC.swift
//  Bizmi
//
//  Created by Alex on 7/20/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import Toast_Swift

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var emailTextField: MaterialTextField!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        self.navigationItem.title = "Forgot Password"
    }
    
    @IBAction func sendEmailBtnPressed(sender: AnyObject) {
        
        if let email = emailTextField.text {
            
             self.emailTextField.text = ""
             DataService.instance.requestUserPasswordChange(email, uiVIew: self.view)
            
        }
        
    }
    
}
