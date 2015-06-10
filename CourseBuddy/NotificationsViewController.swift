//
//  NotificationsViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/2/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import Parse

//class NotificationCell: UITableViewCell {
//    @IBOutlet weak var notificationLabel: UILabel!
//    @IBOutlet var notificationSwitch: UISwitch!
//    var delegate: NotificationCellDelegate?
//    var index: Int!
//    
//    @IBAction func switchFlipped(sender: AnyObject) {
//        delegate?.switchFlipped(index)
//    }
//}

protocol NotificationCellDelegate {
    func switchFlipped(index: Int)
}

class NotificationsViewController: UITableViewController {

    let notificationExplainations = ["Someone Posts in Discussion", "Someone Posts in Discussion as Important", "Someone Comments on Your Post"]
    let notificationTypes = ["post", "important", "comment"]
    var notificationBools = [false,false,false]
    var selectedObject: AnyObject?
    
    @IBOutlet weak var postSwitch: UISwitch!
    @IBOutlet weak var importantSwitch: UISwitch!
    @IBOutlet weak var commentSwitch: UISwitch!
    
    @IBOutlet weak var discussionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //check notification relations of selectedObject for notification settings of current user
        if let object = selectedObject as? PFObject {
            
            let discussionName = object["name"] as! String
            discussionLabel.text = "For \(discussionName)"
            
            //relation name = wantPostNotifications
            var wantsPostNotificationsQuery: PFQuery = object.relationForKey("wantsPostNotifications").query()!
            wantsPostNotificationsQuery.whereKey("objectId", equalTo: PFUser.currentUser()!.objectId!)
            wantsPostNotificationsQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                if error == nil {
                    println("user is in relation to recieve post notifications")
                    self.postSwitch.on = true
                } else {
                    println("user not in relation to recieve post notifications")
                    self.postSwitch.on = false
                }
            })
            //relation name = wantsImportantPostNotifications
            var wantsImportantPostNotificationsQuery: PFQuery = object.relationForKey("wantsImportantPostNotifications").query()!
            wantsImportantPostNotificationsQuery.whereKey("objectId", equalTo: PFUser.currentUser()!.objectId!)
            wantsImportantPostNotificationsQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                if error == nil {
                    println("user is in relation to recieve important post notifications")
                    self.importantSwitch.on = true
                } else {
                    println("user not in relation to recieve important post notifications")
                    self.importantSwitch.on = false
                }
            })
            
            //relation name = wantsCommentNotifications
            var wantsCommentNotificationsQuery: PFQuery = object.relationForKey("wantsCommentNotifications").query()!
            wantsCommentNotificationsQuery.whereKey("objectId", equalTo: PFUser.currentUser()!.objectId!)
            wantsCommentNotificationsQuery.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                if error == nil {
                    println("user is in relation to recieve comment notifications")
                    self.commentSwitch.on = true
                } else {
                    println("user not in relation to recieve comment notifications")
                    self.commentSwitch.on = false
                }
            })
        }
        
    }
    
    @IBAction func postSwitchChanged(sender: UISwitch) {
        if let object = selectedObject as? PFObject {
            var wantsPostNotificationsRelation: PFRelation = object.relationForKey("wantsPostNotifications")
            if sender.on {
                wantsPostNotificationsRelation.addObject(PFUser.currentUser()!)
            } else {
                wantsPostNotificationsRelation.removeObject(PFUser.currentUser()!)
            }
            object.saveInBackground()
        }
    }
    
    @IBAction func importantSwitchChanged(sender: UISwitch) {
        if let object = selectedObject as? PFObject {
            var wantsImportantPostNotificationsRelation: PFRelation = object.relationForKey("wantsImportantPostNotifications")
            if sender.on {
                wantsImportantPostNotificationsRelation.addObject(PFUser.currentUser()!)
            } else {
                wantsImportantPostNotificationsRelation.removeObject(PFUser.currentUser()!)
            }
            object.saveInBackground()
        }
    }
    
    @IBAction func commentSwitchChanged(sender: UISwitch) {
        if let object = selectedObject as? PFObject {
            var wantsCommentNotificationsRelation: PFRelation = object.relationForKey("wantsCommentNotifications")
            if sender.on {
                wantsCommentNotificationsRelation.addObject(PFUser.currentUser()!)
            } else {
                wantsCommentNotificationsRelation.removeObject(PFUser.currentUser()!)
            }
            object.saveInBackground()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 3
//    }
//
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath) as! NotificationCell
//
//        cell.notificationLabel.text = notificationExplainations[indexPath.row]
//        cell.notificationSwitch.on = notificationBools[indexPath.row]
//        cell.index = indexPath.row
//        cell.delegate = self
//        
//        return cell
//    }
//    
//    func switchFlipped(index: Int) {
//        notificationBools[index] = !notificationBools[index]
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
