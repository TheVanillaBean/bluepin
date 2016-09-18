//
//  BusinessViewReservationsVC.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class BusinessViewReservationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
    
    var selectedReservation: Reservation!
    
    let user: User = User()
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let currentUser = appDelegate.backendless.userService.currentUser
        user.populateUserData(currentUser)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BusinessViewReservationsVC.onReservationsRecieved), name: "findBusinessReservations", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BusinessViewReservationsVC.onReservationUpdated), name: "removeReservation", object: nil)
        
        showActivityIndicator()
        DataService.instance.findBusinessReservations(user.userObjectID)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(CustomerViewReservationsVC.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    func refresh(sender:AnyObject) {
        showActivityIndicator()
        DataService.instance.clearCustomerReservation()
        DataService.instance.findBusinessReservations(user.userObjectID)
    }
    
    func onReservationsRecieved(){
        
        activityIndicator.stopAnimating()
        
        tableView.reloadData()
        
        refreshControl.endRefreshing()
    }
    
    func onReservationUpdated(){
        
        DataService.instance.findBusinessReservations(user.userObjectID)

    }
    
    //Setup Tableview
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let reservation = DataService.instance.allBusinessReservations[indexPath.row]
                
        if let cell = tableView.dequeueReusableCellWithIdentifier("BusinessReservationCell") as? BusinessReservationCell{
            
            cell.configureCell(reservation)
            
            return cell
        }else {
            
            let cell = BusinessReservationCell()
            cell.configureCell(reservation)
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataService.instance.allBusinessReservations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true) //So 
        
        selectedReservation = DataService.instance.allBusinessReservations[indexPath.row]
        
        if selectedReservation.Status == DataService.statusType.PENDING.rawValue{
            showAlertDialog()
        }
        
    }
    
    
    func showAlertDialog(){
        
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "Remove Reservation", message: "Do you want to delete this reservation for \(selectedReservation.Leader!)?", preferredStyle: .Alert)
        
        // Initialize Actions
        let yesAction = UIAlertAction(title: "Accept", style: .Default) { (action) -> Void in
            DataService.instance.removeReservation(self.selectedReservation)
        }
        
        let noAction = UIAlertAction(title: "Decline", style: .Default) { (action) -> Void in
        }
        
        // Add Actions
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        // Present Alert Controller
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    //Spinning indicator when loading request
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    
}
