//
//  Messages.swift
//  Bluepin
//
//  Created by Alex on 7/26/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class Messages {
    
    static var view: UIView!
    static let screenSize: CGRect = UIScreen.main.bounds
    static let screenWidth = screenSize.width
    static let screenHeight = screenSize.height
    static let position = CGPoint(x: CGFloat(screenWidth/2), y: CGFloat( (screenHeight * 0.33 ) ))
        
    static func displayToastMessage(_ uiVIew: UIView!, msg: String?){
        
        view = uiVIew
        
        if let message = msg {
           self.view.makeToast(message, duration: 5.0, position: position)
        }
    }

    static func showAlertDialog(_ titleAlert: String?, msgAlert: String?){
        
        if let title = titleAlert, let message = msgAlert {
        
            // Initialize Alert Controller
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            // Initialize Actions
            let okAction = UIAlertAction(title: "Okay", style: .default) { (action) -> Void in
            }
            
            // Add Actions
            alertController.addAction(okAction)
            
            // Present Alert Controller
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
       
    }
 
    
}
    
    
