//
//  Setting.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 7/6/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import Foundation
import MapKit

class Setting {
    var name : String = ""
    var type : Int = 0
    var ival : Int? = 0
    var bval : Bool? = true
    var xval : Double? = 0.0
    var yval : Double? = 0.0
    
    init(name:String, type:Int, ival:Int?, bval:Bool?, xval:Double?, yval:Double?) {
        self.name = name
        self.type = type
        self.ival = ival
        self.bval = bval
        self.xval = xval
        self.yval = yval
    }
}

