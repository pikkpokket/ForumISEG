//
//  OfferViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 14/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit
import MapKit

class OfferViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var lblOffer: UILabel!
    @IBOutlet weak var lblResume: UILabel!
    @IBOutlet weak var lblMissions: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblContact: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    var selectedEntreprise : Entreprise = Entreprise()
    var selectedContact : [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url : String = "http://localhost/~louischeminant/MyJobsPortalAPI/Images/apercu.php?img_nom=\(selectedEntreprise.name)"
        let data : NSData = NSData(contentsOfURL: NSURL(string: url)!)!
        

        
        logoImageView.image = UIImage(data: data)
        lblOffer.text = self.selectedEntreprise.offer
        lblResume.text = self.selectedEntreprise.resume
        lblMissions.text = self.selectedEntreprise.missions
        lblLevel.text = self.selectedEntreprise.level
        lblAddress.text = self.selectedEntreprise.address
        lblType.text = self.selectedEntreprise.type
        lblResume.text = self.selectedEntreprise.description_compagny
        var arrayContact : [String] = [String]()
        var displayContact : String = String()
        for var i=0; i<selectedContact.count; i++ {
            arrayContact.append("\(self.selectedContact[i].name) \(self.selectedContact[i].lastName) - \(self.selectedContact[i].position)")
        }
        displayContact = arrayContact.joinWithSeparator("\n")
        self.lblContact.text = displayContact
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        var poiCoodinates : CLLocationCoordinate2D = CLLocationCoordinate2D()
        if (self.selectedEntreprise.latitude != "" || self.selectedEntreprise.longitude != "") {
            poiCoodinates.latitude = Double(self.selectedEntreprise.latitude)!
            poiCoodinates.longitude = Double(self.selectedEntreprise.longitude)!
        }
        
        let viewRegion : MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(poiCoodinates, 750, 750)
        map.setRegion(viewRegion, animated: true)
        
        let pin : MKPointAnnotation = MKPointAnnotation()
        pin.coordinate = poiCoodinates
        map.addAnnotation(pin)
    }
}
