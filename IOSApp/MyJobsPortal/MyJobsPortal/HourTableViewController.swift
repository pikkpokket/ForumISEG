//
//  hourTableViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 15/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class HourTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("hourCell", forIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.cellForRowAtIndexPath(indexPath)?.accessoryType == .Checkmark {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
        } else {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        }
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
    }
}
