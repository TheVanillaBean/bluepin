//
//  ChoosePartyLeaderVC.swift
//  Bizmi
//
//  Created by Alex on 8/28/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class ChoosePartyLeaderVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
   
    var customerID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        FBDataService.instance.clearAllFollowers()
        
        FBDataService.instance.retriveAllFollowers(businessID: (FBDataService.instance.currentUser?.uid)!) { (errMsg, data) in
            if errMsg == nil{
                self.tableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let follower = FBDataService.instance.allFollowers[(indexPath as NSIndexPath).row]
        let timestamp: Double = FBDataService.instance.allFollowersTime[(indexPath as NSIndexPath).row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseFollowerCell") as? ChoosePartyLeaderCell{
            
            cell.configureCell(follower, timestamp: timestamp)
            
            return cell
        }else {
            
            let cell = ViewFollowersCell()
            cell.configureCell(follower, timestamp: timestamp)
        
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FBDataService.instance.allFollowers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) //So tableview row doesn't stay highlighted
        
        customerID = FBDataService.instance.allFollowers[indexPath.row]
        
        let castedUser = NewUser()
        castedUser.castUser(customerID) { (errMsg) in
            if errMsg == nil{
                FBDataService.instance.appointmentLeaderName = castedUser.fullName
                FBDataService.instance.appointmentLeaderID = self.customerID
                FBDataService.instance.appointmentLeaderDeviceToken = castedUser.deviceToken
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }

    
}
