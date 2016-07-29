//
//  ViewFollowers.swift
//  Bizmi
//
//  Created by Alex on 7/28/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class ViewFollowersCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var emailLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
    }
    
    func configureCell(user: User){
        
        nameLbl.text = user.fullName
        emailLbl.text = user.userEmail
        
    }
    
}
