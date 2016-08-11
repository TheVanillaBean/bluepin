//
//  ViewBusinessHoursVC.swift
//  Bizmi
//
//  Created by Alex on 8/10/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ViewBusinessHoursVC: UIViewController {

    @IBOutlet weak var hoursLbl: TTTAttributedLabel!
    
    var hours: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hoursLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
    }
    
    override func viewDidAppear(animated: Bool) {
        hoursLbl.text = hours
    }
    
    @IBAction func cancelBtnPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
