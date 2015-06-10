//
//  AddImageViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/5/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import Parse

protocol AddImageDelegate {
    func imageToAdd(newImage: UIImage, description: String)
}

class AddImageViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    var delegate: AddImageDelegate?
    var selectedCourse: AnyObject?
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var imageDescription: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    var selectedImage: UIImage?
    var imageSelected: Bool = false
    var defaultImage: UIImage?
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.hidden = true
        if let course = selectedCourse as? PFObject {
            let courseCode = course["courseId"] as! String
            doneButton.setTitle("Share with \(courseCode)", forState: .Normal)
        }
        
        defaultImage = UIImage(named: "image_file")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        imagePicker.allowsEditing = false
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        selectedImage = image
        imageSelected = true
        doneButton.hidden = false
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        imageSelected = false
        imageView.contentMode = UIViewContentMode.Center
        imageView.image = defaultImage
        selectedImage = nil
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneButtonPressed(sender: AnyObject) {
        if !imageSelected {
            self.view.endEditing(true)
        }
        if !imageDescription.text.isEmpty && selectedImage != nil {
            delegate?.imageToAdd(selectedImage!, description: imageDescription.text)
            navigationController?.popViewControllerAnimated(true)
        }
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
