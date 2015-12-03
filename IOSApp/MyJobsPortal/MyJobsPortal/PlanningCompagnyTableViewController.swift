//
//  PlanningCompagnyTableViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 02/12/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class PlanningCompagnyTableViewController: UITableViewController {

    var planning : NSMutableArray = NSMutableArray()
    var selectedEntreprise : Entreprise = Entreprise()
    var selectedPlanning : Planning = Planning()
    let titleError : NSString = "La connexion a échoué !"
    var compagny:String = ""
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data : NSArray = NSUserDefaults.standardUserDefaults().valueForKey("compagnyData") as? NSArray {
            let jsonElement : NSDictionary = data[0] as! NSDictionary
            selectedEntreprise.name = jsonElement["name"] as! String
        }
        
        if revealViewController() != nil {
            revealViewController().rightViewRevealWidth = 230
            menuBtn.target = revealViewController()
            menuBtn.action = "rightRevealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        let post:NSString = "compagny=\(selectedEntreprise.name)"
        let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortalAPI/jsonloadRDVcompagny.php")!
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
                            let newPlanning : Planning = Planning()
                            
                            newPlanning.hour = jsonElement["start"] as! String
                            newPlanning.student_name = jsonElement["name"] as! String
                            newPlanning.student_lastname = jsonElement["lastname"] as! String
                            newPlanning.class_student = jsonElement["class"] as! String
                            newPlanning.mail = jsonElement["mail"] as! String
                            newPlanning.phone = jsonElement["phone"] as! String
                            
                            self.planning.addObject(newPlanning)
                        }
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.tableView.reloadData()
                            self.tableView.reloadInputViews()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planning.count
    }
    
    func errorAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message:message as String, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true){}
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("planningCompagnyCell", forIndexPath: indexPath)
        selectedPlanning = planning.objectAtIndex(indexPath.row) as! Planning
        cell.textLabel!.text =  "\(selectedPlanning.hour) - \(selectedPlanning.student_name) \(selectedPlanning.student_lastname) - \(selectedPlanning.class_student) - \(selectedPlanning.mail) - \(selectedPlanning.phone)"
        return cell
    }
}
