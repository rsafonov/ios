//
//  FalseStepTableViewCell.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 3/7/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit

class FalseStepTableViewCell: UITableViewCell {

    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var instructions: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
