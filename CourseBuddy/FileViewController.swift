//
//  FileViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/3/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import WebKit
import Parse

protocol FileViewDelegate {
    func newFileUploaded()
}

class FileViewController: UIViewController {

    var delegate: FileViewDelegate?
    var selectedCourse: AnyObject?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var confirmButton: UIButton!
    
    var filename: String!
    var mimeType: String!
    var data: NSData?
    var senderType: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidden = true
        if let course = selectedCourse as? PFObject {
            let courseCode = course["courseId"] as! String
            confirmButton.setTitle("Share with \(courseCode)", forState: .Normal)
        }
        navTitle.title = filename
        
        if senderType == "dropbox" {
            let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
            let filePath = documentsDirectoryPath.stringByAppendingPathComponent(filename)
            
            if let fileData = NSFileManager.defaultManager().contentsAtPath(filePath as String) {
                self.data = fileData
                webView.loadData(data, MIMEType: mimeType, textEncodingName: "UTF-8", baseURL: nil)
                
            } else {
                println("Error loading file")
            }
            
        } else if senderType == "parse" {
            confirmButton.hidden = true
            if data != nil {
                webView.loadData(data!, MIMEType: mimeType, textEncodingName: "UTF-8", baseURL: nil)
            }
    
        }
        webView.scalesPageToFit = true

    }
    
    @IBAction func confirmButtonPressed(sender: AnyObject) {

        if selectedCourse != nil {
            
            confirmButton.setTitle("", forState: .Normal)
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            var newDocument = PFObject(className: "File")
            newDocument["filename"] = filename
            newDocument["mimeType"] = mimeType
            newDocument["poster"] = PFUser.currentUser()
            newDocument["course"] = selectedCourse as! PFObject
            let parseFile = PFFile(name: filename, data: data!, contentType: mimeType)
            newDocument["file"] = parseFile
            //        let imageData = UIImagePNGRepresentation(screenshot)
            //        let imageName = title + ".png"
            //        let imageFile = PFFile(name: imageName, data: imageData)
            //        newResource["screenshot"] = imageFile
            newDocument.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if error == nil {
                    let course = self.selectedCourse as! PFObject
                    let documentsRelation: PFRelation = course.relationForKey("files")
                    documentsRelation.addObject(newDocument)
                    course.saveInBackgroundWithBlock {
                        (succeeded: Bool, error: NSError?) -> Void in
                        if succeeded {
                            println("successfully save document: \(self.filename)")
                            self.delegate?.newFileUploaded()
                            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            println("error saving course")
                            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    }
                } else {
                    println("error saving document")
                    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }

        } else {
            println("selectedCourse = nil")
        }
        
        
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
