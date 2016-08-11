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

class ViewBusinessesCell: UITableViewCell {
    
    @IBOutlet weak var businessBGImage: UIImageView!
    
    @IBOutlet weak var businessNameLbl: TTTAttributedLabel!
    
    @IBOutlet weak var businessTypeLbl: UILabel!
    
    @IBOutlet weak var businessLocationLbl: UILabel!
    
    @IBOutlet weak var businessDesclbl: TTTAttributedLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        businessBGImage.layer.cornerRadius = 1
        businessBGImage.clipsToBounds = true
        businessNameLbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
        businessDesclbl.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
        
    }
    
    func configureCell(user: User!){
        
        let URL = NSURL(string: "\(user.userProfilePicLocation)")!
        let placeholderImage = UIImage(named: "Placeholder")!
        
        reverseGeoLocate(user.businessLocation)
        businessBGImage.af_setImageWithURL(URL, placeholderImage: placeholderImage)
        businessNameLbl.text = user.businessName
        businessTypeLbl.text = user.businessType
        businessDesclbl.text = user.businessDesc
        
        
    }
    
    func reverseGeoLocate(location: GeoPoint){
        
        if location.latitude != 0 && location.longitude != 0{
            
            let loc = CLLocation(latitude: Double(location.latitude), longitude: Double(location.longitude) )
            
            CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) -> Void in
                
                if let marks = placemarks where marks.count > 0 {
                    
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
