//
//  PlanStep.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 3/1/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import Foundation
import MapKit

class PlanStep {
    var seq = 0
    var name = ""
    var instructions = ""
    var image = ""
    var icon = ""
    
    init(seq:Int, name:String, instructions:String, image:String, icon:String) {
        self.seq = seq
        self.name = name
        self.instructions = instructions
        self.image = image
        self.icon = icon
    }
}

