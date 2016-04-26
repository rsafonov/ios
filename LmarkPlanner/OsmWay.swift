//
//  OsmWay.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 3/8/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import Foundation

class OsmWay {
    
    //MARK: Properties
    
    var id: Int
    var bounds: NSDictionary
    var nodes: [Int]
    var tags: NSDictionary
    var geometry: [[String:Int]]
    
    //MARK: Initialization
    
    init?(id:Int, bounds:NSDictionary, nodes:[Int], tags:NSDictionary, geometry:[[String:Int]]) {
        self.id = id
        self.bounds = bounds
        self.nodes = nodes
        self.tags = tags
        self.geometry = geometry
        
        if id <= 0 {
            return nil
        }
    }
}