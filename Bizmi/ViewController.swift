//
//  ViewController.swift
//  Bizmi
//
//  Created by Alex on 7/19/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import Toast_Swift
import SendBirdSDK

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var emailTextField: MaterialTextField!
    
    @IBOutlet weak var passwordTextField: MaterialTextField!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = true
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
            
            appDelegate.backendless.userService.setStayLoggedIn(true)
            appDelegate.backendless.userService.login(
                email , password: password,
                response: { ( user : BackendlessUser!) -> () in
                    print("User logged in! \(user.email)")

                    //Cast BackendlessUser object to Bizmi User object
                    let userObj: User = User()
                    userObj.populateUserData(user)

                    self.navigateToTabBarVC(userObj)
                    
                },
                error: { ( fault : Fault!) -> () in
                    Messages.displayLoginErrorMessage(self.view, errorMsg: fault.faultCode)
                }
            )
        
        }
        
    }
    
    func navigateToTabBarVC(user: User?){
    
        if let userObj = user {
            
            if userObj.userType == "Business"{
                self.performSegueWithIdentifier("businessLogin", sender: nil)
                SendBird.loginWithUserId(userObj.objectId, andUserName: userObj.businessName)
            }else {
                self.performSegueWithIdentifier("customerLogin", sender: nil)
                SendBird.loginWithUserId(userObj.objectId, andUserName: userObj.fullName)
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
    
    
}

