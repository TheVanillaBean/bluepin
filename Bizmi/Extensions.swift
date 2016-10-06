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
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return normalizedImage;
    }
    
}

extension CALayer {
    func borderUIColor() -> UIColor? {
        return borderColor != nil ? UIColor(cgColor: borderColor!) : nil
    }
    
    func setBorderUIColor(_ color: UIColor) {
        borderColor = color.cgColor
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
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

//typealias UnixTime = Int
//
//extension UnixTime {
//    private func formatType(form: String) -> DateFormatter {
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
//        dateFormatter.dateFormat = form
//        return dateFormatter
//    }
//    var dateFull: NSDate {
//        return NSDate(timeIntervalSince1970: Double(self))
//    }
//    var toHour: String {
//        return formatType(form: "HH:mm").stringFromDate(dateFull)
//    }
//    var toDay: String {
//        return formatType(form: "MM/dd/yyyy").stringFromDate(dateFull)
//    }
//}

