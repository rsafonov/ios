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
    func sendBoolValToPreviousVC(val: Bool)
    func sendDoubleValsToPreviousVC(xval: Double, yval: Double)
}

class LandmarksTableViewController: UITableViewController {
    
    // MARK: Properties
    
    @IBOutlet var BackButton: UIBarButtonItem!
    
    @IBAction func GoBackToOriginalPlan(sender: AnyObject)
    {
        sol = orig_sol
        tableView.reloadData()
        self.title = "Directions"
        BackButton.enabled = false
    }
    
    var lmarks = [Lmark]()
    var isections = [Intersection]()
    var sol = [SolutionStep]()
    var safety_sol = [SolutionStep]()
    var orig_sol = [SolutionStep]()
    
    var settings = [Setting]()
    var mode = Int()
    var delegate:sendDataBack?
    
    func sendSwitchValToPreviousVC(val: Bool) {
        self.delegate?.sendBoolValToPreviousVC(val)
    }
    
    func sendXYToPreviousVC(xval: Double, yval: Double) {
        self.delegate!.sendDoubleValsToPreviousVC(xval, yval: yval)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadSampleLandmarks() {
        //let photo1 = UIImage(named: "CathedralOfLearning")
        //let pin1 = UIImage(named: "Gyro")
        
        //let lmark1 = Lmark(name: "Cathedral Of Learning", description: "University of Pittsburgh", type: 1, address: "4301 Fifth Ave", latitude: 40.444378, longitude: -79.952799, photo: photo1!, pin: pin1!, pointId: 1, roadId: 1, street: "", amenity: "")
            //lmarks.append(lmark1!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (mode == 1)
        {
            self.title = "Landmarks"
            //print("lmarls.count = \(lmarks.count)")
            return lmarks.count
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
            return isections.count
        }
        else if (mode == 4)
        {
            self.title = "Settings"
            //print("settings.count = \(settings.count)")
            return settings.count
        }
        return 0
    }
 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        //print("mode = \(mode) indexPath.row = \(indexPath.row)")
        
        if mode == 1 {
            let cellIdentifier = "LandmarkTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LandmarkTableViewCell
            
            let lmark = lmarks[indexPath.row]
        
            cell.nameLabel.text = lmark.name
            cell.photoImageView.image = lmark.photo
            cell.descrLabel.text = lmark.description
            cell.addressLabel.text = lmark.address
            return cell
        }
        else if mode == 2
        {
            let step = sol[indexPath.row]
            if (step.iconName != "RedMarker")
            {
                let cellIdentifier = "StepTableViewCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! StepTableViewCell
            
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
                
                cell.photoImageView.image = step.photoImage
                cell.instructions.text = step.instructions
                return cell
            }
        }
        else if mode == 3
        {
            let cellIdentifier = "LandmarkTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LandmarkTableViewCell
        
            let isection = isections[indexPath.row]
        
            cell.nameLabel.text = "Intersection"
            cell.photoImageView.image = UIImage(named: "defaultPhoto")
            cell.descrLabel.text = isection.location as String
            cell.addressLabel.text = "address"
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
                
                return cell
            }
            else if setting.type == 2
            {
                let cellIdentifier = "DoubleSettingCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DoubleSettingCell
                
                cell.xName.text = setting.name + " x = "
                cell.yName.text = setting.name + " y = "
                cell.xVal.text = String(setting.xval!)
                cell.yVal.text = String(setting.yval!)
                cell.parentController = self
                return cell
            }

            let cell1 = UITableViewCell()
            return cell1
        }

        
        /*
        else
        {
            let step = planStepsList[indexPath.row]
            
            if step.image != "HilmanLibrary" {
                let cell = tableView.dequeueReusableCellWithIdentifier("StepTableViewCell", forIndexPath: indexPath) as! StepTableViewCell
                
                    cell.photoImageView.image = UIImage(named: step.image)
                    cell.instructions.text = step.instructions
                    cell.dirImageView.image = UIImage(named: step.icon)
                    return cell
                
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("FalseStepTableViewCell", forIndexPath: indexPath) as! FalseStepTableViewCell

                //cell = StepTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "StepTableViewCell")
                
                cell.photoImageView.image = UIImage(named: step.image)
                cell.instructions.text = step.instructions
                return cell
            }
        }
        */
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //print("You selected  cell #\(indexPath.row)")
        
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!

        if let cell = currentCell as? SwitchSettingCell
        {
            let bval = cell.SwitchPropValue.on
            self.sendSwitchValToPreviousVC(bval)
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
            sol.append(safety_sol[i])
            //print("i=\(i) id2 = \(safety_sol[i].id2) type2 = \(safety_sol[i].type2) orig_seq = \(safety_sol[i].orig_seq)")
        }
        tableView.reloadData()
        self.title = "New Directions"
        BackButton.enabled = true
    }

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
