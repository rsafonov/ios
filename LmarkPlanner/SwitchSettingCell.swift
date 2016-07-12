//
//  SwitchSettingCell.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 7/6/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit
import MapKit

class SwitchSettingCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet var SwitchPropName: UILabel!
    @IBOutlet var SwitchPropValue: UISwitch!
    
    var parentController: LandmarksTableViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
        SwitchPropValue.addTarget(self, action: #selector(SwitchSettingCell.stateChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func stateChanged(switchState: UISwitch) {
        /*
        if switchState.on {
            print("The Switch is On")
        } else {
            print("The Switch is Off")
        }
        */
        
        parentController!.sendSwitchValToPreviousVC(switchState.on)
    }
}

