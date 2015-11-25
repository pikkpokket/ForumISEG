//
//  TableViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 21/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    @IBOutlet weak var detailLabelStart: UILabel!
    @IBOutlet weak var datePickerStart: UIDatePicker!
    @IBOutlet weak var detailLabelEnd: UILabel!
    @IBOutlet weak var datePickerEnd: UIDatePicker!
    @IBOutlet weak var detailLabelDuring: UILabel!
    @IBOutlet weak var datePickerDuring: UIDatePicker!
    @IBOutlet weak var scType: UISegmentedControl!
    
    var datePickerHidden = false
    var datePickerHidden2 = false
    var datePickerHidden3 = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerHidden = !datePickerHidden
        datePickerHidden2 = !datePickerHidden2
        datePickerHidden3 = !datePickerHidden3
        datePickerChanged()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func datePickerChanged () {
        detailLabelStart.text = NSDateFormatter.localizedStringFromDate(datePickerStart.date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        detailLabelEnd.text = NSDateFormatter.localizedStringFromDate(datePickerEnd.date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Hour, .Minute], fromDate: datePickerDuring.date)
        let hour = String(comp.hour)
        let minute = String(comp.minute)
        if hour == "0" { detailLabelDuring.text = "\(minute) minutes" }
        else if hour == "1" { detailLabelDuring.text = "\(hour) heure \(minute) minutes" }
        else { detailLabelDuring.text = "\(hour) heures \(minute) minutes" }
        
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 4 && indexPath.row == 0 {
            datePickerHidden = !datePickerHidden
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        if indexPath.section == 4 && indexPath.row == 2 {
            datePickerHidden2 = !datePickerHidden2
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        if indexPath.section == 4 && indexPath.row == 4 {
            datePickerHidden3 = !datePickerHidden3
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    @IBAction func datePickerValue(sender: AnyObject) {
        datePickerChanged()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if datePickerHidden && indexPath.section == 4 && indexPath.row == 1 {
            return 0
        } else if datePickerHidden2 && indexPath.section == 4 && indexPath.row == 3 {
            return 0
        } else if datePickerHidden3 && indexPath.section == 4 && indexPath.row == 5 {
            return 0
        }else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    
}
