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
    func userSelectedUniversity(named: String, id: String)
}

class UniversitySelectorViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
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
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        getUniversities(searchBar.text)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        getUniversities(searchBar.text)
        searchBar.resignFirstResponder()
    }
    
    func getUniversities(searchBarText: String) {
        var query = PFQuery(className:"Institution")
        if searchBarText != "" {
            query.whereKey("name", containsString: searchBarText)
        }
        //query.orderByDescending("numOfUsers")
        //query.orderByDescending("name")
        //query.whereKeyDoesNotExist("geopoint")
        //query.limit = 1000
        if geoPoint != nil {
            let point = geoPoint as! PFGeoPoint
            query.whereKeyExists("geopoint")
            query.whereKey("geopoint", nearGeoPoint: point)
        } else {
            query.addAscendingOrder("name")
        }
        query.findObjectsInBackgroundWithBlock {
            (universities: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                self.universities = universities
                // The find succeeded.
                NSLog("Successfully retrieved \(universities!.count) universities.")
                if universities!.count == 0 {
                    //show alert
                    self.showAlert()
                }
                // Do something with the found objects
                self.tableView.reloadData()
            } else {
                // Log details of the failure
            }
        }
    }

    func showAlert() {
        let alertController = UIAlertController(title: "Make sure you spelled the university name correctly", message: "If you think your university is missing, enter the name below for confirmation", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler({(txtField: UITextField!) in
            txtField.placeholder = "Your University Name"
        })
        
        let deleteAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
            println("Delete button tapped")
        })
        alertController.addAction(deleteAction)
        
        let okAction = UIAlertAction(title: "Send", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            println("OK button tapped")
            if let textField = alertController.textFields?.first as? UITextField {
                println(textField.text)
                if textField.text != "" {
                    var feedback = PFObject(className: "Feedback")
                    feedback["feedback"] = "university missing named: \(textField.text)"
                    feedback["user"] = PFUser.currentUser()!
                    feedback.saveInBackground()
                    self.confirmAlert()
                }
            }
            
        })
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func confirmAlert() {
        let alertController = UIAlertController(title: "Sent", message: "We will contact you at \(PFUser.currentUser()!.username!) when we confirm your university is missing", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            println("OK button tapped")
            
        })
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
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
            let univID = selectedUniversity.objectId
            
            let alertController = UIAlertController(title: "Confirm", message: "Do you attend or work at \(univName)", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let okAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
                println("Confirm button tapped")
                self.dismissViewControllerAnimated(true, completion: nil)
                let relation = selectedUniversity.relationForKey("participants") as PFRelation
                relation.addObject(PFUser.currentUser()!)
                selectedUniversity.saveInBackground()
                self.delegate?.userSelectedUniversity(univName, id: univID!)
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
