//
//  LandmarksTableViewController.swift
//  LmarkPlanner
//
//  Created by Margarita Safonova on 2/26/16.
//  Copyright © 2016 Margarita Safonova. All rights reserved.
//

import UIKit
import MapKit

class LandmarksTableViewController: UITableViewController {
    
    // MARK: Properties
    
    //var landmarkList = [MKMapItem]()
    //var lmarkList  = [Landmark]()
    var lmarks = [Lmark]()
    //var planStepsList = [PlanStep]()
    //var safetyPlanStepsList = [PlanStep]()
    var isections = [Intersection]()
    var sol = [SolutionStep]()
    var safety_sol = [SolutionStep]()
    var mode = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        print("LandmarkTableViewController - viewDidLoad")
        print("mode = \(mode)")
        
        //print("landmarkList.count = \(landmarkList.count)")
        if (mode == 1) {
            print("lmarks.count = \(lmarks.count)")
        }
        else if (mode == 2)
        {
            print("sol.count = \(sol.count)")
            self.title = "Directions"
        }
        else {
            print("planStepsList.count = \(planStepsList.count)")
            self.title = "Directions"
        }
        */
        
        //loadSampleLandmarks()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }
    
    func loadSampleLandmarks() {
        let photo1 = UIImage(named: "CathedralOfLearning")
        let pin1 = UIImage(named: "Gyro")
        
        let lmark1 = Lmark(name: "Cathedral Of Learning", description: "University of Pittsburgh", type: 1, address: "4301 Fifth Ave", latitude: 40.444378, longitude: -79.952799, photo: photo1!, pin: pin1!, pointId: 1, roadId: 1, street: "", amenity: "")
            lmarks.append(lmark1!)
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
            print("lmarls.count = \(lmarks.count)")
            return lmarks.count
        }
        else if (mode == 2)
        {
            self.title = "Directions"
            print("sol.count = \(sol.count)")
            return sol.count
        }
        else if (mode == 3)
        {
            self.title = "Intersections"
            print("isections.count = \(isections.count)")
            return isections.count
        }
        return 0
    }
 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
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
            let cellIdentifier = "StepTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! StepTableViewCell
            
            let step = sol[indexPath.row]
            
            //cell..text = step.name
            cell.photoImageView.image = UIImage(named: step.imageName)
            cell.instructions.text = step.instructions
            cell.dirImageView.image = UIImage(named: step.iconName)

            return cell
        }
        else //if mode == 3
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
        print("You selected  cell #\(indexPath.row)")
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        print("You tapped accessory button in cell #\(indexPath.row)")
        
        //planStepsList = safetyPlanStepsList
        tableView.reloadData()
        self.title = "New Directions"
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
