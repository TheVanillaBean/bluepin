//
//  BusinessReservationCell.swift
//  bluepin
//
//  Created by Alex on 9/3/16.
//  Copyright © 2016 Alex. All rights reserved.
//
import UIKit
import TTTAttributedLabel
import FirebaseStorage

class BusinessReservationCell: UITableViewCell {
    
    @IBOutlet weak var customerProfilePic: BorderImageView!
    
    @IBOutlet weak var customerNamelbl: TTTAttributedLabel!
    
    @IBOutlet weak var appointmentLbl: TTTAttributedLabel!
    
    @IBOutlet weak var statusLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        customerProfilePic.layer.cornerRadius = 5
        customerProfilePic.clipsToBounds = true
        
        customerNamelbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        appointmentLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        
    }
    
    func configureCell(_ reservation: Reservation){
        
        customerNamelbl.text = reservation.customerName
        appointmentLbl.text = "Appointment Date: \n\(reservation.scheduledTime)"
        statusLbl.text = reservation.status
        setStatusColor(reservation.status)
        
        let user = NewUser()
        user.castUser(reservation.leaderID) { (errMsg) in
            if errMsg == nil{
                self.loadProfilePic(location: user.userProfilePicLocation)
            }
        }
        
    }
    
    func loadProfilePic(location: String!){
        
        if location.characters.count > 2{
            
            let ref = FIRStorage.storage().reference(forURL: location)
            ref.data(withMaxSize: 20 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    let placeholderImage = UIImage(named: "Placeholder")!
                    self.customerProfilePic.image = placeholderImage
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.customerProfilePic.image = img
                        }
                    }
                }
            })
        }
    }
  
    func setStatusColor(_ status: String!){

        if status == PENDING_STATUS{
            statusLbl.textColor = UIColor.orange
        }else if status == ACTIVE_STATUS{
            statusLbl.textColor = UIColor.green
        }else if status == INACTIVE_STATUS{
            statusLbl.textColor = UIColor.red
        }else if status == DECLINED_STATUS{
            statusLbl.textColor = UIColor.red
        }
        
    }
    
}
