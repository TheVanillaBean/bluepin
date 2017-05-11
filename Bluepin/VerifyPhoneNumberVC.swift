//
//  VerifyPhoneNumberVC.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import SinchVerification
import Toast_Swift

class VerifyPhoneNumberVC: UIViewController {

    @IBOutlet weak var verifyTextField: MaterialTextField!
    @IBOutlet weak var verifyBtn: UIButton!
    
   var verification: Verification!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
       // self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Verify Phone Number"
    }
    
    @IBAction func verifyBtnPressed(_ sender: AnyObject) {
        
        if let pinCode = verifyTextField.text {

            self.verifyBtn.isEnabled = false
            self.verifyTextField.text = ""
            
            verification.verify(pinCode,
                completion: { (success:Bool, error:Error?) -> Void in
                    self.verifyBtn.isEnabled = true
                    if (success) {
                        
                        Messages.displayToastMessage(self.view, msg: "Verification Successful! Please wait...")
                        self.view.makeToastActivity(.center)
                        
                        let properties = [PHONE_NUMBER_VERIFIED : "true", DEVICE_TOKEN : self.appDelegate.deviceTokenString!]
                        
                        let currentUserID = FBDataService.instance.currentUser?.uid
                        
                        FBDataService.instance.updateUser(currentUserID, propertes: properties as Dictionary<String, AnyObject>, onComplete: { (errMsg, data) in
                            
                            if errMsg == nil {
                                self.performSegue(withIdentifier: "customerSignUp", sender: nil)
                            }
                            
                        })
                        
                        
                        
                    } else {
                        Messages.displayToastMessage(self.view, msg: "Verification Unsuccessful...")
                    }
            })
            
        }
                                                            
    }

    
}
