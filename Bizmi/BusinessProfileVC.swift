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
import FirebaseStorage
import FirebaseAuth

class BusinessProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userProfileImg: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loadingPicLbl: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    let castedUser = NewUser() //Used for Global Casting Purposes
    
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

        castUser()
        
        NotificationCenter.default.addObserver(self, selector: #selector(BusinessProfileVC.onUploadProgressChanged), name: NSNotification.Name(rawValue: "uploadProgressFB"), object: nil)
    }
    
    
    func castUser(){
        //Casting
        castedUser.castUser((FBDataService.instance.currentUser?.uid)!) { (errMsg) in
            print("Alex: \((FBDataService.instance.currentUser?.uid)!)")
            self.loadBusinesssProfileInfo()
        }
    }
    
    func onUploadProgressChanged(){
        self.loadingPicLbl.text = "\(FBDataService.instance.uploadProgress.roundTo(places: 1))%"
    }
    
    func loadProfilePic(){
        
        if castedUser.userProfilePicLocation != "" {
        
            let ref = FIRStorage.storage().reference(forURL: castedUser.userProfilePicLocation)
            ref.data(withMaxSize: 20 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("Unable to download image from Firebase storage")
                    print(error)
                    let placeholderImage = UIImage(named: "Placeholder")!
                    self.userProfileImg.image = placeholderImage
                } else {
                    print("Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.userProfileImg.image = img
                        }
                    }
                }
            })
            
            print(castedUser.userProfilePicLocation)
        }
    }
    
    func loadBusinesssProfileInfo(){
        
        loadProfilePic()
        print("Alex: \(castedUser.businessName)")
        
        profileTextItems = [
            castedUser.businessName,
            castedUser.businessType,
            castedUser.businessHours,
            castedUser.businessDesc,
            castedUser.phoneNumber,
            castedUser.businessWebsite,
            castedUser.email,
            "Change Location",
            "Change Password", //Because users password should not be displayed
        ]

        tableView.reloadData()
    
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let textItem = profileTextItems[(indexPath as NSIndexPath).row]
        let iconItem = profileIconItems[(indexPath as NSIndexPath).row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessProfileCell") as? BusinessProfileCell {
            
            print(iconItem)
            cell.configureCell(iconItem, text: textItem)
            
            return cell
            
        }else{
            
            let cell = BusinessProfileCell()
            
            cell.configureCell(iconItem, text: textItem)
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) //So tableview row doesn't stay highlighted
        
        if (indexPath as NSIndexPath).row <= 6 { //Password change requires different functionality
            
            keyboardType = keyboardType(indexPath)
            
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
            
        }else if indexPath.row == 7 {
            
            performSegue(withIdentifier: "EditBusinessLocation", sender: nil)
            
        }else {
            
            print("Change Password")
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
        print("generating the TextField")
        textField.text = alertPlaceHolder
        textField.keyboardType = keyboardType
        tField = textField
        
    }
    
    func handleCancel(_ alertView: UIAlertAction!){
        print("Cancelled !!")
    }
    
    func keyboardType(_ indexPath: IndexPath) -> UIKeyboardType{
    
        if (indexPath as NSIndexPath).row == 4 { // Phone Number requires number pad
            return UIKeyboardType.numberPad
        }
        
        return UIKeyboardType.default
        
    }
    
    
    func updateProperties(_ indexPath: IndexPath) -> [String: AnyObject]{
        
        var properties = [String: AnyObject]()
        
        if let textInput = self.tField.text {
            
            switch (indexPath as NSIndexPath).row {
            case 0:
                properties.updateValue(textInput as AnyObject, forKey: BUSINESS_NAME)
            case 1:
                properties.updateValue(textInput as AnyObject, forKey: BUSINESS_TYPE)
            case 2:
                properties.updateValue(textInput as AnyObject, forKey: BUSINESS_HOURS)
            case 3:
                properties.updateValue(textInput as AnyObject, forKey: BUSINESS_DESC)
            case 4:
                properties.updateValue(formatPhoneNumber(textInput) as AnyObject, forKey: PHONE_NUMBER)
            case 5:
                properties.updateValue(textInput as AnyObject, forKey: BUSINESS_WEBSITE)
            case 6:
                properties.updateValue(textInput as AnyObject, forKey: EMAIL)
            default:
                break
            }
        }
        
        return properties
        
    }
    
    func formatPhoneNumber(_ rawPhoneNumber: String?) -> String {
        
        if let rawNumber = rawPhoneNumber{
            
            do {
                let phoneNumber = try PhoneNumber(rawNumber: rawNumber, region: "US" )
                return String(phoneNumber.toNational())
            }
            catch {
                print("Generic parser error")
            }
            
        }
        
        return castedUser.phoneNumber //Doesnt update property if value is empty
        
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
        
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "New Password", message: "Are you sure you want a new password?", preferredStyle: .alert)
        
        // Initialize Actions
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
        
        // Add Actions
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        // Present Alert Controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func pencilBtnPressed(_ sender: AnyObject) {
        
        let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { [weak self] image, asset in
            
            if image != nil {
                
                self?.userProfileImg.image = image?.correctlyOrientedImage()
                
                let imageData: Data = UIImageJPEGRepresentation(image!.correctlyOrientedImage(), 0.5)!
                
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
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func logoutBtnPressed(_ sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
        self.performSegue(withIdentifier: "customerLoggedOut", sender: nil)
    }
    
    @IBAction func analyticsBtnPressed(_ sender: AnyObject) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditBusinessLocation" {
            if let locationVC = segue.destination as? EditBusinessLocationVC{
                    locationVC.uuid = castedUser.uuid
            }
            
        }
        
    }
    
}











