//
//  BusinessViewReservationsVC.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class BusinessViewReservationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    
    var selectedReservation: Reservation!
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
   
        NotificationCenter.default.addObserver(self, selector: #selector(BusinessViewReservationsVC.onReservationsRecieved), name: NSNotification.Name(rawValue: "reservationRetrieved"), object: nil)
        
        showActivityIndicator()
        
        
        if FBDataService.instance.reservationAddedHandler == nil{
            
            FBDataService.instance.observeReservationsChangedForUser(FBDataService.instance.currentUser?.uid)
            FBDataService.instance.observeReservationsAddedForUser(FBDataService.instance.currentUser?.uid)
            FBDataService.instance.observeReservationsDeletedForUser(FBDataService.instance.currentUser?.uid)
        }

        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Data ...", attributes: nil)
        refreshControl.addTarget(self, action: #selector(CustomerViewBusinessesVC.refresh(sender:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
    }
    
    func refresh(sender: UIRefreshControl) {
        FBDataService.instance.userReservationsRef.child((FBDataService.instance.currentUser?.uid)!).removeAllObservers()
   
        FBDataService.instance.reservationAddedHandler = nil
        FBDataService.instance.reservationChangedHandler = nil
        FBDataService.instance.reservationDeletedHandler = nil
        
        if FBDataService.instance.reservationAddedHandler == nil{
            FBDataService.instance.clearAllReservations()
            FBDataService.instance.observeReservationsChangedForUser(FBDataService.instance.currentUser?.uid)
            FBDataService.instance.observeReservationsAddedForUser(FBDataService.instance.currentUser?.uid)
            FBDataService.instance.observeReservationsDeletedForUser(FBDataService.instance.currentUser?.uid)
            self.refreshControl.endRefreshing()
        }
    }
    

    func onReservationsRecieved(){
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = EMPTY_DATA_WELCOME
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = EMPTY_RESERVATION_DATA_SET_BUSINESS
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reservation = FBDataService.instance.allReservations[ FBDataService.instance.allReservationIDS[(indexPath as NSIndexPath).row] ]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessReservationCell") as? BusinessReservationCell{
            
            cell.configureCell(reservation!)
            
            return cell
        }else {
            
            let cell = BusinessReservationCell()
            cell.configureCell(reservation!)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FBDataService.instance.allReservations.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) //So 
        
        selectedReservation = FBDataService.instance.allReservations[ FBDataService.instance.allReservationIDS[(indexPath as NSIndexPath).row] ]
        
        showAlertDialog()
        
    }
    
    func showDeleteConfirmationAlertDialog(){
        
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "Delete Reservation", message: "Are you sure you want to delete this reservation?", preferredStyle: .alert)
        
        // Initialize Actions
        let deleteAction = UIAlertAction(title: "Yes, Delete", style: .default) { (action) -> Void in
           FBDataService.instance.removeReservationForUser(self.selectedReservation.uuid, businessID: self.selectedReservation.businessID, customerID: self.selectedReservation.leaderID, businessName: self.selectedReservation.businessName)
        }
        
        let noAction = UIAlertAction(title: "No, Don't Delete", style: .default) { (action) -> Void in
    
        }
       
        
        // Add Actions
        alertController.addAction(deleteAction)
        alertController.addAction(noAction)
        
        // Present Alert Controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func showAlertDialog(){
        
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "Change Reservation", message: "Do you want to change this reservation for \(selectedReservation.customerName)?", preferredStyle: .alert)
        
        // Initialize Actions
        let changeAction = UIAlertAction(title: "Yes, Change", style: .default) { (action) -> Void in
            self.performSegue(withIdentifier: "editReservation", sender: nil)
        }
        
        let deleteAction = UIAlertAction(title: "Yes, Delete", style: .default) { (action) -> Void in
           self.showDeleteConfirmationAlertDialog()
        }
        
        let noAction = UIAlertAction(title: "No", style: .default) { (action) -> Void in
        }
        
        // Add Actions
        alertController.addAction(changeAction)
        alertController.addAction(deleteAction)
        alertController.addAction(noAction)

        // Present Alert Controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //Spinning indicator when loading request
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editReservation" {
            if let resVC = segue.destination as? NewReservationVC{
                resVC.existingReservation = self.selectedReservation
                resVC.isExistingReservation = true
            }
        }
        
    }
    
}
