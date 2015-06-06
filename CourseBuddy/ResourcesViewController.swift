//
//  ResourcesViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/2/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

class ResourcesViewController: UITableViewController, AddResourceDelegate {

    var defaultData = [["Wikipedia", "http://wikipedia.org"], ["Google", "http://google.com"]]
    var cellShown: [Bool]?

    var resources: AnyObject?
    var selectedTitle: String?
    var selectedAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resources != nil {
            return resources!.count
        } else {
            return 2
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ResourceCell", forIndexPath: indexPath) as! UITableViewCell

        if resources != nil {
            
        } else {
            let data: [String] = defaultData[indexPath.row] as [String]
            cell.detailTextLabel?.text = data[1]
            cell.textLabel?.text = data[0]
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if resources != nil {
            
        } else {
            let data = defaultData[indexPath.row]
            selectedAddress = data[1]
            selectedTitle = data[0]
        }
        performSegueWithIdentifier("showWebViewSegue", sender: nil)
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
