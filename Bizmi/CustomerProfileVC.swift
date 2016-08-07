//
//  CustomerProfileVC.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import ALCameraViewController
import AlamofireImage
import PhoneNumberKit

class CustomerProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var userProfileImg: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var loadingPicLbl: UILabel!

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var currentBackendlessUser: BackendlessUser!
    
    let user = User() //Used for Global Casting Purposes
    
    var tField: UITextField! //Used for alertView when TableView row is tapped
    
    var alertPlaceHolder: String! //PlaceHolder for text input in alertView
    
    var profileTextItems: [String] = [] // fill in tableView with currentUser profile properties
    
    let profileIconItems: [UIImage] = [ //For Tableview
        UIImage(named: "Profile_Blue")!,
        UIImage(named: "Email_Blue")!,
        UIImage(named: "Password_Blue")!
    ]
    
    var alertTitles: [String] = [ //For tableview
        "Edit Full Name",
        "Edit Email",
        "Change Password"
    ]
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        subscribeToNofications()
        editUserProfileImageView()
        
    }
    
    func subscribeToNofications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BusinessProfileVC.onCurrentUserUpdated), name: "userUpdated", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BusinessProfileVC.onFileUploaded), name: "fileUploaded", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BusinessProfileVC.onUserLoggedOut), name: "userLoggedOut", object: nil)
    }
    
    func editUserProfileImageView(){
        self.userProfileImg.layer.cornerRadius = 10.0
        self.userProfileImg.clipsToBounds = true;
        self.userProfileImg.layer.borderWidth = 3.0
        self.userProfileImg.layer.borderColor = ACCENT_COLOR.CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        loadCustomerProfileInfo()
        
    }
    
    func loadCustomerProfileInfo(){
        
        //Casting
        currentBackendlessUser = self.appDelegate.backendless.userService.currentUser
        user.populateUserData(currentBackendlessUser)
        
        let URL = NSURL(string: "\(user.userProfilePicLocation)")!
        let placeholderImage = UIImage(named: "Placeholder")!
        
        userProfileImg.af_setImageWithURL(URL, placeholderImage: placeholderImage)
        
        print(user.userProfilePicLocation)
        
        profileTextItems = [
            user.fullName,
            user.userEmail,
            "Change Password" //Because users password should not be displayed
        ]
    }
    
    func clearImageFromCache(URL: NSURL) {
        let URLRequest = NSURLRequest(URL: URL)
        
        let imageDownloader = UIImageView.af_sharedImageDownloader
        
        // Clear the URLRequest from the in-memory cache
        imageDownloader.imageCache?.removeImageForRequest(URLRequest, withAdditionalIdentifier: nil)
        
        // Clear the URLRequest from the on-disk cache
        imageDownloader.sessionManager.session.configuration.URLCache?.removeCachedResponseForRequest(URLRequest)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let textItem = profileTextItems[indexPath.row]
        let iconItem = profileIconItems[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("BusinessProfileCell") as? BusinessProfileCell {
            
            cell.configureCell(iconItem, text: textItem)
            
            return cell
            
        }else{
            
            let cell = BusinessProfileCell()
            
            cell.configureCell(iconItem, text: textItem)
            
            return cell
            
        }
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true) //So tableview row doesn't stay highlighted
        
        if indexPath.row <= 1 { //Password change requires different functionality
            
            let alert = UIAlertController(title: alertTitles[indexPath.row], message: "", preferredStyle: .Alert)
            
            alertPlaceHolder = profileTextItems[indexPath.row]
            
            alert.addTextFieldWithConfigurationHandler(configurationTextField)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:handleCancel))
            alert.addAction(UIAlertAction(title: "Done", style: .Default, handler:{ (UIAlertAction) in
                
                let properties = self.updateProperties(indexPath)
                                
                DataService.instance.updateUser(properties)
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else {
            
            print("Change Password")
            self.showPasswordAlertDialog()
            
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileTextItems.count
    }
    
    func configurationTextField(textField: UITextField!){
        print("generating the TextField")
        textField.text = alertPlaceHolder
        tField = textField
        
    }
    
    func handleCancel(alertView: UIAlertAction!){
        print("Cancelled !!")
    }
 
    func updateProperties(indexPath: NSIndexPath) -> [String: AnyObject]{
        
        var properties = [String: AnyObject]()
        
        if let textInput = self.tField.text {
            
            switch indexPath.row {
            case 0:
                properties.updateValue(textInput, forKey: "fullName")
            case 1:
                properties.updateValue(textInput, forKey: "email")
            default:
                break
            }
        }
        
        return properties
        
    }
 
    func onCurrentUserUpdated(){
        print("User Updated!")
        
        loadCustomerProfileInfo()
        self.loadingPicLbl.text = ""
        tableView.reloadData()
        
    }
    
    func onFileUploaded(notification: NSNotification){
        
        if let fileDict = notification.object as? [String:AnyObject] {
            if let file = fileDict["uploadedFile"] as? BackendlessFile {
                
                let properties = [
                    "userProfilePicLocation": file.fileURL
                ]
                
                let URL = NSURL(string: "\(user.userProfilePicLocation)")!
                clearImageFromCache(URL)
                
                DataService.instance.updateUser(properties) //Will call onCurrentUserUpdates when finished
                
            }
            
        }
        
    }
    
    func onUserLoggedOut(){
        self.performSegueWithIdentifier("customerLoggedOut", sender: nil)
    }
    
    
    func showPasswordAlertDialog(){
        
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "New Password", message: "Are you sure you want a new password?", preferredStyle: .Alert)
        
        // Initialize Actions
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            DataService.instance.requestUserPasswordChange(self.currentBackendlessUser.email, uiVIew: self.view)
        }
        
        let noAction = UIAlertAction(title: "No", style: .Default) { (action) -> Void in
        }
        
        // Add Actions
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        // Present Alert Controller
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func pencilBtnPressed(sender: AnyObject) {
        
        let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { [weak self] image, asset in
            
            if image != nil {
                
                self?.userProfileImg.image = image?.correctlyOrientedImage()
                
                let imageData: NSData = UIImagePNGRepresentation(image!.correctlyOrientedImage())!
                
                let filePath = "profilePics/\(self!.currentBackendlessUser.objectId)"
                
                self!.loadingPicLbl.text = "Loading..."
                
                DataService.instance.uploadFile(filePath, content: imageData, overwrite: true)
                
            }
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(cameraViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func logoutBtnPressed(sender: AnyObject) {
        DataService.instance.logoutUser()
    }
    
    
}
