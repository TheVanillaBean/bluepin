//
//  CustomerViewReservationsVC.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class CustomerViewReservationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate    {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    
    var selectedReservation: Reservation!
    
    var currentUser: NewUser!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(BusinessViewReservationsVC.onReservationsRecieved), name: NSNotification.Name(rawValue: "reservationRetrieved"), object: nil)
        
        currentUser = NewUser()
        currentUser.castUser((FBDataService.instance.currentUser?.uid)!) { (errMsg) in
            
            if errMsg == nil{
                self.showActivityIndicator()
                FBDataService.instance.observeReservationsChangedForUser(FBDataService.instance.currentUser?.uid)
                FBDataService.instance.observeReservationsAddedForUser(FBDataService.instance.currentUser?.uid)
                FBDataService.instance.observeReservationsDeletedForUser(FBDataService.instance.currentUser?.uid)
            }
            
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
        let str = EMPTY_RESERVATION_DATA_SET_CUSTOMER
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    //Setup Tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reservation = FBDataService.instance.allReservations[ FBDataService.instance.allReservationIDS[(indexPath as NSIndexPath).row] ]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCell") as? CustomerReservationCell{
            
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
            
           self.showAlertDialog()
            
        }
    }
    
    func showAlertDialog(){
        
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "New Reservation", message: "Do you want to accept this pending reservation from \(selectedReservation.businessName)?", preferredStyle: .alert)
        
        let notification = FBDataService.instance.notificationsRef.childByAutoId()
        
        var notificationRequest: Dictionary<String, AnyObject> = [String: AnyObject]()
        
        // Initialize Actions
        let yesAction = UIAlertAction(title: "Accept", style: .default) { (action) -> Void in
            FBDataService.instance.updateReservationForUser(self.selectedReservation.uuid, status: ACTIVE_STATUS, businessID: self.selectedReservation.businessID, customerID: self.selectedReservation.leaderID)
            
            notificationRequest = [REQUEST_ID: notification.key as AnyObject, REQUEST_SENDER_ID: self.currentUser.uuid as AnyObject, REQUEST_RECIPIENT_ID: self.selectedReservation.businessID as AnyObject, REQUEST_MESSAGE: ACCEPTED_RESERVATION_NOTIF as AnyObject, REQUEST_SENDER_NAME: self.currentUser.fullName as AnyObject]

            print("new request customer")
            notification.setValue(notificationRequest)
        }
        
        let noAction = UIAlertAction(title: "Decline", style: .default) { (action) -> Void in
            FBDataService.instance.updateReservationForUser(self.selectedReservation.uuid, status: DECLINED_STATUS, businessID: self.selectedReservation.businessID, customerID: self.selectedReservation.leaderID)
            
             notificationRequest = [REQUEST_ID: notification.key as AnyObject, REQUEST_SENDER_ID: self.currentUser.uuid as AnyObject, REQUEST_RECIPIENT_ID: self.selectedReservation.businessID as AnyObject, REQUEST_MESSAGE: DECLINED_RESERVATION_NOTIF as AnyObject, REQUEST_SENDER_NAME: self.currentUser.fullName as AnyObject]
            
            print("new request customer")
            notification.setValue(notificationRequest)
            
        }
        
        
        // Add Actions
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        // Present Alert Controller
        self.present(alertController, animated: true, completion:{
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            })
    }
    
    func alertControllerBackgroundTapped(){
        self.dismiss(animated: true, completion: nil)
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
