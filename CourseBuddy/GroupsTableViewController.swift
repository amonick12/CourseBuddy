//
//  GroupsTableViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/4/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import Parse

protocol GroupsTableDelegate {
    func didSelectGroup(atIndex: Int)
    func didAddNewGroup(named: String, description: String?)
    func didSelectGroupNotifications(controller: GroupsTableViewController, atIndex: Int)

}

protocol GroupCellDelegate {
    func notificationButtonPressed(atIndex: Int, selected: Bool)
}

class GroupCell: UITableViewCell {
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet var notificationButton: UIButton!
    
    var atIndex: Int?
    var delegate: GroupCellDelegate?
    
    @IBAction func notificationButtonPressed(sender: UIButton) {
        if notificationButton.selected {
            notificationButton.setImage(UIImage(named: "notification-green"), forState: UIControlState.Normal)
        } else {
            notificationButton.setImage(UIImage(named: "notification-green-filled"), forState: UIControlState.Selected)
        }
        notificationButton.selected = !notificationButton.selected
        delegate?.notificationButtonPressed(atIndex!, selected: notificationButton.selected)
    }
    
}

class GroupsTableViewController: UITableViewController, AddGroupDelegate, GroupCellDelegate {

    var delegate: GroupsTableDelegate?
    
    let defaultData = ["Study Group", "Beta Testers"]
    var groups: [AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func notificationButtonPressed(atIndex: Int, selected: Bool) {
        println("notification button pressed at index: \(atIndex), selected: \(selected)")
        delegate?.didSelectGroupNotifications(self, atIndex: atIndex)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! AddGroupViewController
        vc.delegate = self
    }
    
    func returnWithText(groupName: String, groupDescription: String?) {
//        println(groupName)
//        if groupDescription != nil {
//            println(groupDescription!)
//        }
        delegate?.didAddNewGroup(groupName, description: groupDescription)
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
        if groups != nil {
            return groups!.count
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupCell", forIndexPath: indexPath) as! GroupCell

        if groups != nil {
            var group = groups![indexPath.row] as! PFObject
            cell.groupLabel.text = group["name"] as? String
            cell.atIndex = indexPath.row
            cell.delegate = self
        } else {
            cell.groupLabel.text = defaultData[indexPath.row]
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if groups != nil {
            delegate?.didSelectGroup(indexPath.row)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
