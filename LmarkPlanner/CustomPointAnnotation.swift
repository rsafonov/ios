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
    var pointId: Int64 = 0
    var roadId: Int64 = 0
    var type: Int?
    var view: CustomAnnotationView?
    
    init(coord: CLLocationCoordinate2D, name: String, address: String, pinImage: UIImage?, photoImage: UIImage?, pointId: Int64, roadId: Int64, type: Int)
    {
        self.pinImage = pinImage
        self.photoImage = photoImage
        self.pointId = pointId
        self.roadId = roadId
        self.type = type
        super.init()
        self.coordinate = coord
        self.title = name
        self.subtitle = address
    }
    
    convenience init(lat: Double, lon: Double, name: String, address: String, pinImage: UIImage, photoImage: UIImage?, pointId: Int64, roadId: Int64, type: Int)
    {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.init(coord: coord, name: name, address: address, pinImage: pinImage, photoImage: photoImage, pointId: pointId, roadId: roadId, type: type)
    }
    
    convenience init(annotation: CustomPointAnnotation, pinImage: UIImage?)
    {
        self.init(coord: annotation.coordinate, name: annotation.title!, address: annotation.subtitle!, pinImage: pinImage, photoImage: annotation.photoImage, pointId: annotation.pointId, roadId: annotation.roadId, type: annotation.type!)
    }
}
