//
//  NoteDetailViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/3/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var noteTitleItem: UINavigationItem!
    
    var noteTitle: String?
    var noteContent: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if noteTitle != nil {
            self.noteTitleItem.title = noteTitle!
        }
        if noteContent != nil {
            textView.text = noteContent!
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateButtonPressed(sender: AnyObject) {
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
