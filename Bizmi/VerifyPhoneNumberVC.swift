//
//  VerifyPhoneNumberVC.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import SendBirdSDK
import SinchVerification
import Toast_Swift

class VerifyPhoneNumberVC: UIViewController {

    @IBOutlet weak var verifyTextField: MaterialTextField!
    @IBOutlet weak var verifyBtn: UIButton!
    
    var verification: Verification!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Verify Phone Number"
    }
    
    @IBAction func verifyBtnPressed(sender: AnyObject) {
        
        if let pinCode = verifyTextField.text {

            self.verifyBtn.enabled = false
            self.verifyTextField.text = ""
            
            verification.verify(pinCode,
                completion: { (success:Bool, error:NSError?) -> Void in
                    self.verifyBtn.enabled = true
                    if (success) {
                        Messages.displayToastMessage(self.view, msg: "Verification Successful! Please wait...")
                        self.view.makeToastActivity(.Center)
                        
                        let properties = [
                            "phoneNumberVerified" : true
                        ]
                        
                        self.appDelegate.backendless.userService.currentUser.updateProperties( properties )
                        self.appDelegate.backendless.userService.update(self.appDelegate.backendless.userService.currentUser,
                            response: { ( updatedUser : BackendlessUser!) -> () in
                                self.performSegueWithIdentifier("customerSignUp", sender: nil)
                            },
                            
                            error: { ( fault : Fault!) -> () in
                                print("Server reported an error (2): \(fault.message)")
                        })
                        
                    } else {
                        Messages.displayToastMessage(self.view, msg: "Verification Unsuccessful...")
                    }
            })
            
        }
                                                            
    }

    
}
