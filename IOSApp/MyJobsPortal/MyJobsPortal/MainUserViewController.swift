//
//  MainViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 11/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let reuseIdentifier = "logoCell"
    let entreprise : NSMutableArray = NSMutableArray()
    var selectedLocation : Entreprise = Entreprise()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        entrepriseDisplay()
        connection()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        if revealViewController() != nil {
            revealViewController().rightViewRevealWidth = 230
            menuBtn.target = revealViewController()
            menuBtn.action = "rightRevealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDINUSER") as Int
        if (isLoggedIn == 1) {
            if let data : NSArray = prefs.valueForKey("data") as? NSArray {
                let name : String! = data[2] as! String
                let lastname : String! = data[1] as! String
                self.loginLabel.text = "Bienvenue \(name) \(lastname)"
            }
        }
    }
    
    func connection() {
        let login : String! = NSUserDefaults.standardUserDefaults().valueForKey("USERNAME") as? String
        let titleError : NSString = "La connexion a échoué !"
        
        do {
            let post:NSString = "login=\(login)&db=users"
            let url : NSURL = NSURL(string:"http://10.10.253.107/~louischeminant/MyJobsPortalAPI/jsonconnect.php")!
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
                            NSUserDefaults.standardUserDefaults().setObject(jsonData, forKey: "data")
                            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "ISLOGGEDIN")
                            NSUserDefaults.standardUserDefaults().synchronize()
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
    
    func entrepriseDisplay() {
        do {
            let session = NSURLSession.sharedSession()
            let url : NSURL = NSURL(string:"http://10.10.253.107/~louischeminant/MyJobsPortalAPI/jsonentreprise.php")!
            let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
                let res : NSHTTPURLResponse = response as! NSHTTPURLResponse
                let responseData:NSString  = NSString(data:data!, encoding:NSUTF8StringEncoding)!
                NSLog("Response ==> %@", responseData);
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    do {
                        let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) as! NSMutableArray
                        let logoArray : NSMutableArray = NSMutableArray()
                        
                        for (var i = 0; i < jsonData.count; i++) {
                            let jsonElement : NSDictionary = jsonData[i] as! NSDictionary
                            let newEntreprise : Entreprise = Entreprise()
                            
                            newEntreprise.name = jsonElement["compagny"] as! String
                            newEntreprise.offer = jsonElement["offer"] as! String
                            newEntreprise.missions = jsonElement["missions"] as! String
                            newEntreprise.level = jsonElement["level"] as! String
                            newEntreprise.address = jsonElement["address"] as! String
                            newEntreprise.longitude = jsonElement["longitude"] as! String
                            newEntreprise.latitude = jsonElement["latitude"] as! String
                            newEntreprise.type = jsonElement["type"] as! String
                            
                            logoArray[i] = jsonElement["compagny"] as! String
                            
                            self.entreprise.addObject(newEntreprise)
                        }
                        NSUserDefaults.standardUserDefaults().setObject(logoArray, forKey: "logoData")
                        dispatch_async(dispatch_get_main_queue(), {
                            self.collectionView.reloadData()
                        })
                    } catch {
                        self.errorAlert("Error" as String, message: "Échec de connexion")
                    }
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entreprise.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        
        if let data : NSMutableArray = NSUserDefaults.standardUserDefaults().valueForKey("logoData") as? NSMutableArray {
            print(data)
            let url : String = "http://10.10.253.107/~louischeminant/MyJobsPortalAPI/Images/apercu.php?img_nom=\(data.objectAtIndex(indexPath.row))"
            let data2 : NSData = NSData(contentsOfURL: NSURL(string: url)!)!
        
            cell.logoImage.image = UIImage(data: data2)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedLocation = entreprise.objectAtIndex(indexPath.row) as! Entreprise
        self.performSegueWithIdentifier("offer", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailVC : OfferViewController = segue.destinationViewController as! OfferViewController
        detailVC.selectedLocation = selectedLocation
    }

}
