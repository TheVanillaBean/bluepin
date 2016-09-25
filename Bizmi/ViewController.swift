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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //Sinch Phone # Verification
    var verification: Verification!
    
    var authListener: FIRAuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        
        validateUserToken()
        
    }
  
    
    func validateUserToken() {
        
        authListener = FIRAuth.auth()?.addStateDidChangeListener { auth, user in
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
    
    override func viewDidDisappear(_ animated: Bool) {
      //  FIRAuth.auth()?.removeAuthStateDidChangeListener(authListener)
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
   

    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 130), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }

    @IBAction func forgotPasswordBtnPressed(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "forgotPassword", sender: nil)
        
    }
    
    @IBAction func signUpBtnPressed(_ sender: AnyObject) {
        
       showAlertDialog()
        
    }
    
    @IBAction func loginBtnPressed(_ sender: AnyObject) {
        
        if let email = emailTextField.text, let password = passwordTextField.text{
            
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
    
    func navigateToTabBarVC(_ user: NewUser?){
    
        if let userObj = user {
            
            if userObj.userType == USER_BUSINESS_TYPE{
                self.performSegue(withIdentifier: "businessLogin", sender: nil)
            }else {
                
                if userObj.phoneNumberVerified == "true"{
                    self.performSegue(withIdentifier: "customerLogin", sender: nil)
                }else {
                    self.initiateVerificationProcess(userObj.phoneNumber)
                }
                
            }
        }
        
    }
    
    func showAlertDialog(){
    
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "New User", message: "What type of user are you?", preferredStyle: .alert)
        
        // Initialize Actions
        let yesAction = UIAlertAction(title: "Business", style: .default) { (action) -> Void in
            self.performSegue(withIdentifier: "businessSignUp", sender: nil)
        }
        
        let noAction = UIAlertAction(title: "Customer", style: .default) { (action) -> Void in
            self.performSegue(withIdentifier: "customerSignUp", sender: nil)
        }
        
        // Add Actions
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        // Present Alert Controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func initiateVerificationProcess(_ phoneNumber: String){
        
        self.verification =
            SMSVerification(applicationKey: sinchApplicationKey,
                            phoneNumber: phoneNumber)
        self.verification.initiate { (success:Bool, error: NSError?) -> Void in
            if (success){
                self.performSegue(withIdentifier: "phoneNotVerified", sender: nil);
            } else {
                Messages.displayToastMessage(self.view, msg: "There was an error starting the phone number verification process..." + (error?.description)!)
            }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "phoneNotVerified" {
            if let verifyVC = segue.destination as? VerifyPhoneNumberVC{
                verifyVC.verification = self.verification
            }
        }
        
    }
    
    
}

