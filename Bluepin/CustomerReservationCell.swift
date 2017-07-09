//
//  CustomerReservationCell.swift
//  bluepin
//
//  Created by Alex on 9/3/16.
//  Copyright © 2016 Alex. All rights reserved.
//
import UIKit
import TTTAttributedLabel
import FirebaseStorage

class CustomerReservationCell: UITableViewCell {
    
    @IBOutlet weak var businessProfilePic: BorderImageView!
  
    @IBOutlet weak var businessNameLbl: TTTAttributedLabel!
    
    @IBOutlet weak var appointmentLbl: TTTAttributedLabel!
    
    @IBOutlet weak var statusLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        businessProfilePic.layer.cornerRadius = 5
        businessProfilePic.clipsToBounds = true
        
        businessNameLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        
        appointmentLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
   
    }
    
    func configureCell(_ reservation: Reservation){
        
        businessNameLbl.text = reservation.businessName
        appointmentLbl.text = "Appointment Date: \n\(reservation.scheduledTime)"
        statusLbl.text = reservation.status
        setStatusColor(reservation.status)
        
        let user = NewUser()
        user.castUser(reservation.businessID) { (errMsg) in
            if errMsg == nil{
                self.loadProfilePic(location: user.userProfilePicLocation)
            }
        }
        
    }
    
    func loadProfilePic(location: String!){
       
        if location.characters.count > 2{

            let ref = Storage.storage().reference(forURL: location)
            ref.getData(maxSize: 20 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    let placeholderImage = UIImage(named: "Placeholder")!
                    self.businessProfilePic.image = placeholderImage
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.businessProfilePic.image = img
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
