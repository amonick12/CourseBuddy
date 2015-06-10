//
//  AddCourseViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/4/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

protocol AddCourseDelegate {
    func newCourseAdded(courseCode: String)
}

class AddCourseViewController: UIViewController, UITextFieldDelegate {

    var delegate: AddCourseDelegate?
    @IBOutlet weak var courseTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doneButtonPressed(textField)
        return true
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        if courseTextField.text != "" {
            view.resignFirstResponder()
            dismissViewControllerAnimated(true, completion: nil)
            delegate?.newCourseAdded(courseTextField.text.stringByReplacingOccurrencesOfString(" ", withString: ""))
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
