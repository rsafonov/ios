//
//  CalloutView.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 6/7/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit

class CalloutView: UIView
{
    var title: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var calloutLabel: UILabel? = nil
    var imageView: UIImageView?  = nil
    var setStartButton: SuperButton?
    var setGoalButton: SuperButton?
    var closeButton: SuperButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    convenience init(frame: CGRect, text: String, x: CGFloat, y: CGFloat, lat: Double, lon: Double)
    {
        self.init(frame: frame)
        calloutLabel!.text = text
        center.x = x
        center.y = y
        latitude = lat
        longitude = lon
        clipsToBounds = true
        
        let strlat = String(latitude)
        let strlon = String(longitude)
        let fov = String(90)
        
        let imageurl = "http://maps.googleapis.com/maps/api/streetview?size=400x400&location=" + strlat + "," + strlon + "&fov=" + fov + "&sensor=false"
        let image =  UIImage(data: NSData(contentsOfURL: NSURL(string: imageurl)!)!)!
        imageView!.image = image
    }
    
    convenience init() {
        self.init(frame : CGRect.zero);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.blueColor().CGColor
        
        addCalloutLabel()
        setStartButton = addSuperButton(0, oy: 150, width: 50, height: 40, imageName: "RedFlag", txt: "Start")
        setGoalButton = addSuperButton(50, oy: 150, width: 50, height: 40, imageName: "FinishFlag", txt: "Goal")
        closeButton = addSuperButton(100, oy: 150, width: 50, height: 40, imageName: "BlueCross", txt: "Close")
        addImageView()
    }
    
    func addImageView()
    {
        //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        //{
        let w = frame.width

        imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: w, height: 100))
        
        addSubview(imageView!)
        return;
    }
    
    func addCalloutLabel()
    {
        let w = frame.width
        //let h = calloutView.frame.height
        //calloutLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: w, height: 50))
        calloutLabel = UILabel.init(frame: CGRect(x: 0, y: 100, width: w, height: 50))

        calloutLabel!.text = title
        calloutLabel!.textAlignment = .Center
        calloutLabel!.numberOfLines = 4
        calloutLabel!.font = UIFont(name: "Helvetica", size: 12)
        //calloutLabel!.backgroundColor = UIColor.whiteColor()
        calloutLabel?.layer.cornerRadius = 5
        //calloutLabel!.layer.borderColor = UIColor.darkGrayColor().CGColor
        //calloutLabel!.layer.borderWidth = 2
        //calloutLabel.center.x = 0.5 * self.frame.size.width
        //calloutLabel.center.y = -0.5 * self.frame.size.height
        addSubview(calloutLabel!)
    }
    
    func addSuperButton(ox: Double, oy: Double, width: Double, height: Double, imageName: String, txt: String) -> SuperButton
    {
        let btn = SuperButton.init(frame: CGRect(x: ox, y: oy, width: width, height: height))
        let titleLabel = UILabel.init(frame: CGRectMake(0, 27, 50, 10))
        titleLabel.text = txt
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: "Helvetica", size: 10)
        titleLabel.textColor = UIColor.blueColor()
        btn.addSubview(titleLabel)
        
        let imageView = UIImageView.init(frame: CGRectMake(15, 3, 25, 21))
        imageView.image = UIImage(named: imageName)
        btn.addSubview(imageView)
        
        //btn!.backgroundColor = UIColor.lightGrayColor()
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 5
        //btn.layer.borderColor = UIColor.blueColor().CGColor
        btn.addTarget(self, action: #selector(CalloutView.buttonTapped(_:)), forControlEvents: .TouchUpInside)
        addSubview(btn)
        return btn
    }
    
    func buttonTapped(sender: SuperButton!)
    {
        //print("CalloutView: buttonTapped.")

        guard let cview = superview as? LmarkAnnotationView else
        {
            print("Superview is not LmarkAnnotationView")
            return
        }
        guard let ann = cview.annotation as? LmarkAnnotation else
        {
            print("Annotation is not LmarkAnnotation")
            return
        }

        switch sender {
            case setStartButton!:
                cview.setStartPose(ann)
            case setGoalButton!:
                cview.setGoalPose(ann)
            case closeButton!:
                cview.closeCallout()
            default: ()
        }
    }

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
        let viewPoint = superview?.convertPoint(point, toView: self) ?? point
        //let isInsideView = pointInside(viewPoint, withEvent: event)
        let view = super.hitTest(viewPoint, withEvent: event)
        return view
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return CGRectContainsPoint(bounds, point)
    }
}
