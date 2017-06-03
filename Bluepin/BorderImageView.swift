//
//  BorderImageView.swift
//  bluepin
//
//  Created by Alex on 8/10/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class BorderImageView: UIImageView {

    override func awakeFromNib() {
        layer.cornerRadius = 15.0
        clipsToBounds = true;
        layer.borderWidth = 3.0
        layer.borderColor = ACCENT_COLOR.cgColor
    }
    
    
}
