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
import FirebaseStorage
import FirebaseAuth

class CustomerProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var userProfileImg: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var loadingPicLbl: UILabel!
    
    let castedUser = NewUser() //Used for Global Casting Purposes
    
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
        
        castUser()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomerProfileVC.onUploadProgressChanged), name: "uploadProgressFB", object: nil)
        
    }
  
    
    func castUser(){
        //Casting
        castedUser.castUser((FBDataService.instance.currentUser?.uid)!) { (errMsg) in
            print("Alex: \((FBDataService.instance.currentUser?.uid)!)")
                self.loadCustomerProfileInfo()
        }
    }
    
    func onUploadProgressChanged(){
        self.loadingPicLbl.text = "\(FBDataService.instance.uploadProgress.roundToPlaces(1))%"
    }
    
    func loadProfilePic(){
        
        let ref = FIRStorage.storage().referenceForURL(castedUser.userProfilePicLocation)
        ref.dataWithMaxSize(20 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("JESS: Unable to download image from Firebase storage")
                print(error)
                let placeholderImage = UIImage(named: "Placeholder")!
                self.userProfileImg.image = placeholderImage
            } else {
                print("JESS: Image downloaded from Firebase storage")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.userProfileImg.image = img
                    }
                }
            }
        })
        
        print(castedUser.userProfilePicLocation)

        
    }
    
    func loadCustomerProfileInfo(){
  
        loadProfilePic()
        print("Alex: \(castedUser.fullName)")

        profileTextItems = [
            castedUser.fullName,
            castedUser.email,
            "Change Password" //Because users password should not be displayed
        ]
        
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let textItem = profileTextItems[indexPath.row]
        let iconItem = profileIconItems[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("CustomerProfileCell") as? CustomerProfileCell {
            print(iconItem)
            cell.configureCell(iconItem, text: textItem)
            
            return cell
            
        }else{
            
            let cell = CustomerProfileCell()
            
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
                                
                FBDataService.instance.updateUser(self.castedUser.uuid, propertes: properties, onComplete: { (errMsg, data) in
                    self.castUser()
                })
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
                properties.updateValue(textInput, forKey: FULL_NAME)
            case 1:
                properties.updateValue(textInput, forKey: EMAIL)
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
    
    func onFileUploaded(url: NSURL){
     
        let properties = [PROFILE_PIC_LOCATION: url.absoluteString]
                
        FBDataService.instance.updateUser(castedUser.uuid, propertes: properties) { (errMsg, data) in
            if errMsg == nil{
                self.castUser()
            }
        }
    }

    func showPasswordAlertDialog(){
        
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "New Password", message: "Are you sure you want a new password?", preferredStyle: .Alert)
        
        // Initialize Actions
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
          //  DataService.instance.requestUserPasswordChange(self.currentBackendlessUser.email, uiVIew: self.view)
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
                
                let imageData: NSData = UIImageJPEGRepresentation(image!.correctlyOrientedImage(), 0.5)!
                
                let filePath: FIRStorageReference = FBDataService.instance.profilePicsStorageRef.child("\(self!.castedUser.uuid).png")
                
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpg"
                
                self!.loadingPicLbl.text = "Loading..."
                
                FBDataService.instance.uploadFile(filePath, data: imageData, metadata: metadata, onComplete: { (errMsg, data) in
                    if errMsg != nil {
                        Messages.showAlertDialog("Upload Issue", msgAlert: errMsg)
                    }else{
                        self!.loadingPicLbl.text = ""
                        self!.onFileUploaded((data?.downloadURL())!)
                    }
                })
                
            }
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(cameraViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func logoutBtnPressed(sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
        self.performSegueWithIdentifier("customerLoggedOut", sender: nil)

    }
    
    
}
