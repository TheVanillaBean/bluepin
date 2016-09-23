//
//  CustomerProfileCell.swift
//  Bizmi
//
//  Created by Alex on 9/20/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation
import UIKit

class CustomerProfileCell: UITableViewCell {
    
    
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
