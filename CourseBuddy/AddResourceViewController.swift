//
//  AddResourceViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/5/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

protocol AddResourceDelegate {
    func resourceAdded(title: String, url: String)
}

class AddResourceViewController: UIViewController, UITextFieldDelegate, WebViewDelegate {

    var delegate: AddResourceDelegate?
    
    @IBOutlet weak var resourceTitleTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    
    var resourceTitle: String?
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! WebViewController
        vc.resourceTitle = resourceTitle
        vc.address = url
        vc.addingResource = true
        vc.delegate = self
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == resourceTitleTextField {
            urlTextField.select(textField)
        }
        if textField == urlTextField {
            doneButtonPressed(textField)
        }
        return true
    }
    
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        if resourceTitleTextField.text != "" && urlTextField.text != "" {
            resourceTitle = resourceTitleTextField.text
            url = urlTextField.text

            let header1 = "http://"
            let header2 = "https://"
            url = url!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if url!.rangeOfString(header1) == nil && url!.rangeOfString(header2) == nil {
                url = header1 + url!
            }
            
            performSegueWithIdentifier("showWebViewSegue", sender: sender)
        }
    }
    
    func newResourceConfirmed() {
        delegate?.resourceAdded(resourceTitle!, url: url!)
        navigationController?.popViewControllerAnimated(true)
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
