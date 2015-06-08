//
//  ResourcesViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/2/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import Parse

class ResourcesViewController: UITableViewController, AddResourceDelegate {

    var defaultData = [["Wikipedia", "http://wikipedia.org"], ["Google", "http://google.com"]]
    var cellShown: [Bool]?

    var selectedTitle: String?
    var selectedAddress: String?
    
    var selectedCourse: AnyObject?
    var resourceObjects: [AnyObject]?
    
    var resourceShown: [Bool]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadResources()
    }

    func loadResources() {
        if selectedCourse != nil {
            let courseObject = selectedCourse as! PFObject
            var resourcesQuery: PFQuery = courseObject.relationForKey("resources").query()!
            resourcesQuery.orderByDescending("createdAt")
            resourcesQuery.findObjectsInBackgroundWithBlock {
                (resources: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    println("retrieved \(resources!.count) resources")
                    self.resourceObjects = resources
                    self.resourceShown = [Bool](count: resources!.count, repeatedValue: false)
                    self.tableView.reloadData()
                } else {
                    println("There was an error fetching the resources")
                }
            }
        }
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showWebViewSegue" {
            if let destination = segue.destinationViewController as? WebViewController {
                destination.resourceTitle = selectedTitle!
                destination.address = selectedAddress!
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
            }
        }
        else if segue.identifier == "addResourceSegue" {
            if let destination = segue.destinationViewController as? AddResourceViewController {
                destination.delegate = self
            }
        }
    }
    
    func resourceAdded(title: String, url: String) {
        println(title)
        println(url)
        var newResource = PFObject(className: "Resource")
        newResource["title"] = title
        newResource["url"] = url
        newResource["poster"] = PFUser.currentUser()
        newResource["courseId"] = selectedCourse as! PFObject
        newResource["posterName"] = PFUser.currentUser()!["name"] as! String
//        let imageData = UIImagePNGRepresentation(screenshot)
//        let imageName = title + ".png"
//        let imageFile = PFFile(name: imageName, data: imageData)
//        newResource["screenshot"] = imageFile
        newResource.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if error == nil {
                let course = self.selectedCourse as! PFObject
                let resourceRelation: PFRelation = course.relationForKey("resources")
                resourceRelation.addObject(newResource)
                course.saveInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if succeeded {
                        self.loadResources()
                    } else { println("error saving course") }
                }
            } else { println("error saving resource") }
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
        if resourceObjects != nil {
            return resourceObjects!.count
        } else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ResourceCell", forIndexPath: indexPath) as! UITableViewCell

        if resourceObjects != nil {
            var resource: PFObject = self.resourceObjects![indexPath.row] as! PFObject
            cell.textLabel?.text = resource["title"] as? String
            cell.detailTextLabel?.text = resource["url"] as? String
        } else {
            let data: [String] = defaultData[indexPath.row] as [String]
            cell.detailTextLabel?.text = data[1]
            cell.textLabel?.text = data[0]
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if resourceObjects != nil {
            var resource: PFObject = self.resourceObjects![indexPath.row] as! PFObject
            selectedTitle = resource["title"] as? String
            selectedAddress = resource["url"] as? String
        } else {
            let data = defaultData[indexPath.row]
            selectedAddress = data[1]
            selectedTitle = data[0]
        }
        performSegueWithIdentifier("showWebViewSegue", sender: nil)
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if resourceShown![indexPath.row] {
            return
        }
        resourceShown![indexPath.row] = true
        cell.alpha = 0
        UIView.animateWithDuration(1.0, animations: { cell.alpha = 1 })
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
//    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        // Determine if the post is displayed. If yes, we just return and no animation will be created
//        if cellShown![indexPath.row] {
//            return;
//        }
//        // Indicate the post has been displayed, so the animation won't be displayed again
//        cellShown![indexPath.row] = true
//        // Define the initial state (Before the animation)
//        cell.alpha = 0
//        // Define the final state (After the animation)
//        UIView.animateWithDuration(1.0, animations: { cell.alpha = 1 })
//    }

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



}
