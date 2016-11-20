//
//  CustomerSignUpVC.swift
//  Bizmi
//
//  Created by Alex on 7/20/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import DeviceKit
import Toast_Swift
import PhoneNumberKit
import SinchVerification
import FirebaseAuth

class CustomerSignUpVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var emailTextField: MaterialTextField!
    
    @IBOutlet weak var fullNameTextField: MaterialTextField!
    
    @IBOutlet weak var phoneNumberTextField: MaterialPhoneNumberTextView!
    
    @IBOutlet weak var passwordTextField: MaterialTextField!
    
    @IBOutlet weak var confirmPasswordTextField: MaterialTextField!
    
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var verification: Verification!;
    
    override func viewDidLoad() {
       
        self.navigationItem.title = "New Customer"
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        applySmartScrolling(textField)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: -64), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func applySmartScrolling(_ textField: UITextField){
        
        let device = Device()
        let groupOfAllowedDevices: [Device] = [.iPhone4s, .iPhone5, .iPhone5c, .iPhone5s, .simulator(.iPhone5), .simulator(.iPhone4s)]
        
        if device.isPhone {
            
            if device.isOneOf(groupOfAllowedDevices) {
                
                if textField == passwordTextField || textField == phoneNumberTextField {
                    scrollView.setContentOffset(CGPoint(x: 0, y: 40), animated: true)
                }else if textField == fullNameTextField{
                    scrollView.setContentOffset(CGPoint(x: 0, y: 30), animated: true)
                }else{
                    scrollView.setContentOffset(CGPoint(x: 0, y: -64), animated: true)
                }
                
            }
        }
        
    }
    
    func toggleSubmit(_ enable: Bool){
        submitBtn.isEnabled = enable
    }
    
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    @IBAction func signUpBtnPressed(_ sender: AnyObject) {
        
        toggleSubmit(false)
        
        if let customerName = fullNameTextField.text, let phoneNumber = phoneNumberTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text  {
            
            if passwordTextField.text == ""{
                toggleSubmit(true)
                Messages.showAlertDialog("Error", msgAlert: "One or More Fields are Empty")
            }else{

                if !self.validatePassword(password, confirmPassword: confirmPassword){
                    toggleSubmit(true)
                    Messages.showAlertDialog("Error", msgAlert: "Your passwords do not match! Re-enter your password.")
                }else{
                
                passwordTextField.text = ""

                let user = NewUser(email: email, password: password, userType: USER_CUSTOMER_TYPE)
                user.fullName = customerName
                user.phoneNumber = phoneNumber
                user.phoneNumberVerified = "false";

                signUpUser(user)
                    
                }
            }
        }else{
            toggleSubmit(true)
            Messages.showAlertDialog("Error", msgAlert: "One or More Fields are Empty")
        }
    }
    
    func userProperties(_ uuid: String!, name: String!, number: String!, email: String!) -> Dictionary<String, AnyObject>  {
    
        let profile: Dictionary<String, AnyObject> = [UUID: uuid as AnyObject, EMAIL: email as AnyObject, FULL_NAME: name as AnyObject, PHONE_NUMBER: number as AnyObject, USER_TYPE: USER_CUSTOMER_TYPE as AnyObject, PHONE_NUMBER_VERIFIED: "false" as AnyObject]
    
        return profile
    
    }
    
    func initiateVerificationProcess(_ phoneNumber: String){
    
        self.verification =
            SMSVerification(sinchApplicationKey,
                            phoneNumber: phoneNumber)
        self.verification.initiate { (result: InitiationResult, error: Error?) -> Void in
            if (result.success){
                self.performSegue(withIdentifier: "verifyPhoneNumber", sender: nil);
            } else {
                Messages.displayToastMessage(self.view, msg: "There was an error starting the phone number verification process..." + (error.debugDescription))
            }
        }

    }
    
    func signUpUser(_ userObj: NewUser?){
        
        
        if let user = userObj{
            
            self.showActivityIndicator()
       
            AuthService.instance.signUp(user.email, password: user.password, onComplete: { (errMsg, data) in

                user.password = ""
                
                guard errMsg == nil else {
                    Messages.showAlertDialog("Authentication Error", msgAlert: errMsg)
                    return
                }
                
                let firUser = data as? FIRUser
                
                let properties = self.userProperties(firUser?.uid, name: user.fullName, number: user.phoneNumber, email: user.email)
                
                FBDataService.instance.saveUser(firUser?.uid, isCustomer: true, propertes: properties, onComplete: { (errMsg, data) in
                    
                        if errMsg == nil {
                            self.initiateVerificationProcess(user.phoneNumber)
                            self.activityIndicator.stopAnimating()
                        }
                    
                        self.toggleSubmit(true)

                })
                
            })
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "verifyPhoneNumber" {
            if let verifyVC = segue.destination as? VerifyPhoneNumberVC{
                verifyVC.verification = self.verification
            }
        }
    }
    
    @IBAction func termsBtnPressed(_ sender: AnyObject) {
        Hotline.sharedInstance().showFAQs(self)
    }
    
    func validatePassword(_ password: String, confirmPassword: String) -> Bool{
        if password == confirmPassword{
            return true
        }
        return false
    }
    
}





