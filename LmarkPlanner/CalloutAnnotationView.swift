//
//  CalloutAnnotationView.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 6/7/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit

class CalloutAnnotationView: MKAnnotationView
{
    
    //let calloutView = CalloutView()
    
    var imageView : UIImageView?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    
        //if !(annotation is CustomPointAnnotation) {

          //  assert(false, "This annotation view class should only be used with CustompointAnnotations objects.")
        //}
        
        //addSubview(calloutView)//
        imageView = UIImageView(frame: CGRectMake(0, 0, 22, 22))
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //addSubview(calloutView)
    }
    
    /*
    class var reuseIdentifier:String{
        return "CalloutAnnotationView"
    }
    
    private var calloutView:CalloutView?
    
    private var hitOutside:Bool = true
    
    var preventDeselection:Bool {
        return !hitOutside
    }
    
    convenience init(annotation:MKAnnotation) {
        self.init(annotation: annotation, reuseIdentifier: CalloutAnnotationView.reuseIdentifier)
        canShowCallout = false;
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        let calloutViewAdded = calloutView?.superview != nil
        
        if (selected || !selected && hitOutside) {
                super.setSelected(selected, animated: animated)
        }
        
        self.superview?.bringSubviewToFront(self)

        if (calloutView == nil) {
            calloutView = CalloutView(coder: <#T##NSCoder#>)
        }
        
    }
    */

}
