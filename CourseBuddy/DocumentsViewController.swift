//
//  DocumentsViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/9/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import Parse

class DocumentsViewController: UITableViewController, AddDocumentsDelegate {

    var cellShown: [Bool]?
    
    var selectedFileName: String?
    var selectedMimeType: String?
    var selectedData: NSData?
    
    var selectedCourse: AnyObject?
    var documentObjects: [AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.toolbarHidden = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        loadDocuments()
    }
    
    func loadDocuments() {
        if selectedCourse != nil {
            let courseObject = selectedCourse as! PFObject
            var documentsQuery: PFQuery = courseObject.relationForKey("files").query()!
            documentsQuery.orderByDescending("createdAt")
            documentsQuery.findObjectsInBackgroundWithBlock {
                (documents: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    println("retrieved \(documents!.count) documents")
                    self.documentObjects = documents
                    self.cellShown = [Bool](count: documents!.count, repeatedValue: false)
                    self.tableView.reloadData()
                } else {
                    println("There was an error fetching the documents")
                }
            }
        }
    }

    func newFileShared() {
        loadDocuments()
    }

//    func documentSelectedToAdd(filename: String, mimeType: String) {
//        println("document to add named: \(filename)")
//        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
//        let filePath = documentsDirectoryPath.stringByAppendingPathComponent(filename)
//        
//        if let fileData = NSFileManager.defaultManager().contentsAtPath(filePath as String) {
//
//            var newDocument = PFObject(className: "File")
//            newDocument["filename"] = filename
//            newDocument["mimeType"] = mimeType
//            newDocument["poster"] = PFUser.currentUser()
//            newDocument["course"] = selectedCourse as! PFObject
//            let parseFile = PFFile(name: filename, data: fileData, contentType: mimeType)
//            newDocument["file"] = parseFile
//            //        let imageData = UIImagePNGRepresentation(screenshot)
//            //        let imageName = title + ".png"
//            //        let imageFile = PFFile(name: imageName, data: imageData)
//            //        newResource["screenshot"] = imageFile
//            newDocument.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                if error == nil {
//                    let course = self.selectedCourse as! PFObject
//                    let documentsRelation: PFRelation = course.relationForKey("files")
//                    documentsRelation.addObject(newDocument)
//                    course.saveInBackgroundWithBlock {
//                        (succeeded: Bool, error: NSError?) -> Void in
//                        if succeeded {
//                            self.loadDocuments()
//                        } else { println("error saving course") }
//                    }
//                } else { println("error saving document") }
//            }
//            
//        } else {
//            println("Error loading file to add")
//        }
//        
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFileSegue" {
            if let destination = segue.destinationViewController as? FileViewController {
                destination.filename = selectedFileName!
                destination.mimeType = selectedMimeType!
                destination.senderType = "parse"
                destination.data = selectedData
                destination.selectedCourse = self.selectedCourse
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
            }
        } else if segue.identifier == "addDocumentSegue" {
            if let destination = segue.destinationViewController as? AddDocumentsViewController {
                //destination.delegate = self
                destination.selectedCourse = self.selectedCourse
                destination.delegate = self
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if documentObjects != nil {
            return documentObjects!.count
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DocumentCell", forIndexPath: indexPath) as! UITableViewCell

        if documentObjects != nil {
            var document: PFObject = self.documentObjects![indexPath.row] as! PFObject
            cell.textLabel?.text = document["filename"] as? String
        } else {
            
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if documentObjects != nil {
            var document: PFObject = self.documentObjects![indexPath.row] as! PFObject
            selectedFileName = document["filename"] as? String
            selectedMimeType = document["mimeType"] as? String
            
            (document["file"] as! PFFile).getDataInBackgroundWithBlock{
                (fileData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    self.selectedData = fileData
                    self.performSegueWithIdentifier("showFileSegue", sender: nil)
                }
            }
        } else {
            
        }
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cellShown![indexPath.row] {
            return
        }
        cellShown![indexPath.row] = true
        cell.alpha = 0
        UIView.animateWithDuration(1.0, animations: { cell.alpha = 1 })
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
