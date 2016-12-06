//
//  DoubleSettingCell.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 7/6/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit
import MapKit

class DoubleSettingCell: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet var Title: UILabel!
    @IBOutlet var xName: UILabel!
    @IBOutlet var yName: UILabel!
    @IBOutlet var xVal: UITextField!
    @IBOutlet var yVal: UITextField!
    
    var parentController: LandmarksTableViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        xVal.addTarget(self, action: #selector(DoubleSettingCell.xValChanged(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
        
        yVal.addTarget(self, action: #selector(DoubleSettingCell.yValChanged(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func xValChanged(x_Val: UITextField)
    {
        var x: Double = 0.0
        var y: Double = 0.0
        
        if (tag == 5)
        {
            x = updateVal(x_Val.text!, defaultVal: 1500.0)
            y = updateVal(yVal.text!, defaultVal: 1500.0)
        }
        else if (tag == 6)
        {
            x = updateVal(x_Val.text!, defaultVal: 1.0)
            y = updateVal(yVal.text!, defaultVal: 6.0)
        }
        parentController!.sendXYToPreviousVC(x, yval: y, tag: tag)
    }
    
    func yValChanged(y_Val: UITextField)
    {
        var x: Double = 0.0
        var y: Double = 0.0

        if (tag == 5)
        {
            x = updateVal(xVal.text!, defaultVal: 1500.0)
            y = updateVal(y_Val.text!, defaultVal: 1500.0)
        }
        else if (tag == 6)
        {
            x = updateVal(xVal.text!, defaultVal: 1.0)
            y = updateVal(y_Val.text!, defaultVal: 6.0)
        }
        parentController!.sendXYToPreviousVC(x, yval: y, tag: tag)
    }
    
    func updateVal(txt: String, defaultVal: Double) -> Double
    {
        //var val1: Double = 0.0
        //var val2: Double = 0.0
        var val: Double?
        
        /*
        if (tag == 5)
        {
            val1 = 1500.0
            val2 = 1500.0
        }
        else if tag == 6
        {
            val1 = 1.0
            val2 = 6.0
        }
        */
        
        if (!(txt.isEmpty))
        {
            val = Double(txt)
        }
        
        if  txt.isEmpty || val == nil
        {
            val = defaultVal
        }
        return val!
    }
}


