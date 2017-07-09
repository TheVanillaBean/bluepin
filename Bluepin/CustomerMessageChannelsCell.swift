//
//  CustomerMessageChannelsCell.swift
//  bluepin
//
//  Created by Alex on 8/21/16.
//  Copyright © 2016 Alex. All rights reserved.
//


import UIKit
import FirebaseStorage
import TTTAttributedLabel

class CustomerMessageChannelsCell: UITableViewCell {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var businessProfilePic: UIImageView!
    
    @IBOutlet weak var businessNameLbl: TTTAttributedLabel!
    
    @IBOutlet weak var lastMessageLbl: TTTAttributedLabel!
    
    @IBOutlet weak var timestampLbl: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        
        businessProfilePic.layer.cornerRadius = 10
        businessProfilePic.clipsToBounds = true
        businessNameLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        lastMessageLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        
    }
    
    func configureCell(_ message: [String: AnyObject]){
        
        lastMessageLbl.text = message[MESSAGE_TEXT] as? String
        timestampLbl.text = getFormattedTimeStamp(date: message[MESSAGE_TIMESTAMP] as! Date)

        if FBDataService.instance.currentUser?.uid == message[MESSAGE_SENDERID] as? String{
            self.loadUserDisplayName(message[MESSAGE_RECIPIENTID] as! String)
        }else{
            self.loadUserDisplayName(message[MESSAGE_SENDERID] as! String)
        }
        
    }
    
    func getFormattedTimeStamp(date: Date) -> String{
        
        let dateDouble: Double = Double(date.timeIntervalSince1970)
        
        let date = Date(timeIntervalSince1970: dateDouble/1000)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd"
        let dateString = dateFormatter.string(from: date as Date)
        
        return dateString
    }
    
    func loadUserDisplayName(_ uid: String!){
        let user = NewUser()
        user.castUser(uid) { (errMsg) in
            if errMsg == nil{
                
                if user.userType == USER_BUSINESS_TYPE{
                    self.businessNameLbl.text = user.businessName
                }else{
                    self.businessNameLbl.text = user.fullName
                }
                
                self.loadProfilePic(location: user.userProfilePicLocation)
                
            }else{
                self.businessNameLbl.text = "No Username to Display..."
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
}
