//
//  BusinessViewCustomersVC.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class BusinessViewCustomersVC: UIViewController, UITableViewDelegate, UITableViewDataSource,  DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    var customerID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        
        FBDataService.instance.retriveAllFollowers(businessID: (FBDataService.instance.currentUser?.uid)!) { (errMsg, data) in
            self.tableView.reloadData()
        }
        
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Data ...", attributes: nil)
        refreshControl.addTarget(self, action: #selector(CustomerViewBusinessesVC.refresh(sender:)), for: .valueChanged)
        
        // Add to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
    
    func refresh(sender: UIRefreshControl) {
        FBDataService.instance.retriveAllFollowers(businessID: (FBDataService.instance.currentUser?.uid)!) { (errMsg, data) in
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = EMPTY_DATA_WELCOME
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = EMPTY_FOLLOWERS_DATA_SET_BUSINESS
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let follower = FBDataService.instance.allFollowers[(indexPath as NSIndexPath).row]
        let timestamp: Double = FBDataService.instance.allFollowersTime[(indexPath as NSIndexPath).row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "viewFollowersCell") as? ViewFollowersCell{
            
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
        
        let currentCell = tableView.cellForRow(at: indexPath)! as! ViewFollowersCell
        
        let date = currentCell.followingDate.text! as String
        
        customerID = FBDataService.instance.allFollowers[indexPath.row]
        performSegue(withIdentifier: "ViewSingleCustomer", sender: date)
        
    }
 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewSingleCustomer" {
            if let viewCustomerVC = segue.destination as? ViewCustomerVC{
                if let date = sender as? String {
                    viewCustomerVC.customerID = customerID
                    viewCustomerVC.followingDate = date
                }
            }
            
        }
    }
    
}
