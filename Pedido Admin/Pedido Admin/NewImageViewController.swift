//
//  NewImageViewController.swift
//  Pedido Admin
//
//  Created by Alsey Coleman Miller on 1/17/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CorePedido
import JTSImage

class NewImageViewController: NewManagedObjectViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    
    override var entityName: String {
        
        return "Image"
    }
    
    var parentManagedObject: (NSManagedObject, String)!
    
    // MARK: - Actions
    
    @IBAction func tappedImageView(sender: UIGestureRecognizer) {
        
        // table view cell...
        let imageView = sender.view as UIImageView
        
        if imageView.image != nil {
            
            // create image info
            let imageInfo = JTSImageInfo()
            imageInfo.image = imageView.image!
            imageInfo.referenceRect = imageView.frame
            imageInfo.referenceView = imageView.superview!
            
            // create image VC
            let imageVC = JTSImageViewController(imageInfo: imageInfo,
                mode: JTSImageViewControllerMode.Image,
                backgroundStyle: JTSImageViewControllerBackgroundOptions.Blurred)
            
            // present VC
            imageVC.showFromViewController(self, transition: JTSImageViewControllerTransition.FromOriginalPosition)
        }
        
    }
    
    @IBAction func takePhoto(sender: UIBarButtonItem) {
        
        // detect no camera
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            
            self.showErrorAlert(NSLocalizedString("No Camera", comment: "No Camera"))
            
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func choosePhoto(sender: UIBarButtonItem) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.modalPresentationStyle = .Popover
        self.presentViewController(imagePicker, animated: true, completion: nil)
        imagePicker.popoverPresentationController?.barButtonItem = sender
    }
    
    // MARK: - Methods
    
    override func getNewValues() -> [String : AnyObject]? {
        
        // no image set
        if self.imageView.image == nil {
            
            self.showErrorAlert(NSLocalizedString("Must set image.", comment: "Must set image."))
            
            return nil
        }
        
        // relationship
        let (managedObject, parentManagedObjectKey) = self.parentManagedObject
        
        // get data from image
        let imageData = UIImagePNGRepresentation(self.imageView.image)
        
        return ["data": imageData, parentManagedObjectKey: managedObject]
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let image: UIImage = {
            
            if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                
                return editedImage
            }
            
            return info[UIImagePickerControllerOriginalImage] as UIImage
        }()
        
        self.imageView.image = image
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}