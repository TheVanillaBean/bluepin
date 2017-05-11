//
//  ViewFollowers.swift
//  Bizmi
//
//  Created by Alex on 7/28/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import FirebaseStorage

class ViewFollowersCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    
    @IBOutlet weak var nameLbl: TTTAttributedLabel!
    
    @IBOutlet weak var followingDate: TTTAttributedLabel!
    
    private var castedUser: NewUser!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImg.layer.cornerRadius = 1
        profileImg.clipsToBounds = true
        nameLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        followingDate.verticalAlignment = TTTAttributedLabelVerticalAlignment.top

    }
    
    func configureCell(_ uuid: String, timestamp: Double){
        
        castedUser = NewUser()
        castedUser.castUser(uuid) { (errMsg) in
            
            self.nameLbl.text = self.castedUser.fullName
            
            let date = NSDate(timeIntervalSince1970: timestamp/1000)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd yyyy "
            let dateString = dateFormatter.string(from: date as Date)

            self.followingDate.text = "Customer since: \(dateString)"

            self.loadProfilePic()
            
        }

    }
    

    func loadProfilePic(){
        
        if castedUser.userProfilePicLocation != "" {
            
            let ref = FIRStorage.storage().reference(forURL: castedUser.userProfilePicLocation)
            ref.data(withMaxSize: 20 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    let placeholderImage = UIImage(named: "Placeholder")!
                    self.profileImg.image = placeholderImage
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.profileImg.image = img
                        }
                    }
                }
            })
        }
    }
    
   
}
