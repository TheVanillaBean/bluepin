//
//  BusinessViewMessages.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class BusinessViewMessagesVC: UIViewController {

    override func viewDidLoad() {
        self.tabBarController?.navigationItem.hidesBackButton = true
        let titleView = UIImageView(image: UIImage(named: "Nav_Img"))
        self.tabBarController?.navigationItem.titleView = titleView
    }
    
}
