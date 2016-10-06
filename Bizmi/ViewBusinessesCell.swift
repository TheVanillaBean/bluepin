//
//  ViewBusinessesCell.swift
//  Bizmi
//
//  Created by Alex on 8/6/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import AlamofireImage
import TTTAttributedLabel
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ViewBusinessesCell: UITableViewCell {
    
    @IBOutlet weak var businessBGImage: UIImageView!
    
    @IBOutlet weak var businessNameLbl: TTTAttributedLabel!
    
    @IBOutlet weak var businessTypeLbl: UILabel!
    
    @IBOutlet weak var businessLocationLbl: UILabel!
    
    @IBOutlet weak var businessDesclbl: TTTAttributedLabel!
    
    private var castedUser: NewUser!

    var geoFire: GeoFire!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        businessBGImage.layer.cornerRadius = 1
        businessBGImage.clipsToBounds = true
        businessNameLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        businessDesclbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        
    }
    
    func configureCell(_ uuid: String){
        
        //Casting
        self.geoFire = GeoFire(firebaseRef: FBDataService.instance.usersRef.child(uuid))
        
        castedUser = NewUser()
        castedUser.castUser(uuid) { (errMsg) in
            print("Alex: \(uuid)")
            
            self.geoFire.getLocationForKey(BUSINESS_LOCATION, withCallback: { (loc, error) in
                if (error != nil) {
                    print("Error")
                }else if (loc != nil) {
                    self.reverseGeoLocate(loc!)
                } else {
                   print("no loc")
                }
            })
            
            self.businessNameLbl.text = self.castedUser.businessName
            self.businessTypeLbl.text = self.castedUser.businessType
            self.businessDesclbl.text = self.castedUser.businessDesc
            
            self.loadProfilePic()
            
        }
    }
    
    func loadProfilePic(){
        
        if castedUser.userProfilePicLocation != "" {
            
            let ref = FIRStorage.storage().reference(forURL: castedUser.userProfilePicLocation)
            ref.data(withMaxSize: 20 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("Unable to download image from Firebase storage")
                    print(error)
                    let placeholderImage = UIImage(named: "Placeholder")!
                    self.businessBGImage.image = placeholderImage
                } else {
                    print("Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.businessBGImage.image = img
                        }
                    }
                }
            })
        }
        print(castedUser.userProfilePicLocation)
        
    }
    
    func reverseGeoLocate(_ location: CLLocation){
        
        if location.coordinate.latitude != 0 && location.coordinate.longitude != 0{
          
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                
                if let marks = placemarks , marks.count > 0 {
                    
                    let pm = marks[0] as CLPlacemark
                    
                    if let locality = pm.locality{
                        self.businessLocationLbl.text = "\(locality)"
                    }
                    
                }else {
                    print("there was an error no location")
                }
                
            })
            
        }
      
    }
    

}
