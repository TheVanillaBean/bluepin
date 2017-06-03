//
//  ForgotPasswordVC.swift
//  bluepin
//
//  Created by Alex on 7/20/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import Toast_Swift

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var emailTextField: MaterialTextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        self.navigationItem.title = "Forgot Password"
    }
    
    @IBAction func sendEmailBtnPressed(_ sender: AnyObject) {
        
        if let email = emailTextField.text {
            
            FBDataService.instance.resetPassword(email, onComplete: { (errMsg, data) in
                
                if errMsg == nil{
                    Messages.showAlertDialog("Email Sent", msgAlert: "An email has been sent to \(email) with a reset link.")
                }else{
                    Messages.showAlertDialog("Error", msgAlert: errMsg)
                }
            })
        }
        
    }
    
}
