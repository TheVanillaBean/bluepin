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
    
    var partySize: String!
    
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
        
        if customerID != "Select Customer"{
            self.partyLeaderField.setTitle(customerName, for: UIControlState())
            print(customerID)
        }
    
    }
    
    @IBAction func onPartySizeFieldChanged(_ sender: UITextField) {
        
        
        if Int(sender.text!)! == 0{
            sender.text = "1"
        }else if Int(sender.text!)! > 150 {
            sender.text = "150"
        }
        
        partySize = sender.text
        
        if let partySize = sender.text{
            sender.text = "Party Size: \(partySize)"
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
        
        print("\(partyLeaderField.titleLabel?.text) - \(partySizeField.text) - \(reservationTimeLbl.text)")
        
        if fieldsAreValid(){
        
            let reservationTime = reservationTimeLbl.text!
            let currentUserID = (FBDataService.instance.currentUser?.uid)!
            
            let user = NewUser()
            user.castUser(currentUserID, onComplete: { (errMsg) in
                if errMsg == nil{
                   
                    let FBReservation = FBDataService.instance.reservationsRef.childByAutoId()
                    
                    print(reservationTime)
                    
                    let res: Dictionary<String, AnyObject> = [RESERVATION_UID: FBReservation.key as AnyObject, RESERVATION_STATUS: PENDING_STATUS as AnyObject, RESERVATION_TIMESTAMP: FIRServerValue.timestamp() as AnyObject, RESERVATION_SIZE: self.partySize as AnyObject, RESERVATION_SCHEDULED_TIME: reservationTime as AnyObject, RESERVATION_PARTY_LEADER_ID: self.customerID! as AnyObject, RESERVATION_BUSINESS_ID: user.uuid as AnyObject]
                    
                    FBReservation.setValue(res)
                    FBDataService.instance.userReservationsRef.child(self.customerID!).child(FBReservation.key).setValue(FIRServerValue.timestamp())
                    FBDataService.instance.userReservationsRef.child((FBDataService.instance.currentUser?.uid)!).child(FBReservation.key).setValue(FIRServerValue.timestamp())
                    
                    self.clearFields()
                    self.navigationController?.popViewController(animated: true)
                }
            })
            
        

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
    
}
