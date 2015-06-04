//
//  UniversitySelectorViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/4/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

protocol UniversitySelectorDelegate {
    func userSelectedUniversity(named: String)
}

class UniversitySelectorViewController: UITableViewController {

    var delegate: UniversitySelectorDelegate?
    var geoPoint: AnyObject?
    var universities: [AnyObject]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(animated: Bool) {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                self.geoPoint = geoPoint
                self.getUniversities("")
            }
        }
        getUniversities("")
    }
    
    func getUniversities(searchBarText: String) {
        var query = PFQuery(className:"Institution")
        if searchBarText != "" {
            query.whereKey("name", containsString: searchBarText)
        }
        //query.orderByDescending("numOfUsers")
        //query.addAscendingOrder("name")
        //query.orderByDescending("name")
        //query.whereKeyDoesNotExist("geopoint")
        //query.limit = 1000
        if geoPoint != nil {
            let point = geoPoint as! PFGeoPoint
            query.whereKeyExists("geopoint")
            query.whereKey("geopoint", nearGeoPoint: point)
        }
        query.findObjectsInBackgroundWithBlock {
            (universities: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                self.universities = universities
                // The find succeeded.
                NSLog("Successfully retrieved \(universities!.count) universities.")
                // Do something with the found objects
                self.tableView.reloadData()
            } else {
                // Log details of the failure
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if universities != nil {
            return universities!.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UniversityCell", forIndexPath: indexPath) as! UITableViewCell

        if universities != nil {
            let university = universities![indexPath.row] as! PFObject
            let univName = university["name"] as! String
            cell.textLabel?.text = univName
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if universities != nil {
            let selectedUniversity = universities![indexPath.row] as! PFObject
            let univName = selectedUniversity["name"] as! String
            let alertController = UIAlertController(title: "Confirm", message: "Do you attend or work at \(univName)", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
                println("Confirm button tapped")
                self.dismissViewControllerAnimated(true, completion: nil)
                self.delegate?.userSelectedUniversity(univName)
            })
            alertController.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
                println("Cancel button tapped")
            })
            alertController.addAction(cancelAction)
            
            // for ipad
            alertController.popoverPresentationController?.sourceView = view
            // get selected cell
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            //let cell = tableView.dequeueReusableCellWithIdentifier("UniversityCell", forIndexPath: indexPath) as! UITableViewCell
            alertController.popoverPresentationController?.sourceRect = cell!.frame
            
            presentViewController(alertController, animated: true, completion: nil)

        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
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
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
