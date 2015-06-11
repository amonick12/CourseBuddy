//
//  LoginViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/4/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import ParseUI

class LoginViewController: PFLogInViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Helper().colorWithRGBHex(0x00c853, alpha: 0.9)
        let logoView = UIImageView(image: UIImage(named:"cb_logo.png"))
        self.logInView!.logo = logoView
        self.logInView?.logo?.contentMode = UIViewContentMode.ScaleAspectFit
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
