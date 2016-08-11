//
//  ButtonBorderBlue.swift
//  Bizmi
//
//  Created by Alex on 8/9/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

@IBDesignable
class ButtonBorderBlue: UIButton {

    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.CGColor
            layer.borderWidth = 1
        }
    }
    
    
}
