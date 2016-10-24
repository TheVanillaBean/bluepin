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
        
        FBDataService.instance.observeReservationsChangedForUser(FBDataService.instance.currentUser?.uid)
        FBDataService.instance.observeReservationsAddedForUser(FBDataService.instance.currentUser?.uid)
        FBDataService.instance.observeReservationsDeletedForUser(FBDataService.instance.currentUser?.uid)

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
        
        if selectedReservation.status == PENDING_STATUS{
            showAlertDialog()
        }
        
    }
    
    
    func showAlertDialog(){
        
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "Remove Reservation", message: "Do you want to delete this reservation for \(selectedReservation.customerName)?", preferredStyle: .alert)
        
        // Initialize Actions
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
            
            FBDataService.instance.removeReservationForUser(self.selectedReservation.uuid, businessID: self.selectedReservation.businessID, customerID: self.selectedReservation.leaderID)
            
        }
        
        let noAction = UIAlertAction(title: "No", style: .default) { (action) -> Void in
        }
        
        // Add Actions
        alertController.addAction(yesAction)
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

    
}
