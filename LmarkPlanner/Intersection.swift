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
    var id : Int64 = 0
    var index: Int = 0
    var latitude = 0.0
    var longitude = 0.0
    var location : NSString = ""
    var streetsCount : Int = 0
    
    init(id:Int64, index:Int, latutude:CLLocationDegrees, longitude:CLLocationDegrees, location:NSString, streetsCount:Int) {
        self.id = id
        self.index = index
        self.latitude = latutude
        self.longitude = longitude
        self.location = location
        self.streetsCount = streetsCount
    }
}

