//
//  ImagesRelationshipViewController.swift
//  Pedido Admin
//
//  Created by Alsey Coleman Miller on 1/16/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CorePedido
import CorePedidoClient

class ImagesRelationshipViewController: RelationshipViewController {
    
    // MARK: - Methods
    
    override func dequeueReusableCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        
        return self.tableView.dequeueReusableCellWithIdentifier(CellIdentifier.ImageCell.rawValue, forIndexPath: indexPath) as UITableViewCell
    }
    
    override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath, withError error: NSError?) {
        
        let imageCell = cell as ImageTableViewCell
        
        if error != nil {
            
            // TODO: Configure cell for error
            
            return
        }
        
        // get model object
        let managedObject = self.fetchedResultsController!.objectAtIndexPath(indexPath) as Image
        
        // check if fully downloaded
        let dateCached = managedObject.valueForKey(Store.sharedStore.dateCachedAttributeName!) as? NSDate
        
        // not cached
        if dateCached == nil {
            
            // configure empty cell...
            
            // imageCell.textLabel?.text = NSLocalizedString("Loading...", comment: "Loading...")
            
            imageCell.imageView!.image = nil
            
            imageCell.activityIndicatorView.hidden = false
            
            imageCell.activityIndicatorView.startAnimating()
            
            cell.userInteractionEnabled = false
            
            return
        }
        
        // configure cell...
        
        cell.userInteractionEnabled = true
        
        imageCell.imageView!.image = UIImage(data: managedObject.data)
        
        imageCell.activityIndicatorView.stopAnimating()
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch MainStoryboardSegueIdentifier(rawValue: segue.identifier!)! {
            
        case .NewLocalizedDescription:
            
            let newLocalizedTextVC = (segue.destinationViewController as UINavigationController).topViewController as NewLocalizedTextViewController
            
            let (parentManagedObject, key) = self.relationship!
            
            // get relationship description
            let relationshipDescription = parentManagedObject.entity.relationshipsByName[key] as NSRelationshipDescription
            
            newLocalizedTextVC.parentManagedObject = (parentManagedObject, relationshipDescription.inverseRelationship!.name)
            
        case .ShowLocalizedDescription:
            
            // get destination VC
            let managedObjectVC = segue.destinationViewController as ManagedObjectViewController
            
            // get model object
            let managedObject = self.fetchedResultsController!.objectAtIndexPath(self.tableView.indexPathForSelectedRow()!) as NSManagedObject
            
            // configure VC
            managedObjectVC.managedObject = managedObject
            
            // set edit handler
            managedObjectVC.didEditManagedObjectHandler = {
                
                // pop VC
                self.navigationController!.popViewControllerAnimated(true)
                
                return
            }
            
        default:
            return
        }
    }
}

// MARK: - Private Enumerations

private enum CellIdentifier: String {
    
    case ImageCell = "ImageCell"
}

// MARK: - Supporting Classes

class ImageTableViewCell: UITableViewCell {
    
    // @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
}