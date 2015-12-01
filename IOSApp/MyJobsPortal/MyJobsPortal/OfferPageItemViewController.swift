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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let hourVC : HourTableViewController = segue.destinationViewController as! HourTableViewController
        hourVC.selectedEntreprise = selectedEntreprise
        hourVC.selectedUser = selectedUser
    }
}
