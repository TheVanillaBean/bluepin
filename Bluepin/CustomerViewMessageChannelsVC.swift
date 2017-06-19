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

    private lazy var channelsRef: FIRDatabaseReference = FBDataService.instance.userChannelsRef
    private var channelRefAddedHandle: FIRDatabaseHandle?
    private var channelRefChangedHandle: FIRDatabaseHandle?
    
    private var channelMessages: [String: [String: AnyObject]] = [:]
    private var channels: [Channel] = []
    
    var currentUser: NewUser!
    var recipientUser: NewUser!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        setCurrentUser()
        
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
    
    deinit {
        if let refHandle = channelRefAddedHandle {
            channelsRef.child(currentUser.uuid).removeObserver(withHandle: refHandle)
        }
        if let refHandle = channelRefChangedHandle {
            channelsRef.child(currentUser.uuid).removeObserver(withHandle: refHandle)
        }
    }
    
    func setCurrentUser(){
        
        if let currentUserID = FBDataService.instance.currentUser?.uid{
            currentUser = NewUser()
            currentUser.castUser(currentUserID) { (errMsg) in
                self.observeChannelsAdded()
                self.observeChannelsChanged()
            }
        }
    }

    func showActivityIndicator() {
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.startAnimating()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let channel = channelMessages[channels[indexPath.item].channelID]
        
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
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let channel = channelMessages[channels[indexPath.item].channelID] {
            if channel[MESSAGE_SENDERID] as? String == currentUser.uuid {
                recipientUser = NewUser()
                recipientUser.castUser(channel[MESSAGE_RECIPIENTID] as! String) { (errMsg) in
                    self.performSegue(withIdentifier: "ViewMessageThreadFromCustomer", sender: channel)
                }
            }else {
                recipientUser = NewUser()
                recipientUser.castUser(channel[MESSAGE_SENDERID] as! String) { (errMsg) in
                    self.performSegue(withIdentifier: "ViewMessageThreadFromCustomer", sender: channel)
                }
            }
        }
     
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navVc = segue.destination as! UINavigationController
        let messageVC = navVc.viewControllers.first as! ViewMessageThreadVC
        
        if let channel = sender as? [String: AnyObject], let channelName = channel[MESSAGE_CHANNEL_NAME] as? String{
            
            messageVC.senderDisplayName = self.currentUser.fullName
            messageVC.senderId = currentUser.uuid
            messageVC.currentUser = self.currentUser
            messageVC.mainChannelName = channelName
            messageVC.recipientUser = recipientUser
            messageVC.channelRef = FBDataService.instance.channelsRef.child(channelName)
    
        }

    }
    
    func observeChannelsAdded(){
        
        if let currentUserID = FBDataService.instance.currentUser?.uid{
            channelRefAddedHandle = channelsRef.child(currentUserID).queryLimited(toLast: 30).queryOrdered(byChild: SORT_TIMESTAMP).observe(.childAdded, with: { (snapshot) in

                self.showActivityIndicator()

                let lastMessage = snapshot.value as! [String : AnyObject]
                
                if let channelID = lastMessage[MESSAGE_CHANNEL_NAME] as! String!, let type = lastMessage[MESSAGE_TYPE] as! String!, let senderID = lastMessage[MESSAGE_SENDERID] as! String!, let recipientID = lastMessage[MESSAGE_RECIPIENTID] as! String!, let stamp = lastMessage[MESSAGE_TIMESTAMP] as! Double!, let text = lastMessage[MESSAGE_TEXT] as! String!, text.characters.count > 0 {
                    
                    if type == MESSAGE_TEXT_TYPE {
                        
                        let date = Date(timeIntervalSince1970: stamp)
                        let messageItem: Dictionary<String, AnyObject> = [
                            MESSAGE_CHANNEL_NAME: channelID as AnyObject,
                            MESSAGE_TYPE: MESSAGE_TEXT_TYPE as AnyObject,
                            MESSAGE_TEXT: text as AnyObject,
                            MESSAGE_SENDERID: senderID as AnyObject,
                            MESSAGE_RECIPIENTID: recipientID as AnyObject,
                            MESSAGE_TIMESTAMP: date as AnyObject,
                        ]
                        
                        self.channels.append(Channel(channelID: channelID, date: date as Date))
                        self.channelMessages[channelID] = messageItem
                        self.tableView.reloadData()
                        
                    }
                    
                } else {
                    print("Error! Could not decode message data")
                }
                
                
                self.activityIndicator.stopAnimating()
                
            }) 
        }
        
    }
    
    func observeChannelsChanged(){
        
        if let currentUserID = FBDataService.instance.currentUser?.uid{
            channelRefChangedHandle = channelsRef.child(currentUserID).queryLimited(toLast: 30).queryOrdered(byChild: SORT_TIMESTAMP).observe(.childChanged, with: { (snapshot) in
                
                self.showActivityIndicator()
                
                let lastMessage = snapshot.value as! [String : AnyObject]
                
                if let channelID = lastMessage[MESSAGE_CHANNEL_NAME] as! String!, let type = lastMessage[MESSAGE_TYPE] as! String!, let senderID = lastMessage[MESSAGE_SENDERID] as! String!, let recipientID = lastMessage[MESSAGE_RECIPIENTID] as! String!, let stamp = lastMessage[MESSAGE_TIMESTAMP] as! Double!, let text = lastMessage[MESSAGE_TEXT] as! String!, text.characters.count > 0 {
                    
                    if type == MESSAGE_TEXT_TYPE {
                        
                        let date = Date(timeIntervalSince1970: stamp)
                        let messageItem: Dictionary<String, AnyObject> = [
                            MESSAGE_CHANNEL_NAME: channelID as AnyObject,
                            MESSAGE_TYPE: MESSAGE_TEXT_TYPE as AnyObject,
                            MESSAGE_TEXT: text as AnyObject,
                            MESSAGE_SENDERID: senderID as AnyObject,
                            MESSAGE_RECIPIENTID: recipientID as AnyObject,
                            MESSAGE_TIMESTAMP: date as AnyObject,
                            ]
                        
                        self.channels = self.channels.filter {$0.channelID != channelID}
                        self.channels.append(Channel(channelID: channelID, date: date as Date))
                        self.channelMessages[channelID] = messageItem
                        self.channels.sort { $0.date > $1.date }
                        self.tableView.reloadData()
                        
                    }
                    
                } else {
                    print("Error! Could not decode message data")
                }
                
                self.activityIndicator.stopAnimating()
                
            })
        }
        
    }
    
    
}
