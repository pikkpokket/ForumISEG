//
//  CreateOfferViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 20/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class CreateOfferViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var choiceSC: UISegmentedControl!
    @IBOutlet weak var txtTitleOffer: UITextField!
    @IBOutlet weak var txtResume: UITextView!
    @IBOutlet weak var txtLevel: UITextField!
    @IBOutlet weak var txtMission: UITextView!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    var name : String = ""
    var address_c : String = ""
    var latitude : Double = 0
    var longitude : Double = 0
    var contact: String = ""
    
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if revealViewController() != nil {
            revealViewController().rightViewRevealWidth = 230
            menuBtn.target = revealViewController()
            menuBtn.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        txtResume.text = "Description de l'entreprise"
        txtResume.textColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6)
        txtResume.delegate = self
        txtResume.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6).CGColor
        txtResume.layer.borderWidth = 0.6
        txtResume.layer.cornerRadius = 5
        txtResume.clipsToBounds = true
        
        txtMission.text = "Description de l'offre"
        txtMission.textColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6)
        txtMission.delegate = self
        txtMission.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6).CGColor
        txtMission.layer.borderWidth = 0.6
        txtMission.layer.cornerRadius = 5
        txtMission.clipsToBounds = true
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        //txtResume.text = ""
        txtResume.textColor = UIColor.blackColor()
        
        //txtMission.text = ""
        txtMission.textColor = UIColor.blackColor()
        
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func validTapped(sender: AnyObject) {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let data : NSArray = prefs.valueForKey("data") as? NSArray {
            name = data[1] as! String
            address_c = data[5] as! String
        }
        if let contacts : String = prefs.stringForKey("Contacts") {
            contact = contacts
        }
        
        self.geoCodeUsingAddress(address_c)
    }
    
    func geoCodeUsingAddress(address : String) {
        do {
            let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
            var geocodeURLString = baseURLGeocode + "address=" + address
            geocodeURLString = geocodeURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            let geocodeURL = NSURL(string: geocodeURLString)
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: geocodeURL!)
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                if (data != nil) {
                    let res : NSHTTPURLResponse = response as! NSHTTPURLResponse
                    if (res.statusCode >= 200 && res.statusCode < 300) {
                        do {
                            let geocodingResultsData = NSData(contentsOfURL: geocodeURL!)
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                            let status = jsonData["status"] as! String
                            if status == "OK" {
                                let allResults = jsonData["results"] as! Array<Dictionary<NSObject, AnyObject>>
                                self.lookupAddressResults = allResults[0]
                                
                                let geometry = self.lookupAddressResults["geometry"] as! NSDictionary
                                let location = geometry["location"] as! NSDictionary
                                self.latitude = (location["lat"] as! NSNumber).doubleValue
                                self.longitude = (location["lng"] as! NSNumber).doubleValue
                                
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    self.connection()
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    func connection() {
        print(latitude)
        print(longitude)
        print(contact)
        
        let name_compagny : String = name
        let offer: String = self.txtTitleOffer.text!
        let missions: String = self.txtMission.text
        let resume: String = self.txtResume.text!
        let level: String = self.txtLevel.text!
        let address: String = address_c
        let type : String = choiceSC.titleForSegmentAtIndex(choiceSC.selectedSegmentIndex)!
        
        let titleError : NSString = "La connexion a échoué !"
        do {
            let post:NSString = "name_compagny=\(name_compagny)&type=\(type)&offer=\(offer)&missions=\(missions)&resume=\(resume)&level=\(level)&contact=\(contact)&address=\(address)&latitude=\(latitude)&longitude=\(longitude)&start=t&end=t&duration=t"
            let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortal/jsonoffer.php")!
            let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
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
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                                                    }
                            } else {
                                self.errorAlert(titleError as String, message: "Une erreur s'est produite")
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
    
    func errorAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message:message as String, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true){}
        }
    }
}
