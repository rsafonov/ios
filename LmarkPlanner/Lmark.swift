//
//  Lmark.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 3/4/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit
import MapKit

class Lmark {
    //MARK: Properties
    
    var name: String
    var description: String
    var type: Int
    var address: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var photo: UIImage?
    var pin: UIImage?
    var pointId: Int64
    var roadId: Int64
    var street: String
    var amenity: String
    var roadLatitude: CLLocationDegrees
    var roadLongitude: CLLocationDegrees
    
    //MARK: Initialization
    
    init?(name:String, description:String, type:Int, address:String, latitude:CLLocationDegrees, longitude:CLLocationDegrees, photo:UIImage?, pin:UIImage?, pointId:Int64, roadId:Int64, street:String, amenity:String, roadLatitude: CLLocationDegrees, roadLongitude: CLLocationDegrees)
    {
        self.name = name
        self.description = description
        self.type = type
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.photo = photo
        self.pin = pin
        self.pointId = pointId
        self.roadId = roadId
        self.street = street
        self.amenity = amenity
        self.roadLatitude = roadLatitude
        self.roadLongitude = roadLongitude
        
        //Initialization should fail if there is no name, latitude or longitude.
        
        if name.isEmpty || !latitude.isNormal || !longitude.isNormal {
            return nil
        }
    }
    
}