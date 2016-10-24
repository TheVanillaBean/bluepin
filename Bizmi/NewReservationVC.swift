//
//  NewReservationVC.swift
//  Bizmi
//
//  Created by Alex on 8/28/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NewReservationVC: UIViewController, UITextFieldDelegate  {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var partyLeaderField: UIButton!
    
    @IBOutlet weak var partySizeField: UITextField!
    
    @IBOutlet weak var reservationTimeLbl: UILabel!
    
    @IBOutlet weak var dateDialog: UIDatePicker!
    
    var customerName: String?
    var customerID: String?
    var customerDeviceToken: String?
    
    var partySize: String!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 65), animated: true)
        
        dateDialog.minimumDate = Date()
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fillInFields()
    }
    
    func fillInFields(){
        
        customerName = FBDataService.instance.appointmentLeaderName
        customerID = FBDataService.instance.appointmentLeaderID
        customerDeviceToken = FBDataService.instance.appointmentLeaderDeviceToken
        
        if customerID != "Select Customer"{
            self.partyLeaderField.setTitle(customerName, for: UIControlState())
        }
    
    }
    
    @IBAction func onPartySizeFieldChanged(_ sender: UITextField) {
        if let size = Int(sender.text!){
        
            if size == 0{
                sender.text = "1"
            }else if size > 150 {
                sender.text = "150"
            }
            
            partySize = sender.text!
            
            sender.text = "Party Size: \(partySize!)"
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = partySize
    }
    
    @IBAction func onDateChanged(_ sender: UIDatePicker) {
        
        partySizeField.resignFirstResponder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        let strDate = dateFormatter.string(from: sender.date)
        self.reservationTimeLbl.text = strDate
        
    }
    
    @IBAction func onCreateBtnPressed(_ sender: AnyObject) {
        
        self.showActivityIndicator()
        
        if fieldsAreValid(){
        
            let reservationTime = reservationTimeLbl.text!
            let currentUserID = (FBDataService.instance.currentUser?.uid)!
            
            self.clearFields()

            let user = NewUser()
            user.castUser(currentUserID, onComplete: { (errMsg) in
                if errMsg == nil{
                   
                    let FBReservation = FBDataService.instance.reservationsRef.childByAutoId()
                    
                    let res: Dictionary<String, AnyObject> = [RESERVATION_UID: FBReservation.key as AnyObject, RESERVATION_STATUS: PENDING_STATUS as AnyObject, RESERVATION_TIMESTAMP: FIRServerValue.timestamp() as AnyObject, RESERVATION_SIZE: self.partySize as AnyObject, RESERVATION_SCHEDULED_TIME: reservationTime as AnyObject, RESERVATION_PARTY_LEADER_ID: self.customerID! as AnyObject, RESERVATION_BUSINESS_ID: user.uuid as AnyObject]
                    
                    FBReservation.setValue(res)
                    FBDataService.instance.userReservationsRef.child(self.customerID!).child(FBReservation.key).setValue(FIRServerValue.timestamp())
                    FBDataService.instance.userReservationsRef.child((FBDataService.instance.currentUser?.uid)!).child(FBReservation.key).setValue(FIRServerValue.timestamp())
                    
                    let notification = FBDataService.instance.notificationsRef.childByAutoId()
                    
                    var notificationRequest: Dictionary<String, AnyObject>
                    
                    notificationRequest = [REQUEST_ID: notification.key as AnyObject, REQUEST_SENDER_ID: user.uuid as AnyObject, REQUEST_RECIPIENT_ID: self.customerID! as AnyObject, REQUEST_MESSAGE: NEW_RESERVATION_NOTIF as AnyObject, REQUEST_SENDER_NAME: user.businessName as AnyObject]
                    
                    notification.setValue(notificationRequest)
                    
                    self.activityIndicator.stopAnimating()
                    
                    self.navigationController?.popViewController(animated: true)
                }
            })
            
        }else{
            self.activityIndicator.stopAnimating()
        }
    }

    @IBAction func onPartyLeaderBtnPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "ChoosePartyLeaderVC", sender: nil)
    }
    
    func fieldsAreValid() -> Bool{
        if self.partyLeaderField.titleLabel?.text == "Select Customer"{
            
            Messages.showAlertDialog("Invalid Field", msgAlert: "Please Select a Customer.")
            return false
        }
        
        if self.partySizeField.text == ""{
            
            Messages.showAlertDialog("Invalid Field", msgAlert: "Please Enter a Valid Party Size.")
            return false
        }
        if reservationTimeLbl.text == "Time"{
            
            Messages.showAlertDialog("Invalid Field", msgAlert: "Please Enter a Valid Reservation Time.")
            return false
        }
        
        return true
    }

    func clearFields(){
        self.partyLeaderField.setTitle("Select Customer", for: UIControlState())
        self.partySizeField.text = ""
        self.reservationTimeLbl.text = "Time"
    }
    
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
}
