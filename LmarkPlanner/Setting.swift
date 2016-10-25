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
    var name: String = ""
    var tag: Int
    var type: Int = 0
    var ival: Int? = 0
    var xname: String = ""
    var yname: String = ""
    var bval: Bool? = true
    var xval: Double? = 0.0
    var yval: Double? = 0.0
    
    init(name:String, tag: Int, type:Int, ival:Int?, xname: String, yname: String, bval:Bool?, xval:Double?, yval:Double?) {
        self.name = name
        self.tag = tag
        self.type = type
        self.ival = ival
        self.xname = xname
        self.yname = yname
        self.bval = bval
        self.xval = xval
        self.yval = yval
    }
}

