//
//  ResourcesViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/2/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

class ResourcesViewController: UITableViewController {

    var defaultData = [["Wikipedia", "http://wikipedia.org"], ["Google", "http://google.com"]]
    
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionHeaderView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40.0))
        sectionHeaderView.backgroundColor = Helper().colorWithRGBHex(0x00C853, alpha: 0.7)
        sectionHeaderView.layer.cornerRadius = 3
        let headerLabel = UILabel(frame: CGRectMake(5, 5, sectionHeaderView.frame.size.width-10, 30.0))
        headerLabel.backgroundColor = UIColor.clearColor()
        headerLabel.textAlignment = NSTextAlignment.Center
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.font = UIFont(name: "Avenir", size: 18)
        headerLabel.text = "Resources"
        sectionHeaderView.addSubview(headerLabel)
        var wrapperView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 50.0))
        wrapperView.backgroundColor = UIColor.clearColor()
        wrapperView.addSubview(sectionHeaderView)
        return wrapperView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
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
