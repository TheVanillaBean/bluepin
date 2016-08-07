//
//  BusinessProfileCell.swift
//  Bizmi
//
//  Created by Alex on 8/3/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class BusinessProfileCell: UITableViewCell {
    
    
    @IBOutlet weak var iconImg: UIImageView!
    
    @IBOutlet weak var itemLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImg.layer.cornerRadius = 10
        iconImg.clipsToBounds = true
        
    }
    
    func configureCell(icon: UIImage!, text: String!){
        
        iconImg.image = icon
        itemLbl.text = text
        
    }

}
