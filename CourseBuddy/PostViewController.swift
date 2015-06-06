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

class PostViewController: UIViewController, UITextFieldDelegate {

    var delegate: PostDelegate?
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var postTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        let content = postTextField.text
        if content != "" {
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let postAction = UIAlertAction(title: "Post", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.delegate?.postTextEntered(content, type: "post")
            })
            alertController.addAction(postAction)
            
            let importantAction = UIAlertAction(title: "Post as Important", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.delegate?.postTextEntered(content, type: "important")
            })
            alertController.addAction(importantAction)
            
            let anonAction = UIAlertAction(title: "Post as Anonymous", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.delegate?.postTextEntered(content, type: "anon")
            })
            alertController.addAction(anonAction)
            
            if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
                postTextField.resignFirstResponder()
            }

            alertController.popoverPresentationController?.barButtonItem = sender
            presentViewController(alertController, animated: true, completion: nil)
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
