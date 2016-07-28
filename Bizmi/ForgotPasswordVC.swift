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
            
             appDelegate.backendless.userService.restorePassword(email,
                response:{ ( result : AnyObject!) -> () in
                    self.emailTextField.text = ""
                    Messages.showAlertDialog("Password Change", msgAlert: "Check your email for a password reset link.")
                },
                error: { ( fault : Fault!) -> () in
                    Messages.displayForgotPasswordErrorMessage(self.view, errorMsg: fault.faultCode)
                }
                
            )
            
        }
        
    }
    
    
}
