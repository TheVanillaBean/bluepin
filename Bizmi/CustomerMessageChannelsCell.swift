//
//  CustomerMessageChannelsCell.swift
//  Bizmi
//
//  Created by Alex on 8/21/16.
//  Copyright © 2016 Alex. All rights reserved.
//


import UIKit
import AlamofireImage
import TTTAttributedLabel

class CustomerMessageChannelsCell: UITableViewCell {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var businessProfilePic: UIImageView!
    
    @IBOutlet weak var businessNameLbl: TTTAttributedLabel!
    
    @IBOutlet weak var lastMessageLbl: TTTAttributedLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        businessProfilePic.layer.cornerRadius = 10
        businessProfilePic.clipsToBounds = true
        
        
        businessNameLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
        lastMessageLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
        
    }
    
    func configureCell(message: MessageItem){

        let currentUser = appDelegate.backendless.userService.currentUser
        let user = User()
        user.populateUserData(currentUser)
        
        let placeholderImage = UIImage(named: "Placeholder")!
        lastMessageLbl.text = message.message

        if user.userObjectID == message.uuid{ //Current User was last sender
        
            let URL = NSURL(string: "\(message.recipientProfilePictureLocation)")!
            
            businessProfilePic.af_setImageWithURL(URL, placeholderImage: placeholderImage)
            businessNameLbl.text = message.recipientDisplayName
            
        }else{ // Current User was not last sender in convo
            let URL = NSURL(string: "\(message.senderProfilePictureLocation)")!
            
            businessProfilePic.af_setImageWithURL(URL, placeholderImage: placeholderImage)
            businessNameLbl.text = message.senderDisplayName
        }
        
        

    }
    
}
