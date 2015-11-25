//
//  SignUpSocietyViewController.swift
//  MyJobsPortal
//
//  Created by Louis Cheminant on 18/11/2015.
//  Copyright © 2015 Louis Cheminant. All rights reserved.
//

import UIKit

class SignUpSocietyVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmePassword: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtResume: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtName.delegate = self
        txtMail.delegate = self
        txtPhone.delegate = self
        txtPassword.delegate = self
        txtConfirmePassword.delegate = self
        txtAddress.delegate = self
        txtResume.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    override func viewWillAppear(animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(false, animated: animated);
//        super.viewWillDisappear(animated)
//    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    @IBAction func getPhoto(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        //print("toto =\(image.description)")
        //Size
        logoImage.image = image
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = txtName.text!
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }

    @IBAction func validTapped(sender: AnyObject) {
        let name : String = txtName.text!
        let mail : String = txtMail.text!
        let nbr_phone : String = txtPhone.text!
        let address : String = txtAddress.text!
        let password : String = txtPassword.text!
        let password_confirm : String = txtConfirmePassword.text!
        let description : String = txtResume.text!
        let titleError : NSString = "La connexion a échoué !"
        
        do {
            let url : NSURL = NSURL(string:"http://10.10.253.107/~louischeminant/MyJobsPortalAPI/jsonsignup.php")!
            let boundary = generateBoundaryString()
            let param = [
                "name"          : name,
                "mail"          : mail,
                "phone"         : nbr_phone,
                "address"       : address,
                "password"      : password,
                "c_password"    : password_confirm,
                "description"   : description,
                "db"            : "compagnies"
            ]
            let imageData = UIImageJPEGRepresentation(logoImage.image!, 1)
            if(imageData==nil)  { return; }
            let request = NSMutableURLRequest(URL:url);
            request.HTTPMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = createBodyWithParameters(param, filePathKey: "fic", imageDataKey: imageData!, boundary: boundary)
            
            let session = NSURLSession.sharedSession()
            
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
                                prefs.setObject(mail, forKey: "USERNAME")
                                prefs.setInteger(1, forKey: "ISLOGGEDIN")
                                prefs.synchronize()
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    self.performSegueWithIdentifier("pushMainSignUpCompagny", sender: self)
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
    
    func errorAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message:message as String, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true){}
        }
    }
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
