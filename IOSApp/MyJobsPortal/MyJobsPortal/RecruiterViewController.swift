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
    
    var recruiters = [[String]]()
    var validRecruiters = [[String]]()
    var newRecruiter : [String] = []
    var recruiter = String()
    var compagny = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleError : NSString = "La connexion a échoué !"
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
                            print (jsonData)
                            for (var i = 0; i < jsonData.count; i++) {
                                self.recruiter = jsonData[i] as! String
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
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            
            let fullNameArr = self.recruiter.characters.split{$0 == "\n"}.map(String.init)
            
            for (var i = 0; i<fullNameArr.count; i++) {
                let toto = fullNameArr[i].characters.split{$0 == ","}.map(String.init)
                self.recruiters.append(toto)
            }
            self.RecruiterTV.reloadData()
            }
            
            self.RecruiterTV.delegate = self
            self.RecruiterTV.dataSource = self
            
            if self.revealViewController() != nil {
                self.revealViewController().rightViewRevealWidth = 230
                self.menuBtn.target = self.revealViewController()
                self.menuBtn.action = "revealToggle:"
                self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())

        }
    }
    
    @IBAction func done(segue: UIStoryboardSegue) {
        let addRecruiterVC = segue.sourceViewController as! AddRecuiterViewController
        newRecruiter = addRecruiterVC.info
        recruiters.append(newRecruiter)
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
        return recruiters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("recruiterCell", forIndexPath: indexPath)
        
        cell.textLabel!.text = "\(recruiters[indexPath.row][0]) \(recruiters[indexPath.row][1])"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.cellForRowAtIndexPath(indexPath)?.accessoryType == .Checkmark {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
            recruiters[indexPath.row].removeLast()
            validRecruiters.append(recruiters[indexPath.row])
        } else {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            recruiters[indexPath.row] += ["1"]
            validRecruiters.append(recruiters[indexPath.row])
        }
    }
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == UITableViewCellEditingStyle.Delete {
//            recruiters.removeAtIndex(indexPath.row)
//            RecruiterTV.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//        }
//    }
    
    
    
    @IBAction func validTapped(sender: AnyObject) {
        var finalInfo : String = ""
        var tmpArray : [String] = []
        
        for (var i = 0; i < validRecruiters.count; i++) {
            finalInfo = validRecruiters[i].joinWithSeparator(", ")
            tmpArray.append(finalInfo)
        }
        for (var i = 0; i < tmpArray.count; i++) {
            finalInfo = tmpArray.joinWithSeparator("\n")
        }
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        prefs.setObject(finalInfo, forKey: "Contacts")
    }
    
    func errorAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message:message as String, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true){}
        }
    }
}
