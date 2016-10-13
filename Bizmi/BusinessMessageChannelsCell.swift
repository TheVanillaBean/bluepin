//
//  BusinessMessageChannelsCell.swift
//  Bizmi
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        businessProfilePic.layer.cornerRadius = 10
        businessProfilePic.clipsToBounds = true
        
        businessNameLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        lastMessageLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top

    }
    
    func configureCell(_ message: Message){
        
        //let placeholderImage = UIImage(named: "Placeholder")!
        lastMessageLbl.text = message.messageData
        
        if FBDataService.instance.currentUser?.uid == message.senderUID{ //Current User was last sender
            
            self.loadUserDisplayName(message.recipientUID)
            
        }else{ // Current User was not last sender in convo
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
                self.businessNameLbl.text = "No User Name to Display..."
            }
        }
    }
    
    func loadProfilePic(location: String!){
        
        let ref = FIRStorage.storage().reference(forURL: location)
        ref.data(withMaxSize: 20 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("Unable to download image from Firebase storage")
                print(error)
                let placeholderImage = UIImage(named: "Placeholder")!
                self.businessProfilePic.image = placeholderImage
            } else {
                print("Image downloaded from Firebase storage")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.businessProfilePic.image = img
                    }
                }
            }
        })
        
    }
    
}
