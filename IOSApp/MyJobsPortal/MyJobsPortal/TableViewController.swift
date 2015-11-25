//
//  TableViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 21/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var detailLabelStart: UILabel!
    @IBOutlet weak var datePickerStart: UIDatePicker!
    @IBOutlet weak var detailLabelEnd: UILabel!
    @IBOutlet weak var datePickerEnd: UIDatePicker!
    @IBOutlet weak var detailLabelDuring: UILabel!
    @IBOutlet weak var datePickerDuring: UIDatePicker!
    @IBOutlet weak var scType: UISegmentedControl!
    @IBOutlet weak var txtOffer: UITextField!
    @IBOutlet weak var txtMission: UITextView!
    @IBOutlet weak var txtLevel: UITextField!
    
    var name_compagny: String = ""
    var type: String = ""
    var offer: String = ""
    var missions: String = ""
    var address: String = ""
    var level: String = ""
    var address_c: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    
    
    var datePickerHidden = false
    var datePickerHidden2 = false
    var datePickerHidden3 = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerHidden = !datePickerHidden
        datePickerHidden2 = !datePickerHidden2
        datePickerHidden3 = !datePickerHidden3
        datePickerChanged()
        
        txtMission.text = "Description de l'offre"
        txtMission.textColor = UIColor.lightGrayColor()
        txtMission.alpha = 0.6
        txtMission.delegate = self
        
        txtMission.selectedTextRange = txtMission.textRangeFromPosition(txtMission.beginningOfDocument, toPosition: txtMission.beginningOfDocument)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)

        if updatedText.isEmpty {
            
            textView.text = "Description de l'offre"
            textView.textColor = UIColor.lightGrayColor()
            
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            return false
        }
        else if textView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        
        return true
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
            textView.alpha = 1
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "Description de l'offre"
        }
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGrayColor() {
                textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            }
        }
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
    
    @IBAction func validTapped(sender: AnyObject) {
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let data : NSArray = prefs.valueForKey("data") as? NSArray {
            print(data)
            name_compagny = data[1] as! String
            address_c = data[5] as! String
        }

        self.geoCodeUsingAddress(address_c)
    }
    
    func geoCodeUsingAddress(address : String) {
        do {
            let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
            var geocodeURLString = baseURLGeocode + "address=" + address
            geocodeURLString = geocodeURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            let geocodeURL = NSURL(string: geocodeURLString)
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: geocodeURL!)
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                if (data != nil) {
                    let res : NSHTTPURLResponse = response as! NSHTTPURLResponse
                    if (res.statusCode >= 200 && res.statusCode < 300) {
                        do {
                            let geocodingResultsData = NSData(contentsOfURL: geocodeURL!)
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                            let status = jsonData["status"] as! String
                            if status == "OK" {
                                let allResults = jsonData["results"] as! Array<Dictionary<NSObject, AnyObject>>
                                self.lookupAddressResults = allResults[0]
                                
                                let geometry = self.lookupAddressResults["geometry"] as! NSDictionary
                                let location = geometry["location"] as! NSDictionary
                                self.latitude = (location["lat"] as! NSNumber).doubleValue
                                self.longitude = (location["lng"] as! NSNumber).doubleValue
                                
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    self.connection()
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    func connection() {
        
        type = scType.titleForSegmentAtIndex(scType.selectedSegmentIndex)!
        offer = self.txtOffer.text!
        missions = self.txtMission.text!
        address = address_c
        level = self.txtLevel.text!
        
        print(name_compagny)
        print(type)
        print(offer)
        print(missions)
        print(level)
        print(address)
        print(latitude)
        print(longitude)
        
        
        let titleError : NSString = "La connexion a échoué !"
        do {
            let post:NSString = "compagny=\(name_compagny)&type=\(type)&offer=\(offer)&missions=\(missions)&level=\(level)&address=\(address)&latitude=\(latitude)&longitude=\(longitude)"
            let url : NSURL = NSURL(string:"http://10.10.253.107/~louischeminant/MyJobsPortalAPI/jsonoffer.php")!
            let postData:NSData = post.dataUsingEncoding(NSUTF8StringEncoding)!
            print(postData)
            let postLength:NSString = String(postData.length)
            let session = NSURLSession.sharedSession()
            
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = postData
            request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                if (data != nil) {
                    let res : NSHTTPURLResponse = response as! NSHTTPURLResponse
                    let responseData:NSString  = NSString(data:data!, encoding:NSUTF8StringEncoding)!
                    NSLog("Response ==> %@", responseData);
                    if (res.statusCode >= 200 && res.statusCode < 300) {
                        do {
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                            let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                            if (success == 1) {
                                let alert = UIAlertController(title: "Enregistrer", message:"L'offre a bien été créée" as String, preferredStyle: .Alert)
                                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                    UIAlertAction in
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainCompagny") as? SWRevealViewController
                                    self.presentViewController(mainViewController!, animated: true, completion: {})
                                }
                                alert.addAction(okAction)
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    self.presentViewController(alert, animated: true){}
                                }
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                }
                            } else {
                                self.errorAlert(titleError as String, message: "Une erreur s'est produite")
                            }
                        } catch {
                            print(error)
                        }
                    } else {
                        self.errorAlert(titleError as String, message: "Connection Failed")
                    }
                } else {
                    self.errorAlert(titleError as String, message: "Échec de connexion")
                }
            })
            task.resume()
        }
    }
    
    func errorAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message:message as String, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true){}
        }
    }

}
