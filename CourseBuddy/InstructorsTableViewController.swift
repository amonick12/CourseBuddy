//
//  InstructorsTableViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/4/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

protocol InstructorTableDelegate {
    func didSelectInstructor(named: String)
    func didAddNewInstructor(named: String, description: String?)
}

class InstructorCell: UITableViewCell {
    @IBOutlet weak var instructorLabel: UILabel!
    @IBOutlet var notificationButton: UIButton!
}

class InstructorsTableViewController: UITableViewController, AddInstructorDelegate {

    var delegate: InstructorTableDelegate?
    
    let defaultData = ["Professor Chaos", "Stephen Hawking"]
    var instructors: [AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! AddInstructorViewController
        vc.delegate = self
    }
    
    func returnWithText(instructorName: String, instructorDescription: String?) {
//        println(instructorName)
//        if instructorDescription != nil {
//            println(instructorDescription!)
//        }
        delegate?.didAddNewInstructor(instructorName, description: instructorDescription)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if instructors != nil {
            return instructors!.count
        } else {
            return defaultData.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InstructorCell", forIndexPath: indexPath) as! InstructorCell
        if instructors != nil {

        } else {
            cell.instructorLabel.text = defaultData[indexPath.row]
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if instructors != nil {
            
        } else {
            delegate?.didSelectInstructor(defaultData[indexPath.row])
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
