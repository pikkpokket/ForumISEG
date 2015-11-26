//
//  LoginViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 11/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class LoginUserVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    @IBAction func signinTapped(sender: AnyObject) {
        let login : NSString = txtLogin.text!
        let password : NSString = txtPassword.text!
        let titleError : NSString = "La connexion a échoué !"
        
        if (login.isEqualToString("") || password.isEqualToString("")) {
            self.errorAlert(titleError as String, message: "Veuillez rentrer votre login et votre mot de passe")
        } else {
            do {
                let post : NSString = "mail=\(login)&password=\(password)&db=users"
                let url : NSURL = NSURL(string:"http://192.168.22.149/~louischeminant/MyJobsPortalAPI/jsonlogin.php")!
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
                                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                                    prefs.setObject(login, forKey: "USERNAME")
                                    prefs.setInteger(1, forKey: "ISLOGGEDINUSER")
                                    prefs.synchronize()
                                    NSOperationQueue.mainQueue().addOperationWithBlock {
                                        self.performSegueWithIdentifier("pushMainUser", sender: self)
                                    }
                                } else {
                                    var error_msg : NSString = ""
                                    if jsonData["error_message"] as? NSString != nil {
                                        error_msg = jsonData["error_message"] as! NSString
                                    } else {
                                        error_msg = "Unknown Error"
                                    }
                                    self.errorAlert(titleError as String, message: error_msg as String)
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
    }
    
    func errorAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message:message as String, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true){}
        }
    }
}
