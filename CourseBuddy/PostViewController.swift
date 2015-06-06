//
//  PostViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/4/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

protocol PostDelegate {
    func postTextEntered(content: String)
}

class PostViewController: UIViewController, UITextViewDelegate {

    var delegate: PostDelegate?
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet var postTextView: UITextView!
    var senderButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postTextView.textColor = UIColor.lightGrayColor()
    }

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = ""
            textView.textColor = UIColor.darkGrayColor()
        }
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        let content = postTextView.text
        if content != "" && content != "Compose a new post here" {
            self.dismissViewControllerAnimated(true, completion: nil)
            self.delegate?.postTextEntered(content)
        }
    }
    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        // done button
//        
//        return true
//    }
    
    
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
