//
//  NewReservationVC.swift
//  Bizmi
//
//  Created by Alex on 8/28/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class NewReservationVC: UIViewController, UITextFieldDelegate  {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var partyLeaderField: UIButton!
    
    @IBOutlet weak var partySizeField: UITextField!
    
    @IBOutlet weak var reservationTimeLbl: UILabel!
    
    @IBOutlet weak var dateDialog: UIDatePicker!
    
    var customerName: String?
    var customerID: String?
    
    var partySize: String!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        scrollView.setContentOffset(CGPointMake(0, 65), animated: true)
        
        dateDialog.minimumDate = NSDate()
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        fillInFields()
    }
    
    func fillInFields(){
        
        customerName = DataService.instance.appointmentLeaderName
        customerID = DataService.instance.appointmentLeaderID
        
        if customerID != "Select Customer"{
            self.partyLeaderField.setTitle(customerName, forState: .Normal)
            print(customerID)
        }
    
    }
    
    @IBAction func onPartySizeFieldChanged(sender: UITextField) {
        
        
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = partySize
    }
    
    @IBAction func onDateChanged(sender: UIDatePicker) {
        
        partySizeField.resignFirstResponder()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        let strDate = dateFormatter.stringFromDate(sender.date)
        self.reservationTimeLbl.text = strDate
        
    }
    
    @IBAction func onCreateBtnPressed(sender: AnyObject) {
        
        print("\(partyLeaderField.titleLabel?.text) - \(partySizeField.text) - \(reservationTimeLbl.text)")
        
        if fieldsAreValid(){
        
            let reservationTime = reservationTimeLbl.text
            let partySize = partySizeField.text
            let currentUser = appDelegate.backendless.userService.currentUser
            
            let user = User()
            user.populateUserData(currentUser)
            
            let reservation = Reservation()
            reservation.Leader = customerName
            reservation.ReservationTime = reservationTime
            reservation.Size = partySize
            reservation.PartyLeaderID = customerID
            reservation.BusinessID = user.userObjectID
            reservation.Status = "Pending"
            reservation.BusinessName = user.businessName
            
            let dataStore = appDelegate.backendless.data.of(Reservation.ofClass())
            
            // save object asynchronously
            dataStore.save(
                reservation,
                response: { (result: AnyObject!) -> Void in
                    let obj = result as! Reservation
                    print("Time \(obj.ReservationTime)")
                    print("Business ID \(obj.BusinessID)")
                    print("Pary Leader ID \(obj.PartyLeaderID)")
                    print("Leader Name \(obj.Leader)")
                    print("Size \(obj.Size)")
                    
                    self.clearFields()
                    
                    self.navigationController?.popViewControllerAnimated(true)

                },
                error: { (fault: Fault!) -> Void in
                    print("fServer reported an error: \(fault)")
            })
        }
    }

    @IBAction func onPartyLeaderBtnPressed(sender: AnyObject) {
        performSegueWithIdentifier("ChoosePartyLeaderVC", sender: nil)
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
        self.partyLeaderField.setTitle("Select Customer", forState: .Normal)
        self.partySizeField.text = ""
        self.reservationTimeLbl.text = "Time"
    }
    
}
