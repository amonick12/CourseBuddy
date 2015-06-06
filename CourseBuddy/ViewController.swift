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

class ViewController: UIViewController {

    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var scheduleBarButton: UIBarButtonItem!
    var defaultData:[String] = ["Welcome to CourseBuddy"]
    var schedule = ["IST402", "ENG015", "MATH141", "PHYS212", "STAT200"]
    var name: String?
    var email: String?
    var verified: Bool?
    var university: String?
    var universityID: String?
    var logInController = LoginViewController()
    var selectedCourseCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "CourseBuddy"
        let font = UIFont(name: "Noteworthy-Light", size: 23)
        if let font = font {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
        }

        logInController.delegate = self
        logInController.facebookPermissions = [ "public_profile", "email"]
        logInController.fields = (PFLogInFields.Facebook)
        
        for var i=0; i < 100; i++ {
            defaultData.append("\(i): Welcome to CourseBuddy")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        checkUser()
    }
    
    func checkUser() {
        if PFUser.currentUser() == nil {
            //PFUser.logOut()
            self.presentViewController(logInController, animated: true, completion: nil)
        } else {
            self.name = PFUser.currentUser()?["name"] as? String
            self.email = PFUser.currentUser()?.username
            var eduEmail = PFUser.currentUser()?.email
            verified = PFUser.currentUser()?["emailVerified"] as? Bool
            if verified != nil {
                if eduEmail != nil && verified! == true {
                    self.email = eduEmail!
                }
            }
            self.university = PFUser.currentUser()?["university"] as? String
            self.universityID = PFUser.currentUser()?["universityID"] as? String
            println("Name: \(name)")
            println("Email: \(email)")
            println("University: \(university)")
            if university == nil {
                checkUniversity(scheduleBarButton)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
}

extension ViewController: ScheduleDelegate {
    func didSelectCourseCode(courseCode: String) {
        selectedCourseCode = courseCode
        self.navigationItem.title = courseCode.uppercaseString
        let font = UIFont(name: "GeezaPro-Bold", size: 23)
        if let font = font {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
        }
    }
    func newCourseAdded(courseCode: String) {
        selectedCourseCode = courseCode
        self.navigationItem.title = courseCode.uppercaseString
        let font = UIFont(name: "GeezaPro-Bold", size: 23)
        if let font = font {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
        }
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension ViewController: ProfileDelegate {
    func userDidLogout() {
        //if let user = PFUser.currentUser() {
            PFUser.logOut()
            name = nil
            email = nil
            university = nil
            selectedCourseCode = nil
            checkUser()
            //clear course data
            self.navigationItem.title = "CourseBuddy"
            let font = UIFont(name: "Noteworthy-Light", size: 23)
            if let font = font {
                self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
            }
        //}
    }
}

extension ViewController: UniversitySelectorDelegate {
    func userSelectedUniversity(named: String, id: String) {
        self.university = named
        println(university!)
        if let user = PFUser.currentUser() {
            user["university"] = university
            user["universityID"] = id
            user.saveEventually()
            scheduleButtonPressed(scheduleBarButton)
        }
    }
}

extension ViewController: PostDelegate {
    func postTextEntered(content: String) {
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        var type: String?
        let postAction = UIAlertAction(title: "Post", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            self.createPost(content, type: "post")
        })
        alertController.addAction(postAction)
        
        let importantAction = UIAlertAction(title: "Post as Important", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            self.createPost(content, type: "important")
        })
        alertController.addAction(importantAction)
        
        let anonAction = UIAlertAction(title: "Post as Anonymous", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            self.createPost(content, type: "anon")
        })
        alertController.addAction(anonAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (alert: UIAlertAction!) in
            // do nothing
        })
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.barButtonItem = postButton
        presentViewController(alertController, animated: true, completion: nil)

    }
    func createPost(content: String, type: String) {
        println(content)
        println(type)
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
        if university != nil {
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
    
    func checkIfCourseIsSelected(sender: UIBarButtonItem) -> Bool {
        if selectedCourseCode != nil {
            return true
        } else {
            scheduleButtonPressed(sender)
            return false
        }
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
            vc.verified = self.verified
            vc.university = self.university
            vc.delegate = self
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover: UIPopoverPresentationController = vc.popoverPresentationController!
            popover.barButtonItem = sender
            popover.delegate = self
            presentViewController(vc, animated: true, completion:nil)
        }
    }
    
    @IBAction func postButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            if checkIfCourseIsSelected(sender) {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("Post") as! PostViewController
                vc.delegate = self
                vc.senderButton = sender
                vc.modalPresentationStyle = UIModalPresentationStyle.Popover
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                popover.barButtonItem = sender
                popover.delegate = self
                presentViewController(vc, animated: true, completion:nil)
            }
        }
    }
    
    @IBAction func instructorsButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            if checkIfCourseIsSelected(sender) {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("InstructorsNav") as! InstructorsNavViewController
                let root = vc.visibleViewController as! InstructorsTableViewController
                root.delegate = self
                vc.modalPresentationStyle = UIModalPresentationStyle.Popover
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                popover.barButtonItem = sender
                popover.delegate = self
                presentViewController(vc, animated: true, completion:nil)
            }
        }
    }
    
    @IBAction func groupsButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            if checkIfCourseIsSelected(sender) {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("GroupsNav") as! GroupsNavViewController
                let root = vc.visibleViewController as! GroupsTableViewController
                root.delegate = self
                vc.modalPresentationStyle = UIModalPresentationStyle.Popover
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                popover.barButtonItem = sender
                popover.delegate = self
                presentViewController(vc, animated: true, completion:nil)

            }
        }
    }
    
    @IBAction func documentsButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            if checkIfCourseIsSelected(sender) {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("DocNav") as! DocNavViewController
                vc.modalPresentationStyle = UIModalPresentationStyle.Popover
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                popover.barButtonItem = sender
                popover.delegate = self
                presentViewController(vc, animated: true, completion:nil)
            }
        }
    }
    
    @IBAction func resourcesButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            if checkIfCourseIsSelected(sender) {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("ResourceNav") as! ResourceNavViewController
                vc.modalPresentationStyle = UIModalPresentationStyle.Popover
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                popover.barButtonItem = sender
                popover.delegate = self
                presentViewController(vc, animated: true, completion:nil)
            }
        }
    }
    
    @IBAction func notesButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            if checkIfCourseIsSelected(sender) {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("NotesNav") as! NotesNavViewController
                vc.modalPresentationStyle = UIModalPresentationStyle.Popover
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                popover.barButtonItem = sender
                popover.delegate = self
                presentViewController(vc, animated: true, completion:nil)
            }
        }
    }
    
    @IBAction func imagesButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            if checkIfCourseIsSelected(sender) {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("ImagesNav") as! ImagesNavViewController
                vc.modalPresentationStyle = UIModalPresentationStyle.Popover
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                popover.barButtonItem = sender
                popover.delegate = self
                presentViewController(vc, animated: true, completion:nil)
            }
        }
    }
    
    @IBAction func rosterButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            if checkIfCourseIsSelected(sender) {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("RosterNav") as! RosterNavViewController
                vc.modalPresentationStyle = UIModalPresentationStyle.Popover
                let root = vc.visibleViewController as! RosterViewController
                root.courseCode = selectedCourseCode
                root.verified = verified
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                popover.barButtonItem = sender
                popover.delegate = self
                presentViewController(vc, animated: true, completion:nil)
            }
        }
    }
    
    @IBAction func notificationsButtonPressed(sender: UIBarButtonItem) {
        if checkUniversity(sender) {
            if checkIfCourseIsSelected(sender) {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("NotificationsNav") as! NotificationsNavViewController
                vc.modalPresentationStyle = UIModalPresentationStyle.Popover
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                popover.barButtonItem = sender
                popover.delegate = self
                presentViewController(vc, animated: true, completion:nil)
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}

extension ViewController: GroupsTableDelegate, InstructorTableDelegate {
    func didSelectGroup(named: String) {
        println(named)
    }
    func didAddNewGroup(named: String, description: String?) {
        let groupName = named
        println(groupName)
        if let groupDescription = description {
            println(groupDescription)
        }
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    func didSelectInstructor(named: String) {
        println(named)
    }
    func didAddNewInstructor(named: String, description: String?) {
        let instructorName = named
        println(instructorName)
        if let instructorDescription = description {
            println(instructorDescription)
        }
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension ViewController: PFLogInViewControllerDelegate {
    func logInViewController(controller: PFLogInViewController, didLogInUser user: PFUser) -> Void {
        println("\(user.username) did log in")
        self.navigationController?.dismissViewControllerAnimated(true) {
            checkUniversity(scheduleBarButton)
        }
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            //var userProfileRequestParams = [ "fields" : "id, name, email"]
            let userProfileRequest = FBSDKGraphRequest(graphPath: "/me", parameters: nil)
            let graphConnection = FBSDKGraphRequestConnection()
            graphConnection.addRequest(userProfileRequest, completionHandler: {
                (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                if error != nil {
                    println(error)
                }
                else {
                    println(result)
                    let name = result.objectForKey("name") as! String
                    let fbUserId = result.objectForKey("id") as! String
                    let fbEmail = result.objectForKey("email") as! String
                    let gender = result.objectForKey("gender") as! String
                    let link = result.objectForKey("link") as! String
                    let locale = result.objectForKey("locale") as! String
                    let firstName = result.objectForKey("first_name") as! String
                    let lastName = result.objectForKey("last_name") as! String
                    if(fbEmail != "") {
                        self.name = name
                        self.email = fbEmail
                        PFUser.currentUser()?.username = fbEmail
                        //PFUser.currentUser()?.email = fbEmail
                        PFUser.currentUser()?["name"] = name
                        PFUser.currentUser()?["facebookId"] = fbUserId
                        PFUser.currentUser()?["gender"] = gender
                        PFUser.currentUser()?["link"] = link
                        PFUser.currentUser()?["locale"] = locale
                        PFUser.currentUser()?["firstname"] = firstName
                        PFUser.currentUser()?["lastname"] = lastName
                        let domain = fbEmail.componentsSeparatedByString("@")[1]
                        let tld = domain.componentsSeparatedByString(".")[1]
                        println("Domain: \(domain)")
                        println("TLD: \(tld)")
                        if tld == "edu" {
                            PFUser.currentUser()?.email = fbEmail
                            PFUser.currentUser()?["domain"] = domain
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







