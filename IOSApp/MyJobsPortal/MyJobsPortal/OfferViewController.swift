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
    
    var selectedLocation : Entreprise = Entreprise()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url : String = "http://192.168.22.149/~louischeminant/MyJobsPortalAPI/Images/apercu.php?id=11"
        let data : NSData = NSData(contentsOfURL: NSURL(string: url)!)!
        

        
        logoImageView.image = UIImage(data: data)
        lblOffer.text = self.selectedLocation.offer
        lblResume.text = self.selectedLocation.resume
        lblMissions.text = self.selectedLocation.missions
        lblLevel.text = self.selectedLocation.level
        lblContact.text = self.selectedLocation.contact
        lblAddress.text = self.selectedLocation.address
        lblType.text = self.selectedLocation.type
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        var poiCoodinates : CLLocationCoordinate2D = CLLocationCoordinate2D()
        if (self.selectedLocation.latitude != "" || self.selectedLocation.longitude != "") {
            poiCoodinates.latitude = Double(self.selectedLocation.latitude)!
            poiCoodinates.longitude = Double(self.selectedLocation.longitude)!
        }
        
        let viewRegion : MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(poiCoodinates, 750, 750)
        map.setRegion(viewRegion, animated: true)
        
        let pin : MKPointAnnotation = MKPointAnnotation()
        pin.coordinate = poiCoodinates
        map.addAnnotation(pin)
    }
}
