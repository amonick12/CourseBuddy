//
//  AddInstructorViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/5/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

protocol AddInstructorDelegate {
    func returnWithText(instructorName: String, instructorDescription: String?)
}

class AddInstructorViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    var delegate: AddInstructorDelegate?
    
    @IBOutlet weak var instructorNameTextField: UITextField!
    @IBOutlet weak var instructorDescriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        instructorNameTextField.attributedPlaceholder = NSAttributedString(string:"Instructor Name",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        instructorDescriptionTextView.textColor = UIColor.lightGrayColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        instructorDescriptionTextView.select(textField)
        return false
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = ""
            textView.textColor = UIColor.darkGrayColor()
        }
    }
    
//    func textViewDidChange(textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = "Instructor email, office, and office hours"
//            textView.textColor = UIColor.lightGrayColor()
//        }
//    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Instructor email, office, and office hours"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        if instructorNameTextField.text != "" {
            var description: String?
            if instructorDescriptionTextView.text.isEmpty || instructorDescriptionTextView.text != "Instructor email, office, and office hours" {
                description = instructorDescriptionTextView.text
            }
            delegate?.returnWithText(instructorNameTextField.text, instructorDescription: description)
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
