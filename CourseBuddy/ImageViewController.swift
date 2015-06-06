//
//  ImageViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/5/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageTitleItem: UINavigationItem!
    @IBOutlet weak var imageView: UIImageView!
    var imageDescription: String?
    var imageName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)

        if imageName != nil {
            imageView.image = UIImage(named: imageName!)
        }
        if imageDescription != nil {
            imageTitleItem.title = imageDescription!
        }
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        dismissViewControllerAnimated(true, completion: nil)
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
