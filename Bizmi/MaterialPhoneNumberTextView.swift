//
//  MaterialPhoneNumberTextView.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import PhoneNumberKit

class MaterialPhoneNumberTextView: PhoneNumberTextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5.0
        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.1).cgColor
        layer.borderWidth = 2.0
        self.tintColor = ACCENT_COLOR
        
    }
    
    //For Placholder
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
    
    //For Editable Text
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
    
}
