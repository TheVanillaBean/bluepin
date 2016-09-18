//
//  ChoosePartyLeaderCell.swift
//  Bizmi
//
//  Created by Alex on 8/28/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ChoosePartyLeaderCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    
    @IBOutlet weak var nameLbl: TTTAttributedLabel!
    
    @IBOutlet weak var followingDate: TTTAttributedLabel!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImg.layer.cornerRadius = 1
        profileImg.clipsToBounds = true
        
        nameLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
        followingDate.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChoosePartyLeaderCell.onFollowingDateRetrieved), name: "subscriptionStatus", object: nil)
        
    }
    
    func configureCell(user: User){
        
        let URL = NSURL(string: "\(user.userProfilePicLocation)")!
        let placeholderImage = UIImage(named: "Placeholder")!
        
        //TODO: Change Cell from stack view to basic autolayout
        
        profileImg.af_setImageWithURL(URL, placeholderImage: placeholderImage)
        nameLbl.text = user.fullName
        
        let currentUser = appDelegate.backendless.userService.currentUser
        DataService.instance.findCustomerSubscriptionStatus(user.userObjectID, To: currentUser.objectId)
    }
    
    func onFollowingDateRetrieved(notification: NSNotification){
        
        if let responseDict = notification.object as? [String:AnyObject] {
            if let date = responseDict["date"] as? String {
                self.followingDate.text = "Follower Since \(date)"
            }
        }
    }
    
}
