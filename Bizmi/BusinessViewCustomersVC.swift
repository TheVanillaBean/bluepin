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
    
 //   var customerUser: BackendlessUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        DataService.instance.loadAllFollowers()
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(BusinessViewCustomersVC.onFollowersLoaded), name: NSNotification.Name(rawValue: "allFollowersLoaded"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let user = DataService.instance.allFollowers[(indexPath as NSIndexPath).row]
//        
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "viewFollowersCell") as? ViewFollowersCell{
//            
//            cell.configureCell(user)
//            
//            return cell
//        }else {
//            
//            let cell = ViewFollowersCell()
//            cell.configureCell(user)
        
            return ViewFollowersCell()
   //     }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     //   return DataService.instance.allFollowers.count
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        tableView.deselectRow(at: indexPath, animated: true) //So tableview row doesn't stay highlighted
//        
//        let currentCell = tableView.cellForRow(at: indexPath)! as! ViewFollowersCell
//        
//        let date = currentCell.followingDate.text! as String
//        
//        customerUser = DataService.instance.allFollowers[indexPath.row]
//        performSegue(withIdentifier: "ViewSingleCustomer", sender: date)
        
    }
    
//    func onFollowersLoaded(){
//        tableView.reloadData()
//    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ViewSingleCustomer" {
//            if let viewCustomerVC = segue.destination as? ViewCustomerVC{
//                if let date = sender as? String {
//                    viewCustomerVC.backendlessUser = customerUser
//                    viewCustomerVC.followingDate = date
//                }
//            }
//            
//        }
//    }
    
}
