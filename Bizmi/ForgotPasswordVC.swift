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
    
    override func viewDidLoad() {
        
        self.navigationItem.title = "Forgot Password"
        
    }
    
    @IBAction func sendEmailBtnPressed(sender: AnyObject) {
    }
    
}
