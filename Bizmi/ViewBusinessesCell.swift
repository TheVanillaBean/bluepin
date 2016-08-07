//
//  ViewBusinessesCell.swift
//  Bizmi
//
//  Created by Alex on 8/6/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import AlamofireImage
import TTTAttributedLabel

class ViewBusinessesCell: UITableViewCell {
    
    @IBOutlet weak var businessBGImage: UIImageView!
    
    @IBOutlet weak var businessNameLbl: TTTAttributedLabel!
    
    @IBOutlet weak var businessTypeLbl: UILabel!
    
    @IBOutlet weak var businessLocationLbl: UILabel!
    
    @IBOutlet weak var businessDesclbl: TTTAttributedLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        businessBGImage.layer.cornerRadius = 1
        businessBGImage.clipsToBounds = true
        businessNameLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
        businessDesclbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
        
    }
    
    func configureCell(user: User!){
        
        let URL = NSURL(string: "\(user.userProfilePicLocation)")!
        let placeholderImage = UIImage(named: "Placeholder")!
        
        businessBGImage.af_setImageWithURL(URL, placeholderImage: placeholderImage)
        businessNameLbl.text = user.businessName
        businessTypeLbl.text = user.businessType
        businessDesclbl.text = user.businessDesc
        businessLocationLbl.text = "Chandler"  //Location TODO
        
    }
    

}
