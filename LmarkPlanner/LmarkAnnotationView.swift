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

    class var reuseIdentifier:String {
        return "lmark"
    }
    
    var preventDeselection:Bool {
        return !hitOutside
    }
    
    var parent: ViewController?
    
    private var calloutView: CalloutView?
    private var hitOutside:Bool = true
    private let blueBallImage = UIImage(named: "BlueBall")
    private let pinkBallImage = UIImage(named: "PinkBall")
    private let greenBallImage = UIImage(named: "GreenBall")
    private let brownBallImage = UIImage(named: "BrownBall")
    private let orangeBallImage = UIImage(named: "OrangeBall")
    private let yellowBallImage = UIImage(named: "YellowBall")
    
    convenience init(annotation:MKAnnotation!) {
        self.init(annotation: annotation, reuseIdentifier: LmarkAnnotationView.reuseIdentifier)
        canShowCallout = false;
    }
    
    override func setSelected(let selected: Bool, animated: Bool)
    {
        //guard let lmark_ann = (sender.view as? MKAnnotationView)?.annotation as? MyAnnotation else { return }
        guard let ann = annotation as? LmarkAnnotation else
        //if !(annotation  is LmarkAnnotation)
        {
            print("This view can only be used for annotation of type  LmarkAnnotation!")
            return
        }
        
        //ann = annotation as? LmarkAnnotation
        
        let calloutViewAdded = calloutView?.superview != nil
        
        if (selected || !selected && hitOutside) {
            super.setSelected(selected, animated: animated)
        }
        
        self.superview?.bringSubviewToFront(self)
        
        if (selected && calloutView == nil)
        {
            let x = 0.5 * self.frame.size.width
            let y = -3.0 * self.frame.size.height
            var txt = ann.title
            if (ann.lmark.amenity.characters.count > 0)
            {
                txt = txt! + "\n" + ann.lmark.amenity
            }
            if (ann.lmark.street.characters.count > 0)
            {
                txt = txt! + "\n" + ann.lmark.street
            }
            //if (ann?.info?.characters.count > 0)
            //{
            //    txt = txt! + "\n" + ann!.info!
            //}
            //calloutView = CalloutView(frame: CGRectMake(0, 0, 150, 90), text: txt!, x: x, y: y, lat: ann.lmark.latitude, lon: ann.lmark.longitude)
            calloutView = CalloutView(frame: CGRectMake(0, 0, 150, 190), text: txt!, x: x, y: y, lat: ann.lmark.latitude, lon: ann.lmark.longitude)
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
                    let annView = sview as! LmarkAnnotationView
                    let ann2 = annView.annotation as! LmarkAnnotation
                    //print("\(count) \(ann2.lmark.pointId) \(ann2.title!)")
                }
            }
        }
        //print("count = \(count)")
    }

    func setGoalPose(ann: LmarkAnnotation)
    {
        let dir: CInt = 0
        var type: CInt = 0
        var roadId: Int64 = 0

        //print("Set Goal Button Clicked.")
        parent!.goal_set = parent!.MySbplWrapper.setGoalPose_wrapped(ann.lmark.pointId, &roadId, &type, dir)
        if (parent!.goal_set)
        {
            parent?.goal_pointId = ann.lmark.pointId
            parent?.goal_roadId = roadId
            parent?.goal_type = Int(type)
        }
        parent!.generateOptimalPlan()
        processGoalViews()
        processGreenViews()
        parent!.goalViews.append(self)
        setPose("FinishFlag")
        //setPose("BrownBall")
   }

    func setPose(poseImageName: String)
    {
        self.setSelected(false, animated: false)
        let flagPin = UIImage(named: poseImageName)
        //replaceFlagsWithBlueBall(flagPin!)
        image = flagPin
        //replaceFlagsWithBlueBall(greenBallImage!)
        //if (image == greenBallImage)
        //{
        //    image = blueBallImage
        //}
    }
    
    func closeCallout()
    {
        self.setSelected(false, animated: false)
        //if (image == pinkBallImage)
        if (image == greenBallImage)
        {
            image = blueBallImage
        }
        
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
    
    func setStartPose(ann: LmarkAnnotation)
    {
        let dir: CInt = 0
        var type: CInt = 0
        var roadId: Int64 = 0

        //print("Set Start Button Clicked.")
        parent!.start_set = parent!.MySbplWrapper.setStartPose_wrapped(ann.lmark.pointId, &roadId, &type, dir)
        if (parent!.start_set)
        {
            parent?.start_pointId = ann.lmark.pointId
            parent?.start_roadId = roadId
            parent?.start_type = Int(type)
        }
        parent!.generateOptimalPlan()
        
        processStartViews()
        processGreenViews()
        parent!.startViews.append(self)
        
        setPose("RedFlag")
        
        //setPose("PinkBall")
    }
    
    /*
    func hideAnnotationCallout()
    {
        for ann1 : MKAnnotation in parent!.mapView.annotations
        {
            if let selected_ann = ann1 as? LmarkAnnotation
            {
                if (selected_ann.pointId == ann!.pointId)
                {
                    parent!.mapView.deselectAnnotation(selected_ann, animated: false)
                }
            }
        }
    }
    
    func restoreAnnotation(ann0: LmarkAnnotation)
    {
        if (ann0.type == 1)
        {
            let flagPin = UIImage(named: "BlueBall")
            let ann2 = LmarkAnnotation(annotation: ann0, pinImage: flagPin);
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
            if let ann0 = ann1 as? LmarkAnnotation
            {
                //ann0.view?.setSelected(false, animated: false)
                let pinImage = ann0.view?.image
                if (pinImage == flagImage)
                {
                    ann0.view!.image = blueBallImage
                }
            }
        }
    }
    
    func processStartViews()
    {
        for view in parent!.startViews
        {
            if let lview = view as? LmarkAnnotationView
            {
                //ann0.view?.setSelected(false, animated: false)
                lview.image = blueBallImage
            }
        }
        parent?.startViews.removeAll()
    }
    
    func processGoalViews()
    {
        for view in parent!.goalViews
        {
            if let lview = view as? LmarkAnnotationView
            {
                //ann0.view?.setSelected(false, animated: false)
                lview.image = blueBallImage
            }
        }
        parent?.goalViews.removeAll()
    }
    
    func processGreenViews()
    {
        for view in parent!.greenViews
        {
            if let lview = view as? LmarkAnnotationView
            {
                //ann0.view?.setSelected(false, animated: false)
                lview.image = blueBallImage
            }
        }
        parent?.greenViews.removeAll()
    }
    
    /*
    func deleteAnnotationsByPinImage(pinImage: String)
    {
        let pin = UIImage(named: pinImage)
        for ann1 : MKAnnotation in parent!.mapView.annotations
        {
            if let custom_ann = ann1 as? LmarkAnnotation
            {
                let pinImage = custom_ann.pinImage
                if (pinImage == pin)
                {
                    let ann0 = ann1 as! LmarkAnnotation
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
            if let custom_ann = ann as? LmarkAnnotation
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
