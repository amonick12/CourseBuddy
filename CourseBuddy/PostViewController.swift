//
//  PostViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/4/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

protocol PostDelegate {
    func postTextEntered(content: String, type: String)
}

class PostViewController: UIViewController, UITextViewDelegate {

    var delegate: PostDelegate?
    var postType: String?
    
    var contentToUpdate: String?
    
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet var postTextView: UITextView!
    var senderButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if postType != nil {
            switch postType! {
                case "POST":
                    navBarItem.title = "Compose Post"
                    postTextView.text = "Compose a new post here"
                case "COMMENT":
                    navBarItem.title = "Comment"
                    postTextView.text = "Comment on post here"
                case "UPDATE":
                    navBarItem.title = "Update"
                    postTextView.text = contentToUpdate
                default:
                    navBarItem.title = "Compose Post"
                    postTextView.text = "Compose a new post here"
            }
        } else {
            postType = "POST"
        }
        postTextView.textColor = UIColor.lightGrayColor()
    }

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            if let type = postType {
                if type != "UPDATE" {
                    textView.text = ""
                }
            }
            textView.textColor = UIColor.darkGrayColor()
        }
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        let content = postTextView.text
        if content != "" && content != "Compose a new post here" || content == "Comment on post here" {
            self.dismissViewControllerAnimated(true, completion: nil)
            self.delegate?.postTextEntered(content, type: postType!)
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
