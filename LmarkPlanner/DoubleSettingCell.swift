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
        let x = updateVal(x_Val.text!)
        let y = updateVal(yVal.text!)
        parentController!.sendXYToPreviousVC(x, yval: y)
    }
    
    func yValChanged(y_Val: UITextField)
    {
        let x = updateVal(xVal.text!)
        let y = updateVal(y_Val.text!)
        parentController!.sendXYToPreviousVC(x, yval: y)
    }
    
    func updateVal(txt: String) -> Double
    {
        var val: Double? = 1500.0
        if (!(txt.isEmpty))
        {
            val = Double(txt)
            if  val == nil
            {
                val = 1500.0
            }
        }
        return val!
    }
}


