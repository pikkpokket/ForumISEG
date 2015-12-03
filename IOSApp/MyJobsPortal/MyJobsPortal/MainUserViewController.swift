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
    let user : NSMutableArray = NSMutableArray()
    let contact : NSMutableArray = NSMutableArray()
    var selectedEntreprise : Entreprise = Entreprise()
    var selectedUser : User = User()
    var selectedContact : [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadEntreprise()
        loadUser()
        loadContact()

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
    
    func loadUser() {
        let login : String! = NSUserDefaults.standardUserDefaults().valueForKey("USERNAME") as? String
        let titleError : NSString = "La connexion a échoué !"
        
        do {
            let post:NSString = "mail=\(login)&db=users"
            let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortalAPI/jsonuser.php")!
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
                                NSUserDefaults.standardUserDefaults().setObject(jsonData, forKey: "userData")
                                let jsonElement : NSDictionary = jsonData[i] as! NSDictionary
                                let newUser : User = User()
                                
                                newUser.name = jsonElement["name"] as! String
                                newUser.lastName = jsonElement["lastname"] as! String
                                newUser.classe = jsonElement["class"] as! String
                                newUser.mail = jsonElement["mail"] as! String
                                newUser.password = jsonElement["password"] as! String
                                newUser.phone = jsonElement["phone"] as! String
                                
                                self.user.addObject(newUser)
                            }
                            dispatch_async(dispatch_get_main_queue(), {
                                self.selectedUser = self.user.objectAtIndex(0) as! User
                                self.loginLabel.text = "Bienvenue \(self.selectedUser.name) \(self.selectedUser.lastName)"
                                NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "ISLOGGEDIN")
                                NSUserDefaults.standardUserDefaults().synchronize()
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
    
    func loadContact() {
        do {
            let session = NSURLSession.sharedSession()
            let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortalAPI/jsoncontact.php")!
            let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
                let res : NSHTTPURLResponse = response as! NSHTTPURLResponse
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    do {
                        let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) as! NSMutableArray
                        for (var i = 0; i < jsonData.count; i++) {
                            let jsonElement : NSDictionary = jsonData[i] as! NSDictionary
                            let newContact = Contact()
                            
                            newContact.compagny = jsonElement["compagny"] as! String
                            newContact.name = jsonElement["name"] as! String
                            newContact.lastName = jsonElement["lastname"] as! String
                            newContact.mail = jsonElement["mail"] as! String
                            newContact.position = jsonElement["position"] as! String
                            newContact.phone = jsonElement["phone"] as! String
                            newContact.selected = jsonElement["selected"] as! String
                            
                            self.contact.addObject(newContact)
                        }
                    } catch {
                        self.errorAlert("Error" as String, message: "Échec de connexion")
                    }
                }
            })
            task.resume()
        }
    }
    
    func loadEntreprise() {
        do {
            let session = NSURLSession.sharedSession()
            let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortalAPI/jsoncompagny.php")!
            let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
                let res : NSHTTPURLResponse = response as! NSHTTPURLResponse
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    do {
                        let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) as! NSMutableArray
                        for (var i = 0; i < jsonData.count; i++) {
                            let jsonElement : NSDictionary = jsonData[i] as! NSDictionary
                            let newEntreprise : Entreprise = Entreprise()
                            
                            newEntreprise.name = jsonElement["compagny"] as! String
                            
                            self.entreprise.addObject(newEntreprise)
                        }
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
        selectedEntreprise = entreprise.objectAtIndex(indexPath.row) as! Entreprise
        let url : String = "http://localhost/~louischeminant/MyJobsPortalAPI/Images/apercu.php?img_nom=\(selectedEntreprise.name)"
        let data : NSData = NSData(contentsOfURL: NSURL(string: url)!)!
        cell.logoImage.image = UIImage(data: data)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedEntreprise = entreprise.objectAtIndex(indexPath.row) as! Entreprise
        selectedContact.removeAll()
        for var i=0; i < contact.count; i++ {
            var tmpContact : Contact = Contact()
            tmpContact = contact.objectAtIndex(i) as! Contact
            if (tmpContact.compagny == selectedEntreprise.name) && tmpContact.selected == "1" {
                selectedContact.append(contact.objectAtIndex(i) as! Contact)
            }
        }
        self.performSegueWithIdentifier("offer", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailVC : OfferViewController = segue.destinationViewController as! OfferViewController
        detailVC.selectedEntreprise = selectedEntreprise
        detailVC.selectedContact = selectedContact
        detailVC.selectedUser = selectedUser
    }

}
