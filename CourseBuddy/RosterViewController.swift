//
//  RosterViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/2/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import MessageUI
import Parse

class RosterViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    var defaultData = [["Albert Einstein", "aje9329@psu.edu"],["Stephen Hawking", "skh9420@psu.edu"]]
    var roster: [AnyObject]?
    var selectedEmails: [String] = []
    var emails: [String] = []
    var courseCode: String?
    var verified: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        PFUser.currentUser()?.fetch()
        verified = PFUser.currentUser()?["emailVerified"] as? Bool
        if verified != nil {
            if verified! == false {
                emailVerificationAlert()
            }
        } else {
            emailVerificationAlert()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func emailButtonPressed(sender: AnyObject) {
        if !selectedEmails.isEmpty {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                //self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                self.presentViewController(mailComposeViewController, animated: true, completion: { () -> Void in
                    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
                })
            } else {
                showSendMailErrorAlert()
            }
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(selectedEmails)
        mailComposerVC.setMessageBody("\n\n\nSent from CourseBuddy \(courseCode!)", isHTML: false)
        var userEmail = PFUser.currentUser()?.email
        mailComposerVC.setBccRecipients([userEmail!])
        //mailComposerVC.navigationBar.tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        var alert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        controller.dismissViewControllerAnimated(true, completion: nil)
        for email in selectedEmails {
            if var index = find(emails, email) {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        selectedEmails.removeAll(keepCapacity: false)
    }
    
    // MARK: - Table view data source

    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if roster != nil {
            return roster!.count
        } else {
            return defaultData.count
        }
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RosterCell", forIndexPath: indexPath) as! UITableViewCell

        if roster != nil {
            
        } else {
            let person = defaultData[indexPath.row]
            cell.textLabel?.text = person[0]
            cell.detailTextLabel?.text = person[1]
            emails.append(person[1])
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if roster != nil {
            
        } else {
            let person = defaultData[indexPath.row]
            selectedEmails.append(person[1])
        }
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if roster != nil {
            
        } else {
            let person = defaultData[indexPath.row]
            let emailToDeselect = person[1]
            if var index = find(selectedEmails, emailToDeselect) {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                selectedEmails.removeAtIndex(index)
            }
        }
    }
    
    func emailVerificationAlert() {
        let alertController = UIAlertController(title: "Add Your .edu Email", message: "Add your .edu email and verify it by checking your inbox", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler({(txtField: UITextField!) in
            txtField.placeholder = "Your .edu email"
            txtField.keyboardType = UIKeyboardType.EmailAddress
        })
        
        let deleteAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
            println("Delete button tapped")
        })
        alertController.addAction(deleteAction)
        
        let okAction = UIAlertAction(title: "Send Email", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            println("OK button tapped")
            if let textField = alertController.textFields?.first as? UITextField {
                println(textField.text)
                let email = textField.text.lowercaseString
                if email.componentsSeparatedByString("@").count == 2 {
                    let domain = email.componentsSeparatedByString("@")[1]
                    if domain.componentsSeparatedByString(".").count == 2 {
                        let tld = domain.componentsSeparatedByString(".")[1]
                        println("Domain: \(domain)")
                        println("TLD: \(tld)")
                        if tld == "edu" {
                            PFUser.currentUser()?.email = email
                            PFUser.currentUser()?["domain"] = domain
                            PFUser.currentUser()?.saveInBackground()
                            let sentAlert = UIAlertController(title: "Verification Sent", message: "Check your .edu email inbox", preferredStyle: .Alert)
                            sentAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
                            self.presentViewController(sentAlert, animated: true, completion: nil)
                        } else { self.showFailAlert() }
                    } else { self.showFailAlert() }
                } else { self.showFailAlert() }
            }
            
        })
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    func showFailAlert() {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        let failAlert = UIAlertController(title: "Error", message: "Your email needs to be a .edu email", preferredStyle: .Alert)
        failAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
            self.emailVerificationAlert()
        }))
        presentViewController(failAlert, animated: true, completion: nil)
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
