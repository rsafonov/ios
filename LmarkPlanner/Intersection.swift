//
//  Intersection.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 3/2/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import Foundation
import MapKit

class Intersection {
    var latitude = 0.0
    var longitude = 0.0
    var location = ""
    
    init(latutude:CLLocationDegrees, longitude:CLLocationDegrees, location:String) {
        self.latitude = latutude
        self.longitude = longitude
        self.location = location
    }
}

