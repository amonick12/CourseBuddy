//
//  FileViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/3/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import WebKit

class FileViewController: UIViewController {

    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var webView: UIWebView!
    
    var fileName: String!
    var mimeType: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navTitle.title = fileName
        
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        let filePath = documentsDirectoryPath.stringByAppendingPathComponent(fileName)
        
        if let data = NSFileManager.defaultManager().contentsAtPath(filePath as String) {
            webView.loadData(data, MIMEType: mimeType, textEncodingName: "UTF-8", baseURL: nil)

        } else {
            println("Error loading file")
        }
        
        webView.scalesPageToFit = true
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
