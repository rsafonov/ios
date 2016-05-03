//
//  ViewController.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 2/24/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    typealias Payload = [String: AnyObject]
    
    //MARK Properties
    
    let dirRequest = MKDirectionsRequest()
    var landmarks = [MKMapItem]()
    var lmarks = [Lmark]()
    var steps = [PlanStep]()
    var safety_steps = [PlanStep]()
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
    
    @IBOutlet var mapTypeButton: UIBarButtonItem!
    @IBOutlet var lmarksButton: UIBarButtonItem!
    @IBOutlet var zoomInButton: UIBarButtonItem!
    @IBOutlet var osmButton: UIBarButtonItem!
    @IBOutlet var animateButton: UIBarButtonItem!
    @IBOutlet var showPlanButton: UIBarButtonItem!
    
    @IBAction func showPlanSteps(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowTable", sender: sender)
    }
    
    @IBAction func showDirections(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowTable", sender: sender)
    }
    
    var intersections:[Intersection] = [
        Intersection(latutude: 40.443931, longitude: -79.942222, location: "5032 Forbes Ave"),
        Intersection(latutude: 40.444455, longitude: -79.941949, location: "Forbes Ave/Morewood Pl"),
        Intersection(latutude: 40.444620, longitude: -79.942988, location: "Forbes Ave/Morewood Ave"),
        Intersection(latutude: 40.444509, longitude: -79.946759, location: "Forbes Ave/S Neville St"),
        Intersection(latutude: 40.444426, longitude: -79.948679, location: "Forbes Ave/S Craig St"),
        Intersection(latutude: 40.443909, longitude: -79.950741, location: "Forbes Ave/S Bellefield St"),
        Intersection(latutude: 40.443182, longitude: -79.953536, location: "Forbes Ave/Bigelow Blvd"),
        Intersection(latutude: 40.443522, longitude: -79.953718, location: "4449 Bigelow Blvd"),
        Intersection(latutude: 40.444423, longitude: -79.954810, location: "Bigelow Blvd/Fifth Ave"),
        Intersection(latutude: 40.442506, longitude: -79.957481, location: "Fifth Ave/S Bouquet St"),
        Intersection(latutude: 40.441264, longitude: -79.959172, location: "Fifth Ave/Meyran Ave"),
        Intersection(latutude: 40.439773, longitude: -79.961194, location: "3420 Fifth Ave")
    ]
    
    var safety_intersections:[Intersection] = [
        Intersection(latutude: 40.442955, longitude: -79.954348, location: "3920 Forbes Ave"),
        Intersection(latutude: 40.442643, longitude: -79.955471, location: "3942 Forbes Ave"),
        Intersection(latutude: 40.441933, longitude: -79.956442, location: "Forbes Ave/S Bouquet St"),
        Intersection(latutude: 40.442506, longitude: -79.957481, location: "Fifth Ave/S Bouquet St"),
        Intersection(latutude: 40.441264, longitude: -79.959172, location: "Fifth Ave/Meyran Ave"),
        Intersection(latutude: 40.439773, longitude: -79.961194, location: "3420 Fifth Ave")
    ]

    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var searchText: UITextField!
    
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let ann = view.annotation as! CustomPointAnnotation
        let placeName = ann.title
        let placeInfo = ann.subtitle!
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated:true, completion: nil)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) ->MKAnnotationView! {
        //print("delegate viewForAnnotation called")
        
        if !(annotation is CustomPointAnnotation) && !(annotation is SnapshotImageAnnotation) {
        //if annotation is MKUserLocation {
            return nil
        }
        
        if annotation is CustomPointAnnotation {
            let reuseId = "test"
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                anView?.canShowCallout = true
            } else {
                anView?.annotation = annotation
            }
            
            let cpa = annotation as! CustomPointAnnotation
            anView?.image = cpa.pinImage  //UIImage(named:cpa.imageName)
            
            //anView?.setSelected(true, animated: true)
            let btn = UIButton(type: .DetailDisclosure)
            anView?.rightCalloutAccessoryView = btn
            let img = cpa.photoImage //UIImage(named:cpa.photoName)
            anView?.detailCalloutAccessoryView = UIImageView(image: img)
            return anView

        } else if annotation is SnapshotImageAnnotation {
            let reuseId = "snap"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            configureDetailView(annotationView!)
            
            return annotationView
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

        return true
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //CPP_Wrapper().getPlanFromSbplByJson_wrapped("aaa")
        
        /*
        mapTypeButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        animateButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        osmButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        zoomInButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        lmarksButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        showPlanButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        */
        
        //Amsterdam
        //var initialLocation = CLLocation(latitude: 52.3740300, longitude: 4.8896900)//
        //Forest Hills, My House
        //var initialLocation = CLLocation(latitude: 40.428653, longitude: -79.867419)
        //Pittsburgh, Cathedral of Learning
        //let initialLocation = CLLocation(latitude: 40.444451, longitude: -79.953252)
        //initialLocation = CLLocation(latitude: 40.444451, longitude: -79.948175)
        
        initialLocation = CLLocation(latitude: 40.443660, longitude: -79.951712)
        span = MKCoordinateSpanMake(0.022, 0.022)
        
        let coordinateRegion = MKCoordinateRegionMake(initialLocation.coordinate, span)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.showsCompass = false
        mapView.showsPointsOfInterest = false
        mapView.showsScale = false
        mapView.showsTraffic = false
        
        
        //mapView.mapType = .SatelliteFlyover
    
        //camera = MKMapCamera(lookingAtCenterCoordinate: coordinate,
        //    fromDistance: distance,
        //    pitch: pitch,
        //    heading: heading)
        //mapView.camera = camera!
        
        LoadSampleLmarks()
        LoadSampleDirections()
        LoadSampleSafetyDirections()
        
        //var fname = "myimage"
        //self.takeSnapshot(mapView, filename: fname)
    
        
        /*
        var squery:String = "landmark"
        searchInMap(squery, lat: initialLocation.coordinate.latitude, lon: initialLocation.coordinate.longitude, span: span, mode: 0)
        
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
        
        var pointsToUse  = [CLLocationCoordinate2D]()
        //var pointsToUse2  = [CLLocationCoordinate2D]()
        
        
        var info = CustomPointAnnotation()
        /*
        info.coordinate = CLLocationCoordinate2D(latitude: lmarks[0].latitude, longitude: lmarks[0].longitude)
        info.title = lmarks[0].name
        info.subtitle = lmarks[0].address
        info.imageName = "images/BlueFlagLeft.png"
        info.photoName = "images/" + lmarks[7].image
        self.mapView.addAnnotation(info)
        
        var srcPlacemark: MKPlacemark = MKPlacemark(coordinate: info.coordinate, addressDictionary: nil)
        var srcItem: MKMapItem = MKMapItem(placemark: srcPlacemark)
        pointsToUse.append(info.coordinate)
        */
        
        
        
        var i:Int = 0
        for lmark in lmarks {
            i = i+1
            info = CustomPointAnnotation()
            info.coordinate = CLLocationCoordinate2D(latitude: lmark.latitude, longitude: lmark.longitude)
            info.title = lmark.name
            info.subtitle = lmark.address
            //info.description = lmark.description
            info.pinImage = lmark.pin
            info.photoImage = lmark.photo
            self.mapView.addAnnotation(info)
                
            if i < 8 {
                    pointsToUse.append(CLLocationCoordinate2DMake(lmark.latitude, lmark.longitude))
                
            }
        }
        
        //pointsToUse2.append(CLLocationCoordinate2DMake(lmarks[7].latitude, lmarks[7].longitude))
        //pointsToUse2.append(CLLocationCoordinate2DMake(lmarks[5].latitude, lmarks[5].longitude))

        //let polyline2: MKPolyline = MKPolyline(coordinates: &pointsToUse2, count: 2)
        polyline_color = UIColor.brownColor()
        
        //self.mapView.addOverlay(polyline2)
        
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

        

        /*
        
        info = CustomPointAnnotation()
        info.coordinate = CLLocationCoordinate2D(latitude: lmarks[7].latitude, longitude: lmarks[7].longitude)
        info.title = lmarks[7].name
        info.subtitle = lmarks[7].address
        info.imageName = "images/PinkFlagLeft.png"
        info.photoName = "images/" + lmarks[7].image
        self.mapView.addAnnotation(info)
        
        var dstPlacemark: MKPlacemark = MKPlacemark(coordinate: info.coordinate, addressDictionary: nil)
        var dstItem: MKMapItem = MKMapItem(placemark: dstPlacemark)
        
        pointsToUse.append(info.coordinate)
        */
        
        let polyline: MKPolyline = MKPolyline(coordinates: &pointsToUse, count: 7)
        polyline_color = UIColor.blueColor()

        //self.mapView.addOverlay(polyline)
        
        //self.dirRequest.source = srcItem
        //self.dirRequest.destination = dstItem
        
        //self.dirRequest.requestsAlternateRoutes = false
        
        /*
        
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
    
    /*
    func takeSnapshot(mapView: MKMapView, withCallback: (UIImage?, NSError?) -> ())
    {
        let options = MKMapSnapshotOptions()
        options.region = mapView.region
        options.size = mapView.frame.size;
        options.scale = UIScreen.mainScreen().scale
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.startWithCompletionHandler()
            { snapshot, error in
                guard  snapshot != nil else {
                withCallback(nil, error)
                return
            }
            withCallback(snapshot!.image, nil)
        }
    }
    */
    
    func takeSnapshot(mapView: MKMapView, filename: String)
    {
        let snapshotView = UIView(frame: CGRect (x: 0, y: 0, width: 300, height: 300))

        let options = MKMapSnapshotOptions()
        //options.region = snapshotView.frame.   //mapView.region
        //options.size = mapView.frame.size;
        //options.scale = UIScreen.mainScreen().scale
        
        
        options.size = CGSize(width: 300, height: 300)
        options.mapType = .SatelliteFlyover
        
        let camera = MKMapCamera(lookingAtCenterCoordinate: initialLocation.coordinate, fromDistance: 500, pitch: 65, heading: 0)
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
                }
            
            //strongSelf.snp = snapshot
        
        
            let data = UIImagePNGRepresentation(snapshot!.image)
            let filename = self.getDocumentsDirectory().stringByAppendingPathComponent("\(filename).png")
            data?.writeToFile(filename, atomically: true)
            dispatch_semaphore_signal(semaphore)
        })
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3*Double(NSEC_PER_SEC)))
        dispatch_semaphore_wait(semaphore, delayTime)
        
    }
    
    
    /*
    func takeSnapshot(mapView: MKMapView, filename: String)
    {
        takeSnapshot(mapView) { (image, error) ->() in
            guard image != nil else {
                print(error)
                return
            }
            
            if let data = UIImagePNGRepresentation(image!) {
                let filename = self.getDocumentsDirectory().stringByAppendingPathComponent("\(filename).png")
                data.writeToFile(filename, atomically: true)
            }
        }
    }
*/
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func AddLandmark(name: String, description: String, type: String, address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoName: String, pinName: String) {
        
        let photo = UIImage(named:photoName)
        let pin = UIImage(named:pinName)
        
        let lmark = Lmark(name: name, description: description, type: type, address: address, latitude: latitude, longitude: longitude, photo: photo!, pin: pin!)!
        lmarks.append(lmark)
    }
    
    // MARK: Load sample data

    func LoadSampleLmarks()
    {
        AddLandmark("University Center", description: "Carnegie Mellon University", type: "building", address: "5032 Forbes Ave", latitude: 40.443931, longitude: -79.942222, photoName: "UniversityCenter", pinName: "BlueFlagLeft")
        
        AddLandmark("Hamburg Hall", description:"Carnegie Mellon University", type: "building", address: "4800 Forbes Ave", latitude: 40.444307, longitude: -79.945720, photoName: "HeinzCollege", pinName: "BlueBall")
        
        AddLandmark("Starbucks", description: "Coffee Shop", type: "restaurant", address: "417 Craig St", latitude: 40.444658, longitude: -79.948492, photoName: "Starbucks", pinName: "BlueBall")
        
        AddLandmark("Carnegie Museum of Natural History", description: "", type: "museum", address: "4400 Forbes Ave", latitude: 40.443466, longitude: -79.950154, photoName: "MuseumOfNaturalHistory", pinName: "BlueBall")
        
        AddLandmark("Opa Gyro", description: "Cafe", type: "restaurant", address: "4208 Forbes Ave", latitude: 40.443147, longitude: -79.953155, photoName: "Gyro", pinName: "BlueBall")
        
        AddLandmark("Cathedral of Learning", description: "University of Pittsburgh", type: "building", address: "4301 Fifth Ave", latitude: 40.444378, longitude: -79.952799, photoName: "CathedralOfLearning", pinName: "BlueBall")
        
        AddLandmark("Hilman Library", description: "University of Pittsburgh", type: "building", address: "3960 Forbes Ave", latitude: 40.442553, longitude: -79.954137, photoName: "HilmanLibrary", pinName: "PinkBall")
        
        AddLandmark("Soldiers and Sailors Lawn", description: "Gen Matthew B Ridgway", type: "Memorial", address: "Fifth, Ave", latitude: 40.444279, longitude: -79.955271, photoName: "SoldiersAndSailorsLawn", pinName: "BlueBall")
        
        AddLandmark("Litchfield Towers", description: "Student Dormitory. University of Pittsburgh", type: "building", address: "3990 Fifth Ave", latitude: 40.442563, longitude: -79.957175, photoName: "LitchfieldTowers", pinName: "BlueBall")
        
        AddLandmark("Campus Bookstore", description: "campusbookstore.com", type: "store", address: "3610 Fifth Ave", latitude: 40.441429, longitude: -79.958662, photoName: "CampusBookstore", pinName: "BlueBall")
        
        AddLandmark("Nellie's Sandwiches", description: "Middle Estern Sandwich Joint", type: "restaurant", address: "3524 Fifth Ave", latitude: 40.441081, longitude: -79.959120, photoName: "NelliesSandwiches", pinName: "BlueBall")
        
        AddLandmark("Five Guys Burgers and Fries", description: "Fast-food burger and fries chain", type: "restaurant", address: "117 S Bouquet St", latitude: 40.442245, longitude: -79.956725, photoName: "FiveGuys", pinName: "BlueBall")
        
        AddLandmark("The Pitt Shop", description: "Bruce Hall", type: "store", address: "3939 Forbes Ave", latitude: 40.442764, longitude: -79.955601, photoName: "ThePittShop", pinName: "BlueBall")
        
        AddLandmark("The Original Hot Dog Shop", description: "Retro spot for hot dogs since 1960", type: "restaurant", address: "3901 Forbes Ave", latitude: 40.442145, longitude: -79.956509, photoName: "TheOriginalHotDog", pinName: "BlueBall")
        
        AddLandmark("Children's Hospital", description: "UPMC", type: "Hospital", address: "3420 Fifth Ave", latitude: 40.439657, longitude: -79.961088, photoName: "ChildrensHospital", pinName: "PinkFlagLeft")
        
        
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
        
        var locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        
        var fname = "myimage"
        self.takeSnapshot(mapView, filename: fname)
        
        
        
        
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
        
        //overpassQlRequest(minlat, minlon:minlon, maxlat:maxlat, maxlon:maxlon)
        ////overpassQlRequest(40.42, minlon: -79.99, maxlat: 40.43, maxlon: -79.97)
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
    
    /*
    [out:json]
    [timeout:25]
    [bbox:40.437622303418294,-79.96317386627197,40.446881741814444,-79.9395489692688]
    ;
    (
    way["highway"]({{bbox}});
    way["amenity"]({{bbox}});
    node["amenity"]({{bbox}});
    way["leisure"]({{bbox}});
    node["leisure"]({{bbox}});
    way["tourism"]({{bbox}});
    node["tourism"]({{bbox}});
    way["building"]({{bbox}});
    node["building"]({{bbox}});
    );
    out body geom qt;
    */
    
    func overpassQlRequest(minlat: Double, minlon: Double, maxlat: Double, maxlon: Double){
        
        let bbox = "(40.437622303418294,-79.96317386627197,40.446881741814444,-79.9395489692688)"
        //"\(minlat),\(minlon),\(maxlat),\(maxlon)"
        print("bbox = \(bbox)")
        
        let stringUrl = "https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];(way[\"highway\"]\(bbox);way[\"amenity\"]\(bbox);node[\"highway\"]\(bbox);way[\"leisure\"]\(bbox);node[\"leisure\"]\(bbox);way[\"tourism\"]\(bbox);node[\"tourism\"]\(bbox);way[\"building\"]\(bbox);node[\"building\"]\(bbox););out body geom qt;"
        print(stringUrl)
        
        //var stringUrl = "https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];(node[\"amenity\"=\"pub\"](40.42,-79.99,40.43,-79.97);way[\"amenity\"=\"pub\"](40.42,-79.99,40.43,-79.97);relation[\"amenity\"=\"pub\"](40.42,-79.99,40.43,-79.97););out body;>;out skel qt;"
        
        let myUrl = NSURL(string: stringUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
        
        let request = NSMutableURLRequest(URL:myUrl);
        request.HTTPMethod = "GET";
        print(myUrl)
        print("\n")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data,response, error in
            if error != nil
            {
                print("error=\(error)\n")
                return
            }
            print("response = \(response)\n")
                
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
            //print("responseString = \(responseString)")
            
            //pl CLLocationCoordinate2D* pl;
            var pl = CPP_Wrapper().getPlanFromSbplByJson_wrapped(responseString);
            
            
            var json: Payload!
            
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? Payload
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
                    var id = element!["id"] as? Int
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
        task.resume()
    }
    
    func overlayOsm() {
        let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(URLTemplate: template)
        overlay.canReplaceMapContent = true
        mapView.addOverlay(overlay, level: .AboveRoads)
        
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
                
                    var item1:MKMapItem = (response?.mapItems[0])!
                    var info1 = CustomPointAnnotation()
                    info1.coordinate = CLLocationCoordinate2D(latitude: item1.placemark.location!.coordinate.latitude, longitude: item1.placemark.location!.coordinate.longitude)
                    info1.title = "info1"
                    info1.subtitle = "Subtitle"
                    //info1.photoImage = "flag.png"
                    self.mapView.addAnnotation(info1)
                
                    self.dirRequest.source = item1
                
                    let n = response?.mapItems.count
                    var item2:MKMapItem = (response?.mapItems[n!-1])!

                    //var info2 = MKPointAnnotation()
                    //info2.coordinate = CLLocationCoordinate2D(latitude: item2.placemark.location!.coordinate.latitude, longitude: item2.placemark.location!.coordinate.longitude)
                    //info2.title = item2.name
                    //self.mapView.addAnnotation(info2)
                
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
                        
                        //var item1:MKMapItem = (response?.mapItems[0])!
                        var info = SnapshotImageAnnotation()
                        info.coordinate = CLLocationCoordinate2D(latitude: item.placemark.location!.coordinate.latitude, longitude: item.placemark.location!.coordinate.longitude)
                        info.title = "info1"
                        //info.subtitle = "Subtitle"
                        //info.imageName = "flag.png"
                        self.mapView.addAnnotation(info)
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
                                print("j=\(j) i=\(i)")
                                print("Item name = \(item.name)")
                                //print("Item name = \(item.description)")
                                print("Lat = \(ilat)")
                                print("Lon = \(ilon)")
                    
                                self.addPinToMapView(item.name!, latitude: ilat, longitude:ilon)
                                self.landmarks.append(item)
                                print("landmarks count: \(self.landmarks.count)")
                        }
                    }
                }
                
            }
        })
    }
    
    func showRoute(response: MKDirectionsResponse) {
        for route in response.routes as! [MKRoute] {
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
        
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            mapView.addAnnotation(pinAnnotationView.annotation!)
    }
}

class CustomPointAnnotation: MKPointAnnotation {
    var pinImage: UIImage!
    var photoImage: UIImage!
}

class SnapshotImageAnnotation: MKPointAnnotation {
}

