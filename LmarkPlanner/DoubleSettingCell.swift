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
    
    func xValChanged(x_Val: UITextField) {
        //print("x_Val = \(x_Val.text) yVal = \(yVal.text)")
        var x: Double = 1000.0
        var y: Double = 1000.0
        
        if (!(x_Val.text?.isEmpty)!)
        {
            x = Double(x_Val.text!)!
        }
        if (!(yVal.text?.isEmpty)!)
        {
            y = Double(yVal.text!)!
        }
        
        parentController!.sendXYToPreviousVC(x, yval: y)
    }
    
    func yValChanged(y_Val: UITextField) {
        //print("xVal = \(xVal) y_Val = \(y_Val.text)")
        parentController!.sendXYToPreviousVC(Double(xVal.text!)!, yval: Double(y_Val.text!)!)
    }
}


