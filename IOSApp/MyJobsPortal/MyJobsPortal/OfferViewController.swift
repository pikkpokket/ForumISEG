//
//  TestViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 30/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class OfferViewController: UIViewController, UIPageViewControllerDataSource {

    let entreprise : NSMutableArray = NSMutableArray()
    var selectedEntreprise : Entreprise = Entreprise()
    var selectedUser : User = User()
    var selectedContact : [Contact] = []
    var pageViewController: UIPageViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.blackColor()
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.grayColor()
        loadEntreprise()
    }
    
    func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageController.dataSource = self
        
        if entreprise.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    func loadEntreprise() {
        let titleError : NSString = "La connexion a échoué !"
        
        do {
            let post:NSString = "compagny=\(selectedEntreprise.name)"
            let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortalAPI/jsonentreprise.php")!
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
                                let newEntreprise : Entreprise = Entreprise()
                                
                                newEntreprise.name = jsonElement["compagny"] as! String
                                newEntreprise.offer = jsonElement["offer"] as! String
                                newEntreprise.missions = jsonElement["missions"] as! String
                                newEntreprise.level = jsonElement["level"] as! String
                                newEntreprise.address = jsonElement["address"] as! String
                                newEntreprise.longitude = jsonElement["longitude"] as! String
                                newEntreprise.latitude = jsonElement["latitude"] as! String
                                newEntreprise.type = jsonElement["type"] as! String
                                newEntreprise.description_compagny = jsonElement["description"] as! String
                                newEntreprise.id = (jsonElement["id"]?.doubleValue)!
                                
                                self.entreprise.addObject(newEntreprise)
                                
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    self.createPageViewController()
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
    
    func getItemController(itemIndex: Int) -> OfferPageItemViewController? {
        
        if itemIndex < entreprise.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("ItemController") as! OfferPageItemViewController
            var arrayContact : [String] = [String]()
            var displayContact : String = String()
            for var i=0; i<selectedContact.count; i++ {
                arrayContact.append("\(self.selectedContact[i].name) \(self.selectedContact[i].lastName) - \(self.selectedContact[i].position)")
            }
            displayContact = arrayContact.joinWithSeparator("\n")
            
            pageItemController.itemIndex = itemIndex
            selectedEntreprise =  entreprise[itemIndex] as! Entreprise
            pageItemController.selectedEntreprise = selectedEntreprise
            pageItemController.contacts = displayContact
            pageItemController.selectedUser = selectedUser
            
            return pageItemController
        }
        
        return nil
    }
    
    func errorAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message:message as String, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true){}
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! OfferPageItemViewController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! OfferPageItemViewController
        
        if itemController.itemIndex+1 < entreprise.count {
            return getItemController(itemController.itemIndex+1)
        }
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return entreprise.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
