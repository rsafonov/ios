//
//  LandmarksTableViewController.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 2/26/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit
import MapKit

protocol sendDataBack
{
    func sendBoolValToPreviousVC(val: Bool, tag: Int)
    func sendDoubleValsToPreviousVC(xval: Double, yval: Double, tag: Int)
    //func sendSelectionToPreviousVC(mode: Int, id: Int64, type: Int)
    //func findLandmarkByID(id: Int64) -> Int
    //func findIntersectionByID(id: Int64) -> Int
}

class LandmarksTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate
{
    
    // MARK: Properties
    
    @IBOutlet var BackButton: UIBarButtonItem!
        
    @IBAction func GoBackToOriginalPlan(sender: AnyObject)
    {
        //Going back from safety_solution to the original solution
        if (mode == 2 && sol_mode == 1)
        {
            sol = orig_sol
            sol_mode = 0
            tableView.reloadData()
            self.title = "Directions"
            //BackButton.enabled = false
        }
        else
        {
            performSegueWithIdentifier("HideTable", sender: self)
        }
    }
    
    var lmarks = [Lmark]()
    var filtered_lmarks = [Lmark]()
    var isections = [Intersection]()
    var filtered_isections = [Intersection]()
    var sol = [SolutionStep]()
    var safety_sol = [SolutionStep]()
    var orig_sol = [SolutionStep]()
    
    var settings = [Setting]()
    var mode = Int()
    var sol_mode = Int();
    var delegate:sendDataBack?
    var workOffline: Bool = false
    var debug: Bool = false
    var selectedID: Int64 = 0
    var selectionType: Int = -1
    var selectedIndex: Int = -1
    
    var nil_photo_steps: Int = 0
    var nil_photo_lmarks: Int = 0
    var nil_photo_isections: Int = 0
    
    var cellBackgroundView = UIView()
    let light_yellow_color = UIColor(red: 252/255, green: 248/255, blue: 196/255, alpha: 1.0)
    
    var searchController: UISearchController?
    var resultsController: UITableViewController?  // = UITableViewController()
    
    func sendSwitchValToPreviousVC(val: Bool, tag: Int) {
        self.delegate?.sendBoolValToPreviousVC(val, tag: tag)
    }
    
    func sendXYToPreviousVC(xval: Double, yval: Double, tag: Int) {
        self.delegate!.sendDoubleValsToPreviousVC(xval, yval: yval, tag: tag)
    }
   
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //let setStartButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "RedFlag"), style: .Plain, target: self, action: #selector(buttonTapped))
        //let label: UILabel = UILabel()
        //label.text = "start"
        //setStartButton.customView?.addSubview(label)
        //let setGoalButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "FinishFlag"), style: .Plain, target: self, action: #selector(buttonTapped))
        //navigationItem.setRightBarButtonItems([setStartButton, setGoalButton], animated: false)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //This gesture recognizer helps to dismiss keyboard when the user tapc outside of the text field.
        let gestureRecognizer: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LandmarksTableViewController.hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        sol_mode = 0
        
        //let light_yellow_color = UIColor(red: 252/255, green: 248/255, blue: 196/255, alpha: 1.0)
        //cellBackgroundView.backgroundColor = light_yellow_color

        //self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(animated: Bool)
    {
        if (mode == 1 || mode == 3)
        {
            tableView.dataSource = self
            filtered_lmarks = lmarks
            filtered_isections = isections
            searchController = UISearchController(searchResultsController:  nil) //resultsController)
            searchController?.delegate = self
            //tableView.tableHeaderView = self.searchController!.searchBar
            searchController!.searchResultsUpdater = self
            searchController!.dimsBackgroundDuringPresentation = false
            definesPresentationContext = true
            //searchController!.searchBar.showsSearchResultsButton = true
            searchController!.searchBar.searchBarStyle = .Prominent
            searchController!.searchBar.sizeToFit()
            //searchController?.searchBar.hidden = true
            searchController?.searchBar.showsCancelButton = false
            //searchController?.searchBar.barTintColor = UIColor.blueColor()
            //self.searchController?.searchBar.
            //self.navigationController?.navigationBar.barTintColor = UIColor.clearColor()
            if (mode == 1)
            {
                searchController?.searchBar.placeholder = "Search landmarks"
                searchController?.searchBar.prompt = "Landmarks"
            }
            else
            {
                searchController?.searchBar.placeholder = "Search intersection"
                searchController?.searchBar.prompt = "Intersections"
            }
            searchController?.hidesNavigationBarDuringPresentation = false
            self.navigationItem.titleView = searchController?.searchBar
            //UITableViewCell.selected
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "HideTable" && (mode == 1 || mode == 3) && selectedID > 0)
        {
            let vc = segue.destinationViewController
            let vc0 = vc as! ViewController
            vc0.setSelectedPose(mode, id: selectedID, type: selectionType)
        }
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.setShowsCancelButton(false, animated: false)
    }
    
    func filterContentForSearchText(searchText: String)
    {
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        let txt = searchController.searchBar.text
        if (txt == nil || txt!.isEmpty)
        {
            if (mode == 1)
            {
                filtered_lmarks = lmarks
            }
            else if (mode == 3)
            {
                filtered_isections = isections
            }
        }
        else
        {
            if (mode == 1)
            {
                filtered_lmarks = self.lmarks.filter
                { (lm: Lmark) -> Bool in
                    if lm.name.lowercaseString.containsString(txt!.lowercaseString) || lm.amenity.lowercaseString.containsString(txt!.lowercaseString)
                        || lm.street.lowercaseString.containsString(txt!.lowercaseString)
                        || lm.address.lowercaseString.containsString(txt!.lowercaseString)
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                }
            }
            else if (mode == 3)
            {
                filtered_isections = self.isections.filter
                { (isct: Intersection) -> Bool in
                        if isct.location!.lowercaseString.containsString(txt!.lowercaseString) || isct.location!.lowercaseString.containsString(txt!.lowercaseString)
                        {
                            return true
                        }
                        else
                        {
                            return false
                        }
                }
            }
        }
        //resultsController!.tableView.reloadData()
        tableView.reloadData()
    }
    
    func hideKeyboard()
    {
        self.view.endEditing(true)
    }
    
    //This function helps to dismiss keyboard when Return button is clicked.
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (mode == 1)
        {
            self.title = "Landmarks"
            return filtered_lmarks.count
        }
        else if (mode == 2)
        {
            self.title = "Directions"
            //print("sol.count = \(sol.count)")
            return sol.count
        }
        else if (mode == 3)
        {
            self.title = "Intersections"
            //print("isections.count = \(isections.count)")
            return filtered_isections.count
        }
        else if (mode == 4)
        {
            self.title = "Settings"
            //print("settings.count = \(settings.count)")
            return settings.count
        }
        return 0
    }
    
    func getURLImage(lat: Double, lon: Double) -> UIImage?
    {
        let strlat = String(lat)
        let strlon = String(lon)

        let fov = String(90)
        
        //let imageurl = "http://maps.googleapis.com/maps/api/streetview?size=400x400&location=" + strlat + "," + strlon + "&heading=90&sensor=false"
        let imageurl = "http://maps.googleapis.com/maps/api/streetview?size=400x400&location=" + strlat + "," + strlon + "&fov=" + fov + "&sensor=false&key=AIzaSyD3jESuue6j-P5ylGPUsqW7ZjTdY59HKy4"
        
        if let url = NSURL(string: imageurl)
        {
            if let data = NSData(contentsOfURL: url)
            {
                if let image = UIImage(data: data)
                {
                    return image
                }
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
        
        return nil
    }
 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        //print("mode = \(mode) indexPath.row = \(indexPath.row)")
        
        if (mode == 1)
        {
            let cellIdentifier = "LandmarkTableViewCell"
            let lmark: Lmark = filtered_lmarks[indexPath.row]
            let cell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LandmarkTableViewCell
            
            //print("cell: \(indexPath.row) \(cell.isKindOfClass(LandmarkTableViewCell))  \(cell.reuseIdentifier!)")
        
            cell.nameLabel.text = lmark.name
            
            if (lmark.photo == nil)
            {
                if (!workOffline)
                {
                    lmark.photo = self.getURLImage(lmark.latitude, lon: lmark.longitude)
                }
                nil_photo_lmarks += 1
                print("Nil photo \(nil_photo_lmarks) : \(lmark.pointId) : \(lmark.name)")
            }
            
            cell.photoImageView.image = lmark.photo
            cell.descrLabel.text = lmark.amenity //lmark.description
            cell.addressLabel.text = lmark.address
            if (!lmark.address.isEmpty)
            {
                cell.addressLabel.text = lmark.address
            }
            else if (!lmark.street.isEmpty)
            {
                cell.addressLabel.text = lmark.street
            }
            cell.parentController = self
            cell.btn1!.hidden = true
            cell.btn2!.hidden = true
            cell.selectedBackgroundView = cellBackgroundView
            cell.backgroundColor = UIColor.whiteColor()
            cell.selected = false
            cell.highlighted = false
            return cell
        }
        else if (mode == 2)
        {
            let step = sol[indexPath.row]
            if (step.iconName != "RedMarker")
            {
                let cellIdentifier = "StepTableViewCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! StepTableViewCell
                
                if (step.photoImage == nil)
                {
                    if (!workOffline)
                    {
                        step.photoImage = self.getURLImage(step.lat2, lon: step.lon2)
                    }
                    nil_photo_steps += 1
                    identifyStep(step)
                }
                cell.photoImageView.image = step.photoImage
                cell.instructions.text = step.instructions
                cell.dirImageView.image = UIImage(named: step.iconName)
                return cell
            }
            else
            {
                let step = sol[indexPath.row]
                let cellIdentifier = "FalseStepTableViewCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FalseStepTableViewCell
                
                if (step.photoImage == nil)
                {
                    if (!workOffline)
                    {
                        step.photoImage = self.getURLImage(step.lat2, lon: step.lon2)
                    }
                    nil_photo_steps += 1
                    identifyStep(step)
                }
                cell.photoImageView.image = step.photoImage
                cell.instructions.text = step.instructions
                return cell
            }
        }
        else if (mode == 3)
        {
            let cellIdentifier = "LandmarkTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LandmarkTableViewCell
        
            let isection = filtered_isections[indexPath.row]

            cell.nameLabel.text = isection.location
            
            if (isection.photo == nil)
            {
                if (!workOffline)
                {
                    isection.photo = self.getURLImage(isection.latitude, lon: isection.longitude)
                }
                nil_photo_isections += 1
                print("Nil photo \(nil_photo_isections) : \(isection.id) : \(isection.location)")
            }
            cell.photoImageView.image = isection.photo
            cell.descrLabel.text = ""
            if (debug)
            {
                cell.addressLabel.text = "\(isection.id)"
            }
            else
            {
                cell.addressLabel.text = ""
            }
            return cell
        }
        else //if mode == 4
        {
            let setting = settings[indexPath.row]
            
            print("setting: name=\(setting.name) type = \(setting.type)")
            
            if setting.type == 1
            {
                let cellIdentifier = "SwitchSettingCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SwitchSettingCell
            
                cell.SwitchPropName.text = setting.name
                cell.SwitchPropValue.setOn(setting.bval!, animated: true)
                cell.parentController = self
                cell.tag = setting.tag
                return cell
            }
            else if setting.type == 2
            {
                let cellIdentifier = "DoubleSettingCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DoubleSettingCell
                
                cell.Title.text = setting.name
                cell.xName.text = setting.xname
                cell.yName.text = setting.yname
                cell.xVal.text = String(setting.xval!)
                cell.yVal.text = String(setting.yval!)
                cell.parentController = self
                cell.tag = setting.tag
                return cell
            }

            let cell1 = UITableViewCell()
            return cell1
        }
    }
    
    func identifyStep(step: SolutionStep)
    {
        var tmp: String = ""
        if (step.type2 == 1)
        {
            let ind = findLandmarkByID(step.id2)
            if (ind >= 0)
            {
                tmp = "Lmark: \(lmarks[ind].name)"
            }
            else
            {
                tmp = "Lmark \(step.id2) not found"
            }
        }
        else
        {
            let ind = findIntersectionByID(step.id2)
            if (ind >= 0)
            {
                tmp = "Isection: \(isections[ind].location)"
            }
            else
            {
                tmp = "Isection \(step.id2) not found"
            }
        }
        print("Nil photo \(nil_photo_steps) : \(tmp) : \(step.instructions)")
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        //let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
        
        if (mode == 1)
        {
            let lmark: Lmark = filtered_lmarks[indexPath.row]
            selectedID = lmark.pointId
            if let cell = currentCell as? LandmarkTableViewCell
            {
                cell.btn1!.hidden = true
                cell.btn2!.hidden = true
                cell.backgroundColor = UIColor.whiteColor()
                cell.highlighted = false
                cell.selected = false
            }
        }
    }
    
    /*
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        //let tmpcell = LandmarkTableViewCell()
        let cellHeight = CGFloat(90.0) //tmpcell.frame.height
        let y = targetContentOffset.memory.y
        targetContentOffset.memory.y -= y % cellHeight
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (cell.selected == true)
        {
            cell.selected = true
        }
        else
        {
            cell.selected = false
        }
    }
    */

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        print("You selected  cell #\(indexPath.row)")
        
        //let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
        
        if (mode == 1)
        {
            let lmark: Lmark = filtered_lmarks[indexPath.row]
            selectedID = lmark.pointId
            if let cell = currentCell as? LandmarkTableViewCell
            {
                cell.btn1!.hidden = false
                cell.btn2!.hidden = false
                cell.backgroundColor = light_yellow_color
                selectedIndex = indexPath.row
            }
        }

        if let cell = currentCell as? SwitchSettingCell
        {
            let bval = cell.SwitchPropValue.on
            self.sendSwitchValToPreviousVC(bval, tag: 1)
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        //print("You tapped accessory button in cell #\(indexPath.row)")
        
        orig_sol.removeAll()
        for i in 0...sol.count-1
        {
            orig_sol.append(sol[i])
        }
        
        let istart = sol[indexPath.row].safety_ind_start
        let iend = sol[indexPath.row].safety_ind_end
        //print("start = \(istart) end = \(iend)")
        
        sol.removeAll()
        
        for i in istart...iend
        {
            if (!safety_sol[i].skip)
            {
                sol.append(safety_sol[i])
            }
            
            //print("i=\(i) id2 = \(safety_sol[i].id2) type2 = \(safety_sol[i].type2) orig_seq = \(safety_sol[i].orig_seq)")
        }
        tableView.reloadData()
        self.title = "New Directions"
        //BackButton.enabled = true
        sol_mode = 1
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
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
    
    //override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //    return 80
    //}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func cprepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
