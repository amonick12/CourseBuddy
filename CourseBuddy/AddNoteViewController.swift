//
//  AddNoteViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/5/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

protocol AddNoteDelegate {
    func newNoteAdded(title: String, content: String)
}

class AddNoteViewController: UIViewController, UITextFieldDelegate {

    var delegate: AddNoteDelegate?
    
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet var noteContentTextView: UITextView!
    
    var noteTitle: String?
    var content: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        noteTitleTextField.attributedPlaceholder = NSAttributedString(string:"Note Title",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        noteContentTextView.textColor = UIColor.lightGrayColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        noteContentTextView.select(textField)
        return false
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = ""
            textView.textColor = UIColor.darkGrayColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Start New Note Here"
            textView.textColor = UIColor.lightGrayColor()
        }
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        if !noteTitleTextField.text.isEmpty && noteTitleTextField.text != "Note Title"{
            noteTitle = noteTitleTextField.text
            if !noteContentTextView.text.isEmpty || noteContentTextView.text != "Start New Note Here" {
                content = noteContentTextView.text
                delegate?.newNoteAdded(noteTitle!, content: content!)
                navigationController?.popViewControllerAnimated(true)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
