//
//  ViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/2/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ViewController: UIViewController, PFLogInViewControllerDelegate {

    @IBOutlet weak var scheduleBarButton: UIBarButtonItem!
    var defaultData:[String] = ["Welcome to CourseBuddy"]
    var schedule = ["IST402", "ENG015", "MATH141", "PHYS212", "STAT200"]
    var name: String?
    var email: String?
    var university: String?
    var logInController = PFLogInViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "CourseBuddy"
        let font = UIFont(name: "Noteworthy-Light", size: 23)
        if let font = font {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
        }
        
        logInController.delegate = self
        logInController.facebookPermissions = [ "public_profile" ]
        logInController.fields = (PFLogInFields.Facebook)
        
        checkUser()
        
        for var i=0; i < 100; i++ {
            defaultData.append("\(i): Welcome to CourseBuddy")
        }
    }
    
    func checkUser() {
        if PFUser.currentUser() == nil {
            PFUser.logOut()
            self.presentViewController(logInController, animated: true, completion: nil)
        } else {
            self.name = PFUser.currentUser()?["name"] as? String
            self.email = PFUser.currentUser()?.email
            checkUniversity(scheduleBarButton)
        }
    }

    func logInViewController(controller: PFLogInViewController, didLogInUser user: PFUser) -> Void {
        println("\(user.username) did log in")
        self.navigationController?.dismissViewControllerAnimated(true) {
            self.showUniversitySelector(self.scheduleBarButton)
        }
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            var userProfileRequestParams = [ "fields" : "id, name, email"]
            let userProfileRequest = FBSDKGraphRequest(graphPath: "me", parameters: userProfileRequestParams)
            let graphConnection = FBSDKGraphRequestConnection()
            graphConnection.addRequest(userProfileRequest, completionHandler: {
                (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                if error != nil {
                    println(error)
                }
                else {
                    let fbEmail = result.objectForKey("email") as! String
                    let fbUserId = result.objectForKey("id") as! String
                    let name = result.objectForKey("name") as! String
                    if(fbEmail != "") {
                        self.name = name
                        self.email = fbEmail
                        PFUser.currentUser()?.username = fbEmail
                        PFUser.currentUser()?.email = fbEmail
                        PFUser.currentUser()?["name"] = name
                        PFUser.currentUser()?["facebookId"] = fbUserId
                        
                        let emailParts = fbEmail.lowercaseString.componentsSeparatedByString("@")
                        let domain = emailParts[1] as String
                        if domain.rangeOfString("edu") != nil {
                            PFUser.currentUser()?["eduEmail"] = fbEmail
                        }
                        
                        PFUser.currentUser()?.saveEventually(nil)
                    }
                }
            })
            graphConnection.start()
        }
    }
    
    func logInViewControllerDidCancelLogIn(controller: PFLogInViewController) -> Void {
        println("user canceled log in")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
}

extension ViewController: ScheduleDelegate {
    func didSelectCourseCode(courseCode: String) {
        self.navigationItem.title = courseCode.uppercaseString
        let font = UIFont(name: "GeezaPro-Bold", size: 23)
        if let font = font {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
        }
    }
}

extension ViewController: ProfileDelegate {
    func userDidLogout() {
        if let user = PFUser.currentUser() {
            PFUser.logOut()
            checkUser()
            self.navigationItem.title = "CourseBuddy"
            let font = UIFont(name: "Noteworthy-Light", size: 23)
            if let font = font {
                self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
            }
        }
    }
}

extension ViewController: UniversitySelectorDelegate {
    func userSelectedUniversity(named: String) {
        self.university = named
        println(university)
        scheduleButtonPressed(scheduleBarButton)
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    @IBAction func swipeDownGesture(sender: UISwipeGestureRecognizer) {
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }
    @IBAction func swipeUpGesture(sender: UISwipeGestureRecognizer) {
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    
    func checkUniversity(sender: UIBarButtonItem) -> Bool {
        if self.university != nil {
            return true
        } else {
            showUniversitySelector(sender)
            return false
        }
    }
    
    func showUniversitySelector(sender: UIBarButtonItem) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("UniversitySelector") as! UniversitySelectorViewController
        vc.delegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.barButtonItem = sender
        popover.delegate = self
        presentViewController(vc, animated: true, completion:nil)
    }
    
    @IBAction func scheduleButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ScheduleNav") as! ScheduleNavViewController
            let root = vc.visibleViewController as! ScheduleViewController
            root.schedule = self.schedule
            root.delegate = self
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover: UIPopoverPresentationController = vc.popoverPresentationController!
            popover.barButtonItem = sender
            popover.delegate = self
            presentViewController(vc, animated: true, completion:nil)
        }
    }
    
    @IBAction func profileButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("Profile") as! ProfileViewController
            vc.name = self.name
            vc.email = self.email
            vc.university = self.university
            vc.delegate = self
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover: UIPopoverPresentationController = vc.popoverPresentationController!
            popover.barButtonItem = sender
            popover.delegate = self
            presentViewController(vc, animated: true, completion:nil)
        }
    }
    
    @IBAction func documentsButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("DocNav") as! DocNavViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover: UIPopoverPresentationController = vc.popoverPresentationController!
            popover.barButtonItem = sender
            popover.delegate = self
            presentViewController(vc, animated: true, completion:nil)
        }
    }
    
    @IBAction func resourcesButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ResourceNav") as! ResourceNavViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover: UIPopoverPresentationController = vc.popoverPresentationController!
            popover.barButtonItem = sender
            popover.delegate = self
            presentViewController(vc, animated: true, completion:nil)
        }
    }
    
    @IBAction func notesButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("NotesNav") as! NotesNavViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover: UIPopoverPresentationController = vc.popoverPresentationController!
            popover.barButtonItem = sender
            popover.delegate = self
            presentViewController(vc, animated: true, completion:nil)
        }
    }
    
    @IBAction func imagesButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("Images") as! ImagesViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover: UIPopoverPresentationController = vc.popoverPresentationController!
            popover.barButtonItem = sender
            popover.delegate = self
            presentViewController(vc, animated: true, completion:nil)
        }
    }
    
    @IBAction func rosterButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("Roster") as! RosterViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover: UIPopoverPresentationController = vc.popoverPresentationController!
            popover.barButtonItem = sender
            popover.delegate = self
            presentViewController(vc, animated: true, completion:nil)
        }
    }
    
    @IBAction func notificationsButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("Notifications") as! NotificationsViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover: UIPopoverPresentationController = vc.popoverPresentationController!
            popover.barButtonItem = sender
            popover.delegate = self
            presentViewController(vc, animated: true, completion:nil)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}

class MainCell: UITableViewCell {
    @IBOutlet var label: UILabel!
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return defaultData.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MainCell", forIndexPath: indexPath) as! MainCell
        
         cell.label.text = defaultData[indexPath.row]
        
        return cell
    }

}







