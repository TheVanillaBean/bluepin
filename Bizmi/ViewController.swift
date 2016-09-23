//
//  ViewController.swift
//  Bizmi
//
//  Created by Alex on 7/19/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import Toast_Swift
import SinchVerification
import FirebaseAuth

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var emailTextField: MaterialTextField!
    
    @IBOutlet weak var passwordTextField: MaterialTextField!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //Sinch Phone # Verification
    var verification: Verification!
    
    var authListener: FIRAuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = true
        
        validateUserToken()
        
    }
  
    
    func validateUserToken() {
        
        authListener = FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
               print(user.uid)
               let newUser = NewUser()
               newUser.castUser(user.uid, onComplete: { (errMsg) in
                    if errMsg == nil {
                        self.navigateToTabBarVC(newUser)
                    }else{
                        Messages.showAlertDialog("Error", msgAlert: errMsg)
                    }
               })
                
            }
            
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
      //  FIRAuth.auth()?.removeAuthStateDidChangeListener(authListener)
    }
    
    override func viewWillDisappear(animated: Bool){
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
   

    func textFieldDidBeginEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPointMake(0, 130), animated: true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }

    @IBAction func forgotPasswordBtnPressed(sender: AnyObject) {
        
        performSegueWithIdentifier("forgotPassword", sender: nil)
        
    }
    
    @IBAction func signUpBtnPressed(sender: AnyObject) {
        
       showAlertDialog()
        
    }
    
    @IBAction func loginBtnPressed(sender: AnyObject) {
        
        if let email = emailTextField.text, password = passwordTextField.text{
            
            AuthService.instance.login(email, password: password, onComplete: { (errMsg, data) in
                
                if errMsg == nil{
                    if let firUser = data as? FIRUser{
                        let newUser = NewUser()
                        newUser.castUser(firUser.uid, onComplete: { (errMsg) in
                            if errMsg == nil {
                                self.navigateToTabBarVC(newUser)
                            }
                        })
                    }
                }else{
                    Messages.showAlertDialog("Error", msgAlert: "There was an error authenticating")
                }
            })
        
        }else{
            Messages.showAlertDialog("Invalid", msgAlert: "Please Enter an Email and Password")
        }
        
    }
    
    func navigateToTabBarVC(user: NewUser?){
    
        if let userObj = user {
            
            if userObj.userType == USER_BUSINESS_TYPE{
                self.performSegueWithIdentifier("businessLogin", sender: nil)
            }else {
                
                if userObj.phoneNumberVerified == "true"{
                    self.performSegueWithIdentifier("customerLogin", sender: nil)
                }else {
                    self.initiateVerificationProcess(userObj.phoneNumber)
                }
                
            }
        }
        
    }
    
    func showAlertDialog(){
    
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "New User", message: "What type of user are you?", preferredStyle: .Alert)
        
        // Initialize Actions
        let yesAction = UIAlertAction(title: "Business", style: .Default) { (action) -> Void in
            self.performSegueWithIdentifier("businessSignUp", sender: nil)
        }
        
        let noAction = UIAlertAction(title: "Customer", style: .Default) { (action) -> Void in
            self.performSegueWithIdentifier("customerSignUp", sender: nil)
        }
        
        // Add Actions
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        // Present Alert Controller
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func initiateVerificationProcess(phoneNumber: String){
        
        self.verification =
            SMSVerification(applicationKey: sinchApplicationKey,
                            phoneNumber: phoneNumber)
        self.verification.initiate { (success:Bool, error: NSError?) -> Void in
            if (success){
                self.performSegueWithIdentifier("phoneNotVerified", sender: nil);
            } else {
                Messages.displayToastMessage(self.view, msg: "There was an error starting the phone number verification process..." + (error?.description)!)
            }
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "phoneNotVerified" {
            if let verifyVC = segue.destinationViewController as? VerifyPhoneNumberVC{
                verifyVC.verification = self.verification
            }
        }
        
    }
    
    
}

