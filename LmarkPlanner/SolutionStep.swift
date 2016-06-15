//
//  SolutionStep.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 5/20/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import Foundation
import MapKit

class SolutionStep {
    var seq :Int = 0
    var name :String = ""
    var instructions :String = ""
    var imageName :String = ""
    var iconName :String = ""
    var k: Int = 0
    var id1 :Int64 = 0
    var id2 :Int64 = 0
    var lat1: Double = 0.0
    var lon1: Double = 0.0
    var lat2: Double = 0.0
    var lon2: Double = 0.0
    var act1: Int = 0
    var type1: Int = 0
    var act2: Int = 0
    var type2: Int = 0
    
    init(seq:Int, name:String, instructions:String, imageName:String, iconName:String, k:Int, id1:Int64, lat1:Double, lon1:Double, act1:Int, type1:Int, id2:Int64, lat2:Double, lon2:Double, act2:Int, type2:Int) {
        self.seq = seq
        self.name = name
        self.instructions = instructions
        self.imageName = imageName
        self.iconName = iconName
        self.k = k
        self.id1 = id1
        self.lat1 = lat1
        self.lon1 = lon1
        self.act1 = act1
        self.type1 = type1
        self.id2 = id2
        self.lat2 = lat2
        self.lon2 = lon2
        self.act2 = act2
        self.type2 = type2
    }
}

