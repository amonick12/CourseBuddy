//
//  WebViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/3/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import Parse

protocol WebViewDelegate {
    func newResourceConfirmed()
}

class WebViewController: UIViewController {

    var delegate: WebViewDelegate?
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var webView: UIWebView!
    
    var selectedCourse: AnyObject?
    var resourceTitle: String?
    var address: String?
    var addingResource: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        confirmButton.hidden = true
        if let adding = addingResource {
            if adding {
                if let course = selectedCourse as? PFObject {
                    let courseCode = course["courseId"] as! String
                    confirmButton.setTitle("Share with \(courseCode)", forState: .Normal)
                    confirmButton.hidden = false
                }
            }
        }
        
        navTitle.title = resourceTitle
        let url = NSURL(string: address!)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func confirmButtonPressed(sender: AnyObject) {
        delegate?.newResourceConfirmed()
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
