//
//  ViewBusinessesCell.swift
//  bluepin
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
import Kingfisher

class ViewBusinessesCell: UITableViewCell {
    
    @IBOutlet weak var businessBGImage: UIImageView!
    
    @IBOutlet weak var businessNameLbl: TTTAttributedLabel!
    
    @IBOutlet weak var businessTypeLbl: UILabel!
    
    @IBOutlet weak var businessLocationLbl: UILabel!
    
    private var castedUser: NewUser!

    var geoFire: GeoFire!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        businessBGImage.layer.cornerRadius = 1
        businessBGImage.clipsToBounds = true
        businessNameLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        let placeholderImage = UIImage(named: "Placeholder")!
        self.businessBGImage.image = placeholderImage
        
    }
    
    func configureCell(_ uuid: String){
        
        if uuid != ""{
        
            self.geoFire = GeoFire(firebaseRef: FBDataService.instance.usersRef.child(uuid))
            
            castedUser = NewUser()
            castedUser.castUser(uuid) { (errMsg) in
                
                if errMsg == nil{
                
                    self.geoFire.getLocationForKey(BUSINESS_LOCATION, withCallback: { (loc, error) in
                        if (error == nil) {
                            
                            if let location  = loc{
                                self.reverseGeoLocate(location)
                            }else{
                                self.businessLocationLbl.text = "No Location Set"
                            }
                        }else{
                            self.businessLocationLbl.text = "No Location Set"
                        }
                    })
                    
                    self.businessNameLbl.text = self.castedUser.businessName
                    self.businessTypeLbl.text = self.castedUser.businessType
                    
                    self.loadProfilePic(uuid: uuid)
                
                }
                
            }
        }
    }
    
    func loadProfilePic(uuid: String){
        
        
        if castedUser.userProfilePicLocation != "" {
            
            if ImageCache.default.isImageCached(forKey: uuid).cached {
                
                ImageCache.default.retrieveImage(forKey: uuid, options: nil) {
                    image, cacheType in
                    if let image = image {
                        self.businessBGImage.image = image
                    }
                }
                
            }else{
                
                let ref = FIRStorage.storage().reference(forURL: castedUser.userProfilePicLocation)
                ref.data(withMaxSize: 20 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        let placeholderImage = UIImage(named: "Placeholder")!
                        self.businessBGImage.image = placeholderImage
                    } else {
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                
                                ImageCache.default.store(img,
                                                         original: imgData,
                                                         forKey: uuid,
                                                         toDisk: false)
                                
                                self.businessBGImage.image = img
                            }
                        }
                    }
                })

            }
        }
        
    }
    
    func reverseGeoLocate(_ location: CLLocation){
        
        if location.coordinate.latitude != 0 && location.coordinate.longitude != 0{
          
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                
                if let marks = placemarks, marks.count > 0 {
                    
                    let pm = marks[0] as CLPlacemark
                    
                    if let locality = pm.locality{
                        self.businessLocationLbl.text = "\(locality)"
                    }
                    
                }
                
            })
            
        }
      
    }
    

}
