//
//  ViewController.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 2/24/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UIGestureRecognizerDelegate { //, CLLocationManagerDelegate {
    
    // MARK: Properties
    
    typealias Payload = [String: AnyObject]
    
    let dirRequest = MKDirectionsRequest()
    var landmarks = [MKMapItem]()
    var lmarks = [Lmark]()
    var isections = [Intersection]()
    var steps = [PlanStep]()
    var safety_steps = [PlanStep]()
    
    var sol_steps = [SolutionStep]()
    var safety_sol_steps = [SolutionStep]()
    
    var initialLocation = CLLocation()
    var span = MKCoordinateSpan()
    var distance: CLLocationDistance = 650
    var pitch: CGFloat = 0   //65
    var heading = 0.0
    var camera: MKMapCamera?
    
    var nodes = [OsmNode]()
    var ways = [OsmWay]()
    var polyline_color = UIColor()
    var snp : MKMapSnapshot?

    var MySbplWrapper = CPPWrapper()
    var start_set: Bool = false
    var goal_set: Bool = false
    
    //let locationManager = CLLocationManager()
    
    @IBOutlet var mapTypeButton: UIBarButtonItem!
    @IBOutlet var lmarksButton: UIBarButtonItem!
    @IBOutlet var zoomInButton: UIBarButtonItem!
    @IBOutlet var osmButton: UIBarButtonItem!
    @IBOutlet var animateButton: UIBarButtonItem!
    @IBOutlet var showPlanButton: UIBarButtonItem!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var searchText: UITextField!
    
    var intersections:[Intersection] = [
        Intersection(id:1, index:0, latutude: 40.443931, longitude: -79.942222, location: "5032 Forbes Ave"),
        Intersection(id:1, index:1, latutude: 40.444455, longitude: -79.941949, location: "Forbes Ave/Morewood Pl"),
        Intersection(id:1, index:2, latutude: 40.444620, longitude: -79.942988, location: "Forbes Ave/Morewood Ave"),
        Intersection(id:1, index:3, latutude: 40.444509, longitude: -79.946759, location: "Forbes Ave/S Neville St"),
        Intersection(id:1, index:4, latutude: 40.444426, longitude: -79.948679, location: "Forbes Ave/S Craig St"),
        Intersection(id:1, index:5, latutude: 40.443909, longitude: -79.950741, location: "Forbes Ave/S Bellefield St"),
        Intersection(id:1, index:6, latutude: 40.443182, longitude: -79.953536, location: "Forbes Ave/Bigelow Blvd"),
        Intersection(id:1, index:7, latutude: 40.443522, longitude: -79.953718, location: "4449 Bigelow Blvd"),
        Intersection(id:1, index:8, latutude: 40.444423, longitude: -79.954810, location: "Bigelow Blvd/Fifth Ave"),
        Intersection(id:1, index:9, latutude: 40.442506, longitude: -79.957481, location: "Fifth Ave/S Bouquet St"),
        Intersection(id:1, index:10, latutude: 40.441264, longitude: -79.959172, location: "Fifth Ave/Meyran Ave"),
        Intersection(id:1, index:11, latutude: 40.439773, longitude: -79.961194, location: "3420 Fifth Ave")
    ]
    
    var safety_intersections:[Intersection] = [
        Intersection(id:1, index:0, latutude: 40.442955, longitude: -79.954348, location: "3920 Forbes Ave"),
        Intersection(id:1, index:1, latutude: 40.442643, longitude: -79.955471, location: "3942 Forbes Ave"),
        Intersection(id:1, index:2, latutude: 40.441933, longitude: -79.956442, location: "Forbes Ave/S Bouquet St"),
        Intersection(id:1, index:3, latutude: 40.442506, longitude: -79.957481, location: "Fifth Ave/S Bouquet St"),
        Intersection(id:1, index:4, latutude: 40.441264, longitude: -79.959172, location: "Fifth Ave/Meyran Ave"),
        Intersection(id:1, index:5, latutude: 40.439773, longitude: -79.961194, location: "3420 Fifth Ave")
    ]
    
    // MARK: Methods
    
    @IBAction func showPlanSteps(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowTable", sender: sender)
    }
    
    @IBAction func showDirections(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowTable", sender: sender)
    }
    
    @IBAction func animateCamera(sender: AnyObject) {
        
        mapView.mapType = .SatelliteFlyover
        pitch = 65
        
        let coordinate = CLLocationCoordinate2D(latitude: 40.444718, longitude: -79.947537)

        camera = MKMapCamera(lookingAtCenterCoordinate: coordinate,
            fromDistance: distance,
            pitch: pitch,
            heading: heading)

        UIView.animateWithDuration(20.0, animations: {
            self.camera!.heading += 180
            self.camera!.pitch = 25
            self.mapView.camera = self.camera!
        })
    }
    
    @IBAction func cancelToLandmarksViewController(seque:UIStoryboardSegue) {
        
    }
    
    @IBAction func saveLandmarkDetail(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func cancelToPlanViewController(seque:UIStoryboardSegue) {
        
    }
    
    @IBAction func savePlanDetail(segue:UIStoryboardSegue) {
        
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) ->MKOverlayRenderer! {
        if overlay.isKindOfClass(MKCircle) {
            let circleView = MKCircleRenderer(overlay: overlay)
            circleView.strokeColor = UIColor.redColor()
            circleView.lineWidth = 5.0
            return circleView
        } else if overlay.isKindOfClass(MKTileOverlay) {
            guard let tileOverlay = overlay as? MKTileOverlay else {
                    return MKOverlayRenderer()
            }
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        } else if overlay.isKindOfClass(MKPolyline){
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = polyline_color //UIColor.blueColor()
            renderer.lineWidth = 4.0
            renderer.lineDashPattern = [3,5]
            return renderer
        }
        return nil
    }
    
    // MARK: Annotation Delegate Methods
    
    /*
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        //if let view1 = view as? CustomAnnotationView {
            //if view1.preventDeselection {
            //    mapView.selectAnnotation(view.annotation!, animated: false)
            //}
        //}
    }
    */
    
    func updatePinPosition(pin:CustomAnnotationView) {
        let defaultShift:CGFloat = 80 //50
        let pinPosition = CGPointMake(pin.frame.midX, pin.frame.maxY)
        let y = pinPosition.y - defaultShift
        let controlPoint = CGPointMake(pinPosition.x, y)
        let controlPointCoordinate = mapView.convertPoint(controlPoint, toCoordinateFromView: mapView)
        mapView.setCenterCoordinate(controlPointCoordinate, animated: true)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        print("didSelectAnnotationView: Selected annotation")
        
        //if let view1 = view as? CustomAnnotationView {
        //    updatePinPosition(view1)
        //}
        
        /*
        if let ann = view.annotation as? CustomPointAnnotation
        {
            let lat = 40.4431911837908 //ann.coordinate.latitude
            let lon = -79.9508464336395 //ann.coordinate.longitude
            //let name = ann.title
            //let addr = ""
        
            //var coord = item.placemark.location!.coordinate
            var photoImage = UIImage()
            
            let coord_test = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            //self.takeSnapshot(self.mapView, coord:ann.coordinate, completion: {(result) -> Void in
            self.takeSnapshot(self.mapView, coord:coord_test, completion: {(result) -> Void in
                photoImage = result!
            })
            //let pinImage = UIImage(named: "BlueBall")
            
            //ann.photoImage = photoImage
            view.image = photoImage
        }
        */
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        return
        
        let ann = view.annotation as! CustomPointAnnotation
        let placeName = ann.title
        let placeInfo = ann.subtitle!
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        func setStartHandler(act:UIAlertAction!) {
            start_set = self.MySbplWrapper.setStartPose_wrapped(ann.pointId)
            generateOptimalPlan()
        }
        
        func setGoalHandler(act:UIAlertAction!) {
            goal_set = self.MySbplWrapper.setGoalPose_wrapped(ann.pointId)
            generateOptimalPlan()
        }
        
        ac.addAction(UIAlertAction(title: "Set as Start", style: .Default, handler: setStartHandler))
        ac.addAction(UIAlertAction(title: "Set as Goal", style: .Default, handler: setGoalHandler))

        presentViewController(ac, animated:true, completion: nil)
    }
    
    func generateOptimalPlan()
    {
        if (start_set && goal_set)
        {
            mapView.removeOverlays(mapView.overlays)
            print("Number of Overlays: \(mapView.overlays.count)")
            
            //self.sol_steps.removeAll()
            
            var pathlen: CInt = 0
            var path: NSString? = nil
            let plan_found = self.MySbplWrapper.generatePlan_wrapped(&pathlen, &path)
            if (plan_found && pathlen > 0)
            {
                DisplayPath(path!)
            }
        }
        else
        {
            //dispatch_async(dispatch_get_main_queue()) {

                let ac = UIAlertController(title: "Error", message: "msg", preferredStyle: .Alert)
                if (!self.start_set)
                {
                    dispatch_async(dispatch_get_main_queue()) {
                        ac.addAction(UIAlertAction(title: "Start state not set!", style: .Default, handler: nil))
                    }
                }
                else
                {   dispatch_async(dispatch_get_main_queue()) {
                        ac.addAction(UIAlertAction(title: "Goal state not set!", style: .Default, handler: nil))
                    }
                }
            //}
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) ->MKAnnotationView! {
        //print("delegate viewForAnnotation called")
        
        //if annotation is MKUserLocation {
        if !(annotation is CustomPointAnnotation) && !(annotation is SnapshotImageAnnotation) {
            return nil
        }
        
        if annotation is CustomPointAnnotation {
            //print("ViewForAnnotation: CustomPointAnnotation clicked.")
            
            let reuseId = "test"
            var annView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if annView == nil {
                annView = CustomAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            } else {
                annView?.annotation = annotation
            }
            
            let ann = annotation as! CustomPointAnnotation
            annView?.image = ann.pinImage
            let cView = annView as! CustomAnnotationView
            cView.parent = self
            annView?.canShowCallout = false
            ann.view = cView
            if (ann.type == 0)
            {
                cView.setSelected(true, animated: false)
            }
            else
            {
                cView.setSelected(false, animated: false)
            }
            return annView

        } else if annotation is SnapshotImageAnnotation {
            let reuseId = "snap"
            var annView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if annView == nil {
                annView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                annView?.canShowCallout = true
            } else {
                annView?.annotation = annotation
            }
            configureDetailView(annView!)
            
            return annView
        }
        return nil
    }


    func configureDetailView(annotationView: MKAnnotationView) {
        let snapshotView = UIView(frame: CGRect (x: 0, y: 0, width: 300, height: 300))
        let options = MKMapSnapshotOptions()
        options.size = CGSize(width: 300, height: 300)
        options.mapType = .SatelliteFlyover
        
        let camera = MKMapCamera(lookingAtCenterCoordinate: annotationView.annotation!.coordinate, fromDistance: 500, pitch: 65, heading: 0)
        options.camera = camera
        
        let snapshotter = MKMapSnapshotter(options: options)
        
        snapshotter.startWithCompletionHandler { (snapshot, error) -> Void
            in
            if let actualSnapshot = snapshot {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
                imageView.image = actualSnapshot.image
                snapshotView.addSubview(imageView)
            }
        }
        annotationView.detailCalloutAccessoryView = snapshotView
    
        
        
        /*
        let width = 300
        let height = 200
        
        let snapshotView = UIView()
        let views = ["snapshotView": snapshotView]
        snapshotView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[snapshotView(300)]", options: [], metrics: nil, views: views))
        snapshotView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[snapshotView(200)]", options: [], metrics: nil, views: views))
        
        let options = MKMapSnapshotOptions()
        options.size = CGSize(width: width, height: height)
        options.mapType = .SatelliteFlyover
        options.camera = MKMapCamera(lookingAtCenterCoordinate: annotationView.annotation!.coordinate, fromDistance: 250, pitch: 65, heading: 0)
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.startWithCompletionHandler( {snapshot, error in
            if snapshot != nil {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                imageView.image = snapshot!.image
                snapshotView.addSubview(imageView)
            }
        })
        annotationView.detailCalloutAccessoryView = snapshotView
*/
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        mapView.removeAnnotations(mapView.annotations)
        searchText.resignFirstResponder()
        
        searchInMap(searchText.text!, lat: initialLocation.coordinate.latitude, lon: initialLocation.coordinate.longitude, span: span, mode: 2)
        
        _ = initEnv()
        return true
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        mapTypeButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        animateButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        osmButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        zoomInButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        lmarksButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        showPlanButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        */
        
        //Show current location
        //self.locationManager.delegate = self
        //self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //self.locationManager.requestWhenInUseAuthorization()
        //self.locationManager.startUpdatingLocation()
        //self.mapView.showsUserLocation = true
        
        initialLocation = CLLocation(latitude: 40.443660, longitude: -79.951712)
        span = MKCoordinateSpanMake(0.022, 0.022)
        //span = MKCoordinateSpanMake(0.011, 0.011)
        
        let coordinateRegion = MKCoordinateRegionMake(initialLocation.coordinate, span)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.showsCompass = false
        mapView.showsPointsOfInterest = false
        mapView.showsScale = false
        mapView.showsTraffic = false
        
        //Gesture recognizer
        let gst = UITapGestureRecognizer(target: self, action: "processGesture:")
        mapView.addGestureRecognizer(gst)
        gst.numberOfTapsRequired = 1

        //gst.minimumPressDuration = 2.0
        
        //mapView.mapType = .SatelliteFlyover
    
        //camera = MKMapCamera(lookingAtCenterCoordinate: coordinate,
        //    fromDistance: distance,
        //    pitch: pitch,
        //    heading: heading)
        //mapView.camera = camera!
        
        
        //LoadSampleLmarks()
        //LoadSampleDirections()
        //LoadSampleSafetyDirections()
        
        //runSampleSearches()
        
        //displaySampleData()
        
/*
        //self.dirRequest.source = srcItem
        //self.dirRequest.destination = dstItem
        //self.dirRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: self.dirRequest)
        directions.calculateDirectionsWithCompletionHandler() { (response, error) in
            guard let response = response else {
                print("Directions error: \(error)")
                return
            }
    
            //self.showRoute(response)
        }
*/
    }
    
    // MARK: Location Delegate Methods
    
    /*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    */
    
    func processGesture(gestureRecognizer: AnyObject?) //gestureRecognizer:UIGestureRecognizer)
    {
        if (gestureRecognizer is UIGestureRecognizer)
        //if gestureRecognizer.state == UIGestureRecognizerState.Began
        {
            let touchPoint = gestureRecognizer!.locationInView(mapView)
            if let subView = mapView.hitTest(touchPoint, withEvent: nil)
            {
                if subView is MKAnnotationView
                {
                    print("processGesture: Annotation tapped")
                    let annView  = subView as! MKAnnotationView
                    //let ann = annView.annotation
                    //if ann is CustomPointAnnotation
                    if (annView is CustomAnnotationView)
                    {
                        //let cpa = ann as! CustomPointAnnotation
                        //if cpa.pinImage == UIImage(named: "BlueBall")
                        //{
                            print("processGesture: CustomAnnotationView tapped. Exiting.")
                            return
                        //}
                    }
                    else if (annView is CalloutView)
                    {
                        print("processGesture: CalloutView tapped. Exiting.")
                        return
                    }
                }
            }
            
            let coord = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            print("touchPoint coord: \(coord.latitude) \(coord.longitude)")
            
            //Find closest intersection
            let getLat: CLLocationDegrees = coord.latitude
            let getLon: CLLocationDegrees = coord.longitude
            let loc: CLLocation =  CLLocation(latitude: getLat, longitude: getLon)
            
            var closestLocation: CLLocation?
            var smallestDistance: CLLocationDistance?
            var pointId: Int64?
            var roadId: Int64?
            var index: Int = -1
            
            for isection in intersections {
                let iloc = CLLocation(latitude: isection.latitude, longitude: isection.longitude)
                let distance = loc.distanceFromLocation(iloc)
                if smallestDistance == nil || distance < smallestDistance {
                    closestLocation = iloc
                    smallestDistance = distance
                    pointId = isection.id
                    //roadId = isection.
                    index = isection.index
                }
            }
            print("smallestDistance = \(smallestDistance) id = \(pointId)")
            let location = intersections[index].location
            
            //Create temporary pin annotation with blue flag
            let blueFlagPin = UIImage(named:"BlueFlagLeft")
            let ann = CustomPointAnnotation(coord: closestLocation!.coordinate, name: String(location), address: "", pinImage: blueFlagPin!, photoImage: nil, pointId: pointId!, roadId: 0, type: 0)
            self.mapView.addAnnotation(ann)
        }
    }

    func deleteAnnotationsByPinImage(pinImage: String)
    {
        let pin = UIImage(named: pinImage)
        for ann : MKAnnotation in mapView.annotations
        {
            if let custom_ann = ann as? CustomPointAnnotation
            {
                let pinImage = custom_ann.pinImage
                if (pinImage == pin)
                {
                    mapView.removeAnnotation(ann)
                }
            }
        }
    }
    
    func deleteAnnotationsByPointId(pointId: Int64)
    {
        for ann : MKAnnotation in mapView.annotations
        {
            if let custom_ann = ann as? CustomPointAnnotation
            {
                if (custom_ann.pointId == pointId)
                {
                    mapView.removeAnnotation(ann)
                }
            }
        }
    }
    
    /*
    func createCustomPointAnnotation(lat: Double, lon: Double, name: String, address: String, pin: UIImage, photo: UIImage, pointId: Int64, roadId: Int64, type: Int) -> CustomPointAnnotation
    {
        let ann = CustomPointAnnotation()
        ann.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        ann.title = name
        ann.subtitle = address
        ann.pinImage = pin
        ann.photoImage = photo
        ann.pointId = pointId
        ann.roadId = roadId
        ann.type = type
        return ann
    }
    
    func createCustomPointAnnotation(lat: Double, lon: Double, name: String, address: String, pin: UIImage, pointId: Int64, roadId: Int64, type: Int) -> CustomPointAnnotation
    {
        let ann = CustomPointAnnotation()
        ann.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        ann.title = name
        ann.subtitle = address
        ann.pinImage = pin
        ann.pointId = pointId
        ann.roadId = roadId
        ann.type = type
        return ann
    }
    */

    
    /*
    func takeSnapshot(mapView: MKMapView, filename: String, completion: ((result:UIImage?) -> Void)!)
    {
        //let snapshotView = UIView(frame: CGRect (x: 0, y: 0, width: 300, height: 300))

        let options = MKMapSnapshotOptions()
        //options.region = snapshotView.frame.   //mapView.region
        //options.size = mapView.frame.size;
        //options.scale = UIScreen.mainScreen().scale
        
        
        options.size = CGSize(width: 300, height: 300)
        options.mapType = .SatelliteFlyover
        
        let camera = MKMapCamera(lookingAtCenterCoordinate: self.initialLocation.coordinate, fromDistance: 500, pitch: 65, heading: 0)
        options.camera = camera
        
        let semaphore = dispatch_semaphore_create(0)
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        let snapshotter = MKMapSnapshotter(options: options)
        //snapshotter.startWithCompletionHandler()

        snapshotter.startWithQueue(backgroundQueue, completionHandler:  { (snapshot: MKMapSnapshot?, error: NSError?) -> Void in
 
            guard (snapshot != nil) else {
                    print("Snapshot error:\(error)")
                    dispatch_semaphore_signal(semaphore)
                    return
                    //completion(result:nil)
            }
            //return snapshot!.image
            completion(result: snapshot!.image)
        
            //let data = UIImagePNGRepresentation(snapshot!.image)
            //let filename = self.getDocumentsDirectory().stringByAppendingPathComponent("\(filename).png")
            //data?.writeToFile(filename, atomically: true)
            dispatch_semaphore_signal(semaphore)
        })
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3*Double(NSEC_PER_SEC)))
        dispatch_semaphore_wait(semaphore, delayTime)
        
    }
    */
    
    func takeSnapshot(mapView: MKMapView, coord: CLLocationCoordinate2D, completion: ((result:UIImage?) -> Void)!)
    {
        //let coordSpan = MKCoordinateSpan(latitudeDelta: 0.0000000001, longitudeDelta: 0.0000000001)
        let options = MKMapSnapshotOptions()
        //let region = MKCoordinateRegion(center: coord, span: coordSpan)
        let region = MKCoordinateRegionMakeWithDistance(coord, 20.0, 20.0)
        options.region = region
        //options.size = mapView.frame.size;
        options.scale = UIScreen.mainScreen().scale
        options.size = CGSize(width: 200, height: 200)
        options.mapType = .HybridFlyover //.SatelliteFlyover
        options.showsPointsOfInterest = true
        options.showsBuildings = true
        
        let eyeCoord = CLLocationCoordinate2D(latitude: coord.latitude+0.00050, longitude: coord.longitude)
        let eyeAlt = CLLocationDistance(0.0)
        let BellefiedHallCoord = CLLocationCoordinate2D(latitude: 40.4453588019383, longitude: -79.950951061835)
        let IntersCoord = CLLocationCoordinate2D(latitude: 40.443922, longitude: -79.950749)
        
        let camera = MKMapCamera(lookingAtCenterCoordinate: IntersCoord, fromDistance: 20, pitch: 45, heading: 180)
        //let camera = MKMapCamera(lookingAtCenterCoordinate: coord, fromEyeCoordinate: eyeCoord, eyeAltitude: eyeAlt)
        
        camera.altitude = 20.0
        //camera.centerCoordinate = coord
        options.camera = camera
        
        let semaphore = dispatch_semaphore_create(0)
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        let snapshotter = MKMapSnapshotter(options: options)
        //snapshotter.startWithCompletionHandler()
        
        snapshotter.startWithQueue(backgroundQueue, completionHandler:  { (snapshot: MKMapSnapshot?, error: NSError?) -> Void in
            
            guard (snapshot != nil) else {
                print("Snapshot error:\(error)")
                dispatch_semaphore_signal(semaphore)
                return
                //completion(result:nil)
            }
            completion(result: snapshot!.image)
            dispatch_semaphore_signal(semaphore)
        })
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3*Double(NSEC_PER_SEC)))
        dispatch_semaphore_wait(semaphore, delayTime)
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func AddLandmark(name: String, description: String, type: String, address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoName: String, pinName: String, pointId: Int64, roadId: Int64) {
        
        var photo: UIImage
        if !photoName.isEmpty
        {
            photo = UIImage(named:photoName)!
        }
        else
        {
            photo = UIImage(named:"UniversityCenter")!
        }
        let pin = UIImage(named:pinName)
        
        let lmark = Lmark(name: name, description: description, type: type, address: address, latitude: latitude, longitude: longitude, photo: photo, pin: pin!, pointId: pointId, roadId: roadId)!
        lmarks.append(lmark)
    }
    
    func AddLandmark(name: String, description: String, type: String, address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, photo: UIImage, pinName: String, pointId: Int64, roadId: Int64) {
        
        //let photo = UIImage(named:photoName)
        let pin = UIImage(named:pinName)
        
        let lmark = Lmark(name: name, description: description, type: type, address: address, latitude: latitude, longitude: longitude, photo: photo, pin: pin!, pointId: pointId, roadId: roadId)!
        lmarks.append(lmark)
    }
    
    // MARK: Load sample data

    func LoadSampleLmarks()
    {
        AddLandmark("University Center", description: "Carnegie Mellon University", type: "building", address: "5032 Forbes Ave", latitude: 40.443931, longitude: -79.942222, photoName: "UniversityCenter", pinName: "BlueFlagLeft", pointId: 1, roadId: 1)
        
        AddLandmark("Hamburg Hall", description:"Carnegie Mellon University", type: "building", address: "4800 Forbes Ave", latitude: 40.444307, longitude: -79.945720, photoName: "HeinzCollege", pinName: "BlueBall", pointId: 1, roadId: 1)
        
        AddLandmark("Starbucks", description: "Coffee Shop", type: "restaurant", address: "417 Craig St", latitude: 40.444658, longitude: -79.948492, photoName: "Starbucks", pinName: "BlueBall", pointId: 1, roadId: 1)
        
        AddLandmark("Carnegie Museum of Natural History", description: "", type: "museum", address: "4400 Forbes Ave", latitude: 40.443466, longitude: -79.950154, photoName: "MuseumOfNaturalHistory", pinName: "BlueBall", pointId: 1, roadId: 1)
        
        AddLandmark("Opa Gyro", description: "Cafe", type: "restaurant", address: "4208 Forbes Ave", latitude: 40.443147, longitude: -79.953155, photoName: "Gyro", pinName: "BlueBall", pointId: 1, roadId: 1)
        
        AddLandmark("Cathedral of Learning", description: "University of Pittsburgh", type: "building", address: "4301 Fifth Ave", latitude: 40.444378, longitude: -79.952799, photoName: "CathedralOfLearning", pinName: "BlueBall", pointId: 1, roadId: 1)
        
        AddLandmark("Hilman Library", description: "University of Pittsburgh", type: "building", address: "3960 Forbes Ave", latitude: 40.442553, longitude: -79.954137, photoName: "HilmanLibrary", pinName: "PinkBall", pointId: 1, roadId: 1)
        
        AddLandmark("Soldiers and Sailors Lawn", description: "Gen Matthew B Ridgway", type: "Memorial", address: "Fifth, Ave", latitude: 40.444279, longitude: -79.955271, photoName: "SoldiersAndSailorsLawn", pinName: "BlueBall", pointId: 1, roadId: 1)
        
        AddLandmark("Litchfield Towers", description: "Student Dormitory. University of Pittsburgh", type: "building", address: "3990 Fifth Ave", latitude: 40.442563, longitude: -79.957175, photoName: "LitchfieldTowers", pinName: "BlueBall", pointId: 1, roadId: 1)
        
        AddLandmark("Campus Bookstore", description: "campusbookstore.com", type: "store", address: "3610 Fifth Ave", latitude: 40.441429, longitude: -79.958662, photoName: "CampusBookstore", pinName: "BlueBall", pointId: 1, roadId: 1)
        
        AddLandmark("Nellie's Sandwiches", description: "Middle Estern Sandwich Joint", type: "restaurant", address: "3524 Fifth Ave", latitude: 40.441081, longitude: -79.959120, photoName: "NelliesSandwiches", pinName: "BlueBall", pointId: 1, roadId: 1)
        
        AddLandmark("Five Guys Burgers and Fries", description: "Fast-food burger and fries chain", type: "restaurant", address: "117 S Bouquet St", latitude: 40.442245, longitude: -79.956725, photoName: "FiveGuys", pinName: "BlueBall", pointId: 1, roadId: 1)
        
        AddLandmark("The Pitt Shop", description: "Bruce Hall", type: "store", address: "3939 Forbes Ave", latitude: 40.442764, longitude: -79.955601, photoName: "ThePittShop", pinName: "BlueBall", pointId: 1, roadId: 1)
        
        AddLandmark("The Original Hot Dog Shop", description: "Retro spot for hot dogs since 1960", type: "restaurant", address: "3901 Forbes Ave", latitude: 40.442145, longitude: -79.956509, photoName: "TheOriginalHotDog", pinName: "BlueBall", pointId: 1, roadId: 1)
        
        AddLandmark("Children's Hospital", description: "UPMC", type: "Hospital", address: "3420 Fifth Ave", latitude: 40.439657, longitude: -79.961088, photoName: "ChildrensHospital", pinName: "PinkFlagLeft", pointId: 1, roadId: 1)
        
        
/*
        //Landmark(name: "Gates Center for Computer Science", description: "Carnegie Mellon University", type: "building", latitude: 40.443293, longitude: -79.945045, address: "", image: "GatesHillmanCenter.png", pin: "BlueBall.png"),
        //Landmark(name: "Starbucks", description: "Cafe", type: "restaurant", latitude: 40.443666, longitude: 79.955674, address: "4022 Fifth Ave", image: "StarbacksOnFifth.png", pin: "BluePushPin24.png"),
        // Landmark(name: "Pittsburgh Region International", description: "Non-profit Organization", type: "building", latitude: 40.443568, longitude: -79.956547, address: "4001 Fifth Ave", image: "", pin: "BlueBall.png"),
        //Landmark(name: "Dollar Bank", description: "dollarbank.com", type: "bank", latitude: 40.441978, longitude: -79.957847, address: "3714 Fifth Ave", image: "DollarBank.png", pin: "BlueBall.png"),
        //Landmark(name: "UPMC Department of Urology - Kaufmann Medical Building", description: "upmc.com", type: "building", latitude: 40.440416, longitude: -79.960370, address: "3471 Fifth Ave", image: "DepartmentOfUrology.png", pin: "BlueBall.png"),
        //Landmark(name: "UPMC Montefiore Inpatient Rehab", description: "Rehabilitation Center", type: "hospital", latitude: 40.440085, longitude: -79.960834, address: "3459 Fifth Ave", image: "MontefioreRehab.png", pin: "BlueBall.png"),
*/
    }
    
    func LoadSampleDirections() {
        steps.append(PlanStep(seq: 0, name: "", instructions: "Start at the Carnegie Mellon University Center and go straight toward Forbes Ave. Turn left onto Forbes Ave.", image: "UniversityCenter", icon: "ArrowLeftTurn"))
        
        //PlanStep(seq: 1, name: "", instructions: "Turn left onto Forbes Ave.", image: "CmuUniversityCenter.png", icon: "Arrow-turn-left-icon.png")
        
        steps.append(PlanStep(seq: 2, name: "", instructions: "Go west on Forbes Ave until you reach Hamburg Hall on your left", image: "HeinzCollege", icon: "ArrowUp"))
        
        steps.append(PlanStep(seq: 3, name: "", instructions: "Continue west on Forbes Ave until you see Starbucks Cafe on your right", image: "Starbucks", icon: "ArrowUp"))
        
        steps.append(PlanStep(seq: 4, name: "", instructions: "Continue west on Forbes Ave until you see Carnegie Museum of Natural History on your left", image: "MuseumOfNaturalHistory", icon: "ArrowUp"))
        
        steps.append(PlanStep(seq: 5, name: "", instructions: "Continue west on Forbes Ave until you see Gyro Cafe on your left. Turn right onto Bigelow Blvd.", image: "Gyro", icon: "ArrowRightTurn"))
        
        steps.append(PlanStep(seq: 6, name: "", instructions: "If you see Hilman Library on your left, you missed your turn. Press the button to see new directions.", image: "HilmanLibrary", icon: "fake.png"))
        
        //PlanStep(seq: 6, name: "", instructions: "Turn left onto Bigelow Blvd.", image: "Gyro.png", icon: "Arrow-turn-left-icon.png"),
        
        steps.append(PlanStep(seq: 7, name: "", instructions: "Go north on Bigelow Blvd until you see Cathedral of Learning on your right.", image: "CathedralOfLearning", icon: "ArrowUp"))
        
        steps.append(PlanStep(seq: 8, name: "", instructions: "Continue north on Bigelow Blvd until you see the Soldiers and Sailors Lawn on your right. Turn left onto Fifth Ave.", image: "SoldiersAndSailorsLawn", icon: "ArrowLeftTurn"))
        
        //PlanStep(seq: 9, name: "", instructions: "Turn left onto Fifth Ave.", image: "SoldiersAndSailorsLawn", icon: "Arrow-turn-left-icon.png"),
        //PlanStep(seq: 10, name: "", instructions: "Go west on Fifth Ave until you see the Starbucks Cafe on your left.", image: "StarbacksOnFifth.png", icon: "arrow-left-icon.png"),
        //PlanStep(seq: 11, name: "", instructions: "Continue west on Fifth Ave until you see the Pittsburgh Region International on your right.", image: "PittsburghRegion.png", icon: "arrow-left-icon.png"),
        
        steps.append(PlanStep(seq: 12, name: "", instructions: "Continue west on Fifth Ave until you see the Litchfield Towers on your left.", image: "LitchfieldTowers", icon: "ArrowUp"))
        
        steps.append(PlanStep(seq: 13, name: "", instructions: "Continue west on Fifth Ave until you see the Campus Bookstore on your left.", image: "CampusBookstore", icon: "ArrowUp"))
        
        //PlanStep(seq: 14, name: "", instructions: "Continue west left on Fifth Ave until you see the Dollar Bank on your left.", image: "DollarBank.png", icon: "arrow-left-icon.png"),
        
        //PlanStep(seq: 15, name: "", instructions: "Continue west on Fifth Ave until you see the Dollar Bank on your left.", image: "DollarBank.png", icon: "arrow-left-icon.png"),
        
        steps.append(PlanStep(seq: 16, name: "", instructions: "Continue west on Fifth Ave until you see the Nellie's Sanfwiches Cafe on your left.", image: "NelliesSandwiches", icon: "ArrowUp"))
        
        //PlanStep(seq: 17, name: "", instructions: "Continue west on Fifth Ave until you see the Kaufman Medical Building on your right.", image: "DepartmentOfUrology.png", icon: "arrow-left-icon.png"),
        
        //PlanStep(seq: 18, name: "", instructions: "Continue west on Fifth Ave until you see the UPMC Montefiore Inpatient Rehab on your right.", image: "MontefioreRehab.png", icon: "arrow-left-icon.png"),
        
        steps.append(PlanStep(seq: 19, name: "", instructions: "Continue west on Fifth Ave until you see the Children's Hospital of Pittsburgh of UPMC on your right. You have reached you destination.", image: "ChildrensHospital", icon: "ArrowUp"))
    }
    
    func LoadSampleSafetyDirections() {

        //PlanStep(seq: 6, name: "", instructions: "If you see Hilman Library on your left, you missed your turn. Press the button to see new directions.", image: "HilmanLibrary.png", icon: "Counterclockwise-arrow-icon.png"),
        
        safety_steps.append(PlanStep(seq: 8, name: "", instructions: "Continue west on Forbes Ave until you see The Pitt Shop on your right.", image: "ThePittShop", icon: "ArrowUp"))
        
        safety_steps.append(PlanStep(seq: 8, name: "", instructions: "Continue west on Forbes Ave until you see The Original Hot Dog Shop on your right. Turn right onto S Bouquet St.", image: "TheOriginalHotDog", icon: "ArrowRightTurn"))
        
        safety_steps.append(PlanStep(seq: 8, name: "", instructions: "Continue west on S Bouquet St until you see the Five Guys Burgers and Fries Cafe on your right.", image: "FiveGuys", icon: "ArrowUp"))
        
        safety_steps.append(PlanStep(seq: 8, name: "", instructions: "Continue north on S Bouquet St until you see the Litchfield Towers on your right. Turn left onto Fifth Ave.", image: "LitchfieldTowers", icon: "ArrowLeftTurn"))
        
        safety_steps.append(PlanStep(seq: 13, name: "", instructions: "Continue west on Fifth Ave until you see the Campus Bookstore on your left.", image: "CampusBookstore", icon: "ArrowUp"))
        
        //PlanStep(seq: 14, name: "", instructions: "Continue west left on Fifth Ave until you see the Dollar Bank on your left.", image: "DollarBank.png", icon: "arrow-left-icon.png"),
        
        //PlanStep(seq: 15, name: "", instructions: "Continue west on Fifth Ave until you see the Dollar Bank on your left.", image: "DollarBank.png", icon: "arrow-left-icon.png"),
        
        safety_steps.append(PlanStep(seq: 16, name: "", instructions: "Continue west on Fifth Ave until you see the Nellie's Sanfwiches Cafe on your left.", image: "NelliesSandwiches", icon: "ArrowUp"))
        
        //PlanStep(seq: 17, name: "", instructions: "Continue west on Fifth Ave until you see the Kaufman Medical Building on your right.", image: "DepartmentOfUrology.png", icon: "arrow-left-icon.png"),
        
        //PlanStep(seq: 18, name: "", instructions: "Continue west on Fifth Ave until you see the UPMC Montefiore Inpatient Rehab on your right.", image: "MontefioreRehab.png", icon: "arrow-left-icon.png"),
        
        safety_steps.append(PlanStep(seq: 19, name: "", instructions: "Continue west on Fifth Ave until you see the Children's Hospital of Pittsburgh of UPMC on your right. You have reached you destination.", image: "ChildrensHospital", icon: "ArrowUp"))
    }
    
    
    func runSampleSearches() {
    
    
    var squery:String = "landmark"
    searchInMap(squery, lat: initialLocation.coordinate.latitude, lon: initialLocation.coordinate.longitude, span: span, mode: 0)
    
        
    squery = "hall"
    searchInMap(squery, lat: initialLocation.coordinate.latitude, lon: initialLocation.coordinate.longitude, span: span, mode: 0)

    /*
    squery = "museum"
    searchInMap(squery, lat: initialLocation.coordinate.latitude, lon: initialLocation.coordinate.longitude, span: span, mode: 0)
    
    squery = "church"
    searchInMap(squery, lat: initialLocation.coordinate.latitude, lon: initialLocation.coordinate.longitude, span: span, mode: 0)
    
    //searchInMap("parking", lat: initialLocation.coordinate.latitude, lon: initialLocation.coordinate.longitude, span: span, mode: 0)
    
    searchInMap("university", lat: initialLocation.coordinate.latitude, lon: initialLocation.coordinate.longitude, span: span, mode: 0)
    
    searchInMap("center", lat: initialLocation.coordinate.latitude, lon: initialLocation.coordinate.longitude, span: span, mode: 0)
    
    searchInMap("gas station", lat: initialLocation.coordinate.latitude, lon: initialLocation.coordinate.longitude, span: span, mode: 0)
    */
    //squery = "library"
    //searchInMap(squery, lat: initialLocation.coordinate.latitude, lon: initialLocation.coordinate.longitude, span: span, mode: 0)
    
    //print("Landmarks found: \(landmarks.count)")

    }
    
    func displaySampleData()
    {
    
        var pointsToUse  = [CLLocationCoordinate2D]()
    
        var i:Int = 0
        for lmark in lmarks {
    
            let info = CustomPointAnnotation(lat: lmark.latitude, lon: lmark.longitude, name: lmark.name, address: lmark.address, pinImage: lmark.pin!, photoImage: lmark.photo!, pointId: lmark.pointId, roadId: lmark.roadId, type: 1)
            i = i+1
            self.mapView.addAnnotation(info)
    
            if i < 8 {
                pointsToUse.append(CLLocationCoordinate2DMake(lmark.latitude, lmark.longitude))
    
            }
        }
    
         polyline_color = UIColor.brownColor()
    
        var coords1 = [CLLocationCoordinate2D]()
        var coords2 = [CLLocationCoordinate2D]()
    
        for intersection in intersections {
            coords1.append(CLLocationCoordinate2DMake(intersection.latitude, intersection.longitude))
        }
        let polyline1: MKPolyline = MKPolyline(coordinates: &coords1, count: intersections.count)
        polyline_color = UIColor.blueColor()
        self.mapView.addOverlay(polyline1)
    
        for intersection in safety_intersections {
            coords2.append(CLLocationCoordinate2DMake(intersection.latitude, intersection.longitude))
        }
        let polyline2: MKPolyline = MKPolyline(coordinates: &coords2, count: safety_intersections.count)
       polyline_color = UIColor.brownColor()
        self.mapView.addOverlay(polyline2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //if (sender is self.showPlanButton) {
        //    print("Show Plan pressed")
        //}
        
        var btn  = UIBarButtonItem()
        btn = sender as! UIBarButtonItem;
        print("btn: \(btn.title)")
        
        print("segue.identifier = \(segue.identifier)")
        
        let destNavController = segue.destinationViewController as! UINavigationController
        let targetController = destNavController.topViewController as! LandmarksTableViewController

        
        //if (segue.identifier == "") {
        
        if (btn.title == "Landmarks") {
            
            //for i in 0...landmarks.count-1 {
            //    targetController.landmarkList.append(landmarks[i])
            //}
        
            for i in 0...lmarks.count-1 {
                //targetController.lmarkList.append(lmarks[i])
                targetController.lmarks.append(lmarks[i])
            }
            targetController.mode = 0
        
        } else {
            
            for i in 0...steps.count-1 {
                targetController.planStepsList.append(steps[i])
            }
            for i in 0...safety_steps.count-1 {
                targetController.safetyPlanStepsList.append(safety_steps[i])
            }
            targetController.mode = 1            
        }
        
    }

    @IBAction func sendOsmQuery(sender: AnyObject) {
        
        //let locationManager = CLLocationManager()
        //locationManager.requestAlwaysAuthorization()
        
        //var fname = "myimage1"
        //self.takeSnapshot(mapView, filename: fname) {(result) -> Void in
            
            //let data = UIImagePNGRepresentation(snapshot!.image)
        //    let data = UIImagePNGRepresentation(result!)
        //    var filename = self.getDocumentsDirectory().stringByAppendingPathComponent("\(fname).png")
        //    data?.writeToFile(filename, atomically: true)
        //}

        
        let rect:MKMapRect = self.mapView.visibleMapRect
        print("x=\(rect.origin.x) y=\(rect.origin.y)")
        
        let neCoord:CLLocationCoordinate2D = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(rect), rect.origin.y))
        print("neCoord.latitude = \(neCoord.latitude)")
        print("neCoord.logitude = \(neCoord.longitude)")
        
        let swCoord:CLLocationCoordinate2D = MKCoordinateForMapPoint(MKMapPointMake(rect.origin.x, MKMapRectGetMaxY(rect)))
        print("swCoord.latitude = \(swCoord.latitude)")
        print("swCoord.logitude = \(swCoord.longitude)")
        
        let minlat:Double = swCoord.latitude
        let minlon:Double = swCoord.longitude
        let maxlat:Double = neCoord.latitude
        let maxlon:Double = neCoord.longitude
        print("minlat=\(minlat) minlon=\(minlon) maxlat=\(maxlat) maxlon=\(maxlon)")

        overpassQlRequest(minlat, minlon:minlon, maxlat:maxlat, maxlon:maxlon, completion: {(result: Bool)->Void in
        
            var anns = [CustomPointAnnotation]()
            for lmark in self.lmarks
            {
                let ann = CustomPointAnnotation(lat: lmark.latitude, lon: lmark.longitude, name: lmark.name, address: lmark.address, pinImage: lmark.pin!, photoImage: lmark.photo!, pointId: lmark.pointId, roadId: lmark.roadId, type: 1)
                anns.append(ann)
            }
            
            for ann in anns {
                self.mapView.addAnnotation(ann)
            }
        
            self.mapView.showAnnotations(anns, animated: true)
            
            let number_of_subviews = self.mapView.subviews.count
            print("number of annotations: \(anns.count) number of subviews: \(number_of_subviews)")
            

            
            /*
            for intersection in safety_intersections {
                coords2.append(CLLocationCoordinate2DMake(intersection.latitude, intersection.longitude))
            }
            let polyline2: MKPolyline = MKPolyline(coordinates: &coords2, count: safety_intersections.count)
            polyline_color = UIColor.brownColor()
            self.mapView.addOverlay(polyline2)
            */
        })
    }
    
    @IBAction func zoomInMap(sender: AnyObject) {
        displayRegion(27.17, lon: 78.04, span: 0.03)
    
        //let coordinate = initialLocation.coordinate;
    
        let coord = CLLocationCoordinate2D(latitude: 27.17, longitude: 78.04)
        
        print("latitude = \(coord.latitude) longitude = \(coord.longitude)")
        
        let circleOverlay: MKCircle = MKCircle(centerCoordinate: coord, radius: 300)
        mapView.addOverlay(circleOverlay, level: MKOverlayLevel.AboveRoads)
        
        overlayOsm()
    }
    
    @IBAction func changeMapType(sender: AnyObject) {
        if mapView.mapType == MKMapType.Standard {
            mapView.mapType = MKMapType.Satellite
        } else if mapView.mapType == MKMapType.Satellite {
            mapView.mapType = MKMapType.SatelliteFlyover
        } else {
            mapView.mapType = MKMapType.Standard
        }
        //Hybryd
        //HybridFlyover
    }
    
    func displayRegion(lat: Double, lon: Double, span: Double)
    {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        let latDelta:CLLocationDegrees = span
        let lngDelta:CLLocationDegrees = span
        let spn = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let rgn = MKCoordinateRegion(center: coord, span: spn)
        mapView.setRegion(rgn, animated: true)
        
    }
    
    func overpassQlRequest(minlat: Double, minlon: Double, maxlat: Double, maxlon: Double, completion: ((result: Bool) -> Void)!){
        
        //let bbox = "40.437622303418294,-79.96317386627197,40.446881741814444,-79.9395489692688"
        let bbox = "\(minlat),\(minlon),\(maxlat),\(maxlon)"
        print("bbox = \(bbox)")
        
        let stringUrl = "https://overpass-api.de/api/interpreter?data=[out:json][timeout:25][bbox:\(bbox)];(way[\"highway\"](\(bbox));node[\"highway\"](\(bbox));way[\"amenity\"](\(bbox));node[\"amenity\"](\(bbox));way[\"leisure\"](\(bbox));node[\"leisure\"](\(bbox));way[\"tourism\"](\(bbox));node[\"tourism\"](\(bbox));way[\"building\"](\(bbox));node[\"building\"](\(bbox)););out body geom qt;"

        print("Original URL")
        print(stringUrl)
        print("\n")
        
        let myUrl = NSURL(string: stringUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
        
        let request = NSMutableURLRequest(URL:myUrl);
        request.HTTPMethod = "GET";
        
        //print("Encoded URL")
        //print(myUrl)
        //print("\n")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if error != nil
            {
                print("Error: \(error)\n Error!!!!\n")
                //let dialog = UIAlertController(title: "Error!", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                return
            }
            var statusCode: Int = -1
            if let httpResponse = response as? NSHTTPURLResponse {
                statusCode = httpResponse.statusCode
            }
            print("response = \(response)\n")
            print("Status code: \(statusCode)")
            //print("desciption: \(response?.description)")
            
            if statusCode != 200
            {
                if statusCode == 400 {
                    print("Bad Request")
                }
                else if statusCode == 401 {
                    print("Unauthorized")
                }
                else if statusCode == 403 {
                    print("Forbidden")
                }
                else {
                    print("Some error")
                }
                return
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
            //print("responseString = \(responseString)")
            
            let filename = self.getDocumentsDirectory().stringByAppendingPathComponent("test1.txt")
            do {
                try responseString?.writeToFile(filename, atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
                print("Error saving json string to file!")
            }
            
            var lmarks: NSString? = nil
            var isections: NSString? = nil
            let res = self.MySbplWrapper.initPlannerByOsm_wrapped(responseString, &lmarks, &isections)
            
            if (res)
            {
                print("Planner initialized succesfully.")
                
                self.processLandmarks(lmarks!, minlat: minlat, maxlat: maxlat, minlon: minlon, maxlon: maxlon)
                
                print("Length of intersections string = \(isections!.length)")
                
                self.processIntersections(isections!, minlat: minlat, maxlat: maxlat, minlon: minlon, maxlon: maxlon)
                
            }
            else
            {
                
            }
            
            completion(result: res)
        }
        
        task.resume()
    }
    
    func overlayOsm() {
        let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(URLTemplate: template)
        overlay.canReplaceMapContent = true
        mapView.addOverlay(overlay, level: .AboveRoads)
        
    }
    
    func initEnv() -> Bool
    {
        var res :Bool = true
        let rect:MKMapRect = self.mapView.visibleMapRect
        print("x=\(rect.origin.x) y=\(rect.origin.y)")
        
        let neCoord:CLLocationCoordinate2D = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(rect), rect.origin.y))
        print("neCoord: lat = \(neCoord.latitude) lon = \(neCoord.longitude)")
        
        let swCoord:CLLocationCoordinate2D = MKCoordinateForMapPoint(MKMapPointMake(rect.origin.x, MKMapRectGetMaxY(rect)))
        print("swCoord: lat = \(swCoord.latitude) lon = \(swCoord.longitude)")
        
        let minlat:Double = swCoord.latitude
        let minlon:Double = swCoord.longitude
        let maxlat:Double = neCoord.latitude
        let maxlon:Double = neCoord.longitude
        print("minlat=\(minlat) minlon=\(minlon) maxlat=\(maxlat) maxlon=\(maxlon)")
        
        //var thr: NSThread
        //var b: Bool
        
        //thr = NSThread.currentThread()
        //b = thr.isMainThread;
        //print("1: isMainThread = \(b)")
        
        overpassQlRequest(minlat, minlon:minlon, maxlat:maxlat, maxlon:maxlon, completion: {(result: Bool)->Void in
            
            print("result=\(result)")
            
            //thr = NSThread.currentThread()
            //b = thr.isMainThread;
            //print("2: isMainThread = \(b)")
            
            res = result
            if (res)
            {
                var anns = [CustomPointAnnotation]()
                for lmark in self.lmarks
                {
                    let ann = CustomPointAnnotation(lat:lmark.latitude, lon: lmark.longitude, name: lmark.name, address: lmark.address, pinImage: lmark.pin!, photoImage: lmark.photo!, pointId: lmark.pointId, roadId: lmark.roadId, type: 1)
                    
                    //self.createCustomPointAnnotation(lmark.latitude, lon: lmark.longitude, name: lmark.name, address: lmark.address, pin: lmark.pin!, photo: lmark.photo!, pointId: lmark.pointId, roadId: lmark.roadId, type: 1)
                    anns.append(ann)
                }
            
                for ann in anns {
                    self.mapView.addAnnotation(ann)
                }
            
                self.mapView.showAnnotations(anns, animated: true)
            
            }
            else
            {
                //func errorAlertHandler(act:UIAlertAction!) {
                //}
                let ac = UIAlertController(title: "Error", message: "Init planner environment failed.", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Close", style: .Default, handler: nil))
            
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(ac, animated:true, completion: nil)
                }
            }
        })
        
        //thr = NSThread.currentThread()
        //b = thr.isMainThread;
        //print("3: isMainThread = \(b)")
        
        /*
        if (!res)
        {
            func errorAlertHandler(act:UIAlertAction!) {
            }
        
            let ac = UIAlertController(title: "Error", message: "Init failed", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "Close", style: .Default, handler: errorAlertHandler))
            self.presentViewController(ac, animated:true, completion: nil)
        }
        */

        return res
    }
    
    func searchInMap(search_query: String, lat: CLLocationDegrees, lon: CLLocationDegrees, span: MKCoordinateSpan, mode: Int)
    {
        let latmin: CLLocationDegrees = lat - span.latitudeDelta
        let latmax: CLLocationDegrees = lat + span.latitudeDelta
        let lonmin: CLLocationDegrees = lon - span.longitudeDelta
        let lonmax: CLLocationDegrees = lon + span.longitudeDelta
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = search_query
        
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        request.region = MKCoordinateRegion(center: coord, span: span)
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({(response: MKLocalSearchResponse?, error: NSError?) in
        
            if error != nil {
                print("Error occured in search: \(error?.localizedDescription)")
            } else if response?.mapItems.count == 0 {
                print("No matches found")
            } else {
                print("\(response?.mapItems.count) matches found")
                
                
                if mode == 1 {
                
                    let item1:MKMapItem = (response?.mapItems[0])!
                    let pinImage: UIImage?
                    //let photoImage: UIImage?
                    let info1 = MKPointAnnotation()
                    info1.coordinate = item1.placemark.location!.coordinate
                    info1.title = "info1"
                    info1.subtitle = "subtitle"
                    self.mapView.addAnnotation(info1)
                
                    self.dirRequest.source = item1
                
                    let n = response?.mapItems.count
                    let item2:MKMapItem = (response?.mapItems[n!-1])!
                
                    self.addPinToMapView(item2.name!, latitude: item2.placemark.location!.coordinate.latitude, longitude:item2.placemark.location!.coordinate.longitude)
                
                    self.dirRequest.destination = item2
                
                    self.dirRequest.requestsAlternateRoutes = false
                
                    let directions = MKDirections(request: self.dirRequest)
                    directions.calculateDirectionsWithCompletionHandler() { (response, error) in
                            guard let response = response else {
                                print("Directions error: \(error)")
                                return
                        }
                    
                        self.showRoute(response)
                    }
                } else if mode == 2 {
                  
                    for item in (response?.mapItems)! {
                        
                        /*
                        let lat = item.placemark.location!.coonate.latitude
                        let lon = item.placemark.location!.coordinate.longitude
                        let name = item.placemark.name
                        let addr = ""
                        
                        //var coord = item.placemark.location!.coordinate
                        let fname = "myimage1"
                        var photoImage = UIImage("named:")
                        //self.takeSnapshot(self.mapView, filename: fname) {(result) -> Void in
                        //    photoImage = result!
                        //}
                        
                        let pinImage = UIImage(named: "BlueBall")
                        
                        let ann = self.createCustomPointAnnotation(lat, lon: lon, name: name!, address: addr, pin: pinImage!, photo: photoImage)

                        self.mapView.addAnnotation(ann)
                        */
                        self.addPinToMapView(item.name!, latitude: item.placemark.location!.coordinate.latitude, longitude:item.placemark.location!.coordinate.longitude)

                        break
                    }
                } else {
                    var i = 0;
                    var j = 0;
                    for item in (response?.mapItems)! {
                        j = j+1
                        
                        let ilat: CLLocationDegrees = item.placemark.location!.coordinate.latitude
                        let ilon: CLLocationDegrees = item.placemark.location!.coordinate.longitude
                        if (ilat < latmax && ilat > latmin && ilon < lonmax && ilon > lonmin) {
                                i = i+1
                                //print("j=\(j) i=\(i)")
                                //print("Item name = \(item.name)")
                                //print("Lat = \(ilat)")
                                //print("Lon = \(ilon)")
                    
                                self.addPinToMapView(item.name!, latitude: ilat, longitude:ilon)
                                self.landmarks.append(item)
                                //print("landmarks count: \(self.landmarks.count)")
                        }
                    }
                }
                
            }
        })
    }
    
    func showRoute(response: MKDirectionsResponse) {
        for route in response.routes {
            mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            
            for step in route.steps {
                print(step.instructions)
            }
        }
    }
    
    func addPinToMapView(title: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = title
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
            //let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            //mapView.addAnnotation(pinAnnotationView.annotation!)
            mapView.addAnnotation(pointAnnotation)
    }
    
    func DisplayPath(path: NSString)
    {
        let pathArr: Array = path.componentsSeparatedByString("\n")
    
        var sol = [SolutionStep]()
        var i=0
        for step in pathArr
        {
            var stepdata: Array = step.componentsSeparatedByString(";")
    
            i++
            if (stepdata.count < 11) {continue}
    
            let k = Int(stepdata[0])
            let act1 = Int(stepdata[4])
            let type1 = Int(stepdata[5])
            let act2 = Int(stepdata[9])
            let type2 = Int(stepdata[10])
            let lat1 = Double(stepdata[2])
            let lon1 = Double(stepdata[3])
            let lat2 = Double(stepdata[7])
            let lon2 = Double(stepdata[8])
            let id1 = Int64(stepdata[1])
            let id2 = Int64(stepdata[6])
    
            print("i=\(i) count=\(stepdata.count) k=\(k!) id1=\(id1!) lat1=\(lat1!) lon1=\(lon1!) act1=\(act1!) type1=\(type1!) id2=\(id2!) lat2=\(lat2!) lon2=\(lon2!) act2=\(act2!) type2=\(type2!)")
    
            let step = SolutionStep(seq: i, name: "", instructions: "", imageName: "", iconName: "", k: k!, id1: id1!, lat1: lat1!, lon1: lon1!, act1: act1!, type1: type1!, id2: id2!, lat2: lat2!, lon2: lon2!, act2: act2!, type2: type2!)
    
            if k == 0
            {
                //self.sol_steps.append(step)
                sol.append(step)
            }
            else if k == 1
            {
                self.safety_sol_steps.append(step)
            }
        }
        
        drawPlan(0, planColor: UIColor.blueColor(), sol: sol)
        //drawPlan(1, planColor: UIColor.brownColor())
     }
    
    func drawPlan(k: Int, planColor: UIColor, sol: [SolutionStep])
    {
        var coords1 = [CLLocationCoordinate2D]()
        for step in sol //self.sol_steps
        {
            if (step.k == k)
            {
                coords1.append(CLLocationCoordinate2DMake(step.lat1, step.lon1))
            }
        }
        let polyline1: MKPolyline = MKPolyline(coordinates: &coords1, count: sol.count)
        self.polyline_color = planColor
        self.mapView.addOverlay(polyline1)
    }
    
    func processLandmarks(lmarks: NSString, minlat: Double, maxlat: Double, minlon: Double, maxlon: Double)
    {
        print("--- lmarks ---\n");
        //print("\(lmarks)");
        //print("\n");
    
        let lmarksArr: Array = lmarks.componentsSeparatedByString("\n")
        //var nlmarks = lmarksArr.count
    
        var i=0
        var j=0
        for lmark in lmarksArr
        {
            var lmarkdata: Array = lmark.componentsSeparatedByString(";")
            i++
            if (lmarkdata.count < 4) {continue}
            
            print("i=\(i) \(lmarkdata[0]) \(lmarkdata[1]) \(lmarkdata[2]) \(lmarkdata[3])")
    
            let name = lmarkdata[3]
            let lat = Double(lmarkdata[1])
            let lon = Double(lmarkdata[2])
            let pointId = Int64(lmarkdata[0])

            if (lat >= minlat && lat <= maxlat && lon >= minlon && lon <= maxlon)
            {
                j++
                self.AddLandmark(name, description: "", type: "", address: "", latitude: lat!, longitude: lon!, photoName: "", pinName: "BlueBall", pointId: pointId!, roadId: 1)
            }
        }
        print("Landmarks total: \(i) within bbox \(j)")
    }
    
    func processIntersections(isections: NSString, minlat: Double, maxlat: Double, minlon: Double, maxlon: Double)
    {
        //print("--- isectionss ---\n");
        //print("\(isections)");
        //print("\n");
        
        var lat: Double = 0
        var lon: Double = 0
        
        let isectionsArr: Array = isections.componentsSeparatedByString("\n")
        
        var i=0
        var j=0
        for isection in isectionsArr
        {
            i++
            let pointId = Int64(isection)
            if (pointId == nil)
            {
                continue
            }
            
            //print("i=\(i) pointId=(\(pointId)")
            
            //self.MySbplWrapper.getCoordsById_wrapped(pointId!, &lat, &lon)
            
            var ind: CInt = 0
            var location: NSString? = nil
            self.MySbplWrapper.getIntersectionDetails_wrapped(pointId!, &ind, &lat, &lon, &location)
            print("i=\(i) \(pointId!) \(ind) \(lat) \(lon) \(location!)")
            
            if (lat >= minlat && lat <= maxlat && lon >= minlon && lon <= maxlon)
            {
                let isct = Intersection(id: pointId!, index: Int(j), latutude: lat, longitude: lon, location: location!)
                intersections.append(isct)
                j++
            }
        }
        print("Intersections total: \(i) within bbox \(j+1)")
    }
    
    func parseJson(data: NSData)
    {
        var json: Payload!
    
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Payload
        } catch {
            print(error)
            return
        }
    
        guard let elements = json["elements"] as? [NSDictionary]
            else {
                print("No elements")
                return
        }
    
        let count = elements.count
    
        for i in 1...count-1 {
    
            let element = elements[i] as? NSDictionary
            let type = element!["type"] as? String
    
            if type == "node" {
                let id = element!["id"] as? Int
                let lat = element!["lat"] as? Double
                let lon = element!["lon"] as? Double
                let tags = element!["tags"] as? NSDictionary
                //print("id = \(id) type=\(type) lat=\(lat) lon=\(lon)")
    
                let node:OsmNode = OsmNode(id: id!, lat: lat!, lon: lon!, tags: tags!)!
                self.nodes.append(node)
    
            } else if type == "way" {
                let id = element!["id"] as? Int
                let bounds = element!["bounds"] as? NSDictionary
                let tags = element!["tags"] as? NSDictionary
                let nodes = element!["nodes"] as? [Int]
                let geometry = element!["geometry"] as? [[String:Int]]
    
                let way:OsmWay = OsmWay(id: id!, bounds: bounds!, nodes: nodes!, tags: tags!, geometry: geometry!)!
                self.ways.append(way)
            } else {
    
            }
        }
    
    
            var count1 = 0
        for node in self.nodes {
            if let i = self.nodes.indexOf({$0.id == node.id})
            {
                print("i=\(i) id=\(self.nodes[i].id) lat=\(self.nodes[i].lat) lon=\(self.nodes[i].lon)")
                count1++
            }
            else
            {
                print("not found");
            }
        }
        print("count1=\(count1)");
    
    
        //for node in self.nodes {
        //    let filteredNode = filter(self.nodes) {$0.id == node.id};
    
        //
    }
}

class SnapshotImageAnnotation: MKPointAnnotation {
}

