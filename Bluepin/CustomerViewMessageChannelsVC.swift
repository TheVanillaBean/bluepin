//
//  CustomerMessages.swift
//  bluepin
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseMessaging

class CustomerViewMessageChannelsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    
    @IBOutlet weak var tableView: UITableView!
    
    var lastMessage: Message!
        
    var castedUser: NewUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        let titleView = UIImageView(image: UIImage(named: "Nav_Img"))
        self.tabBarController?.navigationItem.titleView = titleView
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        
        castUser()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CustomerViewMessageChannelsVC.onChannelsRetrieved), name: NSNotification.Name(rawValue: "channelRetrieved"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func onChannelsRetrieved(){
        self.tableView.reloadData()
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = EMPTY_DATA_WELCOME
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = EMPTY_MESSAGES_DATA_SET_CUSTOMER
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func castUser(){
        
        castedUser = NewUser()
        castedUser.castUser((FBDataService.instance.currentUser?.uid)!) { (errMsg) in
            let userID = FBDataService.instance.currentUser?.uid
            
            if FBDataService.instance.channelChangedHandler == nil{
                FBDataService.instance.observeChannelsAddedForUser(userID)
                FBDataService.instance.observeChannelsChangedForUser(userID)
            }
        }
    }
    
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let channel = FBDataService.instance.allLastMessages[ FBDataService.instance.allChannelNames[(indexPath as NSIndexPath).row] ]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerChannelsCell") as? CustomerMessageChannelsCell{
            
            cell.configureCell(channel!)
            
            return cell
        }else {
            
            let cell = CustomerMessageChannelsCell()
            cell.configureCell(channel!)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FBDataService.instance.allLastMessages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    
        lastMessage = FBDataService.instance.allLastMessages[ FBDataService.instance.allChannelNames[(indexPath as NSIndexPath).row] ]
        performSegue(withIdentifier: "ViewMessageThreadFromCustomer", sender: nil)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navVc = segue.destination as! UINavigationController
        let messageVC = navVc.viewControllers.first as! ViewMessageThreadVC

        messageVC.mainChannelName = lastMessage.channelName
        messageVC.currentUserID = castedUser.uuid
        messageVC.currentUser = self.castedUser
        
        if castedUser.uuid == lastMessage.senderUID{
          
            messageVC.senderId =  lastMessage.senderUID // 3
            messageVC.senderDisplayName = lastMessage.senderUserObj.fullName // 4
            messageVC.otherUserName = lastMessage.recipientUserObj.businessName
            messageVC.otherUserID = lastMessage.recipientUID
            messageVC.otherUserProfilePictureLocation = lastMessage.recipientUserObj.userProfilePicLocation
            
            
        }else{ 
     
            messageVC.senderId =  lastMessage.recipientUID // 3
            messageVC.senderDisplayName = lastMessage.recipientUserObj.fullName // 4
            messageVC.otherUserName = lastMessage.senderUserObj.businessName
            messageVC.otherUserID = lastMessage.senderUID
            messageVC.otherUserProfilePictureLocation = lastMessage.senderUserObj.userProfilePicLocation
            
        }


    }
    
    
}
