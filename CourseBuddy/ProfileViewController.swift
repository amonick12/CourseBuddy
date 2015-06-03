//
//  ProfileViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/2/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import Parse

protocol ProfileDelegate {
    func userDidLogout()
}

class ProfileViewController: UIViewController {

    var delegate: ProfileDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var universityLabel: UILabel!
    
    var name: String?
    var email: String?
    var university: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if name != nil {
            nameLabel.text = name
        }
        if email != nil {
            emailLabel.text = email
        }
        if university != nil {
            universityLabel.text = university
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
        delegate?.userDidLogout()

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
