//
//  CustomerReservationCell.swift
//  Bizmi
//
//  Created by Alex on 9/3/16.
//  Copyright © 2016 Alex. All rights reserved.
//
import UIKit
import TTTAttributedLabel

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
//    
//    func configureCell(_ reservation: Reservation!){
//        
//        let URL = Foundation.URL(string: "\(profilePicLocation(reservation.BusinessID!))")!
//        let placeholderImage = UIImage(named: "Placeholder")!
//        
//        businessProfilePic.af_setImageWithURL(URL, placeholderImage: placeholderImage)
//        
//        businessNameLbl.text = reservation.BusinessName
//        appointmentLbl.text = reservation.ReservationTime
//        statusLbl.text = reservation.Status
//        setStatusColor(reservation.Status)
//
//    }
//    
//    func profilePicLocation(_ userID: String) -> String{
//        
//        return "https://api.backendless.com/127af0a5-6fb8-985e-ff8c-2ee5ffb8ff00/v1/files/profilePics/\(userID)"
//        
//    }
//    
//    func setStatusColor(_ status: String!){
//        
//        if status == DataService.statusType.PENDING.rawValue{
//            statusLbl.textColor = UIColor.orange
//        }else if status == DataService.statusType.ACTIVE.rawValue{
//            statusLbl.textColor = UIColor.green
//        }else if status == DataService.statusType.INACTIVE.rawValue{
//            statusLbl.textColor = UIColor.red
//        }else if status == DataService.statusType.DECLINED.rawValue{
//            statusLbl.textColor = UIColor.red
//        }
//        
//    }
    
}
