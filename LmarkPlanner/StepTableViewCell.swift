//
//  StepTableViewCell.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 3/4/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit
import MapKit

class StepTableViewCell: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet var instructions: UILabel!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var dirImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    // Initialization code
    
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
