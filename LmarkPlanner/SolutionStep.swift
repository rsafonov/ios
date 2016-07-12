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
    var seq: Int = 0
    var name: String = ""
    var instructions: String = ""
    var photoImage: UIImage?
    var iconName: String = ""
    var k: Int = 0
    var id1: Int64 = 0
    var id2: Int64 = 0
    var lat1: Double = 0.0
    var lon1: Double = 0.0
    var lat2: Double = 0.0
    var lon2: Double = 0.0
    var act1: Int = 0
    var type1: Int = 0
    var act2: Int = 0
    var type2: Int = 0
    var dir1: Int = 0
    var dir2: Int = 0
    var safety_ind_start: Int = -1
    var safety_ind_end: Int = -1
    var orig_seq: Int = -1
    var isection_count: Int = 0
    
    init(seq:Int, name:String, instructions:String, photoImage:UIImage?, iconName:String, k:Int, id1:Int64, lat1:Double, lon1:Double, act1:Int, type1:Int, id2:Int64, lat2:Double, lon2:Double, act2:Int, type2:Int, dir1:Int, dir2:Int) {
        self.seq = seq
        self.name = name
        self.instructions = instructions
        self.photoImage = photoImage
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
        self.dir1 = dir1
        self.dir2 = dir2
    }
    
    init(step: SolutionStep) {
        self.seq = step.seq
        self.name = step.name
        self.instructions = step.instructions
        self.photoImage = step.photoImage
        self.iconName = step.iconName
        self.k = step.k
        self.id1 = step.id1
        self.lat1 = step.lat1
        self.lon1 = step.lon1
        self.act1 = step.act1
        self.type1 = step.type1
        self.id2 = step.id2
        self.lat2 = step.lat2
        self.lon2 = step.lon2
        self.act2 = step.act2
        self.type2 = step.type2
        self.dir1 = step.dir1
        self.dir2 = step.dir2

    }
}

