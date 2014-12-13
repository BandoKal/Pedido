//
//  CurrencyLocalePickerViewController.swift
//  Pedido Admin
//
//  Created by Alsey Coleman Miller on 12/12/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit

class CurrencyLocalePickerViewController: UITableViewController {
    
    // MARK: - Properties
    
    /** Currency Locales sorted by ISO code. */
    class var currencyLocales: [NSLocale] {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : [NSLocale]? = nil
        }
        dispatch_once(&Static.onceToken) {
            
            let currencylocales: [NSLocale] = {
                
                let localeIdentifiers = NSLocale.availableLocaleIdentifiers() as [String]
                
                // create locales
                var locales = [NSLocale]()
                
                for localeID in localeIdentifiers {
                    
                    let locale = NSLocale(localeIdentifier: localeID)
                    
                    // only add locales with currencyCode
                    if let currencyCode = locale.objectForKey(NSLocaleCurrencyCode) as? String {
                        
                        locales.append(NSLocale(localeIdentifier: localeID))
                    }
                }
                
                // sort by currency symbol
                let sortedLocales = (locales as NSArray).sortedArrayUsingComparator({ (first, second) -> NSComparisonResult in
                    
                    let firstLocale = first as NSLocale
                    
                    let secondLocale = second as NSLocale
                    
                    return (firstLocale.localeIdentifier as NSString).compare(secondLocale.localeIdentifier)
                }) as [NSLocale]
                
                return sortedLocales
                }()
            
            Static.instance = currencylocales
        }
        return Static.instance!
    }
    
    /** The selected currency locale. */
    var selectedCurrencyLocale: NSLocale? {
        
        didSet {
            
            // reload table view
            if self.isViewLoaded() {
                
                self.tableView.reloadData()
            }
        }
    }
    
    var selectionHandler: (() -> Void)?
    
    // MARK: - Private Properties
    
    private let numberFormatter: NSNumberFormatter = {
        
        let numberFormatter = NSNumberFormatter()
        
        numberFormatter.numberStyle = .CurrencyStyle
        
        return numberFormatter
    }()
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dynamicType.currencyLocales.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.CurrencyLocaleCell.rawValue, forIndexPath: indexPath) as UITableViewCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // get model
        let locale = self.dynamicType.currencyLocales[indexPath.row]
        
        // set selected
        self.selectedCurrencyLocale = locale
        
        // perform selected handler
        self.selectionHandler?()
    }
    
    // MARK: - Private Methods
    
    private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        // get model
        let locale = self.dynamicType.currencyLocales[indexPath.row]
        
        // configure cell
        cell.textLabel!.text = locale.localeIdentifier
        cell.detailTextLabel!.text = locale.objectForKey(NSLocaleCurrencySymbol) as? String
        
        // add checkmark if selected
        if locale == self.selectedCurrencyLocale {
            
            cell.accessoryType = .Checkmark
        }
        else {
            
            cell.accessoryType = .None
        }
    }
}

// MARK: - Private Enumerations

private enum CellIdentifier: String {
    
    case CurrencyLocaleCell = "CurrencyLocaleCell"
}

