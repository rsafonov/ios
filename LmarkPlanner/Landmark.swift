//
//  Landmark.swift
//
//  Created by Margarita Safonova on 2/29/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import Foundation
import MapKit

class Landmark {
    var name = ""
    var description = ""
    var type = ""
    var latitude = 0.0
    var longitude = 0.0
    var address = ""
    var image = ""
    var pin = ""
    
    init(name:String, description:String, type:String, latitude:CLLocationDegrees, longitude:CLLocationDegrees, address:String, image:String, pin:String) {
        self.name = name
        self.description = description
        self.type = type
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.image = image
        self.pin = pin
    }
}
