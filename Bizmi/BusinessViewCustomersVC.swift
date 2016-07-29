//
//  BusinessViewCustomersVC.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class BusinessViewCustomersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.instance.loadAllUsers()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BusinessViewCustomersVC.onUsersLoaded), name: "allUsersLoaded", object: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
     
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let user = DataService.instance.allUsers[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("viewFollowersCell") as? ViewFollowersCell{
            
            cell.configureCell(user)
            
            return cell
        }else {
            
            let cell = ViewFollowersCell()
            cell.configureCell(user)
            
            return ViewFollowersCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataService.instance.allUsers.count
    }
    
    func onUsersLoaded(){
        tableView.reloadData()
    }
    
    
}
