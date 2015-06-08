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

    @IBOutlet weak var tableView: UITableView!
    //var postShown: [Bool]?
    var descriptionShown: Bool?
    //var commentShown: [Bool]?
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var scheduleBarButton: UIBarButtonItem!
    
    var courses: [AnyObject]?       //for querying objects
    var courseCodes = [String]()    //for showing in schedule
    var selectedCourse: AnyObject?  //current course
    var selectedCourseCode: String? //for navigation bar

    var name: String?
    var email: String?
    var verified: Bool?
    var university: String?
    var universityID: String?
    var logInController = LoginViewController()
    
    var postObjects: [AnyObject]?
    var posts: [Post]?
    var discussionDescription: String?
    
    var comment1: Comment!
    var comment2: Comment!
    var post: Post!
    var defaultDescription: String = "\nWelcome to CourseBuddy, the mobile online collaboration app for University Courses\n"
    
    var selectedPostIndex: Int?
    var currentPostType: String?
    
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
        
        setDefaultPost()
        setupTable()
    }
    
    func setDefaultPost() {
        comment2 = Comment(content: "Here are some things you can do in each course:\n\t• Share Files\n\t• Share Webpages\n\t• Share Notes\n\t• Share Images\n\t• Email Classmates\n\t• Select Notifications\n\t• Have Focused Discussions", courseCode: "coursebuddy", poster: "CourseBuddy", date: NSDate(), anon: false, shown: false)
        comment1 = Comment(content: "Check out all the ways to promote social learning for each course on your schedule in the menu above", courseCode: "coursebuddy", poster: "CourseBuddy", date: NSDate(), anon: true, shown: false)
        post = Post(content: "After you select your university and input the course codes from your schedule, you will be connected in a discussion with your classmates and professors", courseCode: "coursebuddy", poster: "CourseBuddy", date: NSDate(), anon: false, important: false, comments: [comment1, comment2], shown: false)
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
            } else {
                loadSchedule()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSchedule() {
        if let queryScedule = PFUser.currentUser()?.relationForKey("schedule").query() {
            queryScedule.orderByAscending("courseId")
            queryScedule.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved \(objects!.count) courses.")
                    // Do something with the found objects
                    self.courses = objects
                    if let objects = objects as? [PFObject] {
                        self.courseCodes.removeAll(keepCapacity: false)
                        for course in objects {
                            //println(course.objectId)
                            println(course["courseId"])
                            self.courseCodes.append(course["courseId"] as! String)
                        }
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        }
    }
    
    func loadPosts() {
        println("get posts for \(selectedCourseCode)")
        if selectedCourseCode != nil {
            let courseObject = selectedCourse as! PFObject
            var postsQuery: PFQuery = courseObject.relationForKey("posts").query()!
            postsQuery.orderByDescending("createdAt")
            postsQuery.findObjectsInBackgroundWithBlock {
                (postObjects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    
                    if let description = courseObject["description"] as? String {
                        self.discussionDescription = description
                    } else {
                        self.discussionDescription = self.defaultDescription
                    }
                    
                    println("retrieved \(postObjects!.count) posts")
                    self.postObjects = postObjects
                    //self.posts?.removeAll(keepCapacity: false)
                    var tempPosts = [Post]()
                    if let postObjects = postObjects as? [PFObject] {
                        for post in postObjects {
                            var content = post["content"] as! String
                            var name = post["poster"] as! String
                            var date = post.createdAt 
                            var anon = post["anon"] as! Bool
                            //var important = post["importat"]
                            var comments = [Comment]()
                            if let commentContents = post["comments"] as? [String] {
                                var commentPosters = post["commentPosters"] as! [String]
                                var commentDates = post["commentDates"] as! [NSDate]
                                var commentsAnon = post["commentsAnon"] as! [Bool]
                                var i = 0
                                for comment in commentContents {
                                    let newComment = Comment(content: commentContents[i], courseCode: self.selectedCourseCode!, poster: commentPosters[i], date: commentDates[i], anon: commentsAnon[i], shown: false)
                                        comments.append(newComment)
                                    i++
                                }
                            }
                            let newPost = Post(content: content, courseCode: self.selectedCourseCode!, poster: name, date: date!, anon: anon, important: false, comments: comments, shown: false)
                            comments.removeAll(keepCapacity: false)
                            tempPosts.append(newPost)
                        }
                        self.posts = tempPosts
                        self.descriptionShown = false
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                        self.tableView.reloadData()
                    }
                } else {
                    //failure
                    println("There was an error querrying the posts")
                }
            }
        }
    }

}

extension ViewController: ScheduleDelegate {
    func didSelectCourseCode(index: Int) {
        selectedCourseCode = courseCodes[index]
        selectedCourse = courses![index]
        println("selected course: \(selectedCourseCode)")
        loadPosts()
        self.navigationItem.title = selectedCourseCode!.uppercaseString
        let font = UIFont(name: "GeezaPro-Bold", size: 23)
        if let font = font {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
        }
    }
    func checkForRepeatedCourse(courseCode: String) -> Bool {
        if let index = find(courseCodes, courseCode) {
            return true
        }
        return false
    }
    func newCourseAdded(courseCode: String) {
        println("new course to be added: \(courseCode)")
        if courseCode != "" && university != nil && checkForRepeatedCourse(courseCode) == false {
            var query = PFQuery(className: "Course")
            var schedule: PFRelation = PFUser.currentUser()!.relationForKey("schedule")
            query.whereKey("university", equalTo: self.university!)
            query.whereKey("courseId", equalTo: courseCode)
            var newCourse = query.getFirstObject()
            if newCourse == nil {
                newCourse = PFObject(className: "Course") as PFObject
                newCourse!["courseId"] = courseCode
                newCourse!["creator"] = PFUser.currentUser()
                newCourse!["university"] = self.university
                newCourse!["description"] = "\n\(courseCode) Discussion\n\nAdd Course Name Here\n"
                addDefaultData(newCourse!, courseId: courseCode)
            }
            var participants: PFRelation = newCourse!.relationForKey("participants")
            participants.addObject(PFUser.currentUser()!)
            newCourse!.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                //add channel to installation
//                let uniqueIdentifier = courseId + "-" + newClass.objectId
//                PFInstallation.currentInstallation().addUniqueObject(uniqueIdentifier, forKey: "channels")
//                PFInstallation.currentInstallation().saveInBackground()
                schedule.addObject(newCourse!)
                PFUser.currentUser()!.saveInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if succeeded {
                        println("user saved new course: \(courseCode)")
                        self.selectedCourseCode = courseCode
                        self.selectedCourse = newCourse
                        self.loadSchedule()
                        self.loadPosts()
//                        self.loadInstructors()
//                        self.loadGroups()
                        self.navigationItem.title = courseCode.uppercaseString
                        let font = UIFont(name: "GeezaPro-Bold", size: 23)
                        if let font = font {
                            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
                        }
                        self.navigationController?.setToolbarHidden(false, animated: true)
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                    }
                }
            })
        } else {
            //display alert
            println("invalid course code: \(courseCode)")
        }
    }
    func didDeleteCourse(atIndex: Int) {
        println("Delete course at index: \(atIndex)")
        println("Course to delete: \(courseCodes[atIndex])")
        var courseToDelete: PFObject = courses![atIndex] as! PFObject
        let schedule = PFUser.currentUser()?.relationForKey("schedule")
        schedule!.removeObject(courseToDelete)
        let participants = courseToDelete.relationForKey("participants")
        participants.removeObject(PFUser.currentUser()!)
        
        //check if course to delete is the current course
        if courseCodes[atIndex] == selectedCourseCode {
            postObjects = nil
            posts = nil
            discussionDescription = nil
            selectedCourseCode = nil
            tableView.reloadData()
            self.navigationItem.title = "CourseBuddy"
            let font = UIFont(name: "Noteworthy-Light", size: 23)
            if let font = font {
                self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
            }
        }
        courseCodes.removeAtIndex(atIndex)
        courses?.removeAtIndex(atIndex)
        courseToDelete.saveInBackgroundWithBlock(nil)
        PFUser.currentUser()!.saveInBackgroundWithBlock(nil)
    }
}

extension ViewController: ProfileDelegate {
    func userDidLogout() {
        PFUser.logOut()
        name = nil
        email = nil
        university = nil
        universityID = nil
        selectedCourseCode = nil
        checkUser()
        //clear course data
        self.navigationItem.title = "CourseBuddy"
        let font = UIFont(name: "Noteworthy-Light", size: 23)
        if let font = font {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
        }
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
    func postTextEntered(content: String, type: String) {
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        switch type {
        case "POST":
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
        case "COMMENT":
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            var type: String?
            let postAction = UIAlertAction(title: "Comment", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
                self.createCommentOnPost(self.selectedPostIndex!, content: content, type: "regular")
            })
            alertController.addAction(postAction)
            
            let anonAction = UIAlertAction(title: "Comment as Anonymous", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
                self.createCommentOnPost(self.selectedPostIndex!, content: content, type: "anon")
            })
            alertController.addAction(anonAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (alert: UIAlertAction!) in
                // do nothing
            })
            alertController.addAction(cancelAction)
            
            alertController.popoverPresentationController?.barButtonItem = postButton
            presentViewController(alertController, animated: true, completion: nil)
        case "UPDATE":
            self.updateDescription(content)
        default:
            println("unknown post type")
        }
        currentPostType = nil
    }
    func createPost(content: String, type: String) {
        var anon: Bool?
        if type == "anon" { anon = true
        } else { anon = false }
        if (content == "") {
            //do nothing
        } else {
            //make post
            var newPost = PFObject(className:"Post")
            if anon! {
                newPost["poster"] = "Anonymous"
            } else {
                newPost["poster"] = PFUser.currentUser()?["name"] as! String
            }
            newPost["content"] = content
            newPost["courseId"] = selectedCourseCode
            newPost["user"] = PFUser.currentUser()
            let participants = newPost.relationForKey("participants")
            participants.addObject(PFUser.currentUser()!)
            if anon == true {
                newPost["anon"] = true
            } else { newPost["anon"] = false }
            newPost.saveInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                //set course to post relation
                var course = self.selectedCourse as! PFObject
                var postsRelation: PFRelation = course.relationForKey("posts")
                postsRelation.addObject(newPost)
                course.saveInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if succeeded {
                        self.loadPosts()
                        //create push
                    } else { println("error making post relation") }
                }
            }
        }
    }
    func createCommentOnPost(atIndex: Int, content: String, type: String) {
        var anon: Bool?
        if type == "anon" {
            anon = true
        } else {
            anon = false
        }
        if let post = postObjects![atIndex] as? PFObject {
            var comments = [String]()
            if post["comments"] as? [String] != nil {
                comments = post["comments"] as! [String]
                comments.append(content)
            } else { comments = [content] }
            post["comments"] = comments
            var commentPosters = [String]()
            if post["commentPosters"] as? [String] != nil {
                commentPosters = post["commentPosters"] as! [String]
                if anon! { commentPosters.append("Anonymous")
                } else { commentPosters.append(PFUser.currentUser()?["name"] as! String) }
            } else {
                if anon! { commentPosters.append("Anonymous") }
                else { commentPosters.append(PFUser.currentUser()?["name"] as! String) }
            }
            post["commentPosters"] = commentPosters
            var commentDates = [NSDate]()
            if post["commentDates"] as? [NSDate] != nil {
                commentDates = post["commentDates"] as! [NSDate]
                commentDates.append(NSDate())
            } else { commentDates = [NSDate()] }
            post["commentDates"] = commentDates
            var commentsAnon = [Bool]()
            if post["commentsAnon"] as? [Bool] != nil {
                commentsAnon = post["commentsAnon"] as! [Bool]
                commentsAnon.append(anon!)
            } else { commentsAnon = [anon!] }
            post["commentsAnon"] = commentsAnon
            let participants = post.relationForKey("participants")
            participants.addObject(PFUser.currentUser()!)
            post.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                if succeeded {
                    self.loadPosts()
                }
            })
        }
    }
    func updateDescription(updatedContent: String) {
        var course = selectedCourse as! PFObject
        course["description"] = updatedContent
        course.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if error == nil {
                self.loadPosts()
            }
        }
    }

}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    @IBAction func swipeDownGesture(sender: UISwipeGestureRecognizer) {
        self.navigationController?.setToolbarHidden(false, animated: true)
        //self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }
    @IBAction func swipeUpGesture(sender: UISwipeGestureRecognizer) {
        self.navigationController?.setToolbarHidden(true, animated: true)
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
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
            root.schedule = self.courseCodes
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
        if sender == postButton {
            currentPostType = "POST"
        }
        if checkUniversity(sender) {
            if checkIfCourseIsSelected(sender) {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("Post") as! PostViewController
                vc.delegate = self
                vc.senderButton = sender
                vc.postType = currentPostType
                if currentPostType == "UPDATE" {
                    vc.contentToUpdate = discussionDescription
                }
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
                let root = vc.visibleViewController as! ResourcesViewController
                root.selectedCourse = self.selectedCourse
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
                let root = vc.visibleViewController as! NotesViewController
                root.selectedCourse = self.selectedCourse
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
                let root = vc.visibleViewController as! ImagesViewController
                root.selectedCourse = self.selectedCourse
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
                root.selectedCourse = self.selectedCourse
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

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupTable() {
        tableView.estimatedRowHeight = 85
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 80
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if post != nil {
//            if indexPath.section != 0 {
//                if posts![indexPath.section-1].comments.count == 0 {
//                    return 40.0
//                }
//            }
//        }
//        return UITableViewAutomaticDimension
//    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if posts != nil {
            return posts!.count + 1
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if posts != nil {
                if posts![section-1].comments.count == 0 {
                    return 1
                } else {
                    return posts![section-1].comments.count
                }
            } else {
                return 2
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostCell
            if posts != nil {
                let post = posts![section-1]
                cell.postContentLabel.text = post.content
                cell.nameLabel.text = post.poster
                cell.dateLabel.text = Helper().timeAgoSinceDate(post.date, numericDates: true)
            } else {
                cell.postContentLabel.text = post.content
                cell.nameLabel.text = post.poster
                cell.dateLabel.text = Helper().timeAgoSinceDate(post.date, numericDates: true)
            }
            return cell

        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clearColor()
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DescriptionCell", forIndexPath: indexPath) as! DescriptionCell
            if posts != nil {
                cell.descriptLabel.text = discussionDescription
            } else {
                cell.descriptLabel.text = defaultDescription
            }
            cell.selectedBackgroundView = bgColorView
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
            if posts != nil {
                if posts![indexPath.section-1].comments.count == 0 {
                    cell.commentContentLabel.textAlignment = NSTextAlignment.Center
                    cell.commentContentLabel.text = "Add Comment"
                    cell.nameLabel.hidden = true
                    cell.dateLabel.hidden = true
                } else {
                    let post = posts![indexPath.section-1]
                    let comment = post.comments[indexPath.row]
                    cell.commentContentLabel.text = comment.content
                    cell.commentContentLabel.textAlignment = NSTextAlignment.Left
                    cell.nameLabel.text = comment.poster
                    cell.dateLabel.text = Helper().timeAgoSinceDate(comment.date, numericDates: true)
                    cell.nameLabel.hidden = false
                    cell.dateLabel.hidden = false
                }
            } else {
                let comment = post.comments[indexPath.row]
                cell.commentContentLabel.text = comment.content
                cell.nameLabel.text = comment.poster
                cell.dateLabel.text = Helper().timeAgoSinceDate(comment.date, numericDates: true)
            }
            cell.selectedBackgroundView = bgColorView
            return cell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if posts != nil {
            if indexPath.row == 0 && indexPath.section == 0 {
                // update description
                if discussionDescription != nil {
                    println("Update: \(discussionDescription!)")
                    currentPostType = "UPDATE"
                } else {
                    println("Update: \(defaultDescription)")
                }
                postButtonPressed(scheduleBarButton)

            } else {
                // comment on post with index: indexPath.section
                selectedPostIndex = indexPath.section-1
                println(selectedPostIndex)
                currentPostType = "COMMENT"
                postButtonPressed(scheduleBarButton)

            }

        } else {
            println(indexPath.section)
            postButtonPressed(postButton)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // Determine if the post is displayed. If yes, we just return and no animation will be created
        if posts != nil {
            if posts![section-1].shown {
                return
            }
            // Indicate the post has been displayed, so the animation won't be displayed again
            posts![section-1].shown = true
            // Define the initial state (Before the animation)
            view.alpha = 0
            // Define the final state (After the animation)
            UIView.animateWithDuration(1.0, animations: { view.alpha = 1 })
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Determine if the post is displayed. If yes, we just return and no animation will be created
        if posts != nil {
            if indexPath.section == 0 && indexPath.row == 0 {
                if descriptionShown == true {
                    return
                }
                descriptionShown = true
                cell.alpha = 0
                UIView.animateWithDuration(1.0, animations: { cell.alpha = 1 })
            } else {
//                let post = posts![indexPath.section-1]
//                var comment = post.comments[indexPath.row]
                if posts![indexPath.section-1].comments.count == 0 {
                    // Add Comment Cell
                } else {
                    if posts![indexPath.section-1].comments[indexPath.row].shown {
                        return
                    }
                    posts![indexPath.section-1].comments[indexPath.row].shown = true
                }
                cell.alpha = 0
                UIView.animateWithDuration(1.0, animations: { cell.alpha = 1 })
            }
        }
    }

}

class PostCell: UITableViewCell {
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}

class CommentCell: UITableViewCell {
    @IBOutlet weak var commentContentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}

class DescriptionCell: UITableViewCell {
    @IBOutlet weak var descriptLabel: UILabel!
}

extension UIViewController {    //load data functions
    
    
    func loadInstructors() {
        
    }
    
    func loadGroups() {
        
    }
    
    func getResources() {
        
    }
    
    func getNotes() {
        
    }
    
    func getImages() {
        
    }
    
    func getRoster() {
        
    }
    
    func addDefaultData(course: PFObject, courseId: String) {
        var post = PFObject(className: "Post")
        post["poster"] = "CourseBuddy"
        post["content"] = "Here are some things you can do within CourseBuddy \(courseId.uppercaseString)"
        post["courseId"] = courseId
        post["anon"] = false
        var comments = ["Create an anonymous post to ask a question or start a converstation", "Tap a post to add a comment", "Share a screenshot of \(courseId.uppercaseString) related content", "Have discussions specific to your instructor for course assignments and reminders", "Start a group discussion to communicate with your classmates on group projects outside of class", "Email classmates and instructors from within the roster section of the app", "Contribute to shared notes related to \(courseId.uppercaseString) with your classmates", "Share a resource related to \(courseId.uppercaseString) by simply copying and pasting a URL", "Configure your notifications to be alerted of activity in your CourseBuddy courses"]
        var commentPosters = [String]()
        var commentDates = [NSDate]()
        var commentsAnon = [Bool]()
        for comment in comments {
            commentPosters.append("CourseBuddy")
            commentDates.append(NSDate())
            commentsAnon.append(false)
        }
        post["comments"] = comments
        post["commentPosters"] = commentPosters
        post["commentDates"] = commentDates
        post["commentsAnon"] = commentsAnon
        post.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            var postsRelation: PFRelation = course.relationForKey("posts")
            postsRelation.addObject(post)
            course.saveInBackground()
        }
        
        //make document to explain the purpose of documents
        var image0 = PFObject(className: "Document")
        image0["poster"] = "CourseBuddy"
        image0["title"] = "Take a Picture of Written Notes"
        image0["courseId"] = courseId
        image0["user"] = PFUser.currentUser()
        let stickyImage = UIImage(named: "stickynote")
        //save image to file
        let imageData0 = UIImagePNGRepresentation(stickyImage)
        let imageFile0 = PFFile(name: "stickynote.png", data: imageData0)
        image0["image"] = imageFile0
        let docRelation: PFRelation = course.relationForKey("documents")
        image0.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            docRelation.addObject(image0)
            course.saveInBackground()
        }
        
        var image1 = PFObject(className: "Document")
        image1["poster"] = "CourseBuddy"
        image1["title"] = "Share a Screenhot"
        image1["courseId"] = courseId
        image1["user"] = PFUser.currentUser()
        let screenshot = UIImage(named: "screenshot")
        //save image to file
        let imageData1 = UIImagePNGRepresentation(screenshot)
        let imageFile1 = PFFile(name: "screenshot.png", data: imageData1)
        image1["image"] = imageFile1
        image1.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            docRelation.addObject(image1)
            course.saveInBackground()
        }
        
        //make instructor named CourseBuddy with posts explaining the purpose of instructors
        var newInstructor = PFObject(className: "Instructor") as PFObject
        newInstructor["name"] = "CourseBuddy"
        newInstructor["courseId"] = courseId
        newInstructor["creator"] = PFUser.currentUser()
        let instructorMessage = "This is the default instructor discussion to teach you about CourseBuddy Instructors!"
        newInstructor["message"] = instructorMessage

        var instructorPost = PFObject(className: "Post")
        instructorPost["poster"] = "CourseBuddy"
        instructorPost["content"] = "CourseBuddy Instructors"
        instructorPost["courseId"] = courseId
        instructorPost["anon"] = true
        var instructorComments = [String]()
        instructorComments.append("If you don't see your instructor for " + courseId.uppercaseString + " when you tap the X on CourseBuddy to go back to the list of instructors, simply enter their name to start a discussion specific to events happening in their classes")
        instructorComments.append("Encourage your instructor to join to get notifications from them about reminders and homework help")
        var instructorCommentPosters = [String]()
        instructorCommentPosters.append("CourseBuddy")
        instructorCommentPosters.append("CourseBuddy")
        var instructorCommentDates = [NSDate]()
        instructorCommentDates.append(NSDate())
        instructorCommentDates.append(NSDate())
        var instructorCommentsAnon = [Bool]()
        instructorCommentsAnon.append(false)
        instructorCommentsAnon.append(true)
        
        instructorPost["comments"] = instructorComments
        instructorPost["commentPosters"] = instructorCommentPosters
        instructorPost["commentDates"] = instructorCommentDates
        instructorPost["commentsAnon"] = instructorCommentsAnon
        instructorPost.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            var instructorPostsRelation: PFRelation = newInstructor.relationForKey("posts")
            instructorPostsRelation.addObject(instructorPost)
            newInstructor.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                var instructorRelation: PFRelation = course.relationForKey("instructors")
                instructorRelation.addObject(newInstructor)
                course.saveInBackground()
            })
        }
        
        //make default group named Study Group with posts explaining the purpose of groups
        var newGroup = PFObject(className: "Group") as PFObject
        newGroup["name"] = "Study Group"
        newGroup["creator"] = PFUser.currentUser()
        newGroup["courseId"] = courseId
        let groupMessage = "This is a specfic discussion for a study group within " + courseId.uppercaseString + "\n\nTap here to add a Group Description"
        newGroup["message"] = groupMessage
        
        var groupPost = PFObject(className: "Post")
        groupPost["poster"] = "CourseBuddy"
        groupPost["content"] = "CourseBuddy Groups"
        groupPost["courseId"] = courseId
        groupPost["anon"] = true
        var groupComments = [String]()
        groupComments.append("Make a small group within " + courseId.uppercaseString + " by tapping the X on Study Group and adding a new one of your choice")
        groupComments.append("Then tell your classmates within your group the name of your new group to have discussions and get notified of new activity")
        var groupCommentPosters = [String]()
        groupCommentPosters.append("CourseBuddy")
        groupCommentPosters.append("CourseBuddy")
        var groupCommentDates = [NSDate]()
        groupCommentDates.append(NSDate())
        groupCommentDates.append(NSDate())
        var groupCommentsAnon = [Bool]()
        groupCommentsAnon.append(true)
        groupCommentsAnon.append(true)
        
        groupPost["comments"] = groupComments
        groupPost["commentPosters"] = groupCommentPosters
        groupPost["commentDates"] = groupCommentDates
        groupPost["commentsAnon"] = groupCommentsAnon
        groupPost.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            var groupPostsRelation: PFRelation = newGroup.relationForKey("posts")
            groupPostsRelation.addObject(groupPost)
            newGroup.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                var groupRelation: PFRelation = course.relationForKey("groups")
                groupRelation.addObject(newGroup)
                course.saveInBackground()
            })
        }
        
        //make default note explaining the purpose of notes
        var newNote = PFObject(className: "Note") as PFObject
        newNote["creatorName"] = "CourseBuddy"
        newNote["creator"] = PFUser.currentUser()
        newNote["title"] = "First Note"
        newNote["content"] = "Collaborate on the same content with you classmates here\n"
        newNote["ups"] = 0
        newNote["course"] = course as PFObject
        newNote.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            var notesRelation: PFRelation = course.relationForKey("notes")
            notesRelation.addObject(newNote)
            course.saveInBackground()
        }
        
        //make default resource google.com and wikipedia.org
        let resourceRelation: PFRelation = course.relationForKey("resources")

        var newResource = PFObject(className: "Resource")
        newResource["title"] = "Google"
        newResource["sharedTitle"] = "Google"
        newResource["url"] = "http://google.com"
        newResource["poster"] = PFUser.currentUser()
        newResource["course"] = course as PFObject
        newResource["posterName"] = "CourseBuddy"
        newResource.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            resourceRelation.addObject(newResource)
            course.saveInBackground()
        }
        
        var anotherResource = PFObject(className: "Resource")
        anotherResource["title"] = "Wikipedia"
        anotherResource["sharedTitle"] = "Wikipedia"
        anotherResource["url"] = "http://wikipedia.org"
        anotherResource["poster"] = PFUser.currentUser()
        anotherResource["courseId"] = courseId
        anotherResource["posterName"] = "CourseBuddy"
        anotherResource.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            resourceRelation.addObject(anotherResource)
            course.saveInBackground()
        }
    }
}


