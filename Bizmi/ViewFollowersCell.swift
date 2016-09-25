//
//  ViewFollowers.swift
//  Bizmi
//
//  Created by Alex on 7/28/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ViewFollowersCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    
    @IBOutlet weak var nameLbl: TTTAttributedLabel!
    
    @IBOutlet weak var followingDate: TTTAttributedLabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImg.layer.cornerRadius = 1
        profileImg.clipsToBounds = true
        
        nameLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        followingDate.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewFollowersCell.onFollowingDateRetrieved), name: NSNotification.Name(rawValue: "subscriptionStatus"), object: nil)
        
    }
    
    func configureCell(_ user: User){
        
        let URL = Foundation.URL(string: "\(user.userProfilePicLocation)")!
        let placeholderImage = UIImage(named: "Placeholder")!
        
        //TODO: Change Cell from stack view to basic autolayout
        
        profileImg.af_setImageWithURL(URL, placeholderImage: placeholderImage)
        nameLbl.text = user.fullName
        
        let currentUser = appDelegate.backendless.userService.currentUser
        DataService.instance.findCustomerSubscriptionStatus(user.userObjectID, To: currentUser.objectId)
    }
    
    func onFollowingDateRetrieved(_ notification: Notification){

        if let responseDict = notification.object as? [String:AnyObject] {
            if let date = responseDict["date"] as? String {
                self.followingDate.text = "Follower Since \(date)"
            }
        }
    }
   
}
