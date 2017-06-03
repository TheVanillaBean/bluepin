//
//  BusinessMessageChannelsCell.swift
//  bluepin
//
//  Created by Alex on 8/21/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import AlamofireImage
import FirebaseStorage
import TTTAttributedLabel

class BusinessMessageChannelsCell: UITableViewCell {
    
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
    
    func configureCell(_ message: Message){
        
        lastMessageLbl.text = message.messageData
        timestampLbl.text = message.timeStamp
        
        if FBDataService.instance.currentUser?.uid == message.senderUID{
            self.loadUserDisplayName(message.recipientUID)
        }else{
            self.loadUserDisplayName(message.senderUID)
        }
        
    }
    
    func loadUserDisplayName(_ uid: String!){
        let user = NewUser()
        user.castUser(uid) { (errMsg) in
            if errMsg == nil{
                
                if user.userType == "Business"{
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
            let ref = FIRStorage.storage().reference(forURL: location)
            ref.data(withMaxSize: 20 * 1024 * 1024, completion: { (data, error) in
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
