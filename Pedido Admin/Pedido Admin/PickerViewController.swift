//
//  PickerViewController.swift
//  Pedido Admin
//
//  Created by Alsey Coleman Miller on 12/10/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CorePedido
import CorePedidoClient

/** View controller for editing to-many relationships between entities. It allows selection from a list of existing items. */
class PickerViewController: FetchedResultsViewController {
    
    // MARK: - Properties
    
    var relationship: (NSManagedObject, String)? {
        
        didSet {
            
            // create fetch request
            if relationship != nil {
                
                let (managedObject, key) = self.relationship!
                
                let relationshipDescription = managedObject.entity.relationshipsByName[key] as? NSRelationshipDescription
                
                assert(relationshipDescription != nil, "Relationship \(key) not found on \(managedObject.entity.name!) entity")
                
                assert(relationshipDescription!.toMany, "Relationship \(key) on \(managedObject.entity.name!) is not to-many")
                
                let fetchRequest = NSFetchRequest(entityName: relationshipDescription!.destinationEntity!.name!)
                
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: Store.sharedStore.resourceIDAttributeName, ascending: true)]
                
                self.fetchRequest = fetchRequest
                
            }
            else {
                
                self.fetchRequest = nil
            }
        }
    }
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - Methods
    
    func selectManagedObject(managedObject: NSManagedObject) {
        
        let (parentManagedObject, relationshipName) = self.relationship!
        
        let relationshipValue = parentManagedObject.valueForKey(relationshipName) as? NSSet
        
        var newRelationshipValue: NSSet?
        
        if relationshipValue?.containsObject(managedObject) ?? false {
            
            // remove...
            
            let arrayValue = (relationshipValue!.allObjects as NSArray).mutableCopy() as NSMutableArray
            
            arrayValue.removeObject(managedObject)
            
            newRelationshipValue = NSSet(array: arrayValue)
            
        }
        else {
            
            // add to set...
            
            var arrayValue: NSMutableArray?
            
            if relationshipValue != nil {
                
                arrayValue = (relationshipValue!.allObjects as NSArray).mutableCopy() as? NSMutableArray
            }
            else {
                
                arrayValue = NSMutableArray()
            }
            
            arrayValue!.addObject(managedObject)
            
            newRelationshipValue = NSSet(array: arrayValue!)
        }
        
        // edit managed object
        
        Store.sharedStore.editManagedObject(parentManagedObject, changes: [relationshipName: newRelationshipValue!], completionBlock: { (error) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                // show error
                if error != nil {
                    
                    self.showErrorAlert(error!.localizedDescription, retryHandler: { () -> Void in
                        
                        self.selectManagedObject(managedObject)
                    })
                    
                    return
                }
                
            })
        })
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // get model object
        let managedObject = self.fetchedResultsController!.objectAtIndexPath(indexPath) as NSManagedObject
        
        let dateCached = managedObject.valueForKey(Store.sharedStore.dateCachedAttributeName!) as? NSDate
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        // only set selection if managed object was cached
        
        if dateCached != nil {
            
            // set selection
            
            let (parentManagedObject, relationshipName) = self.relationship!
            
            let relationshipValue = parentManagedObject.valueForKey(relationshipName) as? NSSet
            
            if relationshipValue?.containsObject(managedObject) ?? false {
                
                cell.accessoryType = .Checkmark
            }
            else {
                
                cell.accessoryType = .None
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // remove or add to relationship...
        
        let managedObject = self.fetchedResultsController!.objectAtIndexPath(indexPath) as NSManagedObject
        
        self.selectManagedObject(managedObject)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    override func controller(controller: NSFetchedResultsController,
        didChangeObject object: AnyObject,
        atIndexPath indexPath: NSIndexPath,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath) {
            switch type {
            case .Insert:
                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            case .Update:
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) {
                    
                    self.configureCell(cell, atIndexPath: indexPath)
                    
                    // get model object
                    let managedObject = self.fetchedResultsController!.objectAtIndexPath(indexPath) as NSManagedObject
                    
                    let dateCached = managedObject.valueForKey(Store.sharedStore.dateCachedAttributeName!) as? NSDate
                    
                    // only set selection if managed object was cached
                    
                    if dateCached != nil {
                        
                        // set selection
                        
                        let (parentManagedObject, relationshipName) = self.relationship!
                        
                        let relationshipValue = parentManagedObject.valueForKey(relationshipName) as? NSSet
                        
                        if relationshipValue?.containsObject(managedObject) ?? false {
                            
                            cell.accessoryType = .Checkmark
                        }
                        else {
                            
                            cell.accessoryType = .None
                        }
                    }
                }
            case .Move:
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            case .Delete:
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            default:
                return
            }
    }
}


