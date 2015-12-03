//
//  PageItemViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 30/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit
import MapKit

class OfferPageItemViewController: UIViewController {

    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnFavorites: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblOffer: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblMissions: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblContacts: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var validBtn: UIButton!
    
    var selectedEntreprise : Entreprise = Entreprise()
    var selectedUser : User = User()
    
    var itemIndex: Int = 0
    var contacts: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url : String = "http://localhost/~louischeminant/MyJobsPortalAPI/Images/apercu.php?img_nom=\(selectedEntreprise.name)"
        let data : NSData = NSData(contentsOfURL: NSURL(string: url)!)!
        logoImageView.image = UIImage(data: data)
        lblType.text = selectedEntreprise.type
        lblOffer.text = selectedEntreprise.offer
        lblDescription.text = selectedEntreprise.description_compagny
        lblMissions.text = selectedEntreprise.missions
        lblLevel.text = selectedEntreprise.level
        lblAddress.text = selectedEntreprise.address
        lblContacts.text = contacts
        scrollViewHeight.constant = validBtn.frame.origin.y + validBtn.frame.size.height + 250
    }
    
    override func viewDidAppear(animated: Bool) {
        var poiCoodinates : CLLocationCoordinate2D = CLLocationCoordinate2D()
        if (selectedEntreprise.latitude != "" || selectedEntreprise.longitude != "") {
            poiCoodinates.latitude = Double(selectedEntreprise.latitude)!
            poiCoodinates.longitude = Double(selectedEntreprise.longitude)!
        }
        
        let viewRegion : MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(poiCoodinates, 750, 750)
        mapView.setRegion(viewRegion, animated: true)
        
        let pin : MKPointAnnotation = MKPointAnnotation()
        pin.coordinate = poiCoodinates
        mapView.addAnnotation(pin)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tappedFav(sender: AnyObject) {
        let titleError : NSString = "La connexion a échoué !"
        do {
            let post:NSString = "user=\(selectedUser.mail)&id=, \(Int(selectedEntreprise.id))"
            let url : NSURL = NSURL(string:"http://localhost/~louischeminant/MyJobsPortalAPI/jsonaddfav.php")!
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
                    let responseData:NSString  = NSString(data:data!, encoding:NSUTF8StringEncoding)!
                    NSLog("Response ==> %@", responseData);
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
    
    func errorAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message:message as String, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true){}
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let hourVC : HourTableViewController = segue.destinationViewController as! HourTableViewController
        hourVC.selectedEntreprise = selectedEntreprise
        hourVC.selectedUser = selectedUser
    }
}
