//
//  CustomAnnotationView.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 6/8/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotationView: MKAnnotationView {

    class var reuseIdentifier:String {
        return "test"
    }
    
    var preventDeselection:Bool {
        return !hitOutside
    }
    
    var parent: ViewController?
    
    private var calloutView: CalloutView?
    private var ann: CustomPointAnnotation?
    private var hitOutside:Bool = true
    private let blueBallImage = UIImage(named: "BlueBall")
    private let pinkBallImage = UIImage(named: "PinkBall")
    
    convenience init(annotation:MKAnnotation!) {
        self.init(annotation: annotation, reuseIdentifier: CustomAnnotationView.reuseIdentifier)
        canShowCallout = false;
    }
    
    override func setSelected(let selected: Bool, animated: Bool)
    {
        if !(annotation  is CustomPointAnnotation)
        {
            print("This view can only be used for annotation of type  CustomPointAnnotation!")
            return
        }
        
        ann = annotation as? CustomPointAnnotation
        
        let calloutViewAdded = calloutView?.superview != nil
        
        if (selected || !selected && hitOutside) {
            super.setSelected(selected, animated: animated)
        }
        
        self.superview?.bringSubviewToFront(self)
        
        if (calloutView == nil) {
            let x = 0.5 * self.frame.size.width
            let y = -3.0 * self.frame.size.height
            let txt = ann?.title
            calloutView = CalloutView(frame: CGRectMake(0, 0, 150, 80), text: txt!, x: x, y: y)
        }
        
        if (selected && !calloutViewAdded)
        {
            if ann!.pinImage == blueBallImage
            {
                self.image = pinkBallImage
            }
            addSubview(calloutView!)
            
            print("Selected annotation: \(ann!.pointId) \(ann!.title!)")
            
            //print("Annotations behind calloutView")
            //listAnnotationsBehindCallout(calloutView!.frame)
            
            //print("Annotations behind setStart button")
            //let larea = calloutView!.setStartButton!.frame
            //listAnnotationsBehindCallout(larea)
        }
        else if (!selected) {
            calloutView?.removeFromSuperview()
        }
    }
    
    //override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    //}
    
    func listAnnotationsBehindCallout(larea: CGRect)
    {
        var count = 0
        var i = 0
        print("Total annotations in mapView: \(parent?.mapView.annotations.count)")
       
        print("Callout area (local coords): \(larea.origin.x), \(larea.origin.y), \(larea.height), \(larea.width)")
    
        let area = self.convertRect(larea, toView: parent?.mapView)
        print("Callout area: \(area.origin.x), \(area.origin.y), \(area.height), \(area.width)")
    
        for ann1 in (parent?.mapView.annotations)!
        {
            let sview = parent?.mapView.viewForAnnotation(ann1)
            i++
            let sarea = sview?.frame
            //print("(\(i) annview area: \(sarea!.origin.x), \(sarea!.origin.y), \(sarea!.height), \(sarea!.width)")
    
            if (CGRectContainsRect(area, sarea!))
            {
                count++
                if sview is CustomAnnotationView
                {
                    let annView = sview as! CustomAnnotationView
                    let ann2 = annView.annotation as! CustomPointAnnotation
                    print("\(count) \(ann2.pointId) \(ann2.title!)")
                }
            }
        }
        print("count = \(count)")
    }

    func setGoalPose(sender: AnyObject?)
    {
        print("Set Goal Button Clicked.")
        parent!.goal_set = parent!.MySbplWrapper.setGoalPose_wrapped(ann!.pointId)
        parent!.generateOptimalPlan()
        setPose("FinishFlag")
   }

    func setPose(poseImageName: String)
    {
        self.setSelected(false, animated: false)
    
        let flagPin = UIImage(named: poseImageName)
        replaceFlagsWithBlueBall(flagPin!)
        image = flagPin
    }
    
    func closeCallout(sender: AnyObject?)
    {
        self.setSelected(false, animated: false)
        if (ann?.type == 1)
        {
            image = blueBallImage
        }
        else
        {
            image = UIImage(named: "BlueFlagLeft")
        }
    }
    
    func setStartPose(sender: AnyObject?)
    {
        print("Set Start Button Clicked.")
        parent!.start_set = parent!.MySbplWrapper.setStartPose_wrapped(ann!.pointId)
        parent!.generateOptimalPlan()
        setPose("RedFlag")
    }
    
    /*
    func hideAnnotationCallout()
    {
        for ann1 : MKAnnotation in parent!.mapView.annotations
        {
            if let selected_ann = ann1 as? CustomPointAnnotation
            {
                if (selected_ann.pointId == ann!.pointId)
                {
                    parent!.mapView.deselectAnnotation(selected_ann, animated: false)
                }
            }
        }
    }
    
    func restoreAnnotation(ann0: CustomPointAnnotation)
    {
        if (ann0.type == 1)
        {
            let flagPin = UIImage(named: "BlueBall")
            let ann2 = CustomPointAnnotation(annotation: ann0, pinImage: flagPin);
            self.setSelected(false, animated: false)
    
            //dispatch_async(dispatch_get_main_queue())
            //{
                self.parent!.mapView.addAnnotation(ann2)
            //}
        }
    }
    */
    
    func replaceFlagsWithBlueBall(flagImage: UIImage)
    {
        for ann1 : MKAnnotation in parent!.mapView.annotations
        {
            if let ann0 = ann1 as? CustomPointAnnotation
            {
                //let ann0 = ann1 as! CustomPointAnnotation
                ann0.view?.setSelected(false, animated: false)
                let pinImage = ann0.view?.image
                if (pinImage == flagImage)
                {
                    ann0.view!.image = blueBallImage
                }
            }
        }
    }
    
    /*
    func deleteAnnotationsByPinImage(pinImage: String)
    {
        let pin = UIImage(named: pinImage)
        for ann1 : MKAnnotation in parent!.mapView.annotations
        {
            if let custom_ann = ann1 as? CustomPointAnnotation
            {
                let pinImage = custom_ann.pinImage
                if (pinImage == pin)
                {
                    let ann0 = ann1 as! CustomPointAnnotation
                    parent!.mapView.removeAnnotation(ann1)
                    restoreAnnotation(ann0)
                }
            }
        }
    }
    
    func deleteAnnotationsByPointId(pointId: Int64)
    {
        for ann : MKAnnotation in parent!.mapView.annotations
        {
            if let custom_ann = ann as? CustomPointAnnotation
            {
                if (custom_ann.pointId == pointId)
                {
                    parent!.mapView.removeAnnotation(ann)
                }
            }
        }
    }
    */
    
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
        
        var hitView = super.hitTest(point, withEvent: event)
        
        if let callout = calloutView {
            if (hitView == nil && selected) {
                hitView = callout.hitTest(point, withEvent: event)
            }
        }
        
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
        //print("CustomAnnotationView: pointInside")
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
