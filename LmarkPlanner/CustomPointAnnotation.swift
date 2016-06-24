//
//  CustomPointAnnotation.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 5/23/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import Foundation
import MapKit

class CustomPointAnnotation: MKPointAnnotation {
    var pinImage: UIImage!
    var photoImage: UIImage?
    //var pointId: Int64 = 0
    //var roadId: Int64 = 0
    //var type: Int?
    //var street: String?
    //var amenity: String?
    var view: CustomAnnotationView?
    var lmark: Lmark

    init(lmark: Lmark, pinImage: UIImage?, photoImage: UIImage?)
    {
        self.lmark = lmark
        self.pinImage = pinImage
        self.photoImage = photoImage
        super.init()
        
        let coord = CLLocationCoordinate2D(latitude: lmark.latitude, longitude: lmark.longitude)
        
        self.coordinate = coord
        self.title = lmark.name
        self.subtitle = lmark.address

    }
    
    
    /*
    init(coord: CLLocationCoordinate2D, name: String, address: String, pinImage: UIImage?, photoImage: UIImage?, pointId: Int64, roadId: Int64, type: Int, street: String, amenity: String)
    {
        self.pinImage = pinImage
        self.photoImage = photoImage
        
        self.pointId = pointId
        self.roadId = roadId
        self.type = type
        self.street = street
        self.amenity = amenity
        super.init()
        
        self.coordinate = coord
        self.title = name
        self.subtitle = address
    }
    */
    
    /*
    convenience init(lat: Double, lon: Double, name: String, address: String, pinImage: UIImage, photoImage: UIImage?, pointId: Int64, roadId: Int64, type: Int, street: String, amenity: String)
    {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.init(coord: coord, name: name, address: address, pinImage: pinImage, photoImage: photoImage, pointId: pointId, roadId: roadId, type: type, street: street, amenity: amenity)
    }
    */
    
    convenience init(annotation: CustomPointAnnotation, pinImage: UIImage?)
    {
        //self.init(coord: annotation.coordinate, name: annotation.title!, address: annotation.subtitle!, pinImage: pinImage, photoImage: annotation.photoImage, pointId: annotation.pointId, roadId: annotation.roadId, type: annotation.type!, street: annotation.street!, amenity: annotation.amenity!)
        
        self.init(lmark: annotation.lmark, pinImage: pinImage, photoImage: annotation.photoImage)
    }
}
