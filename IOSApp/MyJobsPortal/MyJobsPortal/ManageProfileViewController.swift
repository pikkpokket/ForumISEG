//
//  ManageProfileViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 02/12/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class ManageProfileViewController: UIViewController {

    var compagny: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let data : NSArray = NSUserDefaults.standardUserDefaults().valueForKey("compagnyData") as? NSArray {
            let jsonElement : NSDictionary = data[0] as! NSDictionary
            compagny = jsonElement["name"] as! String
        }
        
        print(compagny)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
