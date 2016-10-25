//
//  LmarkAnnotationView.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 6/8/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit
import MapKit

class LmarkAnnotationView: MKAnnotationView {

    //class var reuseIdentifier:String {
    //    return "lmark"
    //}
    
    //let reuseIdentifier = "lmark"
    
    var preventDeselection:Bool {
        return !hitOutside
    }
    
    var parent: ViewController?
    var count_selected: Int = 0
    var count_deselected: Int = 0
    var calloutView: CalloutView?
    
    var calloutAdded: Bool = false
    
    private var hitOutside:Bool = true
    //private let blueBallImage = UIImage(named: "BlueBall")
    //private let pinkBallImage = UIImage(named: "PinkBall")
    //private let greenBallImage = UIImage(named: "GreenBall")
    
    convenience init(annotation:MKAnnotation!) {
        self.init(annotation: annotation, reuseIdentifier: "lmark") //LmarkAnnotationView.reuseIdentifier)
        canShowCallout = false;
    }
    
    override func setSelected(let selected: Bool, animated: Bool)
    {
        guard let ann = annotation as? LmarkAnnotation else
        {
            print("This view can only be used for annotation of type  LmarkAnnotation!")
            return
        }
        
        if (selected)
        {
            count_selected += 1
            print("count_selected = \(count_selected)")
            
            superview?.bringSubviewToFront(self)
            
            super.setSelected(selected, animated: animated)
            
            if (calloutView == nil)
            {
                let x = 0.5 * self.frame.size.width
                let y = -3.0 * self.frame.size.height
                calloutView = CalloutView(frame: CGRectMake(0, 0, 150, 190), x: x, y: y, lmark0: ann.lmark)
                calloutView!.alpha = 1.0
                calloutView!.backgroundColor = UIColor.whiteColor()
                calloutView!.exclusiveTouch = true
            }
            
            let blueBallImage = UIImage(named: "BlueBall")
            if (image == blueBallImage)
            {
                let greenBallImage = UIImage(named: "GreenBall")
                self.image = greenBallImage
                parent?.greenViews.append(self)
            }
            addSubview(calloutView!)
            calloutAdded = true;
            //self.bringSubviewToFront(calloutView!)
        }
        else
        {
            count_deselected += 1
            print("count_deselected = \(count_deselected)")
            calloutView!.removeFromSuperview()
            calloutAdded = false
        }
        
        
        /*
        let calloutViewAdded = calloutView?.superview != nil
        
        if (selected || !selected && hitOutside) {
            super.setSelected(selected, animated: animated)
        }
        
        self.superview?.bringSubviewToFront(self)
        
        if (selected && calloutView == nil)
        {
            let x = 0.5 * self.frame.size.width
            let y = -3.0 * self.frame.size.height
            calloutView = CalloutView(frame: CGRectMake(0, 0, 150, 190), x: x, y: y, lmark0: ann.lmark)
        }
        
        if (selected && !calloutViewAdded)
        {
            //if ann!.pinImage == blueBallImage
            if image == blueBallImage
            {
                //self.image = pinkBallImage
                self.image = greenBallImage
                parent?.greenViews.append(self)
            }
            addSubview(calloutView!)
            self.bringSubviewToFront(calloutView!)
            
            //print("Selected annotation: \(ann.lmark.pointId) \(ann.title!)")
            
            //print("Annotations behind calloutView")
            //listAnnotationsBehindCallout(calloutView!.frame)
            
            //print("Annotations behind setStart button")
            //let larea = calloutView!.setStartButton!.frame
            //listAnnotationsBehindCallout(larea)
        }
        else if (!selected) {
            calloutView?.removeFromSuperview()
        }
        */
    }
    
    //override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    //}
    
    func listAnnotationsBehindCallout(larea: CGRect)
    {
        var count = 0
        var i = 0
        //print("Total annotations in mapView: \(parent?.mapView.annotations.count)")
       
        //print("Callout area (local coords): \(larea.origin.x), \(larea.origin.y), \(larea.height), \(larea.width)")
    
        let area = self.convertRect(larea, toView: parent?.mapView)
        //print("Callout area: \(area.origin.x), \(area.origin.y), \(area.height), \(area.width)")
    
        for ann1 in (parent?.mapView.annotations)!
        {
            let sview = parent?.mapView.viewForAnnotation(ann1)
            i += 1
            let sarea = sview?.frame
            //print("(\(i) annview area: \(sarea!.origin.x), \(sarea!.origin.y), \(sarea!.height), \(sarea!.width)")
    
            if (CGRectContainsRect(area, sarea!))
            {
                count += 1
                if sview is LmarkAnnotationView
                {
                    //let annView = sview as! LmarkAnnotationView
                    //let ann2 = annView.annotation as! LmarkAnnotation
                    //print("\(count) \(ann2.lmark.pointId) \(ann2.title!)")
                }
            }
        }
        //print("count = \(count)")
    }
    
    func setStartPose(ann: LmarkAnnotation)
    {
        if (parent?.goal_set == true && parent?.goal_pointId == ann.lmark.pointId)
        {
            parent!.goal_set = false
            parent!.goal_pointId = -1
            processGoalViews()
            parent!.mapView.removeOverlays(parent!.mapView.overlays)
        }
        
        parent?.start_pointId = ann.lmark.pointId
        parent?.start_roadId = ann.lmark.roadId
        parent?.start_type = ann.lmark.type
        parent?.start_set = true
        processStartViews()
        parent!.startViews.append(self)
        
        setPose("RedFlag")
        callGeneratePlan()

    }

    func setGoalPose(ann: LmarkAnnotation)
    {
        if (parent?.start_set == true && parent?.start_pointId == ann.lmark.pointId)
        {
            parent?.start_set = false
            parent?.start_pointId = -1
            processStartViews()
            parent!.mapView.removeOverlays(parent!.mapView.overlays)
        }
        
        parent?.goal_pointId = ann.lmark.pointId
        parent?.goal_roadId = ann.lmark.roadId
        parent?.goal_type = ann.lmark.type
        parent!.goal_set = true
        processGoalViews()
        parent!.goalViews.append(self)
        setPose("FinishFlag")
        callGeneratePlan()
    }
    
    func callGeneratePlan()
    {
        let start = NSDate()
        var end: NSDate?
        
        if (self.parent!.debug)
        {
            self.parent!.DebugInfo.text = "Searching...\nStart \(self.parent!.start_roadId):\(self.parent!.start_pointId)\nGoal  \(self.parent!.goal_roadId):\(self.parent!.goal_pointId)"
        }

        parent!.generateOptimalPlan ( { (error:NSError!) -> () in

            dispatch_async(dispatch_get_main_queue(), {

                self.parent!.activityIndicatorView.stopAnimating()
                
                if (self.parent!.debug)
                {
                    end = NSDate()
                    let duration = end!.timeIntervalSinceDate(start)
                    print("Duration = \(duration)")
                }

                if ((error == nil))
                {
                    print("generateOptimalPlan completed")
                    print("safety plan count = \(self.parent!.safety_plan.count) goal_pointId = \(self.parent!.goal_pointId)")
                    
                    if (self.parent!.safety_plan.count > 0)
                    {
                        if (self.parent!.debug)
                        {
                            var safety_plan_part = [SolutionStep]()
                            var i = 0
                            var j = 0
                            for step in self.parent!.safety_plan
                            {
                                safety_plan_part.append(step)
                                if (step.id2 != self.parent!.goal_pointId)
                                {
                                    j += 1
                                }
                                else
                                {
                                    //print("portion count = \(safety_plan_part.count)")
                                    self.parent!.drawPlan(1, planColor: UIColor.brownColor(), lineWidth: 3, path: safety_plan_part)
                                
                                    safety_plan_part.removeAll()
                                    j=0
                                }
                                i += 1
                            }
                        }
                    }
                    
                    if (self.parent!.plan.count > 0)
                    {
                        self.parent!.drawPlan(0, planColor: UIColor.blueColor(), lineWidth: 4, path: self.parent!.plan)
                    }
                        
                    if (self.parent!.debug)
                    {
                        if (self.parent!.cond0 != nil)
                        {
                            self.parent!.DebugInfo.text = "k=\(self.parent!.cond0!.k) time=\(self.parent!.duration0)\nStart \(self.parent!.start_roadId):\(self.parent!.start_pointId):\(self.parent!.cond0!.start_dir)\nGoal  \(self.parent!.goal_roadId):\(self.parent!.goal_pointId):\(self.parent!.cond0!.goal_dir)"
                        }
                        else
                        {
                            self.parent!.DebugInfo.text = "Plan not found.\nStart \(self.parent!.start_roadId):\(self.parent!.start_pointId)\nGoal  \(self.parent!.goal_roadId):\(self.parent!.goal_pointId)"
                        }
                    
                        if (self.parent!.searchText.text == "osm")
                        {
                            self.parent!.searchText.text = "cathedral of learning"
                        }
                    }
                }
            })
        })
    }

    func setPose(poseImageName: String)
    {
        processGreenViews()
        parent!.mapView.deselectAnnotation(self.annotation, animated: false)
        let flagPin = UIImage(named: poseImageName)
        image = flagPin
    }
    
    func closeCallout()
    {
        print("closeCallout: selectedAnnotations.count = \(parent!.mapView.selectedAnnotations.count)")
        processGreenViews()
        parent!.mapView.deselectAnnotation(self.annotation, animated: false)
        
        /*
        if (ann?.lmark.type == 1)
        {
            image = blueBallImage
        }
        else
        {
            image = UIImage(named: "BlueFlagLeft")
        }
        */
    }
    
    func processStartViews()
    {
        for view in parent!.startViews
        {
            let blueBallImage = UIImage(named: "BlueBall")
            view.image = blueBallImage
        }
        parent?.startViews.removeAll()
    }
    
    func processGoalViews()
    {
        for view in parent!.goalViews
        {
            let blueBallImage = UIImage(named: "BlueBall")
            view.image = blueBallImage
        }
        parent?.goalViews.removeAll()
    }
    
    func processGreenViews()
    {
        for view in parent!.greenViews
        {
            let blueBallImage = UIImage(named: "BlueBall")
            view.image = blueBallImage
        }
        parent?.greenViews.removeAll()
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
        //if (event != nil)
        //{
            //NSLog("Event=%@", event!)
        //}
        
        //let viewPoint = superview?.convertPoint(point, toView: self) ?? point
        //let isInsideView = pointInside(viewPoint, withEvent: event)
        //let h = self.bounds.height
        //let w = self.bounds.width
        //let ox = self.bounds.origin.x
        //let oy = self.bounds.origin.y
        
        if (self.hidden)
        {
            print("point \(point) is hidden")
            return nil
        }
        
        var hitView = super.hitTest(point, withEvent: event)
        //if (hitView != nil)
        //{
        //    print("point: \(point)")
        //}
        if (hitView != nil && calloutAdded && !self.selected)
        {
            print("hitView != nil && calloutAdded")
            return nil
        }
        
        if ((hitView == nil || hitView != nil && calloutAdded) && self.selected)
        {
            let pointInCalloutView = self.convertPoint(point, toView: calloutView)
            hitView = calloutView?.hitTest(pointInCalloutView, withEvent: event)
        }
        
        /*
        if let callout = calloutView {
            if (hitView == nil && selected) {
                hitView = callout.hitTest(point, withEvent: event)
            }
        }
        */
        
        hitOutside = (hitView == nil)
        return hitView;
    }
  
    /*
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
        let hitView = super.hitTest(point, withEvent: event)
        if (hitView != nil)
        {
            self.superview?.bringSubviewToFront(hitView!)
        }
        return hitView
    
        //let viewPoint = superview?.convertPoint(point, toView: self) ?? point
        //let isInsideView = pointInside(viewPoint, withEvent: event)
        //var view = super.hitTest(viewPoint, withEvent: event)
        //return view
    }
    */
    
    /*
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool
    {
        //print("LmarkAnnotationView: pointInside")
        //return CGRectContainsPoint(bounds, point)
        
        let rect = self.bounds;
        var isInside = CGRectContainsPoint(rect, point);
        if (!isInside)
        {
            for view in self.subviews
            {
                isInside = CGRectContainsPoint(view.frame, point);
                if (isInside)
                {
                    break;
                }
            }
        }
        //print("inInside = \(isInside)")
        return isInside;
    }
    */
}
