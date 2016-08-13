//
//  LmarkAnnotation.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 5/23/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import Foundation
import MapKit

class LmarkAnnotation: MKPointAnnotation
{
    var lmark: Lmark

    init(lmark: Lmark)
    {
        self.lmark = lmark
        super.init()
        
        let coord = CLLocationCoordinate2D(latitude: lmark.latitude, longitude: lmark.longitude)
        
        self.coordinate = coord
        self.title = lmark.name
        self.subtitle = lmark.address
    }
    
    convenience init(annotation: LmarkAnnotation)
    {
        self.init(lmark: annotation.lmark)
    }
}
