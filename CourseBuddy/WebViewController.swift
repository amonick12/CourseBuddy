//
//  WebViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/3/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

protocol WebViewDelegate {
    func newResourceConfirmed()
}

class WebViewController: UIViewController {

    var delegate: WebViewDelegate?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var webView: UIWebView!
    
    var resourceTitle: String?
    var address: String?
    var addingResource: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if let adding = addingResource {
            if adding {
                doneButton.title = "Confirm"
                cancelButton.enabled = true
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
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        if let adding = addingResource {
            if adding {
                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
                dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        if let adding = addingResource {
            if adding {
                delegate?.newResourceConfirmed()
            }
        }
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
