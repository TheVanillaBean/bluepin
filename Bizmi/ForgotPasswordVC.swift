//
//  ForgotPasswordVC.swift
//  Bizmi
//
//  Created by Alex on 7/20/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var emailTextField: MaterialTextField!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        self.navigationItem.title = "Forgot Password"
    }
    
    @IBAction func sendEmailBtnPressed(sender: AnyObject) {
        
        if let email = emailTextField.text {
            
             appDelegate.backendless.userService.restorePassword( email,
                response:{ ( result : AnyObject!) -> () in
                    self.emailTextField.text = ""
                    self.showAlertDialog()
                    print("Check your email address! result = \(result)")
                },
                error: { ( fault : Fault!) -> () in
                    print("Server reported an error: \(fault)")
                }
                
            )
            
        }
        
    }
    
    
    func showAlertDialog(){
        
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "Password Change", message: "Check your email for a password reset link.", preferredStyle: .Alert)
        
        // Initialize Actions
        let okAction = UIAlertAction(title: "Okay", style: .Default) { (action) -> Void in
        }
        
        // Add Actions
        alertController.addAction(okAction)
        
        // Present Alert Controller
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
}
