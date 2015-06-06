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
    var verified: Bool?
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
        if verified != nil {
            if verified! == true {
                email = PFUser.currentUser()?.email
                emailLabel.text = email
            }
        }
        // Do any additional setup after loading the view.
    }

//    func emailVerificationAlert() {
//        let alertController = UIAlertController(title: "Verify .edu Email", message: "Verify your .edu email by checking your inbox", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        alertController.addTextFieldWithConfigurationHandler({(txtField: UITextField!) in
//            txtField.placeholder = "Your .edu email"
//            txtField.keyboardType = UIKeyboardType.EmailAddress
//        })
//        
//        let deleteAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
//            println("Delete button tapped")
//        })
//        alertController.addAction(deleteAction)
//        
//        let okAction = UIAlertAction(title: "Send Email", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
//            println("OK button tapped")
//            if let textField = alertController.textFields?.first as? UITextField {
//                println(textField.text)
//                let email = textField.text.lowercaseString
//                let domain = email.componentsSeparatedByString("@")[1]
//                let tld = domain.componentsSeparatedByString(".")[1]
//                println("Domain: \(domain)")
//                println("TLD: \(tld)")
//                if tld == "edu" {
//                    PFUser.currentUser()?.email = email
//                    PFUser.currentUser()?["domain"] = domain
//                    PFUser.currentUser()?.saveEventually(nil)
//                    let sentAlert = UIAlertController(title: "Verification Sent", message: "Check your .edu inbox", preferredStyle: .Alert)
//                    sentAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//                } else {
//                    let failAlert = UIAlertController(title: "Error", message: "Your email needs to be a .edu email", preferredStyle: .Alert)
//                    failAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
//                        self.emailVerificationAlert()
//                    }))
//                }
//            }
//            
//        })
//        alertController.addAction(okAction)
//        
//        presentViewController(alertController, animated: true, completion: nil)
//    }
    
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
