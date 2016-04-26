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
    
    var landmarkList = [MKMapItem]()
    var lmarkList  = [Landmark]()
    var lmarks = [Lmark]()
    
    var planStepsList = [PlanStep]()
    var safetyPlanStepsList = [PlanStep]()
    var mode = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("LandmarkTableViewController - viewDidLoad")
        print("mode = \(mode)")
        
        //print("landmarkList.count = \(landmarkList.count)")
        if (mode == 0) {
            print("lmarkList.count = \(lmarkList.count)")
        } else {
            print("planStepsList.count = \(planStepsList.count)")
            self.title = "Directions"
        }
        
        loadSampleLandmarks()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }
    
    func loadSampleLandmarks() {
        let photo1 = UIImage(named: "CathedralOfLearning")
        let pin1 = UIImage(named: "Gyro")
        
        let lmark1 = Lmark(name: "Cathedral Of Learning", description: "University of Pittsburgh", type: "building", address: "4301 Fifth Ave", latitude: 40.444378, longitude: -79.952799, photo: photo1!, pin: pin1!)
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
        
        if (mode == 0) {
            //return lmarkList.count
            return lmarks.count
        } else {
            return planStepsList.count
        }
    }
    
 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if mode == 0 {
            let cellIdentifier = "LandmarkTableViewCell"
        
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LandmarkTableViewCell
            
            let lmark = lmarks[indexPath.row]
        
            cell.nameLabel.text = lmark.name
            cell.photoImageView.image = lmark.photo
            cell.descrLabel.text = lmark.description
            cell.addressLabel.text = lmark.address
            return cell
        } else {
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
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected  cell #\(indexPath.row)")
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        print("You tapped accessory button in cell #\(indexPath.row)")
        
        planStepsList = safetyPlanStepsList
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
