//
//  OsmNode.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 3/8/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import Foundation


class OsmNode {
    
    //MARK: Properties
    
    var id: Int;
    var lat: Double
    var lon: Double
    var tags: NSDictionary

    //MARK: Initialization
    
    init?(id:Int, lat:Double, lon:Double, tags:NSDictionary) {
        self.id = id
        self.lat = lat
        self.lon = lon
        self.tags = tags
        
        if id <= 0 || !lat.isNormal || !lon.isNormal {
            return nil
        }
    }
}