//
//  LmarkAnnotation.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 5/23/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import Foundation
import MapKit

class LmarkAnnotation: MKPointAnnotation {
    var pinImage: UIImage!
    var photoImage: UIImage?
    var view: LmarkAnnotationView?
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
    
    convenience init(annotation: LmarkAnnotation, pinImage: UIImage?)
    {
        self.init(lmark: annotation.lmark, pinImage: pinImage, photoImage: annotation.photoImage)
    }
}
