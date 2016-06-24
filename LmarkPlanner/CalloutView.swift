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
    
    var calloutLabel: UILabel? = nil
    var setStartButton: SuperButton?
    var setGoalButton: SuperButton?
    var closeButton: SuperButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    convenience init(frame: CGRect, text: String, x: CGFloat, y: CGFloat)
    {
        self.init(frame: frame)
        calloutLabel!.text = text
        center.x = x
        center.y = y
        clipsToBounds = true
    }
    
    convenience init() {
        self.init(frame : CGRect.zero);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
    
        //UINib(nibName: "CalloutView", bundle: nil).instantiateWithOwner(self, options: nil)
        //addSubview(annCalloutView)
        //annCalloutView.frame = self.bounds
        
        backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.blueColor().CGColor
        
        addCalloutLabel()
        setStartButton = addSuperButton(0, oy: 50, width: 50, height: 30, imageName: "RedFlag48", txt: "Set Start")
        setGoalButton = addSuperButton(50, oy: 50, width: 50, height: 30, imageName: "FinishFlag40", txt: "Set Goal")
        closeButton = addSuperButton(100, oy: 50, width: 50, height: 30, imageName: "BlueCross", txt: "Close")
    }
    
    func addCalloutLabel()
    {
        let w = frame.width
        //let h = calloutView.frame.height
        calloutLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: w, height: 50))
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
        btn.setImage(UIImage(named: imageName), forState: .Normal)
        //btn.setTitle(txt, forState: .Normal)
        //btn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        //btn.titleLabel?.font = UIFont(name: "Helvetica", size: 13)
        //btn.titleLabel?.textAlignment = .Center
        //btn!.backgroundColor = UIColor.lightGrayColor()
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 5
        //btn.layer.borderColor = UIColor.blueColor().CGColor
        btn.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
        addSubview(btn)
        return btn
    }
    
    func buttonTapped(sender: AnyObject?)
    {
        print("CustomAnnotationView: buttonTapped.")
        let btn = sender as! SuperButton
        let cview  = superview as! CustomAnnotationView
        switch btn {
            case setStartButton!:
                cview.setStartPose(sender)
            case setGoalButton!:
                cview.setGoalPose(sender)
            case closeButton!:
                cview.closeCallout(sender)
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
