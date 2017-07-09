//
//  CustomerProfileVC.swift
//  bluepin
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
import FirebaseMessaging

class CustomerProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var userProfileImg: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var loadingPicLbl: UILabel!
    
    let castedUser = NewUser()
    
    var tField: UITextField!
    
    var alertPlaceHolder: String!
    
    var profileTextItems: [String] = []
    
    let profileIconItems: [UIImage] = [
        UIImage(named: "Profile_Blue")!,
        UIImage(named: "Email_Blue")!,
        UIImage(named: "Password_Blue")!,
        UIImage(named: "Contact_Support")!

    ]
    
    var alertTitles: [String] = [ 
        "Edit Full Name",
        "Edit Email",
        "Change Password",
        "Contact Bluepin Support"
    ]
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        castUser()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CustomerProfileVC.onUploadProgressChanged), name: NSNotification.Name(rawValue: "uploadProgressFB"), object: nil)
        
    }
  
    
    func castUser(){
        castedUser.castUser((FBDataService.instance.currentUser?.uid)!) { (errMsg) in
            self.loadCustomerProfileInfo()
        }
    }
    
    func onUploadProgressChanged(){
        self.loadingPicLbl.text = "\(FBDataService.instance.uploadProgress.roundTo(places: 1))%"
    }
    
    func loadProfilePic(){
       
        if castedUser.userProfilePicLocation != "" {
            
            let ref = Storage.storage().reference(forURL: castedUser.userProfilePicLocation)
            ref.getData(maxSize: 20 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    let placeholderImage = UIImage(named: "Placeholder")!
                    self.userProfileImg.image = placeholderImage
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.userProfileImg.image = img
                        }
                    }
                }
            })
        }
    }
    
    func loadCustomerProfileInfo(){
  
        loadProfilePic()

        profileTextItems = [
            castedUser.fullName,
            castedUser.email,
            "Change Password",
            "Contact Bluepin Support"
        ]
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let textItem = profileTextItems[(indexPath as NSIndexPath).row]
        let iconItem = profileIconItems[(indexPath as NSIndexPath).row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerProfileCell") as? CustomerProfileCell {
            
            print(iconItem)
            cell.configureCell(iconItem, text: textItem)
            
            return cell
            
        }else{
            
            let cell = CustomerProfileCell()
            cell.configureCell(iconItem, text: textItem)
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath as NSIndexPath).row < 2 {
            
            let alert = UIAlertController(title: alertTitles[(indexPath as NSIndexPath).row], message: "", preferredStyle: .alert)
            
            alertPlaceHolder = profileTextItems[(indexPath as NSIndexPath).row]
            
            alert.addTextField(configurationHandler: configurationTextField)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:handleCancel))
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler:{ (UIAlertAction) in
                
                let properties = self.updateProperties(indexPath)
                                
                FBDataService.instance.updateUser(self.castedUser.uuid, propertes: properties, onComplete: { (errMsg, data) in
                    self.castUser()
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }else if ( (indexPath as NSIndexPath).row == 3 ){
            
            let user = HotlineUser.sharedInstance();
            
            user?.name = castedUser.fullName
            user?.email = castedUser.email
            user?.phoneNumber = castedUser.phoneNumber
            user?.externalID = castedUser.uuid;
            
            Hotline.sharedInstance().update(user)
            
            Hotline.sharedInstance().showConversations(self)
        }else {
            self.showPasswordAlertDialog()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileTextItems.count
    }
    
    func configurationTextField(_ textField: UITextField!){
        textField.text = alertPlaceHolder
        tField = textField
        
    }
    
    func handleCancel(_ alertView: UIAlertAction!){
    }
 
    func updateProperties(_ indexPath: IndexPath) -> [String: AnyObject]{
        
        var properties = [String: AnyObject]()
        
        if let textInput = self.tField.text {
            
            switch (indexPath as NSIndexPath).row {
            case 0:
                properties.updateValue(textInput as AnyObject, forKey: FULL_NAME)
            case 1:
                FBDataService.instance.resetEmail(textInput as String, onComplete: { (errMsg, data) in
                    if errMsg != nil{
                        Messages.showAlertDialog("Email Error", msgAlert: errMsg)
                    }else{
                        properties.updateValue(textInput as AnyObject, forKey: EMAIL)
                        FBDataService.instance.updateUser(self.castedUser.uuid, propertes: properties, onComplete: { (errMsg, data) in
                            self.castUser()
                        })
                    }
                })
            default:
                break
            }
        }
        
        return properties
        
    }
    
    func onFileUploaded(_ url: URL){
     
        let properties = [PROFILE_PIC_LOCATION: url.absoluteString]
                
        FBDataService.instance.updateUser(castedUser.uuid, propertes: properties as Dictionary<String, AnyObject>) { (errMsg, data) in
            if errMsg == nil{
                self.castUser()
            }
        }
    }

    func showPasswordAlertDialog(){
        
        let alertController = UIAlertController(title: "New Password", message: "Are you sure you want a new password?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
            
            FBDataService.instance.resetPassword(self.castedUser.email, onComplete: { (errMsg, data) in
                
                if errMsg == nil{
                    Messages.showAlertDialog("Email Sent", msgAlert: "An email has been sent to \(self.castedUser.email) with a reset link.")
                }else{
                    Messages.showAlertDialog("Error", msgAlert: errMsg)
                }
            })
            
        }
        
        let noAction = UIAlertAction(title: "No", style: .default) { (action) -> Void in
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func pencilBtnPressed(_ sender: AnyObject) {
        
        let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { [weak self] image, asset in
            
            if image != nil {
                
                self?.userProfileImg.image = image?.correctlyOrientedImage()
                
                let imageData: Data = UIImageJPEGRepresentation(image!.correctlyOrientedImage(), 0.5)!
                
                let filePath: StorageReference = FBDataService.instance.profilePicsStorageRef.child("\(self!.castedUser.uuid).png")
                
                let metadata = StorageMetadata()
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
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func logoutBtnPressed(_ sender: AnyObject) {
        
        let userID = FBDataService.instance.currentUser?.uid
        FBDataService.instance.removeObservers(uuid: userID!)
        Messaging.messaging().unsubscribe(fromTopic: "/topics/user_\(userID!)")
        FBDataService.instance.clearAllFollowers()
        FBDataService.instance.clearAllReservations()
        FBDataService.instance.clearAllBusinesses()

        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "customerLoggedOut", sender: nil)

    }
    
    
}
