//
//  ImagesViewController.swift
//  CourseBuddy
//
//  Created by Aaron Monick on 6/2/15.
//  Copyright (c) 2015 coursebuddy. All rights reserved.
//

import UIKit
import Parse

let reuseIdentifier = "ImageCell"

class ImageCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

class ImagesViewController: UICollectionViewController, AddImageDelegate {

    var defaultImages = [["Share Screenshot","screenshot"],["Share a Written Note","stickynote"]]
//    var selectedImageName: String?
//    var selectedImageDescription: String?
    
    var selectedCourse: AnyObject?
    var imageObjects: [AnyObject]?
    
    var selectedImageDescription: String?
    var selectedImageData: NSData?
    var imageData = [NSData]()
    
    var imageShown: [Bool]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(ImageCollectionCell.self, forCellWithReuseIdentifier: "ImageCell")
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        loadImages()
    }
    
    func loadImages() {
        if selectedCourse != nil {
            let courseObject = selectedCourse as! PFObject
            var imagesQuery: PFQuery = courseObject.relationForKey("documents").query()!
            imagesQuery.orderByDescending("createdAt")
            imagesQuery.findObjectsInBackgroundWithBlock {
                (documents: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    println("retrieved \(documents!.count) documents")
                    self.imageObjects = documents
                    self.imageShown = [Bool](count: documents!.count, repeatedValue: false)
                    self.imageData.removeAll(keepCapacity: false)
                    self.collectionView!.reloadData()

                } else {
                    //failure
                    println("There was an error getting documents")
                }
            }
        }
    }
    
    func imageToAdd(newImage: UIImage, description: String) {
        var image = PFObject(className:"Document")
        image["user"] = PFUser.currentUser()!
        image["title"] = description
        image["course"] = selectedCourse as! PFObject
        
        //save image to file
        let imageData = UIImagePNGRepresentation(newImage)
        let imageFile = PFFile(name: "\(description).png", data: imageData)
        image["image"] = imageFile
        image.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if error == nil {
                let course = self.selectedCourse as! PFObject
                let docRelation: PFRelation = course.relationForKey("documents")
                docRelation.addObject(image)
                course.saveInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if succeeded {
                        self.loadImages()
                    } else { println("error saving course") }
                }
            } else {
                println("error saving documents")
            }
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImageSegue" {
            let vc = segue.destinationViewController as! ImageViewController
            vc.imageDescription = selectedImageDescription
            vc.selectedImageData = selectedImageData
        } else if segue.identifier == "addImageSegue" {
            let vc = segue.destinationViewController as! AddImageViewController
            vc.delegate = self
            vc.selectedCourse = self.selectedCourse
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imageObjects != nil {
            return imageObjects!.count
        } else {
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCollectionCell
        
        if imageObjects != nil {
            var image: PFObject = self.imageObjects![indexPath.row] as! PFObject
            (image["image"] as! PFFile).getDataInBackgroundWithBlock{
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let data = imageData {
                        let image = UIImage(data: data)
                        cell.imageView.image = image
                        self.imageData.append(data)
                    }
                }
            }
        } else {
            let image = defaultImages[indexPath.row]
            let imageName = image[1]
            cell.imageView.image = UIImage(named: imageName)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if imageObjects != nil {
            var image: PFObject = self.imageObjects![indexPath.row] as! PFObject
            selectedImageDescription = image["title"] as? String
            selectedImageData = imageData[indexPath.row]
            
            performSegueWithIdentifier("showImageSegue", sender: nil)
            
        } else {
            let image = defaultImages[indexPath.row]
//            selectedImageName = image[1]
//            selectedImageDescription = image[0]
//            performSegueWithIdentifier("showImageSegue", sender: nil)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
            if imageShown![indexPath.row] {
                return
            }
            imageShown![indexPath.row] = true
            cell.alpha = 0
            UIView.animateWithDuration(1.0, animations: { cell.alpha = 1 })
    }
        
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
