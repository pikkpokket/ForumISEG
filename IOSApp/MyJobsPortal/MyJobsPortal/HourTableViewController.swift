//
//  hourTableViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 15/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class HourTableViewController: UITableViewController {

    var selectedEntreprise : Entreprise = Entreprise()
    var selectedHour : Hour = Hour()
    var selectedUser : User = User()
    
    let hour : NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleError : NSString = "La connexion a échoué !"
        
        do {
            let post:NSString = "id=\(selectedEntreprise.id)&user="
            let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortalAPI/jsonsloadappointment.php")!
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
                                let newHour : Hour = Hour()
                                
                                newHour.start = jsonElement["start"] as! String
                                newHour.user = jsonElement["user"] as! String
                                
                                self.hour.addObject(newHour)
                            }
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hour.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("hourCell", forIndexPath: indexPath)
        selectedHour = hour.objectAtIndex(indexPath.row) as! Hour
        if selectedHour.user == "" {
            cell.textLabel?.text = selectedHour.start
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedHour = hour.objectAtIndex(indexPath.row) as! Hour
        let alert = UIAlertController(title: "Inscription", message:"Êtes-vous définitivement sûr de votre choix ?" as String, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Non", style: UIAlertActionStyle.Cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Oui", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            self.validateHour()
        }))
        self.presentViewController(alert, animated: true, completion: {})
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
    }
    
    func errorAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message:message as String, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true){}
        }
    }
    
    func validateHour() {
        let titleError : NSString = "La connexion a échoué !"
        let name = "\(selectedUser.name) \(selectedUser.lastName)"
        do {
            let post:NSString = "user=\(name)&start=\(selectedHour.start)&compagny=\(selectedEntreprise.name)"
            let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortalAPI/jsonvalidappointment.php")!
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
                                let alert = UIAlertController(title: "Inscription réussite", message:"Votre rendez-vous est bien validé" as String, preferredStyle: .Alert)
                                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                    UIAlertAction in
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainUser") as? SWRevealViewController
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
                        self.errorAlert(titleError as String, message: "Connection Failed")
                    }
                } else {
                    self.errorAlert(titleError as String, message: "Échec de connexion")
                }
            })
            task.resume()
        }
    }
}
