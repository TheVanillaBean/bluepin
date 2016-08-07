//
//  CustomerViewBusinessesVC.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class CustomerViewBusinessesVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
     
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.instance.loadAllBusinesses()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomerViewBusinessesVC.onBusinessesLoaded), name: "allBusinessesLoaded", object: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let business = DataService.instance.allBusinesses[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("ViewBusinessesCell") as? ViewBusinessesCell{
            
            cell.configureCell(business)
            
            return cell
        }else {
            
            let cell = ViewBusinessesCell()
            cell.configureCell(business)
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 128.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataService.instance.allBusinesses.count
    }
    
    func onBusinessesLoaded(){
        tableView.reloadData()
    }
    
    
}
