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
   
    var customer: BackendlessUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.instance.clearAllFollowers()
        DataService.instance.loadAllFollowers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(BusinessViewCustomersVC.onFollowersLoaded), name: NSNotification.Name(rawValue: "allFollowersLoaded"), object: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = DataService.instance.allFollowers[(indexPath as NSIndexPath).row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseFollowerCell") as? ChoosePartyLeaderCell{
            
            cell.configureCell(user)
            
            return cell
        }else {
            
            let cell = ViewFollowersCell()
            cell.configureCell(user)
            
            return ViewFollowersCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataService.instance.allFollowers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) //So tableview row doesn't stay highlighted
        
        customer = DataService.instance.allFollowers[indexPath.row]
        
        let user = User()
        user.populateUserData(customer)
        
        DataService.instance.appointmentLeaderName = user.fullName
        DataService.instance.appointmentLeaderID = user.userObjectID
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func onFollowersLoaded(){
        tableView.reloadData()
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "GoBackToNewReservationVC" {
//            if let newReservationVC = segue.destinationViewController as? NewReservationVC{
//                if let customer = sender as? User {
//                    newReservationVC.customerName = customer.fullName
//                    newReservationVC.customerID = customer.userObjectID
//                    
//                    var navArray:Array = (self.navigationController?.viewControllers)!
//                    navArray.removeAtIndex(navArray.count-2)
//                    self.navigationController?.viewControllers = navArray
//                }
//            }
//            
//        }
//    }
    
}
