//
//  PlanningTableViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 29/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class PlanningTableViewController: UITableViewController {

    var planning : NSMutableArray = NSMutableArray()
    var selectedUser : User = User()
    var selectedPlanning : Planning = Planning()
    let titleError : NSString = "La connexion a échoué !"
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            revealViewController().rightViewRevealWidth = 230
            menuBtn.target = revealViewController()
            menuBtn.action = "rightRevealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if let data : NSArray = NSUserDefaults.standardUserDefaults().valueForKey("userData") as? NSArray {
            let jsonElement : NSDictionary = data[0] as! NSDictionary
            selectedUser.mail = jsonElement["mail"] as! String
        }
        let post:NSString = "user=\(selectedUser.mail)"
        let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortalAPI/jsonloadRDV.php")!
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
                            newPlanning.compagny = jsonElement["compagny"] as! String
                            newPlanning.offer = jsonElement["offer"] as! String
                            
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
        let cell = tableView.dequeueReusableCellWithIdentifier("planningCell", forIndexPath: indexPath)
        selectedPlanning = planning.objectAtIndex(indexPath.row) as! Planning
        cell.textLabel!.text =  "\(selectedPlanning.hour) - \(selectedPlanning.compagny) - \(selectedPlanning.offer)"
        return cell
    }
}
