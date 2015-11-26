//
//  SignUpViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 11/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit
import MessageUI

class SignUpUserVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtLastname: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtClass: UITextField!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    var tField: UITextField!
    var code : NSString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        txtLastname.delegate = self
        txtName.delegate = self
        txtClass.delegate = self
        txtMail.delegate = self
        txtPassword.delegate = self
        txtConfirmPassword.delegate = self
        //tField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func configurationTextField(textField: UITextField!)
    {
        textField.placeholder = "Enter le code"
        textField.textAlignment = .Center
        tField = textField
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    @IBAction func validTapped(sender: AnyObject) {
        
        let lastname : NSString = txtLastname.text!
        let name : NSString = txtName.text!
        let classSchool : NSString = txtClass.text!
        let login : NSString = txtMail.text!
        let password : NSString = txtPassword.text!
        let confirm_password : NSString = txtConfirmPassword.text!
        let nbr_phone : NSString = txtPhone.text!
        let titleError : NSString = "La connexion a échoué !"
        let randomID = arc4random() % 9000 + 1000;
        code = String(randomID)

        if ( lastname.isEqualToString("") || name.isEqualToString("") || classSchool.isEqualToString("") || login.isEqualToString("") || password.isEqualToString("")
            || confirm_password.isEqualToString("") || nbr_phone.isEqualToString("")) {
                self.errorAlert("L'inscription a échoué !", message: "Veuillez remplir impérativement l'ensemble des cases")
        } else if ( !password.isEqual(confirm_password) ) {
            self.errorAlert("L'inscription a échoué !", message: "Les mots de passe sont différents")
        } else {
            do {
                let post:NSString = "mail=\(login)&code=\(code)"
                let url : NSURL = NSURL(string:"http://192.168.22.149/~louischeminant/MyJobsPortalAPI/jsonemail.php")!
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
                                    let alert = UIAlertController(title: "Code de Vérification", message:"Entrer le code de vérification reçu sur l'adresse mail enregistrer afin de finaliser votre compte" as String, preferredStyle: .Alert)
                                    alert.addTextFieldWithConfigurationHandler(self.configurationTextField)
                                    alert.addAction(UIAlertAction(title: "Fermer", style: UIAlertActionStyle.Cancel, handler:nil))
                                    alert.addAction(UIAlertAction(title: "Valider", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
                                        print("tata = \(String(self.tField.text))")
                                        self.finalvalidate(self.tField.text!)
                                    }))
                                    NSOperationQueue.mainQueue().addOperationWithBlock {
                                        self.presentViewController(alert, animated: true, completion: {})
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
                                self.errorAlert(titleError as String, message: error as! String)
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

    func finalvalidate(code2 : NSString) {
        let lastname : NSString = txtLastname.text!
        let name : NSString = txtName.text!
        let classSchool : NSString = txtClass.text!
        let login : NSString = txtMail.text!
        let password : NSString = txtPassword.text!
        let confirm_password : NSString = txtConfirmPassword.text!
        let nbr_phone : NSString = txtPhone.text!
        let titleError : NSString = "La connexion a échoué !"
        
        if (code == code2) {
            do {
                let post:NSString = "lastname=\(lastname)&name=\(name)&class=\(classSchool)&mail=\(login)&password=\(password)&c_password=\(confirm_password)&phone=\(nbr_phone)&db=users"
                let url : NSURL = NSURL(string:"http://192.168.22.149/~louischeminant/MyJobsPortalAPI/jsonsignup.php")!
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
                        let responseData:NSString  = NSString(data:data!, encoding:NSUTF8StringEncoding)!
        
                        NSLog("Response ==> %@", responseData);
                        if (res.statusCode >= 200 && res.statusCode < 300) {
                            do {
                                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                                let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                                if (success == 1) {
                                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                                    prefs.setObject(login, forKey: "USERNAME")
                                    prefs.setInteger(1, forKey: "ISLOGGEDIN")
                                    prefs.synchronize()
                                    NSOperationQueue.mainQueue().addOperationWithBlock {
                                        self.performSegueWithIdentifier("pushMainSignUpUser", sender: self)
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
        } else {
            self.errorAlert(titleError as String, message: "Le code est incorrect.")
        }
    }
}
