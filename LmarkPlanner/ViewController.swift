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

//import GoogleMaps

class ViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource,
    sendDataBack
{
    // MARK: Properties
    
    var debug: Bool = true
    var workOffline: Bool = true
    var saveFiles: Bool = false
    var saveImages: Bool = false
    var queryOSM: Bool = false
    
    var computeTime: Double = 1.0
    var policyTime: Double = 6.0
    
    var lmarks = [Lmark]()
    var i_lmarks = [Lmark]()
    var isections = [Intersection]()
    
    var startViews = [LmarkAnnotationView]()
    var goalViews = [LmarkAnnotationView]()
    var greenViews = [LmarkAnnotationView]()
    var redMarkerViews = [LmarkAnnotationView]()
    
    var directionImages = [String]()
    var directionNames = [String]()
    
    var sol = [SolutionStep]()
    var safety_sol = [SolutionStep]()
    var plan = [SolutionStep]()
    var safety_plan = [SolutionStep]()
    
    //Pittsburgh, Oakland, Cathedral of Learning
    var initialLocation = CLLocation(latitude: 40.443660, longitude: -79.951712)
    var initialLocationName: String = "Cathedral of Learning"
    var currentLocation = CLLocation()
    var span = MKCoordinateSpan()
    var xRegionSizeMeters: Double = 1500.0
    var yRegionSizeMeters: Double = 1500.0
    
    var distance: CLLocationDistance = 650
    var pitch: CGFloat = 0   //65
    var heading = 0.0
    //var camera: MKMapCamera?
    
    var polyline_color = UIColor()
    var polyline_width: CGFloat  = 4.0
    var polyline_dashPattern: [NSNumber] = [3,5]
    var snp : MKMapSnapshot?

    var MySbplWrapper = CPPWrapper()
    
    var start_set: Bool = false
    var goal_set: Bool = false
    var start_pointId: Int64 = 0
    var start_roadId: Int64 = 0
    var start_type: Int = 0
    var goal_pointId: Int64 = 0
    var goal_roadId: Int64 = 0
    var goal_type: Int = 0
    var config_changed: Bool = false
    var docDirectory: String = ""
    var locationManager = CLLocationManager()
    var showCurrentLocation: Bool  = false
    var countViewDidLoad: Int = 0
    var success_count: Int = 0
    var failure_count: Int = 0
    
    struct Condition {
        let k: Int
        let start_dir: Int
        let goal_dir: Int
    }
    
    var conditions = [Condition]()
    
    var cond0: Condition? = nil
    var duration0: Double = 0.0
    var DebugInfoText: String = ""
    var mainBundle: NSBundle?
    var responseString: String = ""
    var cacheSubdir: String = "offdata"
    var jsonCacheSubdir: String = "nsm"
    
    var pickerData: [String] = [String]()
    
    //var resultsController = LandmarksTableViewController()
    
    @IBOutlet var OnlineStatusImage: UIImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var lmarksButton: UIBarButtonItem!
    @IBOutlet var isectionsButton: UIBarButtonItem!
    @IBOutlet var planButton: UIBarButtonItem!
    @IBOutlet var settingsButton: UIBarButtonItem!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var searchText: UITextField!
    @IBOutlet var DebugInfo: UILabel!
    
    
    @IBOutlet var placePicker: UIPickerView!
    
    // MARK: Methods
    
    @IBAction func showSettings(sender: AnyObject) {
        if (lmarks.count > 0)
        {
            self.performSegueWithIdentifier("ShowTable", sender: sender)
    
        }
    }
    
    @IBAction func showIsections(sender: AnyObject) {
        if (isections.count > 0)
        {
            self.performSegueWithIdentifier("ShowTable", sender: sender)
        }
    }
    
    @IBAction func showPlan(sender: AnyObject) {
        if (sol.count > 0)
        {
            self.performSegueWithIdentifier("ShowTable", sender: sender)
        }
    }
    
    @IBAction func saveLandmarkDetail(segue:UIStoryboardSegue)
    {
        //print("Done clicked")
        viewDidLoad()
    }
    
    // MARK: SendDataBack Protocol
    
    func sendBoolValToPreviousVC(bval: Bool, tag: Int) {
        switch tag
        {
        case 1:
            showCurrentLocation = bval
        case 2:
            workOffline = bval
        case 3:
            debug = bval
        case 4:
            saveFiles = bval
        default:
            print("Invalid tag value: \(tag)")
        }
        config_changed  = true
    }
    
    func sendDoubleValsToPreviousVC(xval: Double, yval: Double, tag: Int) {
        
        switch tag
        {
        case 5:
            xRegionSizeMeters = xval
            yRegionSizeMeters = yval
        case 6:
            computeTime = xval
            policyTime = yval
        default:
            print("Invalid tag value: \(tag)")
        }
        config_changed = true
    }
    
/*
    func findLmarkAnnotation(id: Int64) -> LmarkAnnotation
    {
        var ann: LmarkAnnotation?
        let anns1 = self.mapView.annotations.filter {annotation in return (annotation.isKindOfClass(LmarkAnnotation))
        }
        let anns2 = anns1 as! [LmarkAnnotation]
        let anns = anns2.filter {annotation in return (annotation.lmark.pointId == id)
        }
        if (anns.count > 0)
        {
            let view: LmarkAnnotationView = self.mapView.viewForAnnotation(anns[0]) as! LmarkAnnotationView
            
        }
    }
*/
    func setSelectedPose(mode: Int, id: Int64, type: Int)
    {
        if (id > 0)
        {
            switch mode
            {
                case 1:
                    let anns1 = mapView.annotations.filter {annotation in return (annotation.isKindOfClass(LmarkAnnotation))
                    }
                    let anns2 = anns1 as! [LmarkAnnotation]
                    let anns = anns2.filter {annotation in return (annotation.lmark.pointId == id)
                    }
                    
                    if (anns.count > 0)
                    {
                        let view: LmarkAnnotationView = self.mapView.viewForAnnotation(anns[0]) as! LmarkAnnotationView
                        if (type == 0)
                        {
                            view.setStartPose(anns[0])
                            //mapView.showAnnotations(anns, animated: false)
                        }
                        else
                        {
                            view.setGoalPose(anns[0])
                            //mapView.showAnnotations(anns, animated: false)
                        }
                }

                case 3:
                    let isection = findIntersectionByID(id)
                default:
                    print("Invalid mode value: \(mode)")
            }
            //SetStart
        }
    }
    
    // MARK: ViewController methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        pickerData = ["osm", "nsm"]
        
        self.placePicker.delegate = self
        self.placePicker.dataSource = self
        
        
        self.view.bringSubviewToFront(placePicker)
        
        //searchText.autocorrectionType = UITextAutocorrectionType.Yes
        
        mainBundle = NSBundle.mainBundle()
        if (debug)
        {
            print("mainBundle.bundlePath = \(mainBundle!.bundlePath)\n")
        }
        
        if (workOffline)
        {
            OnlineStatusImage.image = UIImage(named: "ledred16")
        }
        else
        {
            OnlineStatusImage.image = UIImage(named: "ledgreen16")
        }
        self.view.bringSubviewToFront(DebugInfo)
        DebugInfo.text = ""
        if (debug)
        {
            DebugInfo.text = "Debug mode" //DebugInfoText
        }
        
        self.view.bringSubviewToFront(OnlineStatusImage)
        self.view.bringSubviewToFront(activityIndicatorView)
        
        if (countViewDidLoad == 0)
        {
            directionImages.append("ArrowCounterclockwise")
            directionImages.append("ArrowLeftTurn")
            directionImages.append("ArrowLeft")
            directionImages.append("ArrowUp")
            directionImages.append("ArrowRight")
            directionImages.append("ArrowRightTurn")
            directionImages.append("ArrowCounterclockwise")
            
            directionNames.append("Uuturn left")
            directionNames.append("sharp turn left")
            directionNames.append("turn left")
            directionNames.append("go straight")
            directionNames.append("turn right")
            directionNames.append("sharp turn right")
            directionNames.append("uturn right")
            
            conditions.append(Condition(k: 1, start_dir: 0, goal_dir: 0))
            conditions.append(Condition(k: 1, start_dir: 0, goal_dir: 1))
            conditions.append(Condition(k: 1, start_dir: 1, goal_dir: 0))
            conditions.append(Condition(k: 1, start_dir: 1, goal_dir: 1))
            
            conditions.append(Condition(k: 0, start_dir: 0, goal_dir: 0))
            conditions.append(Condition(k: 0, start_dir: 0, goal_dir: 1))
            conditions.append(Condition(k: 0, start_dir: 1, goal_dir: 0))
            conditions.append(Condition(k: 0, start_dir: 1, goal_dir: 1))
            
            lmarksButton.tag = 1
            isectionsButton.tag = 3
            planButton.tag = 2
            settingsButton.tag = 4
        }
        
        if (countViewDidLoad == 0 || config_changed)
        {
            var debug_mode = 0;
            if (debug) {
                debug_mode = 1;
            }
            var offline_mode = 0;
            if (workOffline) {
                offline_mode = 1;
            }
            do {
                try self.MySbplWrapper.setParams_wrapped(CInt(debug_mode), CInt(offline_mode), policyTime, computeTime)
            } catch {
                print("SBPL Error: Could not create environment")
                showAlert("SBPL Error", alertMessage: "Could not create environment.", actionTitle: "Close")
            }
        }
        
        var coordinateRegion: MKCoordinateRegion?
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        //Show current location
        if (showCurrentLocation)
        {
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        }
        else
        {
            self.locationManager.stopUpdatingLocation()
            self.mapView.showsUserLocation = false
            self.mapView.showsCompass = false
            self.mapView.showsPointsOfInterest = false
            self.mapView.showsScale = false
            self.mapView.showsTraffic = false
            self.mapView.rotateEnabled = false
            self.mapView.pitchEnabled = false
            //span = MKCoordinateSpanMake(0.011, 0.011)
            
            if (!start_set && !goal_set)
            {
                coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, xRegionSizeMeters, yRegionSizeMeters);
                self.mapView.setRegion(coordinateRegion!, animated: false)
            }
            else
            {
                var lat: Double = 0.0
                var lon: Double = 0.0
                if (start_set && !goal_set)
                {
                    let ind1 = findLandmarkByID(start_pointId)
                    let start_lmark = lmarks[ind1]
                    lat = (start_lmark.latitude + initialLocation.coordinate.latitude)/2
                    lon = (start_lmark.longitude + initialLocation.coordinate.longitude)/2
                }
                else if (!start_set && goal_set)
                {
                    let ind2 = findLandmarkByID(goal_pointId)
                    let goal_lmark = lmarks[ind2]
                    lat = (initialLocation.coordinate.latitude + goal_lmark.latitude)/2
                    lon = (initialLocation.coordinate.longitude + goal_lmark.longitude)/2
                }
                else if (start_set && goal_set)
                {
                    let ind1 = findLandmarkByID(start_pointId)
                    let start_lmark = lmarks[ind1]
                    let ind2 = findLandmarkByID(goal_pointId)
                    let goal_lmark = lmarks[ind2]
                    lat = (start_lmark.latitude + goal_lmark.latitude)/2
                    lon = (start_lmark.longitude + goal_lmark.longitude)/2
                }
                
                let loc = CLLocation(latitude: lat, longitude: lon)
                coordinateRegion = MKCoordinateRegionMakeWithDistance(loc.coordinate, xRegionSizeMeters, yRegionSizeMeters)
                mapView.setRegion(coordinateRegion!, animated: false)
            }
                
            span = coordinateRegion!.span
            if (debug)
            {
                print("span: latitudeDelta = \(span.latitudeDelta)  longitudeDelta = \(span.longitudeDelta)")
            }
        }
        
        if (config_changed)
        {
            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotations(mapView.annotations)
            sol.removeAll()
            safety_sol.removeAll()
            plan.removeAll()
            safety_plan.removeAll()
            config_changed = false
        }
        
        countViewDidLoad += 1
        
        //Gesture recognizer
        //let gst = UITapGestureRecognizer(target: self, action:#selector(ViewController.processGesture(_:)))
        //gst.delegate = self
        //mapView.addGestureRecognizer(gst)
        //gst.numberOfTapsRequired = 1
        ////gst.minimumPressDuration = 2.0
        
        
        //mapView.mapType = .SatelliteFlyover
        //camera = MKMapCamera(lookingAtCenterCoordinate: coordinate,
        //    fromDistance: distance,
        //    pitch: pitch,
        //    heading: heading)
        //mapView.camera = camera!
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This should dismiss the keyboard when tapping outside of the text field that belongs to the current view in this view controller.
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    // MARK: Annotation Delegate Methods
    
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
            renderer.strokeColor = polyline_color
            renderer.lineWidth = polyline_width
            renderer.lineDashPattern = polyline_dashPattern
            return renderer
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!)
    {
        guard let ann = view.annotation as? LmarkAnnotation else
        {
            //if (self.debug)
            //{
                print("didDeselectAnnotationView: not LmarkAnnotation")
            //}
            return
        }
        if (debug)
        {
            print("didDeselectAnnotationView: \(ann.lmark.pointId) \(ann.lmark.name)")
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        guard let ann = view.annotation as? LmarkAnnotation else
        {
            //if (self.debug)
            //{
                print("didSelectAnnotationView: not LmarkAnnotation")
            //}
            return
        }
        
        if (debug)
        {
            print("didSelectAnnotationView: \(ann.lmark.pointId) \(ann.lmark.name)")
        }
        
        //mapView.deselectAnnotation(view.annotation, anima ted: false)
        
        //if let lmarkview = view as? LmarkAnnotationView
        //{
            //let lmarkann = lmarkview.annotation as? LmarkAnnotation
            //print("\(lmarkann?.lmark.pointId)  \(lmarkann!.title)")
        //}
        //if let view1 = view as? LmarkAnnotationView {
        //    updatePinPosition(view1)
        //}
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) ->MKAnnotationView!
    {
        //if annotation is MKUserLocation {
        if !(annotation is LmarkAnnotation) && !(annotation is MKPointAnnotation)
        {
            return nil
        }
        
        if annotation is LmarkAnnotation
        {
            //print("ViewForAnnotation: LmarkAnnotation clicked.")
            var annView: LmarkAnnotationView? = nil
            let reuseId = "lmark"
            
            if let reuseView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? LmarkAnnotationView
            {
                annView = reuseView
                annView!.annotation = annotation
                annView!.calloutView = nil
            }
            else {
                annView = LmarkAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            
            annView!.image = UIImage(named: "BlueBall")
            annView!.parent = self
            annView!.canShowCallout = false
            
            //print("mapView.selectedAnnotations.count = \(mapView.selectedAnnotations.count)")
            
            mapView.deselectAnnotation(annotation, animated: false)
            return annView
        }
        else if annotation is MKPointAnnotation
        {
            let reuseId = "point"
            var annView: MKAnnotationView? = nil
            
            if let reuseView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) {
                annView = reuseView
                annView!.annotation = annotation
            }
            else  {
                annView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            
            if (debug)
            {
                print("annotation.title = \(annotation!.title!!)")
            }
            
            //if (annotation.title! == "BlackDot")
            //{
            //    annView?.image = UIImage(named: "BlackMarker")
            //}
            //else
            //{
                annView?.image = UIImage(named: "Target")
            //}
            return annView
        }
        return nil
    }
    
    // MARK: Processing OCM Landmarks and Interections
    
    func AddLandmark(name: String, description: String, type: Int, address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoName: String, pointId: Int64, roadId: Int64, street: String, amenity: String, roadLatitude: Double, roadLongitude: Double)
    {
        var photo: UIImage?
        if !photoName.isEmpty
        {
            photo = UIImage(named:photoName)!
        }
        
        let lmark = Lmark(name: name, description: description, type: type, address: address, latitude: latitude, longitude: longitude, photo: photo, pointId: pointId, roadId: roadId, street: street, amenity: amenity, roadLatitude: roadLatitude, roadLongitude: roadLongitude)!
        lmarks.append(lmark)
    }

    func processLandmarks(lmarksPtr: UnsafeMutablePointer<Int64>, lmarks_count: Int) -> Bool
    {
        let filename = "lmarkdata"
        let ext = "txt"
        if (self.saveFiles)
        {
            self.CreateOrTruncateFile(filename, ext: ext)
        }
        
        var res = true
        var j=0
        for i in 0..<lmarks_count
        {
            let lmark = lmarksPtr[i]
            let pointId = Int64(lmark)
            
            var ind: CInt = 0
            var name: NSString? = nil
            var address: NSString? = nil
            var info: NSString? = nil
            var street: NSString? = nil
            var amenity: NSString? = nil
            var lat: Double = 0.0
            var lon: Double = 0.0
            var roadId:Int64 = -1
            var roadLat: Double = 0.0
            var roadLon: Double = 0.0
            
            res = self.MySbplWrapper.getLandmarkDetails_wrapped(pointId, &ind, &lat, &lon, &name, &address, &info, &street, &amenity, &roadId, &roadLat, &roadLon)
            if (!res)
            {
                showAlert("SBPL_Exception", alertMessage: "getLandmarkDetails failed for pointId=\(pointId).", actionTitle: "Close")
                NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)] pointId: \(pointId)")
                //NSLog("\(NSThread.callStackSymbols())")
                break;
            }
            
            let name1 = name?.stringByReplacingOccurrencesOfString("_", withString: " ")
            let name0 = name1?.stringByReplacingOccurrencesOfString("/", withString: " ").stringByReplacingOccurrencesOfString("  ", withString: " ")
            let name2 = name0?.capitalizedString
            
            let info1 = info?.stringByReplacingOccurrencesOfString("_", withString: " ")
            let info2 = info1?.capitalizedString
            
            let street1 = street?.stringByReplacingOccurrencesOfString("_", withString: " ")
            let street2 = street1?.capitalizedString
            
            let amenity1 = amenity?.stringByReplacingOccurrencesOfString("_", withString: " ")
            let amenity2 = amenity1?.capitalizedString
            
            //print("i=\(i) \(pointId!) \(ind) \(lat) \(lon) \(name2!) | \(address!) | \(info2!) | \(street2!) | \(amenity2!)")
            
            j += 1
            self.AddLandmark(name2!, description: info2!, type: 1, address: String(address!), latitude: lat, longitude: lon, photoName: "", pointId: pointId, roadId: roadId, street: street2!, amenity: amenity2!, roadLatitude: roadLat, roadLongitude: roadLon)
            
            let txt = "\(name2!);\(info2!);\(address!);\(lat);\(lon);\(pointId);\(roadId);\(street2!);\(amenity2!);\(roadLat);\(roadLon)\n"
            if (self.saveFiles)
            {
                AppendStringToFile(txt, filename: filename, ext: ext)
            }
            
            name = nil
            info = nil
            street = nil
            amenity = nil
        }
        return res;
    }
    
    func processIntersections(isectionsPtr: UnsafeMutablePointer<Int64>, isections_count: Int) -> Bool
    {
        let filename = "isectiondata"
        let ext = "txt"
        if (self.saveFiles)
        {
            self.CreateOrTruncateFile(filename, ext: ext)
        }
        
        var res = true
        var lat: Double = 0
        var lon: Double = 0
        
        var j=0
        for i in 0..<isections_count
        {
            let isection = isectionsPtr[i]
            let pointId = Int64(isection)
            var ind: CInt = 0
            var location: NSString? = nil
            var count: CInt = 0
            res = self.MySbplWrapper.getIntersectionDetails_wrapped(pointId, &ind, &lat, &lon, &location, &count)
            if (!res)
            {
                showAlert("SBPL_Exception", alertMessage: "getIntersectionDetails failed for pointId=\(pointId)", actionTitle: "Close")
                NSLog("SBPL_Exception: [file: \(#file) function: \(#function) at line \(#line)] pointId: \(pointId)")
                break
            }
            
            //if (lat >= minlat && lat <= maxlat && lon >= minlon && lon <= maxlon)
            //{
                j += 1
            //}
            
            let location0 = location?.stringByReplacingOccurrencesOfString("/", withString: " ").stringByReplacingOccurrencesOfString("  ", withString: " ")
            
            let isct = Intersection(id: pointId, index: Int(j), latutude: lat, longitude: lon, location: location0! as String, streetsCount: Int(count))
            isections.append(isct)
            
            let lmark = Lmark(name: isct.location!, description: "", type: 0, address: "", latitude: isct.latitude, longitude: isct.longitude, photo: nil, pointId: pointId, roadId: 0, street: "", amenity: "",  roadLatitude: 0.0, roadLongitude: 0.0);
            i_lmarks.append(lmark!)
            
            let txt = "\(pointId);\(j);\(location0!);\(lat);\(lon);\(count)\n"
            if (self.saveFiles)
            {
                AppendStringToFile(txt, filename: filename, ext: ext)
            }
            
            location = nil
        }
        //print("Intersections total: \(i) within bbox \(j+1)")
        return res
    }

    func processCachedLmarks(subdirname: String) -> Bool
    {
        var res: Bool = true;
        let lmarkdata_path = self.mainBundle!.pathForResource("lmarkdata", ofType: "txt", inDirectory: subdirname)
        if (debug)
        {
            print("lmarkdata_path: \(lmarkdata_path!)\n")
        }
    
        var lmarkdata_list: String
        do {
            lmarkdata_list = try NSString(contentsOfFile: lmarkdata_path!, encoding: NSUTF8StringEncoding) as String
        } catch {
            let serr = "Error reading cashed file: \(lmarkdata_path!)"
            self.showAlert("Error", alertMessage: serr, actionTitle: "Close")
            NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
            return false;
        }
        if (lmarkdata_list.characters.count > 0)
        {
            let lmarkdataArr: Array = lmarkdata_list.componentsSeparatedByString("\n")
            if (debug)
            {
                print("Number of lmarks: \(lmarkdataArr.count)")
            }
    
            self.lmarks.removeAll()
            for elem in lmarkdataArr
            {
                if (elem.characters.count > 0)
                {
                    let lmarkArr: Array = elem.componentsSeparatedByString(";")
                    //print("Number of lmark properties: \(lmarkArr.count)")
    
                    if (lmarkArr.count == 11)
                    {
                        let name = lmarkArr[0]
                        let info = lmarkArr[1]
                        let addr = lmarkArr[2]
                        let s_lat = lmarkArr[3]
                        let s_lon = lmarkArr[4]
                        let s_pointId = lmarkArr[5]
                        let s_roadId = lmarkArr[6]
                        let street = lmarkArr[7];
                        let amenity = lmarkArr[8]
                        let s_roadLat = lmarkArr[9]
                        let s_roadLon = lmarkArr[10]
    
                        //print("name: \(name)\ninfo: \(info)\naddr: \(addr)\nlat: \(s_lat) lon: \(s_lon) pointId: \(s_pointId) roadId: \(s_roadId)\nstreet: \(street)\namenity: \(amenity)\nroadLat: \(s_roadLat) roadLon: \(s_roadLon)")
    
                        self.AddLandmark(name, description: info, type: 1, address: String(addr), latitude: Double(s_lat)!, longitude: Double(s_lon)!, photoName: "", pointId: Int64(s_pointId)!, roadId: Int64(s_roadId)!, street: street, amenity: amenity, roadLatitude: Double(s_roadLat)!, roadLongitude: Double(s_roadLon)!)
                    }
    
                }
            }
            res = true
        }
        else
        {
            print("Number of lmarks: 0")
            res = false
        }
        return res;
    }
    
    func processCachedIsections(subdirname: String) -> Bool
    {
        var res: Bool  = true;
        
        let isectiondata_path = self.mainBundle!.pathForResource("isectiondata", ofType: "txt", inDirectory: subdirname)
        if (debug)
        {
            print("isectiondata_path: \(isectiondata_path!)\n")
        }
    
        var isectiondata_list: String
        do {
            isectiondata_list = try NSString(contentsOfFile: isectiondata_path!, encoding: NSUTF8StringEncoding) as String
        } catch {
            let serr = "Error reading cashed file: \(isectiondata_path!)"
            self.showAlert("Error", alertMessage: serr, actionTitle: "Close")
            NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
            return false;
        }
        
        if (isectiondata_list.characters.count > 0)
        {
            let isectiondataArr: Array = isectiondata_list.componentsSeparatedByString("\n")
            if (debug)
            {
                print("Number of isections: \(isectiondataArr.count)")
            }
    
            self.i_lmarks.removeAll()
            self.isections.removeAll()
    
            for elem in isectiondataArr
            {
                if (elem.characters.count > 0)
                {
                    let isectionArr: Array = elem.componentsSeparatedByString(";")
                    //print("Number of lmark properties: \(lmarkArr.count)")
    
                    if (isectionArr.count == 6)
                    {
                        let s_pointId = isectionArr[0]
                        let s_j = isectionArr[1]
                        let loc = isectionArr[2]
                        let s_lat = isectionArr[3]
                        let s_lon = isectionArr[4]
                        let s_count = isectionArr[5]
    
                        //print("name: \(name)\ninfo: \(info)\naddr: \(addr)\nlat: \(s_lat) lon: \(s_lon) pointId: \(s_pointId) roadId: \(s_roadId)\nstreet: \(street)\namenity: \(amenity)\nroadLat: \(s_roadLat) roadLon: \(s_roadLon)")
    
                        let isct = Intersection(id: Int64(s_pointId)!, index: Int(s_j)!, latutude: Double(s_lat)!, longitude: Double(s_lon)!, location: loc, streetsCount: Int(s_count)!)
                        self.isections.append(isct)
    
                        let lmark = Lmark(name: isct.location!, description: "", type: 0, address: "", latitude: isct.latitude, longitude: isct.longitude, photo: nil, pointId: isct.id, roadId: 0, street: "", amenity: "",  roadLatitude: 0.0, roadLongitude: 0.0);
                        self.i_lmarks.append(lmark!)
                    }
    
                }
            }
            res = true
        }
        else
        {
            print("Number of isections: 0")
            res = false
        }
        return res
    }
    
    // MARK: Planning Methods
    
    func generateOptimalPlan(completion: (error:NSError!)->())
    {
        if (self.start_set && self.goal_set)
        {
            self.activityIndicatorView.startAnimating()
            
            if (debug)
            {
                for view in self.redMarkerViews
                {
                    let ann = view.annotation
                    let ann1: LmarkAnnotation = ann as! LmarkAnnotation
                    
                    //if (ann1.lmark.pointId == goal_pointId)
                    //{
                    //    print("aaa")
                    //}
                    
                    if (ann1.lmark.pointId != goal_pointId)
                    {
                        view.image = UIImage(named: "BlueBall")
                    }
                }
                //DebugInfo.text = ""
                self.redMarkerViews.removeAll()
            }
            
            let queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
            dispatch_async(queue,
            {
                self.mapView.removeOverlays(self.mapView.overlays)
                
                var minlen: Int = 100000
                var itermin: Int = 0
                var plan_found = false
                var ret = false
                var count: Int = 0
            
                for i in 0...3
                {
                    var planPtr : UnsafeMutablePointer<CInt> = nil
                    let cond = self.conditions[i]
                    ret = self.generateOnePlan(i+1, kmax: cond.k, start_dir: cond.start_dir, goal_dir: cond.goal_dir, mode: 0, minlen: &minlen, itermin: &itermin, count: &count, duration0: &self.duration0, planPtr: &planPtr)
                    if (ret)
                    {
                        self.success_count += 1
                    }
                    else
                    {
                        self.failure_count += 1
                    }
                    
                    if (!plan_found && ret)
                    {
                        plan_found = true
                    }
                }
 
                if (!plan_found)
                {
                    for i in 4...7
                    {
                        var planPtr : UnsafeMutablePointer<CInt> = nil
                        let cond = self.conditions[i]
                        plan_found = self.generateOnePlan(i+1, kmax: cond.k, start_dir: cond.start_dir, goal_dir: cond.goal_dir, mode: 0, minlen: &minlen, itermin: &itermin, count: &count, duration0: &self.duration0, planPtr: &planPtr)
                    }
                }
            
                if (itermin > 0)
                {
                    let i = itermin-1
                    let plan_file_name = "plan\(i)"
                    let plan_file_ext = "txt"
                    
                    if (self.debug)
                    {
                        self.CreateOrTruncateFile(plan_file_name, ext: plan_file_ext)
                    }
                
                    let cond = self.conditions[i]
                    self.cond0 = cond
                
                    var planPtr : UnsafeMutablePointer<CInt> = nil
                    plan_found = self.generateOnePlan(itermin, kmax: cond.k, start_dir: cond.start_dir, goal_dir: cond.goal_dir, mode: 1, minlen: &minlen, itermin: &itermin, count: &count, duration0: &self.duration0, planPtr: &planPtr)
                    
                    self.DisplayPath(planPtr, count: count, plan_file_name: plan_file_name, plan_file_ext: plan_file_ext)
                    
                    let res = self.MySbplWrapper.freePlan_wrapped(&planPtr)
                    if (!res)
                    {
                        self.showAlert("SBPL_Exception", alertMessage: "MySbplWrapper.freePlan_wrapped", actionTitle: "Close")
                        NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
                    }
                    
                    completion(error:  nil)
                }
                else
                {
                    self.cond0 = nil
                    self.showAlert("Search", alertMessage: "Plan not found.", actionTitle: "Close")
                    let error: NSError = NSError(domain: "SBPL Search", code: 0, userInfo: nil)
                    
                    completion(error: error)
                }
                
                if (self.debug)
                {
                    print("success_count = \(self.success_count) failure_count = \(self.failure_count)")
                }
            })
        }
    }
    
    func generateOnePlan(iter: Int, kmax: Int, start_dir: Int, goal_dir: Int, mode: Int, inout minlen: Int, inout itermin: Int, inout count: Int, inout duration0: Double, inout planPtr: UnsafeMutablePointer<CInt>) -> Bool
    {
        var pathlen: CInt = 0
        var k0len: CInt = 0
        var k1len: CInt = 0
        let i: CInt = CInt(iter) - 1
        var duration: Double = 0.0
        duration0 = 0.0
        
        if (debug)
        {
            print("\n******** iter = \(iter) start *******")
        }
        
        let plan_found = self.MySbplWrapper.generatePlan_wrapped(CInt(kmax), start_pointId, start_roadId, CInt(start_type), CInt(start_dir), goal_pointId, goal_roadId, CInt(goal_type), CInt(goal_dir), CInt(mode), i, &pathlen, &k0len, &k1len, &duration, &planPtr)

        if (plan_found)
        {
            duration0 = duration
            count = Int(k0len) + Int(k1len)
            if (minlen > Int(k0len))
            {
                itermin = iter
                minlen = Int(k0len)
            }
            
            if (debug)
            {
                print("iter = \(iter) k0len = \(k0len) k1len = \(k1len) count = \(count) pathlen = \(pathlen) minlen = \(minlen) plan found")
            }
        }
        else
        {
            count = 0
            if (debug)
            {
                print("iter = \(iter) plan not found")
            }
        }
        if (debug)
        {
            print("******** iter = \(iter) end *******\n")
        }
        return plan_found
    }
    
    func readDelimitedDataFromFile(filename: String, ext: String, subdirname: String, delimiter: String, inout list: String) -> Bool
    {
        let file_path = self.mainBundle!.pathForResource(filename, ofType: ext, inDirectory: subdirname)
        if (file_path == nil)
        {
            list = "File does not exist: \(subdirname)/\(filename).\(ext)"
            return false;
        }
        if (debug)
        {
            print("file_path: \(file_path!)\n")
        }
    
        do {
            list = try NSString(contentsOfFile: file_path!, encoding: NSUTF8StringEncoding) as String
        } catch
        {
            list = "Error reading cached file: \(file_path!)"
            return false;
        }
        
        if (list.characters.count == 0)
        {
            list = "Cached file is empty: \(file_path!)"
            return false;
        }
    
        let arr: Array = list.componentsSeparatedByString(delimiter)
        if (debug)
        {
            print("Number of elements: \(arr.count)")
        }
        if (arr.count == 0)
        {
            list = "Invalid content of cached file: \(file_path!)"
            return false;
        }
        
        if (debug)
        {
            print("\(list)\n")
        }
        
        
        /*
        for i in 0..<arr.count
        {
            let elem: String = arr[i];
            print("\(i) - \(elem)")
        
            if (elem.isEmpty)
            {
                print("    empty element");
            }
         
            for j in i+1..<arr.count
            {
                if (elem == arr[j])
                {
                    print("   duplicate element)");
                }
            }
        }
        */
 
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        searchText.resignFirstResponder()
        DebugInfo.text = ""
        
        if (queryOSM && (searchText.text == nil || searchText.text!.isEmpty))
        {
            return true
        }
        
        self.activityIndicatorView.startAnimating()
        
        let stext: String = self.searchText.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (debug)
        {
            print("search text: \(self.searchText.text!)")
        }
        
        self.start_set = false
        self.goal_set = false
        self.start_roadId = -1
        self.goal_roadId = -1
        self.start_pointId = -1
        self.goal_pointId = -1
        
        self.lmarks.removeAll()
        self.i_lmarks.removeAll()
        self.isections.removeAll()
        
        if (!workOffline)
        {
            if (self.queryOSM)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
                {
                    self.searchInMap(stext, lat: self.initialLocation.coordinate.latitude, lon: self.initialLocation.coordinate.longitude, span: self.span)
                }
            }
            else
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
                {
                let subdirname = self.cacheSubdir + "/" + self.jsonCacheSubdir
                if (self.readInitialLocationFromFile(subdirname))
                {
                    self.initEnvByCachedOsm(self.initialLocation.coordinate, subdirname: subdirname)

                    dispatch_async(dispatch_get_main_queue())
                    {
                        self.searchText.text = self.initialLocationName
                        
                        let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.initialLocation.coordinate, self.xRegionSizeMeters, self.yRegionSizeMeters);
                        self.mapView.setRegion(coordinateRegion, animated: false)
                        self.addPinToMapView(self.initialLocationName, latitude: self.initialLocation.coordinate.latitude, longitude: self.initialLocation.coordinate.longitude)
                    }
                }
                }
            }
        }
        else
        {
            var anns = [LmarkAnnotation]()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
            {
                let subdirname = self.cacheSubdir + "/" + stext
                if (!self.readInitialLocationFromFile(subdirname))
                {
                    return
                }
                
                var errmsg: NSString? = nil
                let cache_dir = self.mainBundle!.bundlePath + "/" + subdirname + "/"
                if (self.MySbplWrapper.initPlannerByCache_wrapped(cache_dir, &errmsg))
                {
                    self.processCachedLmarks(subdirname)
                    self.processCachedIsections(subdirname)
                
                    dispatch_async(dispatch_get_main_queue())
                    {
                        let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.initialLocation.coordinate, self.xRegionSizeMeters, self.yRegionSizeMeters);
                        self.mapView.setRegion(coordinateRegion, animated: false)
                        self.addPinToMapView(stext, latitude: self.initialLocation.coordinate.latitude, longitude: self.initialLocation.coordinate.longitude)
                    }
                    
                    self.readCachedLmarkImages(subdirname, anns: &anns)
                    self.readCachedIntersectionImages(subdirname)
                    dispatch_async(dispatch_get_main_queue())
                    {
                        self.mapView.showAnnotations(anns, animated: false)
                        let coordinateRegion = MKCoordinateRegionMake(self.initialLocation.coordinate, self.span)
                        self.mapView.setRegion(coordinateRegion, animated: false)
                        self.activityIndicatorView.stopAnimating()
                    }
                }
                else
                {
                    let msg: String = "Initialize planner environment failed!\n \(errmsg!)"
                    self.showAlert("Error", alertMessage: String(msg), actionTitle: "Close")
                    NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
                    return
                }
            }
        }
        return true
    }
    
    func readInitialLocationFromFile(subdirname: String) -> Bool
    {
        var loc: String = ""
        if (!self.readDelimitedDataFromFile("coord", ext: "txt", subdirname: subdirname, delimiter: ";", list: &loc))
        {
            let msg: String = "Initialize planner environment failed!\n \(loc)"
            self.showAlert("Error", alertMessage: String(msg), actionTitle: "Close")
            NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
            return false
        }

        let coordArr: Array = loc.componentsSeparatedByString(";")
        //print("lat=\(coordArr[0]) lon=\(coordArr[1])")
        if (coordArr.count < 3)
        {
            let msg: String = "Invalid format of cached initial location file!\n \(loc)"
            self.showAlert("Error", alertMessage: String(msg), actionTitle: "Close")
            NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
            return false
        }
        
        self.initialLocation = CLLocation(latitude: Double(coordArr[0])!, longitude: Double(coordArr[1])!)
        self.initialLocationName = coordArr[2]
        return true
    }
    
    // MARK: Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
        //let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        //let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        let region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, xRegionSizeMeters, yRegionSizeMeters);
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        mapView.showsCompass = false
        mapView.showsPointsOfInterest = false
        mapView.showsScale = false
        mapView.showsTraffic = false
        span = region.span
        //print("span: latitudeDelta = \(span.latitudeDelta)  longitudeDelta = \(span.longitudeDelta)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
    /*
    func processGesture(gestureRecognizer: UITapGestureRecognizer)
    {
        if gestureRecognizer.state == UIGestureRecognizerState.Ended
        {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            
            if let subView = mapView.hitTest(touchPoint, withEvent: nil)
            {
                if subView is LmarkAnnotationView
                {
                    //print("processGesture: LmarkAnnotationView tapped. Exiting.")
                    return
                }
                else if (subView is CalloutView)
                {
                    //print("processGesture: CalloutView tapped. Exiting.")
                    return
                }
            }
            
            let coord = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            //print("touchPoint coord: \(coord.latitude) \(coord.longitude)")
            
            //Find closest intersection
            let getLat: CLLocationDegrees = coord.latitude
            let getLon: CLLocationDegrees = coord.longitude
            let loc: CLLocation =  CLLocation(latitude: getLat, longitude: getLon)
            
            var closestLocation: CLLocation?
            var smallestDistance: CLLocationDistance?
            var pointId: Int64? = -1
            //var roadId: Int64? = -1
            var index: Int = -1
            
            for isection in isections {
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
            
            if (index >= 0)
            {
                //print("smallestDistance = \(smallestDistance!) id = \(pointId!)")
                let location = isections[index].location
            
                //Create temporary pin annotation with blue flag
                //let blueFlagPin = UIImage(named:"BlueFlagLeft")
            
                let lmark = Lmark(name: String(location), description: "", type: 0, address: "", latitude: closestLocation!.coordinate.latitude, longitude: closestLocation!.coordinate.longitude, photo: nil, pointId: pointId!, roadId: 0, street: "", amenity: "", roadLatitude: 0.0, roadLongitude: 0.0)

                //let ann = LmarkAnnotation(lmark: lmark!, pinImage: blueFlagPin!, photoImage: nil)
                let ann = LmarkAnnotation(lmark: lmark!)
                self.mapView.addAnnotation(ann)
                
            }
        }
    }
    */
    
    // MARK: File System Access Methods
    
    func WriteImageToFile(dirname: String, subdirname: String, data: NSData, filename: String) -> Int
    {
        let docdirpath = self.getDocumentsDirectoryPath()
        let dirpath = self.getSubdirectoryPath(docdirpath, subdirname: dirname, create: true)
        let subdirpath = self.getSubdirectoryPath(dirpath, subdirname: subdirname, create: true)
        
        var isDir:ObjCBool = false
    
        let filepath = NSURL(fileURLWithPath: subdirpath).URLByAppendingPathComponent("\(filename).png")
    
        if (!NSFileManager.defaultManager().fileExistsAtPath(filepath.path!, isDirectory: &isDir))
        {
            do {
                    try data.writeToFile(filepath.path!, options:NSDataWritingOptions.DataWritingWithoutOverwriting)
            } catch let error as NSError {
                print("writeToFile \(filepath.path) failed: \(error.localizedDescription)")
                print("filename:\(filename)")
                print("data size=\(data.length)")
                return -1
            }
            return 1
        }
        else
        {
            print("File \(filepath.path) already exists.")
            return -1
        }
    }
    
    func getDocumentsDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getSubdirectoryPath(dirpath: String, subdirname: String, create: Bool) -> String
    {
        var isDir:ObjCBool = false
        let subdirpath = NSURL(fileURLWithPath: dirpath).URLByAppendingPathComponent(subdirname)
        if (!NSFileManager.defaultManager().fileExistsAtPath(subdirpath.path!, isDirectory: &isDir))
        {
            if (create)
            {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(subdirpath.path!, withIntermediateDirectories: false, attributes: nil)
                    isDir = true
                } catch let error as NSError {
                    print("createDirectoryAtPath \(subdirpath.path) failed: \(error.localizedDescription)")
                    return ""
                }
            }
            else
            {
                print("Directory does not exist ansd creation is not allowed: \(subdirpath.path)")
                return ""
            }
        }
        
        if (isDir)
        {
            return subdirpath.path!
        }
        else
        {
            print("Error in getSubdirectoryPath: exists, but not a directory: \(subdirpath.path)")
            return ""
        }
    }
    
    func saveDataToFiles(subdirname: String)
    {
        let docdirpath = self.getDocumentsDirectoryPath()
        if (debug)
        {
            print("Documents Directory Path:\n\(docdirpath)")
        }
        let subdirpath = self.getSubdirectoryPath(docdirpath, subdirname: subdirname, create: true)
        let filepath = NSURL(fileURLWithPath: subdirpath).URLByAppendingPathComponent("coord.txt")
        
        let sloc = "\(self.initialLocation.coordinate.latitude);\(self.initialLocation.coordinate.longitude);\(self.initialLocationName)"
        do {
            try sloc.writeToFile(filepath.path!, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            print("Error saving location string to file!")
        }
        
        if (saveImages)
        {
            print("Before saving lmark images: number of lmarks = \(self.lmarks.count)")
        
            var savedcount = 0
            var errcount = 0
        
            for lmark in self.lmarks
            {
                let ires = saveURLImage(subdirname, subdirname: "lmarks", objname: lmark.name, id: lmark.pointId, lat: lmark.latitude, lon: lmark.longitude)
            
                switch ires {
                case 1:
                    savedcount += 1
                default:
                    errcount += 1
                }
            }
            print("saved:  \(savedcount)")
            print("errors:  \(errcount)")
        
            print("Before saving isection images: number of isections = \(self.isections.count)")
        
            savedcount = 0
            errcount = 0
        
            for isection in self.isections
            {
                if (isection.streetsCount > 1)
                {
                    let ires = saveURLImage(subdirname, subdirname: "isections", objname: isection.location!, id: isection.id, lat: isection.latitude, lon: isection.longitude)
                
                    switch ires {
                    case 1:
                        savedcount += 1
                    default:
                        errcount += 1
                    }
                }
            }
            print("saved:  \(savedcount)")
            print("errors:  \(errcount)")
        }
    }
    
    func CreateOrTruncateFile(filename: String, ext: String) -> Bool
    {
        let DocumentDirURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        self.getSubdirectoryPath(DocumentDirURL.path!, subdirname: cacheSubdir, create: true)
        
        let fileURL = DocumentDirURL.URLByAppendingPathComponent(cacheSubdir, isDirectory: true).URLByAppendingPathComponent(filename).URLByAppendingPathExtension(ext)
        let file: NSFileHandle? = NSFileHandle(forWritingAtPath: fileURL.path!)
        
        if (file == nil)
        {
            if !(NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: nil, attributes: nil))
            {
                NSLog("1 File open failed at \(fileURL.path!)")
                return false
            }
        }
        else
        {
            file?.truncateFileAtOffset(0)
        }
        return true
    }
    
    func AppendStringToFile(txt: String, filename: String, ext: String) -> Bool
    {
        let DocumentDirURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURL = DocumentDirURL.URLByAppendingPathComponent(cacheSubdir, isDirectory: true).URLByAppendingPathComponent(filename).URLByAppendingPathExtension(ext)
        
        var file: NSFileHandle? = NSFileHandle(forUpdatingAtPath: fileURL.path!)
        if (file == nil)
        {
            if (NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: nil, attributes: nil))
            {
                file = NSFileHandle(forUpdatingAtPath: fileURL.path!)
            }
            else
            {
                NSLog("File open failed at \(fileURL.path!)")
                return false
            }
        }
        else
        {
            file?.seekToEndOfFile()
        }
        
        let fileData = txt.dataUsingEncoding(NSUTF8StringEncoding)
        file?.writeData(fileData!)
        file?.closeFile()
        file = nil
        return true
    }
    
    func readLmarkImage(dirpath: String, objname: String, id: Int64) -> UIImage?
    {
        let filename = "\(objname)_\(id)"
        //print("filename: \(filename)")
                
        let filepath = self.mainBundle!.pathForResource(filename, ofType: "png", inDirectory: dirpath)
        //print("filepath: \(filepath)\n")
        if (filepath == nil)
        {
            print("image \(filename) does not exist")
            return nil
        }
        
        let image = UIImage(contentsOfFile: filepath!)
        if (image == nil)
        {
            print("Reading image from \(filepath!) failed.")
            print("\(objname) \(id)")
            print("image size=\(image?.size)")
            return nil
        }
        return image
    }
    
    func saveURLImage(dirname: String, subdirname: String, objname: String, id: Int64, lat: Double, lon: Double) -> Int
    {
        var res: Int = -1
        let filename = "\(objname)_\(id)"
        let strlat = String(lat)
        let strlon = String(lon)
        //let fov = String(90)
        let fov = String(120)
        
        let imageurl = "http://maps.googleapis.com/maps/api/streetview?size=400x400&location=" + strlat + "," + strlon + "&fov=" + fov + "&sensor=false&key=AIzaSyD3jESuue6j-P5ylGPUsqW7ZjTdY59HKy4"
        
        if let url = NSURL(string: imageurl)
        {
            if let data = NSData(contentsOfURL: url)
            {
                if UIImage(data: data) != nil
                {
                    res = WriteImageToFile(dirname, subdirname: subdirname, data: data, filename: filename)
                }
                else
                {
                    print ("UIImage(data: data) == nil for \(objname) coord: \(lat) \(lon)")
                }
            }
            else
            {
                print ("data = NSData(contentsOfURL: url) failed for \(objname) coord: \(lat) \(lon)")
            }
        }
        else
        {
            print ("url = NSURL(string: imageurl) failed for \(objname) coord: \(lat) \(lon)")
        }
        return res
    }
    
    func readCachedLmarkImages(subdirname: String, inout anns: [LmarkAnnotation]) -> Int
    {
        if (debug)
        {
            print("Before reading lmark images: number of lmarks = \(self.lmarks.count)")
        }
        var readcount = 0
        var errcount = 0
    
        let lmarkspath = self.mainBundle!.pathForResource("lmarks", ofType: "", inDirectory: subdirname)
        //print("lmarkspath: \(lmarkspath!)")
        if (lmarkspath == nil)
        {
            let serr = "Subdirectory \(lmarkspath)does not exist"
            self.showAlert("Error", alertMessage: serr, actionTitle: "Close")
            NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
            return -1;
        }
    
        let lmarkssubdir = "\(subdirname)/lmarks"
        for lmark in self.lmarks
        {
            let ann = LmarkAnnotation(lmark: lmark)
            anns.append(ann)
            let image = self.readLmarkImage(lmarkssubdir, objname: lmark.name, id: lmark.pointId)
            if (image != nil)
            {
                readcount += 1
                lmark.photo = image
            }
            else
            {
                errcount += 1
            }
        }
        if (debug)
        {
            print("Landmark images found:      \(readcount)")
            print("Landmark images not found:  \(errcount)")
        }
        return errcount
    }
    
    func readCachedIntersectionImages(subdirname: String) -> Int
    {
        var readcount = 0
        var errcount = 0
        var isections_with_one_street = 0
        var isections_with_two_streets = 0
        var isection_with_two_identical_streets = 0
        var isections_with_tree_streets = 0
        var isection_with_tree_identical_streets = 0
        var isections_with_more_than_tree_streets = 0
        
        if (debug)
        {
            print("Before reading intersection images: number of isections = \(self.isections.count)")
        }
        
        let isectionspath = self.mainBundle!.pathForResource("isections", ofType: "", inDirectory: subdirname)
        //print("isectionspath: \(isectionspath!)")
        
        if (isectionspath == nil)
        {
            let serr = "Subdirectory \(isectionspath)does not exist"
            self.showAlert("Error", alertMessage: serr, actionTitle: "Close")
            NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
            return -1;
        }
        let isectionssubdir = "\(subdirname)/isections"

        //let i = 0
        for isection in self.isections
        {
            var streets = isection.location!
            let streetsArr: Array = streets.componentsSeparatedByString(",")
            var skip: Bool = false
    
            if (isection.streetsCount == 1)
            {
                isections_with_one_street += 1
                skip = true
            }
            else if (isection.streetsCount == 2)
            {
                isections_with_two_streets += 1
                if (streetsArr[0] == streetsArr[1])
                {
                    isection_with_two_identical_streets += 1
                    //skip = true
                }
            }
            else if (isection.streetsCount == 3)
            {
                isections_with_tree_streets += 1
                if (streetsArr[0] == streetsArr[1] &&
                    streetsArr[0] == streetsArr[2])
                {
                    isection_with_tree_identical_streets += 1
                    //skip = true
                }
            }
            else
            {
                isections_with_more_than_tree_streets += 1
            }
    
            if (!skip)
            {
                var tmp: String = streetsArr[0]
                for i in 1...isection.streetsCount-1
                {
                    /*
                    var found: Bool = false
                    for j in 0...i-1
                    {
                        if (streetsArr[j] == streetsArr[i])
                        {
                            found = true;
                        }
                    }
                    if (!found)
                    {
                    */
                        tmp = tmp + "," + streetsArr[i]
                    //}
                }
                //let streets0 = streets
                streets = tmp
    
                let image = self.readLmarkImage(isectionssubdir, objname: streets, id: isection.id)
                if (image != nil)
                {
                    readcount += 1
                    isection.photo = image
                }
                else
                {
                    errcount += 1
                    //print("streets0: \(streets0)")
                    //print("streets : \(streets)")
                }
            }
        }
        
        //for isection in self.isections
        //{
        //    if isection.photo == nil
        //    {
        //        print("isection \(isection.id): photo is null")
        //    }
        //}
        
        if (debug)
        {
            print("Isection images found:  \(readcount)")
            print("Isection images not found::  \(errcount)")
            print("isections with one street: \(isections_with_one_street)")
            print("isections with two streets: \(isections_with_two_streets)")
            print("isection with two identical streets: \(isection_with_two_identical_streets)")
            print("isections with tree streets: \(isections_with_tree_streets)")
            print("isection with tree identical streets: \(isection_with_tree_identical_streets)")
            print("isections with more than tree streets: \(isections_with_more_than_tree_streets)")
        }
        return errcount
    }
    
    // MARK: Segue to Table Views
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        //print("segue.identifier = \(segue.identifier!)")
        //let progress: UIProgressView = UIProgressView(progressViewStyle: .Default)
        //self.view.addSubview(progress)
        //progress.setProgress(50.0, animated: true)

        if (segue.identifier == "ShowTable")
        {
            let btn = sender as! UIBarButtonItem;
            //print("btn: \(btn.title) tag=\(btn.tag)")
    
            let destNavController = segue.destinationViewController as! UINavigationController
            let targetController = destNavController.topViewController as! LandmarksTableViewController
    
            targetController.delegate = self
            //targetController.parentViewController
            targetController.tableView.bounces = true
            targetController.tableView.scrollEnabled = true
            targetController.mode = btn.tag
            targetController.workOffline = workOffline
            targetController.debug = debug
            
            //targetController.resultsController = self.resultsController
        
            if (btn.tag == 1)  //lmarksButton
            {
                if (lmarks.count > 0)
                {
                    for i in 0...lmarks.count-1
                    {
                        targetController.lmarks.append(lmarks[i])
                        targetController.filtered_lmarks.append(lmarks[i])
                    }
                }
            }
            else if (btn.tag == 2)  //solButton
            {
                if (sol.count > 0)
                {
                    for i in 0...self.sol.count-1
                    {
                        var step = self.sol[i]
                        if (workOffline)
                        {
                            assignImageToStep(i, step: &step)
                        }
                        targetController.sol.append(step)
                    }
            
                    if self.safety_sol.count > 0
                    {
                        for i in 0...self.safety_sol.count-1
                        {
                            var step = self.safety_sol[i]
                            if (workOffline)
                            {
                                assignImageToStep(i, step: &step)
                            }
                            targetController.safety_sol.append(step)
                        }
                    }
                }
            }
            else if (btn.tag == 3)  //Intersections Button
            {
                if (isections.count > 0)
                {
                    for i in 0...isections.count-1
                    {
                        if ((isections[i].photo != nil && workOffline) || (isections[i].streetsCount > 1 && !workOffline))
                        {
                            targetController.isections.append(isections[i])
                        }
                    }
                    print("target isections count: \(targetController.isections.count)")
                }
            }
            else if (btn.tag == 4)  //settingsButton
            {
                //print("Settings button clicked")
                var setting: Setting
                
                setting = Setting(name: "Region Size in Meters", tag: 5, type: 2, ival: nil, xname: "Width", yname: "Height", bval: nil, xval: xRegionSizeMeters, yval: yRegionSizeMeters)
                targetController.settings.append(setting)
                
                setting = Setting(name: "Planning Times", tag: 6, type: 2, ival: nil, xname: "Compute Time", yname: "Policy Time", bval: nil, xval: computeTime, yval: policyTime)
                targetController.settings.append(setting)

                setting = Setting(name: "Show Current Location", tag: 1, type: 1, ival: nil, xname: "", yname: "", bval: showCurrentLocation, xval: nil, yval: nil)
                targetController.settings.append(setting)
                
                setting = Setting(name: "Work Offline", tag: 2, type: 1, ival: nil, xname: "", yname: "", bval: workOffline, xval: nil, yval: nil)
                targetController.settings.append(setting)
                
                setting = Setting(name: "Debug", tag: 3, type: 1, ival: nil, xname: "", yname: "", bval: debug, xval: nil, yval: nil)
                targetController.settings.append(setting)
                
                setting = Setting(name: "Create Cash", tag: 4, type: 1, ival: nil, xname: "", yname: "", bval: saveFiles, xval: nil, yval: nil)
                targetController.settings.append(setting)
           }
        }
    }
    
    // MARK: OSM Processing Methods
    
    func overpassQlRequest(minlat: Double, minlon: Double, maxlat: Double, maxlon: Double, completion: ((result: Bool) -> Void)!)
    {
        let bbox = "\(minlat),\(minlon),\(maxlat),\(maxlon)"
        let stringUrl = "https://overpass-api.de/api/interpreter?data=[out:json][timeout:25][bbox:\(bbox)];(way[\"highway\"](\(bbox));node[\"highway\"](\(bbox));way[\"amenity\"](\(bbox));node[\"amenity\"](\(bbox));way[\"leisure\"](\(bbox));node[\"leisure\"](\(bbox));way[\"tourism\"](\(bbox));node[\"tourism\"](\(bbox));way[\"building\"](\(bbox));node[\"building\"](\(bbox)););out body geom qt;"
        let myUrl = NSURL(string: stringUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
        let request = NSMutableURLRequest(URL:myUrl);
        request.HTTPMethod = "GET";
        
        var statusCode: Int = -1
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
        { data, response, error in
        
            if error != nil
            {
                print("Error: \(error)\n Error!!!!\n")
                self.showAlert("HTTP Session Error", alertMessage: error!.localizedDescription, actionTitle: "Close")
                return
            }
            
            if let httpResponse = response as? NSHTTPURLResponse {
                statusCode = httpResponse.statusCode
            }
            if (self.debug)
            {
                print("HTTPResponse Status code: \(statusCode)")
            }
            
            if (statusCode != 200)
            {
                let msg = self.GetHttpErrorMessage(statusCode)
                self.showAlert("HTTP Error", alertMessage: msg, actionTitle: "Close")
                return
            }
            
            self.responseString = String(data: data!, encoding: NSUTF8StringEncoding)!
            
            if (self.saveFiles)
            {
                //let subdirname = self.cacheSubdir
                
                let docdirpath = self.getDocumentsDirectoryPath()
                if (self.debug)
                {
                    print("Documents Directory Path:\n\(docdirpath)")
                }
                
                let subdirpath = self.getSubdirectoryPath(docdirpath, subdirname: self.cacheSubdir, create: true)
                
                let filepath = NSURL(fileURLWithPath: subdirpath).URLByAppendingPathComponent("map.json")
                do {
                    try self.responseString.writeToFile(filepath.path!, atomically: true, encoding: NSUTF8StringEncoding)
                } catch {
                    print("Error saving json string to file: \(filepath.path)")
                }
            }
            
            let res = true
            completion(result: res)
        }
        
        task.resume()
    }
    
    func ExtractLmarksAndIsections(responseString: String, excludedLmarks: String, excludedIsections: String) -> Bool
    {
        var lmarksPtr = UnsafeMutablePointer<Int64>(nil)
        var isectionsPtr = UnsafeMutablePointer<Int64>(nil)
        var lmarks_count : CInt = 0
        var isections_count : CInt = 0
    
        var res = self.MySbplWrapper.initPlannerByOsm_wrapped(responseString, excludedLmarks, excludedIsections, &lmarksPtr, &lmarks_count, &isectionsPtr, &isections_count)
    
        if (res)
        {
            if (debug)
            {
                print("Planner initialized succesfully.")
                print("Landmarks count = \(lmarks_count)")
            }

            res = self.processLandmarks(lmarksPtr, lmarks_count: Int(lmarks_count))
            if (!res)
            {
                NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
                
            }
    
            res = self.MySbplWrapper.freeMemory_wrapped(&lmarksPtr)
            if (!res)
            {
                self.showAlert("SBPL Exception", alertMessage: "MySbplWrapper.freeMemory_wrapped failed.", actionTitle: "Close")
                NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
            }
    
            if (debug)
            {
                print("Intersections count = \(isections_count)")
            }
            
            res = self.processIntersections(isectionsPtr, isections_count: Int(isections_count))
            if (!res)
            {
                NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
            }
    
            res = self.MySbplWrapper.freeMemory_wrapped(&isectionsPtr)
            if (!res)
            {
                self.showAlert("SBPL Exception", alertMessage: "MySbplWrapper.freeMemory_wrapped failed.", actionTitle: "Close")
                NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
            }
        }
        else
        {
            self.showAlert("SBPL Error", alertMessage: "Could not initialize planner.", actionTitle: "Close")
            NSLog("SBPL ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
        }
        return res
    }
    
    func GetHttpErrorMessage(statusCode: Int) -> String
    {
        let errorDesc = NSHTTPURLResponse.localizedStringForStatusCode((statusCode))
        print("Error: \(String(statusCode)) \(errorDesc)")
    
        var msg: String = ""
        if statusCode == 400 {
            msg = "400 Bad Request"
        }
        else if statusCode == 401 {
            msg = "401 Unauthorized"
        }
        else if statusCode == 402 {
            msg = "402 Payment Required"
        }
        else if statusCode == 403 {
            msg = "403 Forbidden"
        }
        else if statusCode == 404 {
            msg = "404 Not Found"
        }
        else if statusCode == 405 {
            msg = "405 Method Not Allowed"
        }
        else if statusCode == 406 {
            msg = "406 Not Acceptable"
        }
        else if statusCode == 407 {
            msg = "407 Proxy Authentication Required"
        }
        else if statusCode == 408 {
            msg = "408 Request Timeout"
        }
        else {
            msg = String(statusCode) + " Connection failed"
        }
        print("\(msg)")
        
        msg = msg + ". " + errorDesc
        return msg
    }
    
    func initEnvByOsmQuery(coord: CLLocationCoordinate2D) -> Bool
    {
        var res :Bool = true
        
        let minlat: Double = coord.latitude - span.latitudeDelta
        let minlon: Double = coord.longitude - span.longitudeDelta
        let maxlat: Double = coord.latitude + span.latitudeDelta
        let maxlon: Double = coord.longitude + span.longitudeDelta
        
        //var thr: NSThread = NSThread.currentThread()
        //var b: Bool = thr.isMainThread;
        //print("1: isMainThread = \(b)")
        
        responseString = ""
        
        if (queryOSM)
        {
            overpassQlRequest(minlat, minlon:minlon, maxlat:maxlat, maxlon:maxlon, completion:
            { (result: Bool)->Void in
            
                res = result
                if (res)
                {
                    let excluded_lmarks_list: String = ""
                    let excluded_isections_list: String = ""
                    self.aaa(coord, excluded_lmarks_list: excluded_lmarks_list, excluded_isections_list: excluded_isections_list)
                }
                else
                {
                    self.showAlert("Error", alertMessage: "Init planner environment failed!", actionTitle: "Close")
                    NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
                }
            })
        }
        return res
    }
    
    func initEnvByCachedOsm(coord: CLLocationCoordinate2D, subdirname: String) -> Bool
    {
        var res :Bool = true
        let json_path = self.mainBundle!.pathForResource("map", ofType: "json", inDirectory: subdirname)
        if (self.debug)
        {
            print("json_path: \(json_path!)\n")
        }
            
        do {
            responseString = try NSString(contentsOfFile: json_path!, encoding: NSUTF8StringEncoding) as String
        } catch {
            let serr = "Error reading cashed file: \(json_path!)"
            self.showAlert("Error", alertMessage: serr, actionTitle: "Close")
            NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
            res = false
        }
            
        if (res)
        {
            var excluded_lmarks_list: String = ""
            var excluded_isections_list: String = ""

            if (!self.readDelimitedDataFromFile("excluded_lmarks", ext: "txt", subdirname: subdirname, delimiter: ",", list: &excluded_lmarks_list))
            {
                let msg: String = "Error: \(excluded_lmarks_list))"
                self.showAlert("Error", alertMessage: String(msg), actionTitle: "Close")
                NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
                return false
            }
            
            if (!self.readDelimitedDataFromFile("excluded_isections", ext: "txt", subdirname: subdirname, delimiter: ",", list: &excluded_isections_list))
            {
                let msg: String = "Error: \(excluded_isections_list))"
                self.showAlert("Error", alertMessage: String(msg), actionTitle: "Close")
                NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
                return false
            }
            
            aaa(coord, excluded_lmarks_list: excluded_lmarks_list, excluded_isections_list: excluded_isections_list)
        }
        return res
    }

    func aaa(coord: CLLocationCoordinate2D, excluded_lmarks_list: String, excluded_isections_list: String)
    {
        if (self.ExtractLmarksAndIsections(responseString, excludedLmarks: excluded_lmarks_list, excludedIsections: excluded_isections_list))
        {
            var anns = [LmarkAnnotation]()
            for lmark in self.lmarks
            {
                let ann = LmarkAnnotation(lmark: lmark)
                anns.append(ann)
            }
            self.mapView.addAnnotations(anns)
    
            if (self.saveFiles)
            {
                self.saveDataToFiles(cacheSubdir)
            }
    
            dispatch_async(dispatch_get_main_queue())
            {
                self.mapView.showAnnotations(anns, animated: false)
                let coordinateRegion = MKCoordinateRegionMake(coord, self.span)
                self.mapView.setRegion(coordinateRegion, animated: false)
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    func searchInMap(search_query: String, lat: CLLocationDegrees, lon: CLLocationDegrees, span: MKCoordinateSpan)
    {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = search_query
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({(response: MKLocalSearchResponse?, error: NSError?) in
        
            if (error != nil)
            {
                print("Error occured in search: \(error!.localizedDescription)")
                self.showAlert("Search Error", alertMessage: error!.localizedDescription, actionTitle: "Close")
            }
            else if response?.mapItems.count == 0
            {
                print("No matches found")
                self.showAlert("Search Result", alertMessage: "No matches found", actionTitle: "Close")
            }
            else
            {
                print("Search returned \((response?.mapItems)!.count) items")
                var iim = 0;
                for item in (response?.mapItems)!
                {
                    iim += 1
                    print("#\(iim) title: \(item.placemark.name!)") // \(item.placemark.title!) \(item.name!)")
                        
                    self.initialLocation = item.placemark.location!
                    self.initialLocationName = item.name!
                    let coordinateRegion = MKCoordinateRegionMake(self.initialLocation.coordinate, span)
                    self.mapView.setRegion(coordinateRegion, animated: false)
                    self.addPinToMapView(item.name!, latitude: self.initialLocation.coordinate.latitude, longitude: self.initialLocation.coordinate.longitude)

                    self.initEnvByOsmQuery(self.initialLocation.coordinate)
                    break
                }
            }
        })
    }
    
    // MARK: Generate Plan and Directions
    
    func assignImageToStep(i: Int, inout step: SolutionStep)
    {
        var id: Int64
        var type: Int
        if (i == 0)
        {
            type = step.type1
            id = step.id1
        }
        else
        {
            type = step.type2
            id = step.id2
        }
        
        if (type == 1)
        {
            let ind = findLandmarkByID(id)
            if (ind >= 0 && lmarks[ind].photo != nil)
            {
                step.photoImage = lmarks[ind].photo
            }
        }
        else
        {
            let ind = findIntersectionByID(id)
            if (ind >= 0 && isections[ind].photo != nil)
            {
                step.photoImage = isections[ind].photo
            }
            
        }
    }
    
    func DisplayPath(pathArr: UnsafeMutablePointer<CInt>, count: Int, plan_file_name: String, plan_file_ext: String)
    {
        self.sol.removeAll()
        self.safety_sol.removeAll()
        
        var i: Int = 0
        var j: Int = 0
        var l: Int = 0
        plan.removeAll()
        safety_plan.removeAll()
        
        for ii in  0..<count
        {
            let k = Int(pathArr[3*ii])
            let currInd = pathArr[3*ii+1]
            let succInd = pathArr[3*ii+2]
            
            var id1: Int64 = 0
            var id2: Int64 = 0
            var act1: CInt = 0
            var act2: CInt = 0
            var type1: CInt = 0
            var type2: CInt = 0
            var dir1: CInt = 0
            var dir2: CInt = 0
            var lat1: Double = 0.0
            var lon1: Double = 0.0
            var lat2: Double = 0.0
            var lon2: Double = 0.0
            var envId1: CInt = 0
            var envId2: CInt = 0
            
            let res = self.MySbplWrapper.getSolutionStepDetails_wrapped(currInd, succInd, &id1, &id2, &act1, &act2, &type1, &type2, &dir1, &dir2, &lat1, &lon1, &lat2, &lon2, &envId1, &envId2)
            if (!res)
            {
                showAlert("SBPL_Exception", alertMessage: "MySbplWrapper.getSolutionStepDetails_wrapped failed.", actionTitle: "Close")
                NSLog("ERROR: [file: \(#file) function: \(#function) at line \(#line)]")
            }
            
            if (debug)
            {
                autoreleasepool {
                let txt = "\(i) | \(k) |p \(currInd) |e \(envId1) | \(id1) \(lat1) \(lon1) act \(act1) type \(type1) dir \(dir1) |p \(succInd) |e \(envId2) | \(id2) \(lat2) \(lon2) act \(act2) type \(type2) dir \(dir2)\n"
                
                    AppendStringToFile(txt, filename: plan_file_name, ext: plan_file_ext)
                }
            }
            
            let step = SolutionStep(seq: i, name: "", instructions: "", photoImage: nil, iconName: "", k: k, id1: id1, lat1: lat1, lon1: lon1, act1: Int(act1), type1: Int(type1), id2: id2, lat2: lat2, lon2: lon2, act2: Int(act2), type2: Int(type2), dir1: Int(dir1), dir2: Int(dir2))
            step.orig_seq = i
            
            if (k == 0)
            {
                step.seq = j
                plan.append(step)
                j += 1
            }
            else
            {
                step.seq = l
                safety_plan.append(step)
                l += 1
            }
            
            i += 1
        }
        
        var ind = 0
        var match = false
        
        if (safety_plan.count > 0)
        {
            for ii in 0...safety_plan.count-1
            {
                if (!match)
                {
                    for jj in ind...plan.count-1
                    {
                        if (safety_plan[ii].id1 == plan[jj].id1)
                        {
                            plan[jj].safety_ind_start = ii
                            //print("ii=\(ii) jj=\(jj)")
                            ind = jj
                            match = true
                            break
                        }
                    }
                }
                
                if (match)
                {
                    if (safety_plan[ii].act2 == -1000)
                    {
                        match = false
                        plan[ind].safety_ind_end = ii
                        ind += 1
                    }
                }
            }
        }
        
        if (plan.count > 0)
        {
            populatePlan()
        }
    }
    
    func populatePlan()
    {
        var isection_count = 1
        var landmark_count = 0
        var street: String = ""
        
        var n = plan.count
        if (debug)
        {
            print("plan.count = \(plan.count)")
        }
    
        for i in 0...n-1
        {
            let step = plan[i]
    
            if (i == 0)
            {
                let step0 = populateFirstStep(step)
                sol.append(step0)
                isection_count = 1
            }
            
            let turn = (step.act1 == 0 && step.act2 != 0 && step.type2 == 0)
            let three_way = (step.act1 == 0 && step.act2 == 0 && step.type2 == 0 && step.dir1 != step.dir2)
            let landmark = (step.type2 == 1)
            let safety = (step.safety_ind_start >= 0 && step.safety_ind_end > step.safety_ind_start+1)
            
            if (turn || three_way || landmark  || safety)
            {
                if (turn || three_way || landmark)
                {
                    if (landmark)
                    {
                        if (landmark_count > 4)
                        {
                            landmark_count = 0
                        }
                        
                        landmark_count += 1
                        
                        if (landmark_count > 1 && i < n-1)
                        {
                            continue
                        }
                    }
                    
                    step.isection_count = isection_count
                    sol.append(step)
                    isection_count = 1
                    
                    if (turn || three_way)
                    {
                        landmark_count = 0
                    }
                }
                
                if (safety)
                {
                    var istart = step.safety_ind_start
                    let iend = step.safety_ind_end
                    
                    let step1 = populateFalseStep(&istart, iend: iend)
                    
                    let i1 = safety_sol.count
                    if (istart + 1 < iend)
                    {
                        populateSafetyPlan(istart+1, iend: iend)
                        let i2 = safety_sol.count
                    
                        step1.safety_ind_start = i1
                        step1.safety_ind_end = i2-1
                        sol.append(step1)
                    }
                }
            }
            else
            {
                let ind = findIntersectionByID(step.id2)
                let streets = isections[ind].location!
                let streetsArr: Array = streets.componentsSeparatedByString(",")

                if (step.id1 != step.id2 && streetsArr.count > 1)
                {
                    isection_count += 1;
                }
                //print("Skipping intersection i=\(i) isection_count=\(isection_count) \(streets)")
            }
        }
        
        n = sol.count
        for i in 1...n-1
        {
            var instr: String = ""
            var iconName: String = ""
            var type: Int = 0
            var id: Int64 = 0
            
            let step = sol[i]
            if (step.iconName == "RedMarker")
            {
                continue
            }
            
            type = step.type2
            id = step.id2
            
            if (type == 0)
            {
                var nextstreet: String = ""
                var prevstreet: String = ""
                var nextstep: SolutionStep? = nil
                var prevstep: SolutionStep? = nil
                
                if (i < n-1)
                {
                    nextstep = SolutionStep(step: sol[i+1])
                    if (nextstep?.iconName == "RedMarker")
                    {
                        nextstep = SolutionStep(step: sol[i+2])
                    }
                }
                
                prevstep = SolutionStep(step: sol[i-1])
                if (prevstep?.iconName == "RedMarker")
                {
                    if (i >= 2)
                    {
                        prevstep = sol[i-2]
                    }
                    else
                    {
                        print("First step after start position is false step. This should not really happen!")
                    }
                }
                
                getIsectionInstructions(i, step: step, nextstep: nextstep, prevstep: prevstep, prevstreet: &prevstreet, nextstreet: &nextstreet, instr: &instr, iconName: &iconName)
                sol[i].street = nextstreet
                
                //print("i=\(i) type=\(step.type2) prevstreet=\(prevstreet) nextstreet=\(nextstreet)")
            }
            else if (type == 1)
            {
                getLmarkInstructions(step.orig_seq, id: id, act: step.act1, street: &street, instr: &instr, iconName: &iconName)
                //print("i=\(i) type=\(step.type2) street=\(street)")
                sol[i].street = street
            }
            
            if (i == n-1)
            {
                instr = instr + ". You have reached your destination."
                iconName = "FinishLine"
            }
            step.iconName = iconName
            step.instructions = instr
        }
    }
    
    func populateFalseStep(inout istart: Int, iend: Int) -> SolutionStep
    {
        var step = safety_plan[istart]
        let jend = iend - 2
        if (step.type2 == 0 && istart < jend)
        {
            istart += 1
            step = safety_plan[istart]
            if (step.type2 == 0 && istart < jend)
            {
                istart += 1
                step = safety_plan[istart]
                if (step.type2 == 0 && istart < jend)
                {
                    istart += 1
                    step = safety_plan[istart]
                    if (step.type2 == 0 && istart < jend)
                    {
                        istart += 1
                        step = safety_plan[istart]
                        if (step.type2 == 0 && istart < jend)
                        {
                            istart += 1
                            step = safety_plan[istart]
                        }
                    }
                }
            }
        }
        
        let step1 = SolutionStep(step: step)
        step1.iconName = "RedMarker"
        step1.orig_seq = step.orig_seq
        step1.safety_ind_start = step.safety_ind_start + 1
        step1.safety_ind_end = step.safety_ind_end
        
        //var instr = String(step1.seq) + "-" + String(step1.orig_seq) + ": If you see "
        var instr = "If you see "
    
        if step1.type2 == 1
        {
            let ind = findLandmarkByID(step1.id2)
            instr = instr + lmarks[ind].name
    
            if !lmarks[ind].street.isEmpty
            {
                instr = instr + " on " + lmarks[ind].street
            }
        }
        else
        {
            let ind = findIntersectionByID(step1.id2)
            let streets = isections[ind].location!
            instr = instr + "intersection " + streets
        }
    
        instr = instr + ", you missed the turn. Press the button on the right to get new directions."
        step1.instructions = instr
        return step1
    }
    
    func populateFirstStep(step: SolutionStep) -> SolutionStep
    {
        //var street: String
        var instr = ""   //String(step.orig_seq) + ": "
        instr = instr + startPoseDescription(step.id1, type: Int(step.type1))
    
        /*
        if (step.type1 == 1)
        {
            let ind = findLandmarkByID(step.id1)
            
            if !lmarks[ind].street.isEmpty
            {
                street = lmarks[ind].street
            }
            else
            {
                street = ""
            }
            print("street = \(street)")
            instr = instr + " on " + street
        }
        else
        {
            if (step.type2 == 1)
            {
                let ind = findLandmarkByID(step.id2)
                if !lmarks[ind].street.isEmpty
                {
                    street = lmarks[ind].street
                }
                //print("street = \(street)")
                //instr = instr + " on " + street
            }
            else
            {
                let ind1 = findIntersectionByID(step.id1)
                let prevstreets = isections[ind1].location
                //print("prevstreets = \(prevstreets)")
                let streetsArr1: Array = prevstreets!.componentsSeparatedByString(",")
    
                let ind2 = findIntersectionByID(step.id2)
                let nextstreets = isections[ind2].location!
                //print("nextstreets = \(nextstreets)")
                let streetsArr2: Array = nextstreets.componentsSeparatedByString(",")
    
                street = ""
                var found: Bool = false
                for prevstreet in streetsArr1
                {
                    for nextstreet in streetsArr2
                    {
                        if (prevstreet == nextstreet)
                        {
                            street = prevstreet
                            found = true
                            break
                        }
                    }
                    if (found)
                    {
                        break
                    }
                }
                //instr = instr + " on " + street
            }
        }
        */
        
        let step0 = SolutionStep(step: step)
        step0.instructions = instr
        step0.iconName = "StartButton"
        return step0
    }
    
    func populateSafetyPlan(istart: Int, iend: Int)
    {
        var isection_count = 1
        var landmark_count = 0
        var street: String = ""
        let i1 = safety_sol.count
        
        //var n = iend - istart
        //print("count = \(n)")
        
        for i in istart...iend
        {
            let step = safety_plan[i]
            
            if (i == istart)
            {
                let step0 = populateFirstStep(step)
                safety_sol.append(step0)
            }
            
            let turn = (step.act1 == 0 && step.act2 != 0 && step.type2 == 0)
            let three_way = (step.act1 == 0 && step.act2 == 0 && step.type2 == 0 && step.dir1 != step.dir2)
            let landmark = (step.type2 == 1)
            
            if (turn || three_way || landmark)
            {
                isection_count = 1
                
                if (landmark)
                {
                        if (landmark_count > 4)
                        {
                            landmark_count = 0
                        }

                        landmark_count += 1
                        
                        if (landmark_count > 1 && i < iend)
                        {
                            continue
                        }
                }
                    
                step.isection_count = isection_count
                safety_sol.append(step)
                isection_count = 1
                    
                if (turn || three_way)
                {
                    landmark_count = 0
                }
            }
            else
            {
                let ind = findIntersectionByID(step.id2)
                let streets = isections[ind].location!
                let streetsArr: Array = streets.componentsSeparatedByString(",")
                //print("Skipping intersection i=\(i) isection_count=\(isection_count) \(streets)")
                if (step.id1 != step.id2 && streetsArr.count > 1)
                {
                    isection_count += 1;
                }
            }
        }
        let i2 = safety_sol.count
        
        for i in i1+1...i2-1
        {
            var instr: String = ""
            var iconName: String = ""
            var type: Int = 0
            var id: Int64 = 0
            
            let step = safety_sol[i]
            
            type = step.type2
            id = step.id2
            
            if (type == 0)
            {
                var nextstreet: String = ""
                var prevstreet: String = ""
                var nextstep: SolutionStep? = nil
                var prevstep: SolutionStep? = nil
                
                if (i < i2-1)
                {
                    nextstep = SolutionStep(step: safety_sol[i+1])
                }
                
                prevstep = SolutionStep(step: safety_sol[i-1])
                
                getIsectionInstructions(i, step: step, nextstep: nextstep, prevstep: prevstep, prevstreet: &prevstreet, nextstreet: &nextstreet, instr: &instr, iconName: &iconName)
                //print("i=\(i) type=\(step.type2) prevstreet=\(prevstreet) nextstreet=\(nextstreet)")
                if (nextstreet == prevstreet)
                {
                    safety_sol[i].skip = true
                }
            }
            else if (type == 1)
            {
                getLmarkInstructions(step.orig_seq, id: id, act: step.act1, street: &street, instr: &instr, iconName: &iconName)
                //print("i=\(i) type=\(step.type2) street=\(street)")
            }
            
            if (i == i2-1)
            {
                instr = instr + ". You have reached your destination."
                iconName = "FinishLine"
            }
            step.iconName = iconName
            step.instructions = instr
        }
    }
    
    func getLmarkInstructions(i: Int, id: Int64, act: Int, inout street: String, inout instr: String, inout iconName: String)
    {
        instr = ""
        let ind = findLandmarkByID(id)
        if !lmarks[ind].street.isEmpty
        {
            street = lmarks[ind].street
        }
        //print("street = \(street)")
    
        instr = "Follow " + street + " untill you see "
        instr = instr + lmarks[ind].name
        iconName = directionImages[Int(act) + 3]
    }
    
    func getIsectionInstructions(i: Int, step: SolutionStep, nextstep: SolutionStep?, prevstep: SolutionStep?, inout prevstreet: String, inout nextstreet: String, inout instr: String, inout iconName: String)
    {
        let id: Int64 = step.id2
        let ind = findIntersectionByID(id)
        let streets = isections[ind].location!
        //print("currstreets = \(streets)")
        
        let streetsArr: Array = streets.componentsSeparatedByString(",")

        if (nextstep == nil)
        {
            nextstreet = ""
        }
        else if (nextstep!.type2 ==  1)
        {
            let ind1 = findLandmarkByID(nextstep!.id2)
            if !lmarks[ind1].street.isEmpty
            {
                nextstreet = lmarks[ind1].street
            }
            //print("nextstreet = \(nextstreet)")
        }
        else if (nextstep!.type2 == 0)
        {
            let ind1 = findIntersectionByID(nextstep!.id2)
            let nextstreets = isections[ind1].location!
            //print("nextstreets = \(nextstreets)")
            let streetsArr1: Array = nextstreets.componentsSeparatedByString(",")
            
            nextstreet = ""
            var found: Bool = false
            for currstreet in streetsArr
            {
                //print(" \(currstreet)")
                
                for street in streetsArr1
                {
                    //print(" \(street)")
                    
                    if (street == currstreet)
                    {
                        nextstreet = currstreet
                        found = true
                        break;
                    }
                }
                if (found)
                {
                    break
                }
            }
        }
        //print("nextstreet = \(nextstreet)")
        
        var type: Int
        var idd: Int64
        if (prevstep != nil && prevstep!.id1 == step.id1 && prevstep!.id2 == step.id2 && prevstep!.type1 == step.type1 && prevstep!.type2 == step.type2)
        {
            type = prevstep!.type1
            idd = prevstep!.id1
        }
        else
        {
            type = prevstep!.type2
            idd = prevstep!.id2
        }
        
        if (type ==  1)
        {
            let ind1 = findLandmarkByID(idd)
            if !lmarks[ind1].street.isEmpty
            {
                prevstreet = lmarks[ind1].street
            }
            //print("prevstep = \(prevstreet)")
        }
        else if (type == 0)
        {
            let ind1 = findIntersectionByID(idd)
            let prevstreets = isections[ind1].location!
            //print("prevstreets = \(prevstreets)")
            let streetsArr1: Array = prevstreets.componentsSeparatedByString(",")
            
            prevstreet = ""
            var found: Bool = false
            for currstreet in streetsArr
            {
                //print(" \(currstreet)")
                
                for street in streetsArr1
                {
                    //print(" \(street)")
                    
                    if (street == currstreet)
                    {
                        prevstreet = currstreet
                        found = true
                        break;
                    }
                }
                if (found)
                {
                    break
                }
            }
        }
        //print("prevstreet = \(prevstreet)")
        
        let isection_descr = getIsectionSeq(step.isection_count)
        
        //instr = String(step.orig_seq) + ": " + "Follow " + prevstreet + ". When you see " + isection_descr + ", "
        instr = "Follow " + prevstreet + ". When you see " + isection_descr + ", "
        
        let act: Int = step.act2
        
        if (act >= -3 && act <= 3)
        {
            if (nextstreet != "")
            {
                instr = instr + directionNames[Int(act) + 3] + " onto " + nextstreet + "."
            }
            iconName = directionImages[Int(act) + 3]
        }
        
        //instr = instr + " (" + String(id) + ")"
        //instr = instr + " (" + (isections[ind].location as String) + ")"
    }
    
    func getIsectionSeq(isection_count: Int) -> String
    {
        var isection_descr: String = ""
        if (isection_count == 1)
        {
            isection_descr = "first intersection"
        }
        else if (isection_count == 2)
        {
            isection_descr = "second intersection"
        }
        else if (isection_count == 3)
        {
            isection_descr = "third intersection"
        }
        else if (isection_count == 4)
        {
            isection_descr = "fourth intersection"
        }
        else if (isection_count == 5)
        {
        isection_descr = "fifth intersection"
        }
        else
        {
            isection_descr = "intersection # " + String(isection_count)
        }
        return isection_descr
    }
    
    func interimPoseDescription(i: Int, id: Int64, act: Int, type: Int, inout iconName: String, inout streetCount: Int, isection_count: Int) -> String
    {
        var ind: Int = -1
        var descr: String = ""
        var instr: String = ""
        iconName = ""
        streetCount = 0
        
        instr = ""  //String(i) + ": ";
        
        if (act >= -3 && act <= 3)
        {
            iconName = directionImages[act + 3]
            instr = instr + directionNames[act + 3]
        }
        
        if (type == 1)
        {
            //landmark
            descr = lmarkDescriptionForDisplay(id)
        }
        else if (type == 0)
        {
            //intersection
            ind = findIntersectionByID(id)
            streetCount = isections[ind].streetsCount
            
            //let streets = isections[ind].location! //as String
            //let streetsArr: Array = streets.componentsSeparatedByString(",")

            //var istr = 0
            //for street in streetsArr
            //{
                //print("i=\(istr) \(street)")
                //istr += 1
            //}
            
            descr = "intersection " + (isections[ind].location!) //as String)
            descr = descr + " at intersection # " + String(isection_count)
        }
        descr = descr + " (" + String(id) + ")"
        
        
        if (act == 0)
        {
            instr = instr + " until you see " + descr
        }
        else
        {
            instr = instr + " at " + descr
        }

        return instr
    }
    
    func lmarkDescriptionForDisplay(id: Int64) -> String
    {
        //landmark
        let ind = findLandmarkByID(id)
        var instr = lmarks[ind].name
        if !lmarks[ind].street.isEmpty
        {
            instr = instr + " on " + lmarks[ind].street
        }
        else if !lmarks[ind].address.isEmpty
        {
            instr = instr + " at " + lmarks[ind].address
        }
        //if !lmarks[ind].amenity.isEmpty
        //{
        //    instr = instr + " (" + lmarks[ind].amenity + ")"
        //}
        return instr
    }
    
    func startPoseDescription(id: Int64, type: Int) -> String
    {
        var ind: Int = -1
        var instr: String = ""
        if (type == 1)
        {
            //landmark
            //ind = findLandmarkByID(id)
            instr = "Start from " + lmarkDescriptionForDisplay(id)
            /*
            lmarks[ind].name
            if !lmarks[ind].address.isEmpty
            {
                instr = instr + " at " + lmarks[ind].address
            }
            else if !lmarks[ind].street.isEmpty
            {
                instr = instr + " on " + lmarks[ind].street
            }
            
            if !lmarks[ind].amenity.isEmpty
            {
                instr = instr + " (" + lmarks[ind].amenity + ")"
            }
            */
        }
        else if (type == 0)
        {
            //intersection
            ind = findIntersectionByID(id)
            instr = "Start from intersection " + (isections[ind].location!) // as String)
        }
        
        //instr = instr + " (" + String(id) + ")"
        return instr
    }
    
    func replaceLmarkAnnotationViewImage(id: Int64) -> Int
    {
        var ind  = -1
        var i = 0
        for ann in mapView.annotations
        {
            if ann is LmarkAnnotation
            {
                let ann1: LmarkAnnotation = ann as! LmarkAnnotation
                
                if (ann1.lmark.pointId == id)
                {
                    //print("id: \(id) lmark.name: \(ann1.lmark.name)")
                
                    let view = self.mapView.viewForAnnotation(ann1)
                    let view1: LmarkAnnotationView = view as! LmarkAnnotationView
                    view1.image = UIImage(named: "RedMarker")
                    
                    redMarkerViews.append(view1)
                    
                    ind = i
                    break
                }
            }
            i += 1
        }
        return ind
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerData.count
    }
    
    //func drawTempPlan(planColor: UIColor, coords: [CLLocationCoordinate2D])
    //{
    //    let n = coords.count
    //    var tcoords = [CLLocationCoordinate2D]()
    //    tcoords = coords
    //    let polyline: MKPolyline = MKPolyline(coordinates: &tcoords, count: n)
    //    self.polyline_color = planColor
    //    self.mapView.addOverlay(polyline)
    //}
    
    func drawPlan(k: Int, planColor: UIColor, lineWidth: CGFloat, path: [SolutionStep])
    {
        //if (debug)
        //{
        //    redMarkerViews.removeAll()
        //}
        
        let n = path.count
        var coords = [CLLocationCoordinate2D]()
        var i = 0
        for step in path
        {
            if (step.k == k)
            {
                //print("i=\(i) type \(step.type1) id1 \(step.id1) id2 \(step.id2)")
                
                if (step.type1 == 0) //intersection
                {
                    coords.append(CLLocationCoordinate2DMake(step.lat1, step.lon1))
                    
                    //let ind = findIntersectionByID(step.id1)
                    //let isection = isections[ind]
                    //self.addPinToMapView("BlackMarker", latitude: step.lat1, longitude:step.lon1)
                }
                else //landmark
                {
                    let ind = findLandmarkByID(step.id1)
                    let rlat = lmarks[ind].roadLatitude
                    let rlon = lmarks[ind].roadLongitude
                    coords.append(CLLocationCoordinate2DMake(rlat, rlon))
                    
                    if (debug && step.id1 != start_pointId && step.id2 != goal_pointId)
                    {
                        replaceLmarkAnnotationViewImage(step.id1)
                    }
                }
                
                if (i == n-1)
                {
                    if (step.type2 == 0)
                    {
                        coords.append(CLLocationCoordinate2DMake(step.lat2, step.lon2))
                    }
                    else
                    {
                        let ind2 = findLandmarkByID(step.id2)
                        let rlat2 = lmarks[ind2].roadLatitude
                        let rlon2 = lmarks[ind2].roadLongitude
                        coords.append(CLLocationCoordinate2DMake(rlat2, rlon2))
                    }
                }
            }
            i += 1
        }
        
        let polyline: MKPolyline = MKPolyline(coordinates: &coords, count: n+1)
        self.polyline_color = planColor
        self.polyline_width = lineWidth
        self.mapView.addOverlay(polyline)
    }
    
    // MARK: Helper Methods
    
    func addPinToMapView(title: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.title = title
        pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(pointAnnotation)
    }
    
    func findLandmarkByID(id: Int64) -> Int
    {
        var ind  = -1
        var i = 0
        for lmark in lmarks
        {
            if lmark.pointId == id
            {
                ind = i
                break
            }
            i += 1
        }
        return ind
    }
    
    func findIntersectionByID(id: Int64) -> Int
    {
        var ind  = -1
        var i = 0
        for isection in isections
        {
            if isection.id == id
            {
                ind = i
                break
            }
            i += 1
        }
        return ind
    }
    
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String)
    {
        dispatch_async(dispatch_get_main_queue())
        {
            let ac = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
            
            self.presentViewController(ac, animated:true, completion: nil)
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    /*
    @IBAction func zoomInMap(sender: AnyObject)
    {
        displayRegion(27.17, lon: 78.04, span: 0.03)
        //let coordinate = initialLocation.coordinate;
        let coord = CLLocationCoordinate2D(latitude: 27.17, longitude: 78.04)
        //print("latitude = \(coord.latitude) longitude = \(coord.longitude)")
        let circleOverlay: MKCircle = MKCircle(centerCoordinate: coord, radius: 300)
        mapView.addOverlay(circleOverlay, level: MKOverlayLevel.AboveRoads)
        overlayOsm()
    }
    */
    
    /*
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
    */
    
    /*
     func takeSnapshot(mapView: MKMapView, coord: CLLocationCoordinate2D, eyeCoord: CLLocationCoordinate2D, filename: String, completion: ((result:UIImage?) -> Void)!)
     {
     //let coordSpan = MKCoordinateSpan(latitudeDelta: 0.0000000001, longitudeDelta: 0.0000000001)
     let options = MKMapSnapshotOptions()
     //let region = MKCoordinateRegion(center: coord, span: coordSpan)
     let region = MKCoordinateRegionMakeWithDistance(coord, 0.5, 0.5)
     options.region = region
     //options.size = mapView.frame.size;
     options.scale = UIScreen.mainScreen().scale
     //options.size = CGSize(width: 50, height: 50)
     options.mapType = .SatelliteFlyover
     options.showsPointsOfInterest = true
     options.showsBuildings = true
     
     let eyeCoord1 = CLLocationCoordinate2D(latitude: coord.latitude+0.0000002, longitude: coord.longitude+0.0000001)
     let eyeAlt = CLLocationDistance(3.0)
     //let BellefiedHallCoord = CLLocationCoordinate2D(latitude: 40.4453588019383, longitude: -79.950951061835)
     //let IntersCoord = CLLocationCoordinate2D(latitude: 40.443922, longitude: -79.950749)
     
     //let camera = MKMapCamera(lookingAtCenterCoordinate: IntersCoord, fromDistance: 20, pitch: 45, heading: 180)
     let camera = MKMapCamera(lookingAtCenterCoordinate: coord, fromEyeCoordinate: eyeCoord1, eyeAltitude: eyeAlt)
     
     camera.altitude = 10.0
     //camera.centerCoordinate = coord
     options.camera = camera
     
     let semaphore = dispatch_semaphore_create(0)
     let qualityOfServiceClass = QOS_CLASS_BACKGROUND
     let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
     
     let snapshotter = MKMapSnapshotter(options: options)
     
     snapshotter.startWithQueue(backgroundQueue, completionHandler:  { (snapshot: MKMapSnapshot?, error: NSError?) -> Void in
     
     guard (snapshot != nil) else {
     print("Snapshot error:\(error)")
     dispatch_semaphore_signal(semaphore)
     return
     //completion(result:nil)
     }
     completion(result: snapshot!.image)
     
     let data = UIImagePNGRepresentation(snapshot!.image)
     let docdirpath = self.getDocumentsDirectoryPath()
     let filepath = NSURL(fileURLWithPath: docdirpath).URLByAppendingPathComponent("\(filename).png")
     
     data?.writeToFile(filepath.path!, atomically: true)
     
     dispatch_semaphore_signal(semaphore)
     })
     let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3*Double(NSEC_PER_SEC)))
     dispatch_semaphore_wait(semaphore, delayTime)
     }
     */
    
    
    /*
     func showRoute(response: MKDirectionsResponse) {
     for route in response.routes {
     mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
     
     //for step in route.steps {
     //    print(step.instructions)
     //}
     }
     }
     */
    
    /*
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
     */
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
    //}
    
    /*
     func overlayOsm() {
     let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
     let overlay = MKTileOverlay(URLTemplate: template)
     overlay.canReplaceMapContent = true
     mapView.addOverlay(overlay, level: .AboveRoads)
     }
     */
}

