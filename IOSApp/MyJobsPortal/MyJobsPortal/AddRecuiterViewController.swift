//
//  AddRecuiterViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 20/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class AddRecuiterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtPosition: UITextField!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!

    var info : [String] = []
    var compagny = String()
    var selectedRecruiter : Recruiters = Recruiters()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtLastName.delegate = self
        txtName.delegate = self
        txtMail.delegate = self
        txtPosition.delegate = self
        txtPhone.delegate = self
        txtLastName.text = selectedRecruiter.lastname
        txtName.text = selectedRecruiter.name
        txtMail.text = selectedRecruiter.mail
        txtPhone.text = selectedRecruiter.phone
        txtPosition.text = selectedRecruiter.position
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "doneSegue" {
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if let data : NSArray = prefs.valueForKey("data") as? NSArray {
                compagny = data[1] as! String
            }
            
            selectedRecruiter.name = txtName.text!
            selectedRecruiter.compagny = compagny
            selectedRecruiter.lastname = txtLastName.text!
            selectedRecruiter.position = txtPosition.text!
            selectedRecruiter.phone = txtPhone.text!
            selectedRecruiter.mail = txtMail.text!
            selectedRecruiter.selected = selectedRecruiter.selected
        }
    }

}
