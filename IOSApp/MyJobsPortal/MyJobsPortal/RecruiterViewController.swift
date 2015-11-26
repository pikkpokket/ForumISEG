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
    var newRecruiter : [String] = []
    var recruiter = String()
    var compagny = String()
    var arrayTest = NSMutableArray()
    
    let titleError : NSString = "La connexion a échoué !"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let data : NSArray = prefs.valueForKey("data") as? NSArray {
            compagny = data[1] as! String
            print(compagny)
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
                                self.recruiters.append(jsonData[i] as! [String])
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
        
        cell.textLabel!.text = "\(recruiters[indexPath.row][1]) \(recruiters[indexPath.row][2])"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.cellForRowAtIndexPath(indexPath)?.accessoryType == .Checkmark {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
            recruiters[indexPath.row] += ["0"]
        } else {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            recruiters[indexPath.row] += ["1"]
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            recruiters.removeAtIndex(indexPath.row)
            RecruiterTV.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    
    
    @IBAction func validTapped(sender: AnyObject) {
        var infoArray : [String] = []

        for (var i = 0; i < recruiters.count; i++) {
            infoArray  = recruiters[i]

            do {
                let post:NSString = "compagny=\(infoArray[0])&lastname=\(infoArray[1])&name=\(infoArray[2])&position=\(infoArray[3])&mail=\(infoArray[4])&phone=\(infoArray[5])&selected=\(infoArray[6])"
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
