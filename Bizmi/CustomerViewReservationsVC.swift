//
//  CustomerViewReservationsVC.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class CustomerViewReservationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    
//    let user: User = User()
//    
//    var selectedReservation: Reservation!
//    
//    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        let currentUser = appDelegate.backendless.userService.currentUser
//        user.populateUserData(currentUser)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(CustomerViewReservationsVC.onReservationsRecieved), name: NSNotification.Name(rawValue: "findCustomerReservations"), object: nil)
//        
//       NotificationCenter.default.addObserver(self, selector: #selector(CustomerViewReservationsVC.onReservationUpdated), name: NSNotification.Name(rawValue: "updateCustomerReservation"), object: nil)
//       
          showActivityIndicator()
//        DataService.instance.findCustomerReservations(user.userObjectID, status: DataService.statusType.PENDING.rawValue)
//        
//        refreshControl = UIRefreshControl()
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        refreshControl.addTarget(self, action: #selector(CustomerViewReservationsVC.refresh(_:)), for: UIControlEvents.valueChanged)
//        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
//    func refresh(_ sender:AnyObject) {
//        showActivityIndicator()
//        DataService.instance.clearCustomerReservation()
//        DataService.instance.findCustomerReservations(user.userObjectID, status: DataService.statusType.PENDING.rawValue)
//    }
//    
//    func onReservationsRecieved(){
//        
//        activityIndicator.stopAnimating()
//        
//        tableView.reloadData()
//        
//        refreshControl.endRefreshing()
//    }
//    
//    func onReservationUpdated(){
//        
//        activityIndicator.stopAnimating()
//        
//        tableView.reloadData()
//    }
    
    //Setup Tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let reservation = DataService.instance.allCustomerReservations[(indexPath as NSIndexPath).row]
//        
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCell") as? CustomerReservationCell{
//            
//            cell.configureCell(reservation)
//            
//            return cell
//        }else {
//            
//            let cell = CustomerReservationCell()
//            cell.configureCell(reservation)
//            
//            return cell
//        }
        return CustomerReservationCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return DataService.instance.allCustomerReservations.count
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        tableView.deselectRow(at: indexPath, animated: true) //So tableview row doesn't stay highlighted
//        
//        selectedReservation = DataService.instance.allCustomerReservations[(indexPath as NSIndexPath).row]
//        
//        if selectedReservation.Status == DataService.statusType.PENDING.rawValue{
//            showAlertDialog()
//        }
    }
//    
//    func showAlertDialog(){
//        
//        // Initialize Alert Controller
//        let alertController = UIAlertController(title: "New Reservation", message: "Do you want to accept this pending reservation from \(selectedReservation.BusinessName!)?", preferredStyle: .alert)
//        
//        // Initialize Actions
//        let yesAction = UIAlertAction(title: "Accept", style: .default) { (action) -> Void in
//            DataService.instance.updateReservation(self.selectedReservation, status: "Active")
//        }
//        
//        let noAction = UIAlertAction(title: "Decline", style: .default) { (action) -> Void in
//            DataService.instance.updateReservation(self.selectedReservation, status: "Declined")
//        }
//        
//        // Add Actions
//        alertController.addAction(yesAction)
//        alertController.addAction(noAction)
//        
//        // Present Alert Controller
//        self.present(alertController, animated: true, completion:{
//            alertController.view.superview?.isUserInteractionEnabled = true
//            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
//            })
//    }
//    
//    func alertControllerBackgroundTapped(){
//        self.dismiss(animated: true, completion: nil)
//    }
    
    //Spinning indicator when loading request
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
}
