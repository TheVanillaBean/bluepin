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
    
    @IBOutlet weak var reservationTimeLbl: UILabel!
    
    @IBOutlet weak var dateDialog: UIDatePicker!
    
    @IBOutlet weak var createReservationBtn: UIButton!
    
    var customerName: String?
    var customerID: String?
    var timeInterval: Date?
    
    var existingReservation: Reservation?
    var isExistingReservation: Bool = false
    
    
    //Add reservationID and isExistingReservation FIelds - set them in reservation tableview and in choosepesonvc
    //If isExisting - change create resevation to change reservation
    //set customername and customerID
    
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
        
        
        if isExistingReservation{
        
            customerName = self.existingReservation?.customerName
            customerID = self.existingReservation?.leaderID
            
            self.partyLeaderField.setTitle(customerName, for: UIControlState())
            self.createReservationBtn.setTitle("Change Reservation", for: UIControlState())
            
            let date = NSDate(timeIntervalSince1970: ((self.existingReservation?.appointmentTimeInterval)!))
            self.dateDialog.setDate(date as Date, animated: false)
            
        }else{
        
            customerName = FBDataService.instance.appointmentLeaderName
            customerID = FBDataService.instance.appointmentLeaderID
            
            if customerID != "Select Customer"{
                self.partyLeaderField.setTitle(customerName, for: UIControlState())
            }
            
        }
    }

    @IBAction func onDateChanged(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        let strDate = dateFormatter.string(from: sender.date)
        self.reservationTimeLbl.text = strDate
        self.timeInterval = sender.date
        
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
                    
                    var FBReservation: FIRDatabaseReference!
                    var res: Dictionary<String, AnyObject>

                    let integerInterval = Int((self.timeInterval?.timeIntervalSince1970)!)
                    let interval: NSNumber = NSNumber(value: integerInterval)
                    
                    if self.isExistingReservation{
                        
                        FBReservation = FBDataService.instance.reservationsRef.child((self.existingReservation?.uuid)!)
                        
                        res = [RESERVATION_UID: FBReservation.key as AnyObject, RESERVATION_STATUS: (self.existingReservation?.status)! as AnyObject, RESERVATION_TIMESTAMP: FIRServerValue.timestamp() as AnyObject, RESERVATION_SCHEDULED_TIME: reservationTime as AnyObject, RESERVATION_PARTY_LEADER_ID: self.customerID! as AnyObject, RESERVATION_BUSINESS_ID: user.uuid as AnyObject, RESERVATION_APPOINTMENT_TIME_INTERVAL: interval as AnyObject]
                        
                    }else{
                        
                        FBReservation = FBDataService.instance.reservationsRef.childByAutoId()
                        
                        res = [RESERVATION_UID: FBReservation.key as AnyObject, RESERVATION_STATUS: PENDING_STATUS as AnyObject, RESERVATION_TIMESTAMP: FIRServerValue.timestamp() as AnyObject, RESERVATION_SCHEDULED_TIME: reservationTime as AnyObject, RESERVATION_PARTY_LEADER_ID: self.customerID! as AnyObject, RESERVATION_BUSINESS_ID: user.uuid as AnyObject, RESERVATION_APPOINTMENT_TIME_INTERVAL: interval as AnyObject]
                        
                    }
                    
                    FBReservation.setValue(res)

                    FBDataService.instance.userReservationsRef.child(self.customerID!).child(FBReservation.key).setValue(interval)
                    FBDataService.instance.userReservationsRef.child((FBDataService.instance.currentUser?.uid)!).child(FBReservation.key).setValue(interval)
                    
                    let notification = FBDataService.instance.notificationsRef.childByAutoId()
                    
                    var notificationRequest: Dictionary<String, AnyObject>
                    
                    if self.isExistingReservation{
                        
                        notificationRequest = [REQUEST_ID: notification.key as AnyObject, REQUEST_SENDER_ID: user.uuid as AnyObject, REQUEST_RECIPIENT_ID: self.customerID! as AnyObject, REQUEST_MESSAGE: EXISTING_RESERVATION_NOTIF as AnyObject, REQUEST_SENDER_NAME: user.businessName as AnyObject]
                        
                    }else{

                        notificationRequest = [REQUEST_ID: notification.key as AnyObject, REQUEST_SENDER_ID: user.uuid as AnyObject, REQUEST_RECIPIENT_ID: self.customerID! as AnyObject, REQUEST_MESSAGE: NEW_RESERVATION_NOTIF as AnyObject, REQUEST_SENDER_NAME: user.businessName as AnyObject]
                        
                    }
                    
                  
                    notification.setValue(notificationRequest)
                    
                    self.activityIndicator.stopAnimating()
                    
                    _ = self.navigationController?.popViewController(animated: true)
                }
            })
            
        }else{
            self.activityIndicator.stopAnimating()
        }
    }

    @IBAction func onPartyLeaderBtnPressed(_ sender: AnyObject) {
        if !isExistingReservation{
            performSegue(withIdentifier: "ChoosePartyLeaderVC", sender: nil)
        }
    }
    
    func fieldsAreValid() -> Bool{
        if self.partyLeaderField.titleLabel?.text == "Select Customer"{
            
            Messages.showAlertDialog("Invalid Field", msgAlert: "Please Select a Customer.")
            return false
        }
        if reservationTimeLbl.text == "Date and Time"{
            
            Messages.showAlertDialog("Invalid Field", msgAlert: "Please Enter a Valid Reservation Time.")
            return false
        }
        
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        clearFields()
        FBDataService.instance.clearCurrentSelectedUser()
    }

    func clearFields(){
        self.partyLeaderField.setTitle("Select Customer", for: UIControlState())
        self.reservationTimeLbl.text = "Date and Time"
    }
    
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
}
