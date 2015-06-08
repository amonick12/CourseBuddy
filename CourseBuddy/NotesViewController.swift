//
//  NotesViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/2/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import Parse

class NotesViewController: UITableViewController, AddNoteDelegate, UpdateNoteDelegate {

    let defaultNote = [["First Note", "Collaborate on the same content here"], ["Second Note", "What are some good features to add to shared notes"]]
    
    var selectedNoteTitle: String?
    var selectedNoteContent: String?
    var selectedIndex: Int?
    
    var selectedCourse: AnyObject?
    var noteObjects: [AnyObject]?
    
    var noteShown: [Bool]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        loadNotes()
    }

    func loadNotes() {
        if selectedCourse != nil {
            let courseObject = selectedCourse as! PFObject
            var notesQuery: PFQuery = courseObject.relationForKey("notes").query()!
            notesQuery.orderByDescending("updatedAt")
            notesQuery.findObjectsInBackgroundWithBlock {
                (notes: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    println("retrieved \(notes!.count) notes")
                    self.noteObjects = notes
                    self.noteShown = [Bool](count: notes!.count, repeatedValue: false)
                    self.tableView.reloadData()
                } else {
                    println("There was an error fetching the notes")
                }
            }
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showNoteDetail" {
            if let destination = segue.destinationViewController as? NoteDetailViewController {
                destination.noteTitle = selectedNoteTitle
                destination.noteContent = selectedNoteContent
                destination.noteIndex = selectedIndex
                destination.delegate = self
            }
        } else if segue.identifier == "addNoteSegue" {
            if let destination = segue.destinationViewController as? AddNoteViewController {
                destination.delegate = self
            }
        }
    }
    
    func newNoteAdded(title: String, content: String) {
        println(title)
        println(content)
        if title != ""  && content != "" && selectedCourse != nil {
            var newNote = PFObject(className: "Note") as PFObject
            newNote["creatorName"] = PFUser.currentUser()!["name"]
            newNote["creator"] = PFUser.currentUser()
            newNote["title"] = title
            newNote["content"] = content
            newNote["ups"] = 0
            newNote["course"] = selectedCourse as! PFObject
            let contributors = newNote.relationForKey("contributors") as PFRelation
            contributors.addObject(PFUser.currentUser()!)
            var course = self.selectedCourse as! PFObject
            newNote.saveInBackgroundWithBlock{
                (succeeded: Bool, error: NSError?) -> Void in
                if succeeded {
                    var notesRelation: PFRelation = course.relationForKey("notes")
                    notesRelation.addObject(newNote)
                    course.saveInBackgroundWithBlock{
                        (succeeded: Bool, error: NSError?) -> Void in
                        if succeeded {
                            self.loadNotes()
                        }
                    }
                }
            }
        } else {
            println("note error")
        }
    }
    
    func updateNoteAtIndex(index: Int, newContent: String) {
        println("Update note at index: \(index) with content: \(newContent)")
        if selectedCourse != nil && newContent != "" && noteObjects != nil {
            var notes = noteObjects as! [PFObject]
            let selectedNote = notes[index] as PFObject
            selectedNote["content"] = newContent
            let contributors = selectedNote.relationForKey("contributors")
            contributors.addObject(PFUser.currentUser()!)
            selectedNote.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
                if error == nil {
                    self.loadNotes()
                }
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
        if noteObjects != nil {
            return noteObjects!.count
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath) as! UITableViewCell

        if noteObjects != nil {
            var note: PFObject = self.noteObjects![indexPath.row] as! PFObject
            cell.textLabel?.text = note["title"] as? String
            cell.detailTextLabel?.text = note["content"] as? String
        } else {
            let note = defaultNote[indexPath.row]
            cell.textLabel?.text = note[0]
            cell.detailTextLabel?.text = note[1]
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if noteObjects != nil {
            let note = self.noteObjects![indexPath.row] as! PFObject
            selectedNoteTitle = note["title"] as? String
            selectedNoteContent = note["content"] as? String
        } else {
            let note = defaultNote[indexPath.row]
            selectedNoteTitle = note[0]
            selectedNoteContent = note[1]
        }
        selectedIndex = indexPath.row
        performSegueWithIdentifier("showNoteDetail", sender: nil)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if noteShown![indexPath.row] {
            return
        }
        noteShown![indexPath.row] = true
        cell.alpha = 0
        UIView.animateWithDuration(1.0, animations: { cell.alpha = 1 })
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
