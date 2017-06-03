//
//  ViewBusinessHoursVC.swift
//  bluepin
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
        hoursLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
    }
    
    override func viewDidAppear(_ animated: Bool) {
        hoursLbl.text = hours
    }
    
    @IBAction func cancelBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
