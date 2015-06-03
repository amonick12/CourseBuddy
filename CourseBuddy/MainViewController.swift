//
//  MainViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/2/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var titleButton: UIButton!

    let schedule = ["IST402", "ENG015", "MATH141", "PHYS212", "STAT200"]
    let name = "Owen Monix"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func titleButtonPressed(sender: UIButton) {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("Schedule") as! ScheduleViewController
        vc.schedule = self.schedule
        vc.delegate = self
        
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        
        popover.sourceRect = titleButton.frame
        popover.sourceView = view
        
        popover.delegate = self
        
        presentViewController(vc, animated: true, completion:nil)
    }
    
    @IBAction func profileButtonPressed(sender: UIButton) {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("Profile") as! ProfileViewController
        vc.name = self.name
        
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        
        popover.sourceRect = profileButton.frame
        popover.sourceView = view
        
        popover.delegate = self
        
        presentViewController(vc, animated: true, completion:nil)

    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

extension MainViewController: ScheduleDelegate {
    func didSelectCourseCode(courseCode: String) {
        println(courseCode)
        
        let font = UIFont(name: "GeezaPro-Bold", size: 24)
        if let font = font {
            titleButton.setAttributedTitle(NSAttributedString(string: courseCode, attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]), forState: .Normal)
        }
        
        titleButton.setTitle(courseCode, forState: .Normal)
    }
}

