//
//  Extensions.swift
//  Bizmi
//
//  Created by Alex on 8/5/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    public func correctlyOrientedImage() -> UIImage {
        if self.imageOrientation == UIImageOrientation.Up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.drawInRect(CGRectMake(0, 0, self.size.width, self.size.height))
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return normalizedImage;
    }
    
}

extension CALayer {
    func borderUIColor() -> UIColor? {
        return borderColor != nil ? UIColor(CGColor: borderColor!) : nil
    }
    
    func setBorderUIColor(color: UIColor) {
        borderColor = color.CGColor
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}

