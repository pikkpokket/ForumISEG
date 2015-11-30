//
//  EditOfferViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 29/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class EditOfferViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var offerTV: UITableView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    var compagny = String()
    var allOffer = NSMutableArray()
    var selectedOffer : Offer = Offer()
    var newOffer : Offer = Offer()
    
    let titleError : NSString = "La connexion a échoué !"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let data : NSArray = NSUserDefaults.standardUserDefaults().valueForKey("compagnyData") as? NSArray {
            let jsonElement : NSDictionary = data[0] as! NSDictionary
            compagny = jsonElement["name"] as! String
        }
        do {
            let post:NSString = "compagny=\(compagny)"
            let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortalAPI/jsonloadoffer.php")!
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
                                self.newOffer = Offer()
                                
                                self.newOffer.id = jsonElement["id"] as! Int
                                self.newOffer.compagny = jsonElement["compagny"] as! String
                                self.newOffer.type = jsonElement["type"] as! String
                                self.newOffer.offer = jsonElement["offer"] as! String
                                self.newOffer.missions = jsonElement["missions"] as! String
                                self.newOffer.level = jsonElement["level"] as! String
                                self.newOffer.address = jsonElement["address"] as! String
                                self.allOffer.addObject(self.newOffer)
                            }
                            for var i = 0; i < self.allOffer.count; i++ {
                                self.selectedOffer = self.allOffer.objectAtIndex(i) as! Offer
                            }
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                self.offerTV.reloadData()
                                self.offerTV.reloadInputViews()
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
            self.offerTV.delegate = self
            self.offerTV.dataSource = self
            
            if self.revealViewController() != nil {
                self.revealViewController().rightViewRevealWidth = 230
                self.menuBtn.target = self.revealViewController()
                self.menuBtn.action = "revealToggle:"
                self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
            self.offerTV.reloadData()
        }
    }
    
    @IBAction func cancel(segue: UIStoryboardSegue) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("offerCell", forIndexPath: indexPath)
        selectedOffer = allOffer.objectAtIndex(indexPath.row) as! Offer
        cell.textLabel!.text =  "\(selectedOffer.type) - \(selectedOffer.offer)"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allOffer.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedOffer = allOffer.objectAtIndex(indexPath.row) as! Offer
        self.performSegueWithIdentifier("AddOffer", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "AddOffer") {
            let nav = segue.destinationViewController as! UINavigationController
            let offerTC : TableViewController = nav.topViewController as! TableViewController
           offerTC.selectedOffer = selectedOffer
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
