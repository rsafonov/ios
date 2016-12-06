//
//  SetButton.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 11/21/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit

class SetButton: UIButton
{
    var label: UILabel?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    convenience init(frame: CGRect, label_txt: String, img_name: String)
    {
        self.init(frame: frame)
        
        addLabel(label_txt)
        addImageView(img_name)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func addLabel(text: String)
    {
        let w = frame.width
        //let h = frame.height
        label = UILabel.init(frame: CGRect(x: 0, y: 18, width: w, height: 10))
        label!.alpha = 1.0
        label!.text = text
        label!.textAlignment = .Center
        label!.numberOfLines = 1
        label!.font = UIFont(name: "Helvetica", size: 8)
        label!.backgroundColor = UIColor.clearColor()
        label?.textColor = UIColor.blueColor()
        label!.layer.cornerRadius = 10
        //calloutLabel!.layer.borderColor = UIColor.darkGrayColor().CGColor
        //calloutLabel!.layer.borderWidth = 2
        label!.userInteractionEnabled = false
        addSubview(label!)
    }
    
    func addImageView(image_name: String)
    {
        let w = 16  //frame.width/2
        let imageView = UIImageView.init(frame: CGRect(x: 12, y: 2, width: w, height: 16))
        imageView.image = UIImage(named: image_name)
        imageView.userInteractionEnabled = false
        addSubview(imageView)
        return;
    }
        

}
