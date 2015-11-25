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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtLastName.delegate = self
        txtName.delegate = self
        txtMail.delegate = self
        txtPosition.delegate = self
        txtPhone.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "doneSegue" {
            //info = "\(txtName.text!) \(txtLastName.text!) - \(txtPosition.text!) - \(txtPhone.text!) - \(txtMail.text!)"
            info.append(txtName.text!)
            info.append(txtLastName.text!)
            info.append(txtPosition.text!)
            info.append(txtMail.text!)
            info.append(txtPhone.text!)
        }
    }

}
