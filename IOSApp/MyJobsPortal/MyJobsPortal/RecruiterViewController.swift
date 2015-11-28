//
//  RecruiterViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 20/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class RecruiterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var RecruiterTV: UITableView!
    
    var compagny = String()
    var allRecruiter = NSMutableArray()
    var selectedRecruiter : Recruiters = Recruiters()
    var newRecruiter : Recruiters = Recruiters()
    
    let titleError : NSString = "La connexion a échoué !"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let data : NSArray = prefs.valueForKey("data") as? NSArray {
            compagny = data[1] as! String
        }
        
        do {
            let post:NSString = "compagny=\(compagny)"
            let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortalAPI/jsoncontact.php")!
            let postData:NSData = post.dataUsingEncoding(NSUTF8StringEncoding)!
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
                    if (res.statusCode >= 200 && res.statusCode < 300) {
                        do {
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) as! NSMutableArray
                            for (var i = 0; i < jsonData.count; i++) {
                                let jsonElement : NSDictionary = jsonData[i] as! NSDictionary
                                self.newRecruiter = Recruiters()
                                
                                self.newRecruiter.compagny = jsonElement["compagny"] as! String
                                self.newRecruiter.lastname = jsonElement["lastname"] as! String
                                self.newRecruiter.name = jsonElement["name"] as! String
                                self.newRecruiter.position = jsonElement["position"] as! String
                                self.newRecruiter.mail = jsonElement["mail"] as! String
                                self.newRecruiter.phone = jsonElement["phone"] as! String
                                self.newRecruiter.selected = jsonElement["selected"] as! String

                                self.allRecruiter.addObject(self.newRecruiter)
                            }
                            for var i = 0; i < self.allRecruiter.count; i++ {
                                self.selectedRecruiter = self.allRecruiter.objectAtIndex(i) as! Recruiters
                            }
                            self.RecruiterTV.reloadData()
                            self.RecruiterTV.reloadInputViews()
                        } catch {
                            print(error)
                        }
                    } else {
                        self.errorAlert(self.titleError as String, message: "Connection Failed")
                    }
                } else {
                    self.errorAlert(self.titleError as String, message: "Échec de connexion")
                }
            })
            task.resume()
        }
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.RecruiterTV.delegate = self
            self.RecruiterTV.dataSource = self

        if self.revealViewController() != nil {
            self.revealViewController().rightViewRevealWidth = 230
            self.menuBtn.target = self.revealViewController()
            self.menuBtn.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
            self.RecruiterTV.reloadData()
        }
    }
    
    @IBAction func done(segue: UIStoryboardSegue) {
        let addRecruiterVC = segue.sourceViewController as! AddRecuiterViewController
        newRecruiter = addRecruiterVC.selectedRecruiter

        if !(allRecruiter.containsObject(newRecruiter)) {
            allRecruiter.addObject(newRecruiter)
        }
        RecruiterTV.reloadData()
    }
    
    @IBAction func cancel(segue: UIStoryboardSegue) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRecruiter.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("recruiterCell", forIndexPath: indexPath)
        selectedRecruiter = allRecruiter.objectAtIndex(indexPath.row) as! Recruiters
        cell.textLabel!.text =  "\(selectedRecruiter.name) \(selectedRecruiter.lastname)"
        let switchSelected : UISwitch = UISwitch(frame: CGRectMake(cell.frame.width-90, cell.frame.height/2-31/2, 49, 31))
        switchSelected.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged);
        switchSelected.restorationIdentifier = "\(indexPath.row)"
        if selectedRecruiter.selected == "1" {
            switchSelected.on = true
        }
        
        for rmvSeg in cell.contentView.subviews {
            if rmvSeg.isKindOfClass(UISwitch) {
                rmvSeg.removeFromSuperview()
            }
        }
        
        cell.contentView.addSubview(switchSelected)
        
        return cell
    }
    
    func switchValueDidChange(sender:UISwitch!)
    {
        let id:String = sender.restorationIdentifier!
        selectedRecruiter = allRecruiter.objectAtIndex(Int(id)!) as! Recruiters
        if (sender.on == true){
            selectedRecruiter.selected = "1"
        }
        else{
            selectedRecruiter.selected = "0"
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRecruiter = allRecruiter.objectAtIndex(indexPath.row) as! Recruiters
        self.performSegueWithIdentifier("AddRecruiter", sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            allRecruiter.removeObjectAtIndex(indexPath.row)
            RecruiterTV.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "AddRecruiter") {
            let nav = segue.destinationViewController as! UINavigationController
            let detailVC : AddRecuiterViewController = nav.topViewController as! AddRecuiterViewController
            detailVC.selectedRecruiter = selectedRecruiter
        }
    }
    
    @IBAction func validTapped(sender: AnyObject) {
//        print(recruiters)
        selectedRecruiter = allRecruiter.objectAtIndex(0) as! Recruiters
        
        print(selectedRecruiter.name)
        do {
            let post:NSString = "compagny=\(compagny)&db=contacts"
            let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortalAPI/jsondelete.php")!
            let postData:NSData = post.dataUsingEncoding(NSUTF8StringEncoding)!
            let postLength:NSString = String(postData.length)
            let session = NSURLSession.sharedSession()
            
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = postData
            request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                self.pushContacts()
            })
            task.resume()
        }
    }

    func pushContacts() {
        
        for (var i = 0; i < allRecruiter.count; i++) {
            selectedRecruiter = allRecruiter.objectAtIndex(i) as! Recruiters
            
            do {
                let post:NSString = "compagny=\(selectedRecruiter.compagny)&lastname=\(selectedRecruiter.lastname)&name=\(selectedRecruiter.name)&position=\(selectedRecruiter.position)&mail=\(selectedRecruiter.mail)&phone=\(selectedRecruiter.phone)&selected=\(selectedRecruiter.selected)"
                let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortalAPI/jsonrecruiter.php")!
                let postData:NSData = post.dataUsingEncoding(NSUTF8StringEncoding)!
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
                        if (res.statusCode >= 200 && res.statusCode < 300) {
                            do {
                                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                                let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                                if (success == 1) {
                                    let alert = UIAlertController(title: "Enregistrer", message:"Les recruteurs sont à jour" as String, preferredStyle: .Alert)
                                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                        UIAlertAction in
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainCompagny") as? SWRevealViewController
                                        NSOperationQueue.mainQueue().addOperationWithBlock {
                                            self.presentViewController(mainViewController!, animated: true, completion: {})
                                        }
                                    }
                                    alert.addAction(okAction)
                                    NSOperationQueue.mainQueue().addOperationWithBlock {
                                        self.presentViewController(alert, animated: true){}
                                    }
                                } else {
                                    var error_msg : NSString = ""
                                    if jsonData["error_message"] as? NSString != nil {
                                        error_msg = jsonData["error_message"] as! NSString
                                    } else {
                                        error_msg = "Unknown Error"
                                    }
                                    self.errorAlert(self.titleError as String, message: error_msg as String)
                                }
                            } catch {
                                print(error)
                            }
                        } else {
                            self.errorAlert(self.titleError as String, message: "Connection Failed")
                        }
                    } else {
                        self.errorAlert(self.titleError as String, message: "Échec de connexion")
                    }
                })
                task.resume()
            }
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
