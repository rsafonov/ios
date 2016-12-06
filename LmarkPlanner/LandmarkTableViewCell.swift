//
//  LandmarkTableViewCell.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 2/26/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit
import MapKit

class LandmarkTableViewCell: UITableViewCell
{

    //MARK: Properties
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var descrLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    var btn1: SetButton?
    var btn2: SetButton?
    
    var parentController: LandmarksTableViewController?
    
    var selectionType: Int = -1
    
/*
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let w = self.frame.size.width
        let h = self.frame.size.height
        let x1 = w - 45
        let y1 = h - 85
        btn1 = SetButton(frame: CGRectMake(x1, y1, 40, 30), label_txt: "Set Start", img_name: "RedFlag")
        btn1!.layer.borderWidth = 1
        btn1!.layer.borderColor = UIColor.blueColor().CGColor
        btn1!.layer.cornerRadius = 10
        btn1!.addTarget(self, action: #selector(buttonTapped(_:)), forControlEvents: .TouchUpInside)
        btn1!.userInteractionEnabled = true
        btn1?.backgroundColor = UIColor.cyanColor()
        
        addSubview(btn1!)
        btn1!.hidden = true
        
        let x2 = w - 45
        let y2 = h - 45
        btn2 = SetButton(frame: CGRectMake(x2, y2, 40, 30), label_txt: "Set Goal", img_name: "FinishFlag")
        btn2!.layer.borderWidth = 1
        btn2!.layer.borderColor = UIColor.blueColor().CGColor
        btn2!.layer.cornerRadius = 10
        btn2!.addTarget(self, action: #selector(buttonTapped(_:)), forControlEvents: .TouchUpInside)
        btn2!.userInteractionEnabled = true
        addSubview(btn2!)
        btn2!.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func buttonTapped(sender: SetButton!)
    {
        print("LandmarkTableViewCell: buttonTapped.")
        
        switch sender
        {
        case btn1!:
            parentController!.selectionType = 0 //start pose
            parentController?.performSegueWithIdentifier("HideTable", sender: btn1)
        case btn2!:
            parentController!.selectionType = 1 //goal pose
            parentController?.performSegueWithIdentifier("HideTable", sender: btn2)
        default: ()
        }
    }
}