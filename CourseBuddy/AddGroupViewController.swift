//
//  AddGroupViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/5/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

protocol AddGroupDelegate {
    func returnWithText(groupName: String, groupDescription: String?)
}

class AddGroupViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    var delegate: AddGroupDelegate?
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupDescriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupNameTextField.attributedPlaceholder = NSAttributedString(string:"Group Name",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        groupDescriptionTextView.textColor = UIColor.lightGrayColor()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        groupDescriptionTextView.select(textField)
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
            textView.text = "Group Description"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        if groupNameTextField.text != "" {
            var description: String?
            if groupDescriptionTextView.text.isEmpty || groupDescriptionTextView.text != "Group Description" {
                description = groupDescriptionTextView.text
            }
            delegate?.returnWithText(groupNameTextField.text, groupDescription: description)
            dismissViewControllerAnimated(true, completion: nil)
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
