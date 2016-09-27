//
//  BusinessProfileVC.swift
//  Bizmi
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import ALCameraViewController
import AlamofireImage
import PhoneNumberKit

class BusinessProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userProfileImg: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loadingPicLbl: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

 //   var currentBackendlessUser: BackendlessUser!
    
//    let user = User() //Used for Global Casting Purposes
    
    var tField: UITextField! //Used for alertView when TableView row is tapped
    
    var keyboardType: UIKeyboardType! //alertView text input keyboard type

    var alertPlaceHolder: String! //PlaceHolder for text input in alertView
    
    var profileTextItems: [String] = [] // fill in tableView with currentUser profile properties
    
    let profileIconItems: [UIImage] = [
        UIImage(named: "Business_Name_Blue")!,
        UIImage(named: "Business_Blue")!,
        UIImage(named: "Hours_Blue")!,
        UIImage(named: "Business_Desc_Blue")!,
        UIImage(named: "Phone_Blue")!,
        UIImage(named: "Website_Blue")!,
        UIImage(named: "Email_Blue")!,
        UIImage(named: "Marker")!,
        UIImage(named: "Password_Blue")!
    ]

    var alertTitles: [String] = [
        "Edit Business Name",
        "Edit Business Type",
        "Edit Business Hours",
        "Edit Business Description",
        "Edit Phone Number",
        "Edit Business Website",
        "Edit Business Email",
        "Change Password"
    ]
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self

      //  subscribeToNofications()
        
    }
    
//    func subscribeToNofications(){
//        NotificationCenter.default.addObserver(self, selector: #selector(BusinessProfileVC.onCurrentUserUpdated), name: NSNotification.Name(rawValue: "userUpdated"), object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(BusinessProfileVC.onFileUploaded), name: NSNotification.Name(rawValue: "fileUploaded"), object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(BusinessProfileVC.onUserLoggedOut), name: NSNotification.Name(rawValue: "userLoggedOut"), object: nil)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//    
//     //   loadBusinesssProfileInfo()
//        
//    }
    
    func loadBusinesssProfileInfo(){
        
//        //Casting
//        currentBackendlessUser = self.appDelegate.backendless.userService.currentUser
//        user.populateUserData(currentBackendlessUser)
//        
//       // let URL = URL(string: "\(user.userProfilePicLocation)")!
//        let placeholderImage = UIImage(named: "Placeholder")!
//        
//        userProfileImg.af_setImageWithURL(URL, placeholderImage: placeholderImage)
//        
//        print(user.userProfilePicLocation)
// 
//        profileTextItems = [
//            user.businessName,
//            user.businessType,
//            user.businessHours,
//            user.businessDesc,
//            user.phoneNumber,
//            user.businessWebsite,
//            user.userEmail,
//            "Change Location",
//            "Change Password", //Because users password should not be displayed
//        ]
    }
//    
//    func clearImageFromCache(_ URL: Foundation.URL) {
//        let URLRequest = Foundation.URLRequest(url: URL)
//        
//        let imageDownloader = UIImageView.af_sharedImageDownloader
//        
//        // Clear the URLRequest from the in-memory cache
//        imageDownloader.imageCache?.removeImageForRequest(URLRequest, withAdditionalIdentifier: nil)
//        
//        // Clear the URLRequest from the on-disk cache
//        imageDownloader.sessionManager.session.configuration.urlCache?.removeCachedResponse(for: URLRequest)
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let textItem = profileTextItems[(indexPath as NSIndexPath).row]
//        let iconItem = profileIconItems[(indexPath as NSIndexPath).row]
//        
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessProfileCell") as? BusinessProfileCell {
//            
//            cell.configureCell(iconItem, text: textItem)
//            
//            return cell
//            
//        }else{
//            
//            let cell = BusinessProfileCell()
//            
//            cell.configureCell(iconItem, text: textItem)
//            
//            return cell
//            
//        }
        
        return BusinessProfileCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        if (indexPath as NSIndexPath).row <= 6 {
//            
//            keyboardType = keyboardType(indexPath)
//        
//            let alert = UIAlertController(title: alertTitles[(indexPath as NSIndexPath).row], message: "", preferredStyle: .alert)
//            
//            alertPlaceHolder = profileTextItems[(indexPath as NSIndexPath).row]
//
//            alert.addTextField(configurationHandler: configurationTextField)
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:handleCancel))
//            alert.addAction(UIAlertAction(title: "Done", style: .default, handler:{ (UIAlertAction) in
//
//                let properties = self.updateProperties(indexPath)
//                
//                DataService.instance.updateUser(properties)
//            
//            }))
//            self.present(alert, animated: true, completion: nil)
//            
//        }else if (indexPath as NSIndexPath).row == 7 {
//        
//            performSegue(withIdentifier: "EditBusinessLocation", sender: nil)
//        
//        }else {
//            
//            print("Change Password")
//            self.showPasswordAlertDialog()
//            
//        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return profileTextItems.count
        return 0
    }
//    
//    func configurationTextField(_ textField: UITextField!){
//        print("generating the TextField")
//        textField.text = alertPlaceHolder
//        textField.keyboardType = keyboardType
//        tField = textField
//        
//    }
//    
//    func handleCancel(_ alertView: UIAlertAction!){
//        print("Cancelled !!")
//    }
//    
//    func keyboardType(_ indexPath: IndexPath) -> UIKeyboardType{
//    
//        if (indexPath as NSIndexPath).row == 4 { // Phone Number requires number pad
//            return UIKeyboardType.numberPad
//        }
//        
//        return UIKeyboardType.default
//        
//    }
//    
//    
//    func updateProperties(_ indexPath: IndexPath) -> [String: AnyObject]{
//        
//        var properties = [String: AnyObject]()
//        
//        if let textInput = self.tField.text {
//            
//            switch (indexPath as NSIndexPath).row {
//            case 0:
//                properties.updateValue(textInput as AnyObject, forKey: "businessName")
//            case 1:
//                properties.updateValue(textInput as AnyObject, forKey: "businessType")
//            case 2:
//                properties.updateValue(textInput as AnyObject, forKey: "businessHours")
//            case 3:
//                properties.updateValue(textInput as AnyObject, forKey: "businessDesc")
//            case 4:
//                properties.updateValue(formatPhoneNumber(textInput) as AnyObject, forKey: "phoneNumber")
//            case 5:
//                properties.updateValue(textInput as AnyObject, forKey: "businessWebsite")
//            case 6:
//                properties.updateValue(textInput as AnyObject, forKey: "email")
//            default:
//                break
//            }
//        }
//        
//        return properties
//        
//    }
//    
//    func formatPhoneNumber(_ rawPhoneNumber: String?) -> String {
//        
//        if let rawNumber = rawPhoneNumber{
//            
//            do {
//                let phoneNumber = try PhoneNumber(rawNumber: rawNumber, region: "US" )
//                return String(phoneNumber.toNational())
//            }
//            catch {
//                print("Generic parser error")
//            }
//            
//        }
//        
//        return user.phoneNumber //Doesnt update property if value is empty
//        
//    }
//    
//    func onCurrentUserUpdated(){
//        print("User Updated!")
//        
//        self.loadBusinesssProfileInfo()
//        self.loadingPicLbl.text = ""
//        tableView.reloadData()
//    }
//    
//    func onFileUploaded(_ notification: Notification){
//
//        if let fileDict = notification.object as? [String:AnyObject] {
//            if let file = fileDict["uploadedFile"] as? BackendlessFile {
//
//                let properties = [
//                    "userProfilePicLocation" : file.fileURL
//                ]
//                
//           //     let URL = URL(string: "\(user.userProfilePicLocation)")!
//                clearImageFromCache(URL)
//                
//                DataService.instance.updateUser(properties)
//
//            }
//            
//        }
//    
//    }
//    
//    func onUserLoggedOut(){
//        self.performSegue(withIdentifier: "businessLoggedOut", sender: nil)
//    }

//    
//    func showPasswordAlertDialog(){
//        
//        // Initialize Alert Controller
//        let alertController = UIAlertController(title: "New Password", message: "Are you sure you want a new password?", preferredStyle: .alert)
//        
//        // Initialize Actions
//        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
//            DataService.instance.requestUserPasswordChange(self.currentBackendlessUser.email, uiVIew: self.view)
//        }
//        
//        let noAction = UIAlertAction(title: "No", style: .default) { (action) -> Void in
//        }
//        
//        // Add Actions
//        alertController.addAction(yesAction)
//        alertController.addAction(noAction)
//        
//        // Present Alert Controller
//        self.present(alertController, animated: true, completion: nil)
//        
//    }
    
    
    @IBAction func pencilBtnPressed(_ sender: AnyObject) {
        
//        let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { [weak self] image, asset in
//            
//            if image != nil {
//            
//                    self?.userProfileImg.image = image?.correctlyOrientedImage()
//
//                    let imageData: Data = UIImagePNGRepresentation(image!.correctlyOrientedImage())!
//                
//                    let filePath = "profilePics/\(self!.currentBackendlessUser.objectId)"
//                
//                    self!.loadingPicLbl.text = "Loading..."
//
//                    DataService.instance.uploadFile(filePath, content: imageData, overwrite: true)
//                
//            }
//            self?.dismiss(animated: true, completion: nil)
//        }
//        
//        present(cameraViewController, animated: true, completion: nil)
//        
    }
    
    @IBAction func logoutBtnPressed(_ sender: AnyObject) {
      //  DataService.instance.logoutUser()
    }
    
    @IBAction func analyticsBtnPressed(_ sender: AnyObject) {
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue.identifier == "EditBusinessLocation" {
//            if let locationVC = segue.destination as? EditBusinessLocationVC{
//                
//                    let loc = user.businessLocation
//                    locationVC.location = loc
//
//            }
//            
//        }
//        
//    }
    
}











