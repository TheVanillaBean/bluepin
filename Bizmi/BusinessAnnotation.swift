//
//  BusinessAnnotation.swift
//  Bizmi
//
//  Created by Alex on 8/7/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation
import MapKit

class BusinessAnnotation: NSObject, MKAnnotation {

    dynamic var coordinate = CLLocationCoordinate2D()
    
    var title: String?
    var subtitle: String?
    

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
        self.title = ""
        self.subtitle = ""
    }
    
    override init() {
        
    }
    
}
