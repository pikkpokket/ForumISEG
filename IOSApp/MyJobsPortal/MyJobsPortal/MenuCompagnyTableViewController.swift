//
//  MenuCompagnyTableViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 03/12/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class MenuCompagnyTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 5 {
            let appDomain = NSBundle.mainBundle().bundleIdentifier
            NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        }
    }
}
